IF COL_LENGTH('dbo.Mensaje', 'Tipo') IS NULL
    ALTER TABLE dbo.Mensaje ADD Tipo VARCHAR(20) NOT NULL CONSTRAINT DF_Mensaje_Tipo DEFAULT 'TEXTO';
GO

IF COL_LENGTH('dbo.Mensaje', 'ArchivoUrl') IS NULL
    ALTER TABLE dbo.Mensaje ADD ArchivoUrl NVARCHAR(500) NULL;
GO

IF COL_LENGTH('dbo.Mensaje', 'PublicacionId') IS NULL
    ALTER TABLE dbo.Mensaje ADD PublicacionId INT NULL;
GO

IF COL_LENGTH('dbo.Mensaje', 'RespuestaAId') IS NULL
    ALTER TABLE dbo.Mensaje ADD RespuestaAId INT NULL;
GO

IF COL_LENGTH('dbo.Mensaje', 'Editado') IS NULL
    ALTER TABLE dbo.Mensaje ADD Editado BIT NOT NULL CONSTRAINT DF_Mensaje_Editado DEFAULT 0;
GO

IF COL_LENGTH('dbo.Mensaje', 'EliminadoParaTodos') IS NULL
    ALTER TABLE dbo.Mensaje ADD EliminadoParaTodos BIT NOT NULL CONSTRAINT DF_Mensaje_EliminadoParaTodos DEFAULT 0;
GO

IF COL_LENGTH('dbo.Mensaje', 'EliminadoParaRemitente') IS NULL
    ALTER TABLE dbo.Mensaje ADD EliminadoParaRemitente BIT NOT NULL CONSTRAINT DF_Mensaje_EliminadoRemitente DEFAULT 0;
GO

IF COL_LENGTH('dbo.Mensaje', 'EliminadoParaDestinatario') IS NULL
    ALTER TABLE dbo.Mensaje ADD EliminadoParaDestinatario BIT NOT NULL CONSTRAINT DF_Mensaje_EliminadoDestinatario DEFAULT 0;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Mensaje_Publicacion')
    ALTER TABLE dbo.Mensaje ADD CONSTRAINT FK_Mensaje_Publicacion
        FOREIGN KEY (PublicacionId) REFERENCES dbo.Publicacion(PublicacionId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Mensaje_Respuesta')
    ALTER TABLE dbo.Mensaje ADD CONSTRAINT FK_Mensaje_Respuesta
        FOREIGN KEY (RespuestaAId) REFERENCES dbo.Mensaje(MensajeId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Mensaje_Publicacion' AND object_id = OBJECT_ID('dbo.Mensaje'))
    CREATE INDEX IX_Mensaje_Publicacion ON dbo.Mensaje(PublicacionId);
GO