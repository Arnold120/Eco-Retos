






















IF OBJECT_ID('dbo.Publicacion', 'U') IS NULL
BEGIN
    RAISERROR('Ejecuta este script sobre la base de datos de Eco-Retos (debe existir la tabla Publicacion).', 16, 1);
    RETURN;
END
GO



IF COL_LENGTH('dbo.Publicacion', 'Ubicacion') IS NULL
    ALTER TABLE dbo.Publicacion ADD Ubicacion NVARCHAR(200) NULL;
GO

IF COL_LENGTH('dbo.Publicacion', 'Categoria') IS NULL
    ALTER TABLE dbo.Publicacion ADD Categoria NVARCHAR(50) NULL;
GO

IF COL_LENGTH('dbo.Publicacion', 'CompartidoDeId') IS NULL
    ALTER TABLE dbo.Publicacion ADD CompartidoDeId INT NULL;
GO

IF COL_LENGTH('dbo.Publicacion', 'Editada') IS NULL
    ALTER TABLE dbo.Publicacion ADD Editada BIT NOT NULL CONSTRAINT DF_Publicacion_Editada DEFAULT 0;
GO

IF COL_LENGTH('dbo.Publicacion', 'FechaEdicion') IS NULL
    ALTER TABLE dbo.Publicacion ADD FechaEdicion DATETIME2 NULL;
GO

IF COL_LENGTH('dbo.Publicacion', 'CompartidoEliminado') IS NULL
    ALTER TABLE dbo.Publicacion ADD CompartidoEliminado BIT NOT NULL CONSTRAINT DF_Publicacion_CompartidoEliminado DEFAULT 0;
GO

IF COL_LENGTH('dbo.Publicacion', 'Visibilidad') IS NULL
    ALTER TABLE dbo.Publicacion ADD Visibilidad NVARCHAR(20) NOT NULL CONSTRAINT DF_Publicacion_Visibilidad DEFAULT 'PUBLICO';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Publicacion_Visibilidad' AND object_id = OBJECT_ID('dbo.Publicacion'))
    CREATE INDEX IX_Publicacion_Visibilidad ON dbo.Publicacion(Visibilidad, Estado);
GO





IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Publicacion_Compartida')
    ALTER TABLE dbo.Publicacion
        ADD CONSTRAINT FK_Publicacion_Compartida
        FOREIGN KEY (CompartidoDeId) REFERENCES dbo.Publicacion(PublicacionId)
        ON DELETE NO ACTION;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Publicacion_Estado_Fecha' AND object_id = OBJECT_ID('dbo.Publicacion'))
    CREATE INDEX IX_Publicacion_Estado_Fecha ON dbo.Publicacion(Estado, FechaPublicacion DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Publicacion_CompartidoDeId' AND object_id = OBJECT_ID('dbo.Publicacion'))
    CREATE INDEX IX_Publicacion_CompartidoDeId ON dbo.Publicacion(CompartidoDeId);
GO



IF OBJECT_ID('dbo.PublicacionMultimedia', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PublicacionMultimedia (
        MultimediaId  INT PRIMARY KEY IDENTITY(1,1),
        PublicacionId INT NOT NULL,
        Url           NVARCHAR(500) NOT NULL,
        Tipo          NVARCHAR(20) NOT NULL CONSTRAINT DF_PublicacionMultimedia_Tipo DEFAULT 'imagen',
        Duracion      NVARCHAR(20) NULL,

        Poster        NVARCHAR(500) NULL,
        Orden         INT NOT NULL CONSTRAINT DF_PublicacionMultimedia_Orden DEFAULT 0,
        FechaCreacion DATETIME2 NOT NULL CONSTRAINT DF_PublicacionMultimedia_Fecha DEFAULT GETDATE(),
        CONSTRAINT FK_PublicacionMultimedia_Publicacion
            FOREIGN KEY (PublicacionId) REFERENCES dbo.Publicacion(PublicacionId) ON DELETE CASCADE,
        CONSTRAINT CK_PublicacionMultimedia_Tipo CHECK (Tipo IN ('imagen', 'video'))
    );

    CREATE INDEX IX_PublicacionMultimedia_Publicacion ON dbo.PublicacionMultimedia(PublicacionId, Orden);
END
GO

IF COL_LENGTH('dbo.PublicacionMultimedia', 'Poster') IS NULL
    ALTER TABLE dbo.PublicacionMultimedia ADD Poster NVARCHAR(500) NULL;
GO



IF COL_LENGTH('dbo.Comentario', 'ComentarioPadreId') IS NULL
    ALTER TABLE dbo.Comentario ADD ComentarioPadreId INT NULL;
GO

IF COL_LENGTH('dbo.Comentario', 'Editado') IS NULL
    ALTER TABLE dbo.Comentario ADD Editado BIT NOT NULL CONSTRAINT DF_Comentario_Editado DEFAULT 0;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Comentario_Padre')
    ALTER TABLE dbo.Comentario
        ADD CONSTRAINT FK_Comentario_Padre
        FOREIGN KEY (ComentarioPadreId) REFERENCES dbo.Comentario(ComentarioId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Comentario_Padre' AND object_id = OBJECT_ID('dbo.Comentario'))
    CREATE INDEX IX_Comentario_Padre ON dbo.Comentario(ComentarioPadreId);
GO



IF OBJECT_ID('dbo.Reaccion', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Reaccion (
        ReaccionId    INT PRIMARY KEY IDENTITY(1,1),
        PublicacionId INT NULL,
        ComentarioId  INT NULL,
        UsuarioId     INT NOT NULL,
        Tipo          NVARCHAR(20) NOT NULL CONSTRAINT DF_Reaccion_Tipo DEFAULT 'ME_GUSTA',
        Fecha         DATETIME2 NOT NULL CONSTRAINT DF_Reaccion_Fecha DEFAULT GETDATE(),
        CONSTRAINT FK_Reaccion_Publicacion
            FOREIGN KEY (PublicacionId) REFERENCES dbo.Publicacion(PublicacionId) ON DELETE CASCADE,
        CONSTRAINT FK_Reaccion_Comentario
            FOREIGN KEY (ComentarioId) REFERENCES dbo.Comentario(ComentarioId) ON DELETE CASCADE,
        CONSTRAINT FK_Reaccion_Usuario
            FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuario(UsuarioId),
        CONSTRAINT CK_Reaccion_Objetivo
            CHECK ((PublicacionId IS NOT NULL AND ComentarioId IS NULL)
                OR (PublicacionId IS NULL AND ComentarioId IS NOT NULL))
    );

    CREATE UNIQUE INDEX UQ_Reaccion_Publicacion_Usuario
        ON dbo.Reaccion(PublicacionId, UsuarioId) WHERE PublicacionId IS NOT NULL;
    CREATE UNIQUE INDEX UQ_Reaccion_Comentario_Usuario
        ON dbo.Reaccion(ComentarioId, UsuarioId) WHERE ComentarioId IS NOT NULL;
    CREATE INDEX IX_Reaccion_Publicacion ON dbo.Reaccion(PublicacionId);
    CREATE INDEX IX_Reaccion_Comentario ON dbo.Reaccion(ComentarioId);
END
GO



IF OBJECT_ID('dbo.Seguimiento', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Seguimiento (
        SeguidorId INT NOT NULL,
        SeguidoId  INT NOT NULL,
        Fecha      DATETIME2 NOT NULL CONSTRAINT DF_Seguimiento_Fecha DEFAULT GETDATE(),
        CONSTRAINT PK_Seguimiento PRIMARY KEY (SeguidorId, SeguidoId),
        CONSTRAINT FK_Seguimiento_Seguidor FOREIGN KEY (SeguidorId) REFERENCES dbo.Usuario(UsuarioId),
        CONSTRAINT FK_Seguimiento_Seguido  FOREIGN KEY (SeguidoId)  REFERENCES dbo.Usuario(UsuarioId),
        CONSTRAINT CK_Seguimiento_NoPropio CHECK (SeguidorId <> SeguidoId)
    );

    CREATE INDEX IX_Seguimiento_Seguido ON dbo.Seguimiento(SeguidoId);
END
GO



IF OBJECT_ID('dbo.Guardado', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Guardado (
        UsuarioId     INT NOT NULL,
        PublicacionId INT NOT NULL,
        Fecha         DATETIME2 NOT NULL CONSTRAINT DF_Guardado_Fecha DEFAULT GETDATE(),
        CONSTRAINT PK_Guardado PRIMARY KEY (UsuarioId, PublicacionId),
        CONSTRAINT FK_Guardado_Usuario FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuario(UsuarioId),
        CONSTRAINT FK_Guardado_Publicacion FOREIGN KEY (PublicacionId) REFERENCES dbo.Publicacion(PublicacionId) ON DELETE CASCADE
    );

    CREATE INDEX IX_Guardado_Usuario ON dbo.Guardado(UsuarioId, Fecha DESC);
END
GO



IF OBJECT_ID('dbo.Denuncia', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Denuncia (
        DenunciaId    INT PRIMARY KEY IDENTITY(1,1),
        UsuarioId     INT NOT NULL,
        PublicacionId INT NULL,
        ComentarioId  INT NULL,
        Motivo        NVARCHAR(100) NOT NULL,
        Descripcion   NVARCHAR(500) NULL,
        Estado        NVARCHAR(20) NOT NULL CONSTRAINT DF_Denuncia_Estado DEFAULT 'PENDIENTE',
        Fecha         DATETIME2 NOT NULL CONSTRAINT DF_Denuncia_Fecha DEFAULT GETDATE(),
        CONSTRAINT FK_Denuncia_Usuario FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuario(UsuarioId),
        CONSTRAINT FK_Denuncia_Publicacion FOREIGN KEY (PublicacionId) REFERENCES dbo.Publicacion(PublicacionId) ON DELETE SET NULL,
        CONSTRAINT FK_Denuncia_Comentario FOREIGN KEY (ComentarioId) REFERENCES dbo.Comentario(ComentarioId) ON DELETE SET NULL,
        CONSTRAINT CK_Denuncia_Objetivo
            CHECK (PublicacionId IS NOT NULL OR ComentarioId IS NOT NULL)
    );

    CREATE INDEX IX_Denuncia_Estado ON dbo.Denuncia(Estado, Fecha DESC);
END
GO



IF OBJECT_ID('dbo.Conversacion', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Conversacion (
        ConversacionId     INT PRIMARY KEY IDENTITY(1,1),
        FechaCreacion      DATETIME2 NOT NULL CONSTRAINT DF_Conversacion_Fecha DEFAULT GETDATE(),
        FechaUltimoMensaje DATETIME2 NULL
    );
END
GO

IF OBJECT_ID('dbo.ConversacionParticipante', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ConversacionParticipante (
        ConversacionId  INT NOT NULL,
        UsuarioId       INT NOT NULL,
        FechaUltimoLeido DATETIME2 NULL,
        CONSTRAINT PK_ConversacionParticipante PRIMARY KEY (ConversacionId, UsuarioId),
        CONSTRAINT FK_ConversacionParticipante_Conversacion
            FOREIGN KEY (ConversacionId) REFERENCES dbo.Conversacion(ConversacionId) ON DELETE CASCADE,
        CONSTRAINT FK_ConversacionParticipante_Usuario
            FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuario(UsuarioId)
    );

    CREATE INDEX IX_ConversacionParticipante_Usuario ON dbo.ConversacionParticipante(UsuarioId);
END
GO

IF OBJECT_ID('dbo.Mensaje', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Mensaje (
        MensajeId      INT PRIMARY KEY IDENTITY(1,1),
        ConversacionId INT NOT NULL,
        RemitenteId    INT NOT NULL,
        Contenido      NVARCHAR(MAX) NOT NULL,
        Fecha          DATETIME2 NOT NULL CONSTRAINT DF_Mensaje_Fecha DEFAULT GETDATE(),
        Leido          BIT NOT NULL CONSTRAINT DF_Mensaje_Leido DEFAULT 0,
        CONSTRAINT FK_Mensaje_Conversacion
            FOREIGN KEY (ConversacionId) REFERENCES dbo.Conversacion(ConversacionId) ON DELETE CASCADE,
        CONSTRAINT FK_Mensaje_Remitente
            FOREIGN KEY (RemitenteId) REFERENCES dbo.Usuario(UsuarioId)
    );

    CREATE INDEX IX_Mensaje_Conversacion_Fecha ON dbo.Mensaje(ConversacionId, Fecha);
    CREATE INDEX IX_Mensaje_NoLeidos ON dbo.Mensaje(ConversacionId, Leido, RemitenteId);
END
GO



IF COL_LENGTH('dbo.Notificacion', 'ReferenciaTipo') IS NULL
    ALTER TABLE dbo.Notificacion ADD ReferenciaTipo NVARCHAR(30) NULL;
GO

IF COL_LENGTH('dbo.Notificacion', 'ReferenciaId') IS NULL
    ALTER TABLE dbo.Notificacion ADD ReferenciaId INT NULL;
GO

IF COL_LENGTH('dbo.Notificacion', 'ActorUsuarioId') IS NULL
    ALTER TABLE dbo.Notificacion ADD ActorUsuarioId INT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Notificacion_Actor')
    ALTER TABLE dbo.Notificacion
        ADD CONSTRAINT FK_Notificacion_Actor
        FOREIGN KEY (ActorUsuarioId) REFERENCES dbo.Usuario(UsuarioId);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Notificacion_Referencia' AND object_id = OBJECT_ID('dbo.Notificacion'))
    CREATE INDEX IX_Notificacion_Referencia ON dbo.Notificacion(Tipo, ReferenciaId);
GO

PRINT 'Migracion del Muro Social aplicada correctamente.';
GO
