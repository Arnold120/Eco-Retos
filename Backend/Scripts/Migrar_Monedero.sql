
























SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

PRINT '1) Creando tablas de monedero...';

IF OBJECT_ID('dbo.Monedero', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Monedero (
        MonederoId INT PRIMARY KEY IDENTITY(1,1),
        UsuarioId INT NOT NULL,
        Saldo INT NOT NULL DEFAULT 0,
        FechaActualizacion DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_Monedero_Usuario FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuario(UsuarioId),
        CONSTRAINT UQ_Monedero_Usuario UNIQUE (UsuarioId),
        CONSTRAINT CK_Monedero_Saldo CHECK (Saldo >= 0)
    );
    CREATE INDEX IX_Monedero_UsuarioId ON dbo.Monedero(UsuarioId);
    PRINT '   Monedero creado.';
END
ELSE PRINT '   Monedero ya existía.';
GO

IF OBJECT_ID('dbo.HistorialMonedas', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HistorialMonedas (
        HistorialMonedaId INT PRIMARY KEY IDENTITY(1,1),
        UsuarioId INT NOT NULL,
        CategoriaId INT NULL,
        Cantidad INT NOT NULL,
        Tipo NVARCHAR(50) NOT NULL,
        Descripcion NVARCHAR(500) NOT NULL,
        SaldoResultante INT NOT NULL,
        ClaveIdempotencia NVARCHAR(120) NULL,
        Fecha DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_HistorialMonedas_Usuario FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuario(UsuarioId),
        CONSTRAINT FK_HistorialMonedas_Categoria FOREIGN KEY (CategoriaId) REFERENCES dbo.Categoria(CategoriaId),
        CONSTRAINT CK_HistorialMonedas_Cantidad CHECK (Cantidad <> 0)
    );
    CREATE INDEX IX_HistorialMonedas_UsuarioId_Fecha ON dbo.HistorialMonedas(UsuarioId, Fecha DESC);
    CREATE INDEX IX_HistorialMonedas_CategoriaId ON dbo.HistorialMonedas(CategoriaId);
    CREATE UNIQUE INDEX UX_HistorialMonedas_Idempotencia
        ON dbo.HistorialMonedas(UsuarioId, ClaveIdempotencia)
        WHERE ClaveIdempotencia IS NOT NULL;
    PRINT '   HistorialMonedas creado.';
END
ELSE PRINT '   HistorialMonedas ya existía.';
GO

IF OBJECT_ID('dbo.RecompensaReclamada', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RecompensaReclamada (
        RecompensaId INT PRIMARY KEY IDENTITY(1,1),
        UsuarioId INT NOT NULL,
        Clave NVARCHAR(120) NOT NULL,
        Tipo NVARCHAR(50) NOT NULL,
        Fecha DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_RecompensaReclamada_Usuario FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuario(UsuarioId),
        CONSTRAINT UQ_RecompensaReclamada UNIQUE (UsuarioId, Clave)
    );
    CREATE INDEX IX_RecompensaReclamada_UsuarioId ON dbo.RecompensaReclamada(UsuarioId);
    PRINT '   RecompensaReclamada creada.';
END
ELSE PRINT '   RecompensaReclamada ya existía.';
GO

PRINT '2) Agregando Progreso.Experiencia...';
IF COL_LENGTH('dbo.Progreso', 'Experiencia') IS NULL
BEGIN
    ALTER TABLE dbo.Progreso ADD Experiencia INT NOT NULL CONSTRAINT DF_Progreso_Experiencia DEFAULT 0;
    PRINT '   Columna Experiencia agregada.';
END
ELSE PRINT '   Experiencia ya existía.';

IF COL_LENGTH('dbo.Reto', 'MonedasRecompensa') IS NULL
BEGIN
    ALTER TABLE dbo.Reto ADD MonedasRecompensa INT NOT NULL CONSTRAINT DF_Reto_MonedasRecompensa DEFAULT 0;
    PRINT '   Reto.MonedasRecompensa agregada.';
END

IF COL_LENGTH('dbo.Compra', 'ClaveIdempotencia') IS NULL
BEGIN
    ALTER TABLE dbo.Compra ADD ClaveIdempotencia NVARCHAR(120) NULL;
    CREATE UNIQUE INDEX UX_Compra_Idempotencia
        ON dbo.Compra(UsuarioId, ClaveIdempotencia)
        WHERE ClaveIdempotencia IS NOT NULL;
    PRINT '   Compra.ClaveIdempotencia agregada.';
END
GO

PRINT '3) Unificando nombres de columnas...';

IF COL_LENGTH('dbo.Material', 'PrecioPuntos') IS NOT NULL
   AND COL_LENGTH('dbo.Material', 'PrecioMonedas') IS NULL
BEGIN
    EXEC sp_rename 'dbo.Material.PrecioPuntos', 'PrecioMonedas', 'COLUMN';
    PRINT '   Material.PrecioPuntos -> PrecioMonedas';
END

IF COL_LENGTH('dbo.Compra', 'TotalPuntos') IS NOT NULL
   AND COL_LENGTH('dbo.Compra', 'TotalMonedas') IS NULL
BEGIN
    EXEC sp_rename 'dbo.Compra.TotalPuntos', 'TotalMonedas', 'COLUMN';
    PRINT '   Compra.TotalPuntos -> TotalMonedas';
END

IF COL_LENGTH('dbo.DetalleCompra', 'PrecioUnitario') IS NOT NULL
   AND COL_LENGTH('dbo.DetalleCompra', 'PrecioUnitarioMonedas') IS NULL
BEGIN
    EXEC sp_rename 'dbo.DetalleCompra.PrecioUnitario', 'PrecioUnitarioMonedas', 'COLUMN';
    PRINT '   DetalleCompra.PrecioUnitario -> PrecioUnitarioMonedas';
END

IF COL_LENGTH('dbo.Insignia', 'PuntosRecompensa') IS NOT NULL
   AND COL_LENGTH('dbo.Insignia', 'MonedasRecompensa') IS NULL
BEGIN
    EXEC sp_rename 'dbo.Insignia.PuntosRecompensa', 'MonedasRecompensa', 'COLUMN';
    PRINT '   Insignia.PuntosRecompensa -> MonedasRecompensa';
END

IF COL_LENGTH('dbo.Reto', 'Puntos') IS NOT NULL
   AND COL_LENGTH('dbo.Reto', 'ExperienciaRecompensa') IS NULL
BEGIN
    EXEC sp_rename 'dbo.Reto.Puntos', 'ExperienciaRecompensa', 'COLUMN';
    PRINT '   Reto.Puntos -> ExperienciaRecompensa';
END
GO

PRINT '4) Migrando XP a Progreso.Experiencia...';
IF OBJECT_ID('dbo.HistorialPuntos', 'U') IS NOT NULL
BEGIN

    UPDATE p
    SET p.Experiencia = x.Xp
    FROM dbo.Progreso p
    INNER JOIN (
        SELECT hp.UsuarioId,
               SUM(CASE WHEN UPPER(LTRIM(RTRIM(hp.Tipo))) IN ('RETO', 'TRIVIA') THEN hp.Puntos ELSE 0 END) AS Xp
        FROM dbo.HistorialPuntos hp
        GROUP BY hp.UsuarioId
    ) x ON x.UsuarioId = p.UsuarioId
    WHERE p.Experiencia = 0 AND x.Xp > 0;


    INSERT INTO dbo.Progreso (UsuarioId, Experiencia, NivelActual, PorcentajeProgreso)
    SELECT x.UsuarioId, x.Xp, 1, 0
    FROM (
        SELECT hp.UsuarioId,
               SUM(CASE WHEN UPPER(LTRIM(RTRIM(hp.Tipo))) IN ('RETO', 'TRIVIA') THEN hp.Puntos ELSE 0 END) AS Xp
        FROM dbo.HistorialPuntos hp
        GROUP BY hp.UsuarioId
    ) x
    WHERE x.Xp > 0
      AND NOT EXISTS (SELECT 1 FROM dbo.Progreso p WHERE p.UsuarioId = x.UsuarioId);


    UPDATE p
    SET p.NivelActual = (p.Experiencia / 100) + 1,
        p.PorcentajeProgreso = CAST((p.Experiencia % 100) AS DECIMAL(5,2))
    FROM dbo.Progreso p
    WHERE p.Experiencia > 0;
    PRINT '   XP migrado.';
END
ELSE PRINT '   No existe HistorialPuntos; nada que migrar de XP.';
GO

PRINT '5) Migrando monedas a Monedero + HistorialMonedas...';
IF OBJECT_ID('dbo.HistorialPuntos', 'U') IS NOT NULL
BEGIN
    BEGIN TRAN;

    DECLARE @Pendientes TABLE (UsuarioId INT PRIMARY KEY, Total INT NOT NULL);


    INSERT INTO @Pendientes (UsuarioId, Total)
    SELECT u.UsuarioId,
           ISNULL((
               SELECT SUM(CASE
                              WHEN UPPER(LTRIM(RTRIM(hp.Tipo))) IN ('RETO', 'TRIVIA') THEN 0
                              ELSE hp.Puntos
                          END)
               FROM dbo.HistorialPuntos hp
               WHERE hp.UsuarioId = u.UsuarioId
           ), 0)
    FROM dbo.Usuario u
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.HistorialMonedas hm WHERE hm.UsuarioId = u.UsuarioId
    );


    INSERT INTO dbo.HistorialMonedas
        (UsuarioId, CategoriaId, Cantidad, Tipo, Descripcion, SaldoResultante, Fecha)
    SELECT hp.UsuarioId,
           hp.CategoriaId,
           hp.Puntos,
           UPPER(LTRIM(RTRIM(hp.Tipo))),
           ISNULL(NULLIF(LTRIM(RTRIM(hp.Descripcion)), ''), 'Movimiento migrado'),
           SUM(hp.Puntos) OVER (
               PARTITION BY hp.UsuarioId
               ORDER BY hp.Fecha, hp.HistorialId
               ROWS UNBOUNDED PRECEDING
           ),
           hp.Fecha
    FROM dbo.HistorialPuntos hp
    INNER JOIN @Pendientes pend ON pend.UsuarioId = hp.UsuarioId
    WHERE UPPER(LTRIM(RTRIM(hp.Tipo))) NOT IN ('RETO', 'TRIVIA');


    DECLARE @Negativos TABLE (UsuarioId INT PRIMARY KEY, Total INT NOT NULL);
    INSERT INTO @Negativos (UsuarioId, Total)
    SELECT hm.UsuarioId, SUM(hm.Cantidad)
    FROM dbo.HistorialMonedas hm
    INNER JOIN @Pendientes pend ON pend.UsuarioId = hm.UsuarioId
    GROUP BY hm.UsuarioId
    HAVING SUM(hm.Cantidad) < 0;

    INSERT INTO dbo.HistorialMonedas
        (UsuarioId, CategoriaId, Cantidad, Tipo, Descripcion, SaldoResultante, Fecha)
    SELECT n.UsuarioId, NULL, -n.Total, 'AJUSTE',
           'Ajuste de migración: saldo histórico negativo regularizado',
           0, SYSDATETIME()
    FROM @Negativos n;


    UPDATE m
    SET m.Saldo = CASE WHEN s.Total < 0 THEN 0 ELSE s.Total END,
        m.FechaActualizacion = SYSDATETIME()
    FROM dbo.Monedero m
    INNER JOIN (
        SELECT hm.UsuarioId, SUM(hm.Cantidad) AS Total
        FROM dbo.HistorialMonedas hm
        INNER JOIN @Pendientes pend ON pend.UsuarioId = hm.UsuarioId
        GROUP BY hm.UsuarioId
    ) s ON s.UsuarioId = m.UsuarioId;

    INSERT INTO dbo.Monedero (UsuarioId, Saldo)
    SELECT pend.UsuarioId, CASE WHEN pend.Total < 0 THEN 0 ELSE pend.Total END
    FROM @Pendientes pend
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Monedero m WHERE m.UsuarioId = pend.UsuarioId);

    COMMIT;
    PRINT '   Monedas migradas.';
END
ELSE PRINT '   No existe HistorialPuntos; nada que migrar de monedas.';
GO

PRINT '5.bis) Creando monedero para usuarios sin historial...';
INSERT INTO dbo.Monedero (UsuarioId, Saldo)
SELECT u.UsuarioId, 0
FROM dbo.Usuario u
WHERE NOT EXISTS (SELECT 1 FROM dbo.Monedero m WHERE m.UsuarioId = u.UsuarioId);
GO

PRINT '6) Verificación de cuadre (debe devolver 0 filas)...';
SELECT m.UsuarioId,
       m.Saldo AS SaldoMonedero,
       ISNULL(h.Total, 0) AS TotalHistorialMonedas
FROM dbo.Monedero m
LEFT JOIN (
    SELECT hm.UsuarioId, SUM(hm.Cantidad) AS Total
    FROM dbo.HistorialMonedas hm
    GROUP BY hm.UsuarioId
) h ON h.UsuarioId = m.UsuarioId
WHERE m.Saldo <> CASE WHEN ISNULL(h.Total, 0) < 0 THEN 0 ELSE ISNULL(h.Total, 0) END;
GO

PRINT 'Migración de Monedero completada.';
GO
