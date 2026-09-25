USE EcoRetos;
GO

IF OBJECT_ID('dbo.UsuarioDispositivo', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.UsuarioDispositivo (
        UsuarioDispositivoId INT PRIMARY KEY IDENTITY(1,1),
        UsuarioId INT NOT NULL,
        Token NVARCHAR(500) NOT NULL,
        Plataforma NVARCHAR(20) NOT NULL,
        FechaRegistro DATETIME2 NOT NULL DEFAULT GETDATE(),
        FechaActualizacion DATETIME2 NOT NULL DEFAULT GETDATE(),
        Activo BIT NOT NULL DEFAULT 1,
        CONSTRAINT FK_UsuarioDispositivo_Usuario
            FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
        CONSTRAINT UQ_UsuarioDispositivo_Token UNIQUE (Token)
    );

    CREATE INDEX IX_UsuarioDispositivo_UsuarioId
        ON dbo.UsuarioDispositivo(UsuarioId, Activo);
END;
GO
