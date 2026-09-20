IF OBJECT_ID('dbo.Usuario', 'U') IS NULL
BEGIN
    RAISERROR('Ejecuta este script sobre la base de datos de Eco-Retos (debe existir la tabla Usuario).', 16, 1);
    RETURN;
END
GO

IF OBJECT_ID('dbo.CalificacionPerfil', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CalificacionPerfil (
        CalificacionId       INT PRIMARY KEY IDENTITY(1,1),
        UsuarioCalificadoId  INT NOT NULL,
        UsuarioCalificadorId INT NOT NULL,
        Calificacion         INT NOT NULL,
        Comentario           NVARCHAR(500) NULL,
        Fecha                DATETIME2 NOT NULL CONSTRAINT DF_CalificacionPerfil_Fecha DEFAULT GETDATE(),

        CONSTRAINT FK_CalificacionPerfil_Calificado
            FOREIGN KEY (UsuarioCalificadoId) REFERENCES dbo.Usuario(UsuarioId),
        CONSTRAINT FK_CalificacionPerfil_Calificador
            FOREIGN KEY (UsuarioCalificadorId) REFERENCES dbo.Usuario(UsuarioId),
        CONSTRAINT CK_CalificacionPerfil_Rango
            CHECK (Calificacion BETWEEN 1 AND 5),
        CONSTRAINT CK_CalificacionPerfil_NoPropio
            CHECK (UsuarioCalificadoId <> UsuarioCalificadorId)
    );

    CREATE UNIQUE INDEX UQ_CalificacionPerfil
        ON dbo.CalificacionPerfil(UsuarioCalificadoId, UsuarioCalificadorId);

    CREATE INDEX IX_CalificacionPerfil_Calificado
        ON dbo.CalificacionPerfil(UsuarioCalificadoId, Fecha DESC);
END
GO

PRINT 'Tabla CalificacionPerfil aplicada correctamente.';
GO