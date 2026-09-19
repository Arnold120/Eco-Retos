-- =============================================================================
-- Actualizar_Esquema_CategoriaId.sql
-- -----------------------------------------------------------------------------
-- Lleva una base creada con un esquema ANTERIOR al actual de EcoRetosDB.sql
-- (sin las columnas CategoriaId / Codigo) al esquema vigente de la taxonomia
-- de las 7 categorias oficiales.
--
-- Sintoma que resuelve: 500 "Invalid column name 'CategoriaId'" en
--   POST  /api/historial-puntos
--   GET   /api/historial-puntos/usuario/{id}
-- y en general cualquier endpoint que lea/escriba CategoriaId.
--
-- Como usarlo:
--   1. Abrir SQL Server Management Studio.
--   2. Conectarse a la base del proyecto (p. ej. EcoReto).
--   3. Abrir y ejecutar este script. Es IDEMPOTENTE: puede ejecutarse varias
--      veces sin efectos secundarios (cada bloque comprueba si ya existe).
--
-- Requisito: ya debe existir la tabla Categoria con los IDs 1-7 (los crea el
-- script principal EcoRetosDB.sql).
-- =============================================================================

SET NOCOUNT ON;
GO

-- -----------------------------------------------------------------------------
-- 1. HistorialPuntos.CategoriaId (el error reportado)
-- -----------------------------------------------------------------------------
IF COL_LENGTH('dbo.HistorialPuntos', 'CategoriaId') IS NULL
BEGIN
    ALTER TABLE dbo.HistorialPuntos ADD CategoriaId INT NULL;
    PRINT 'HistorialPuntos: columna CategoriaId agregada.';
END;
ELSE
    PRINT 'HistorialPuntos: CategoriaId ya existe, no se hace nada.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_HistorialPuntos_Categoria'
      AND parent_object_id = OBJECT_ID('dbo.HistorialPuntos')
)
BEGIN
    ALTER TABLE dbo.HistorialPuntos
        ADD CONSTRAINT FK_HistorialPuntos_Categoria
        FOREIGN KEY (CategoriaId) REFERENCES dbo.Categoria(CategoriaId);
    PRINT 'HistorialPuntos: FK_HistorialPuntos_Categoria agregada.';
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_HistorialPuntos_CategoriaId'
      AND object_id = OBJECT_ID('dbo.HistorialPuntos')
)
BEGIN
    CREATE INDEX IX_HistorialPuntos_CategoriaId
        ON dbo.HistorialPuntos(CategoriaId);
    PRINT 'HistorialPuntos: indice IX_HistorialPuntos_CategoriaId creado.';
END;
GO

-- -----------------------------------------------------------------------------
-- 2. Reto: columna Codigo (upsert del catalogo) + CategoriaId
-- -----------------------------------------------------------------------------
IF COL_LENGTH('dbo.Reto', 'Codigo') IS NULL
BEGIN
    ALTER TABLE dbo.Reto ADD Codigo NVARCHAR(50) NULL;
    PRINT 'Reto: columna Codigo agregada.';
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_Reto_Codigo' AND object_id = OBJECT_ID('dbo.Reto')
)
BEGIN
    -- Indice unico filtrado: permite multiples NULL en bases migradas.
    CREATE UNIQUE INDEX IX_Reto_Codigo ON dbo.Reto(Codigo) WHERE Codigo IS NOT NULL;
    PRINT 'Reto: indice unico IX_Reto_Codigo creado.';
END;
GO

IF COL_LENGTH('dbo.Reto', 'CategoriaId') IS NULL
BEGIN
    ALTER TABLE dbo.Reto ADD CategoriaId INT NULL;

    -- Los retos existentes sin categoria se asignan a "Reciclaje" (Id 1)
    -- como valor de seguridad; el movil los corrige al sincronizar.
    UPDATE dbo.Reto SET CategoriaId = 1 WHERE CategoriaId IS NULL;
    PRINT 'Reto: columna CategoriaId agregada y datos existentes asignados a Reciclaje (1).';
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_Reto_Categoria'
      AND parent_object_id = OBJECT_ID('dbo.Reto')
)
BEGIN
    ALTER TABLE dbo.Reto
        ADD CONSTRAINT FK_Reto_Categoria
        FOREIGN KEY (CategoriaId) REFERENCES dbo.Categoria(CategoriaId);
    PRINT 'Reto: FK_Reto_Categoria agregada.';
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_Reto_CategoriaId' AND object_id = OBJECT_ID('dbo.Reto')
)
BEGIN
    CREATE INDEX IX_Reto_CategoriaId ON dbo.Reto(CategoriaId);
    PRINT 'Reto: indice IX_Reto_CategoriaId creado.';
END;
GO

-- -----------------------------------------------------------------------------
-- 3. Trivia.CategoriaId
-- -----------------------------------------------------------------------------
IF COL_LENGTH('dbo.Trivia', 'CategoriaId') IS NULL
BEGIN
    ALTER TABLE dbo.Trivia ADD CategoriaId INT NULL;
    PRINT 'Trivia: columna CategoriaId agregada.';
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_Trivia_Categoria'
      AND parent_object_id = OBJECT_ID('dbo.Trivia')
)
BEGIN
    ALTER TABLE dbo.Trivia
        ADD CONSTRAINT FK_Trivia_Categoria
        FOREIGN KEY (CategoriaId) REFERENCES dbo.Categoria(CategoriaId);
    PRINT 'Trivia: FK_Trivia_Categoria agregada.';
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_Trivia_CategoriaId' AND object_id = OBJECT_ID('dbo.Trivia')
)
BEGIN
    CREATE INDEX IX_Trivia_CategoriaId ON dbo.Trivia(CategoriaId);
    PRINT 'Trivia: indice IX_Trivia_CategoriaId creado.';
END;
GO

-- -----------------------------------------------------------------------------
-- 4. Recurso.CategoriaId
-- -----------------------------------------------------------------------------
IF COL_LENGTH('dbo.Recurso', 'CategoriaId') IS NULL
BEGIN
    ALTER TABLE dbo.Recurso ADD CategoriaId INT NULL;
    PRINT 'Recurso: columna CategoriaId agregada.';
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = 'FK_Recurso_Categoria'
      AND parent_object_id = OBJECT_ID('dbo.Recurso')
)
BEGIN
    ALTER TABLE dbo.Recurso
        ADD CONSTRAINT FK_Recurso_Categoria
        FOREIGN KEY (CategoriaId) REFERENCES dbo.Categoria(CategoriaId);
    PRINT 'Recurso: FK_Recurso_Categoria agregada.';
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_Recurso_CategoriaId' AND object_id = OBJECT_ID('dbo.Recurso')
)
BEGIN
    CREATE INDEX IX_Recurso_CategoriaId ON dbo.Recurso(CategoriaId);
    PRINT 'Recurso: indice IX_Recurso_CategoriaId creado.';
END;
GO

PRINT 'Esquema actualizado correctamente.';