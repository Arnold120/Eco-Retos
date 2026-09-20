USE EcoRetos;
GO

IF OBJECT_ID('dbo.SoporteConfig', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SoporteConfig
    (
        Clave       NVARCHAR(50)  NOT NULL PRIMARY KEY,
        Valor       NVARCHAR(MAX) NOT NULL,
        Actualizado DATETIME2     NOT NULL CONSTRAINT DF_SoporteConfig_Actualizado DEFAULT GETDATE()
    );

    INSERT INTO dbo.SoporteConfig (Clave, Valor) VALUES
    ('TerminosVersion', 'v1'),
    ('TerminosTexto',
        'Antes de continuar, debes aceptar que esta conversación podrá ser almacenada y revisada con fines de seguridad, soporte, moderación y resolución del problema.'),
    ('AdvertenciaContenido',
        'Su contenido fue revisado y se determinó que incumple las reglas de la comunidad. Por favor evite repetir este comportamiento para no afectar la experiencia de otros usuarios.');
END
GO

IF OBJECT_ID('dbo.SupportCase', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SupportCase
    (
        SupportCaseId       INT              NOT NULL IDENTITY(1,1) PRIMARY KEY,
        UsuarioId           INT              NOT NULL,
        Titulo              NVARCHAR(200)    NOT NULL,
        Descripcion         NVARCHAR(1000)   NULL,
        Categoria           NVARCHAR(30)     NOT NULL CONSTRAINT DF_SupportCase_Categoria DEFAULT 'OTRO',
        Prioridad           NVARCHAR(20)     NOT NULL CONSTRAINT DF_SupportCase_Prioridad DEFAULT 'NORMAL',
        Estado              NVARCHAR(30)     NOT NULL CONSTRAINT DF_SupportCase_Estado    DEFAULT 'NUEVO',
        Consentimiento      BIT              NOT NULL CONSTRAINT DF_SupportCase_Consent   DEFAULT 0,
        FechaConsentimiento DATETIME2        NULL,
        TerminosVersion     NVARCHAR(20)     NULL,
        AdminUsuarioId      INT              NULL,
        MotivoEscalamiento  NVARCHAR(500)    NULL,
        Resolucion          NVARCHAR(1000)   NULL,
        NotasInternas       NVARCHAR(MAX)    NULL,
        FechaCreacion       DATETIME2        NOT NULL CONSTRAINT DF_SupportCase_Creado    DEFAULT GETDATE(),
        FechaActualizacion  DATETIME2        NOT NULL CONSTRAINT DF_SupportCase_Actualizado DEFAULT GETDATE(),
        FechaCierre         DATETIME2        NULL,
        CONSTRAINT FK_SupportCase_Usuario FOREIGN KEY (UsuarioId)      REFERENCES dbo.Usuario(UsuarioId),
        CONSTRAINT FK_SupportCase_Admin   FOREIGN KEY (AdminUsuarioId) REFERENCES dbo.Usuario(UsuarioId)
    );

    CREATE INDEX IX_SupportCase_Usuario     ON dbo.SupportCase (UsuarioId, FechaActualizacion DESC);
    CREATE INDEX IX_SupportCase_Estado      ON dbo.SupportCase (Estado, FechaActualizacion DESC);
    CREATE INDEX IX_SupportCase_Admin       ON dbo.SupportCase (AdminUsuarioId);
END
GO

IF OBJECT_ID('dbo.SupportCaseMensaje', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SupportCaseMensaje
    (
        SupportCaseMensajeId INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
        SupportCaseId        INT            NOT NULL,
        TipoRemitente        NVARCHAR(10)   NOT NULL,   
        RemitenteUsuarioId   INT            NULL,
        Contenido            NVARCHAR(MAX)  NOT NULL,
        AdjuntosJson         NVARCHAR(MAX)  NULL,       
        SugerenciasJson      NVARCHAR(MAX)  NULL,       
        Leido                BIT            NOT NULL CONSTRAINT DF_SupportCaseMensaje_Leido DEFAULT 0,
        Fecha                DATETIME2      NOT NULL CONSTRAINT DF_SupportCaseMensaje_Fecha DEFAULT GETDATE(),
        CONSTRAINT FK_SCM_SupportCase FOREIGN KEY (SupportCaseId)      REFERENCES dbo.SupportCase(SupportCaseId) ON DELETE CASCADE,
        CONSTRAINT FK_SCM_Usuario     FOREIGN KEY (RemitenteUsuarioId) REFERENCES dbo.Usuario(UsuarioId)
    );

    CREATE INDEX IX_SCM_SupportCase ON dbo.SupportCaseMensaje (SupportCaseId, Fecha);
END
GO

IF OBJECT_ID('dbo.SupportAuditLog', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SupportAuditLog
    (
        AuditLogId      BIGINT         NOT NULL IDENTITY(1,1) PRIMARY KEY,
        ActorUsuarioId  INT            NULL,
        ActorTipo       NVARCHAR(10)   NOT NULL CONSTRAINT DF_SAL_ActorTipo DEFAULT 'USUARIO', 
        Accion          NVARCHAR(60)   NOT NULL,
        EntidadTipo     NVARCHAR(40)   NOT NULL,
        EntidadId       INT            NULL,
        EstadoAnterior  NVARCHAR(30)   NULL,
        EstadoNuevo     NVARCHAR(30)   NULL,
        Motivo          NVARCHAR(500)  NULL,
        MetadataJson    NVARCHAR(MAX)  NULL,
        Fecha           DATETIME2      NOT NULL CONSTRAINT DF_SAL_Fecha DEFAULT GETDATE(),
        CONSTRAINT FK_SAL_Usuario FOREIGN KEY (ActorUsuarioId) REFERENCES dbo.Usuario(UsuarioId)
    );

    CREATE INDEX IX_SAL_Entidad ON dbo.SupportAuditLog (EntidadTipo, EntidadId, Fecha DESC);
    CREATE INDEX IX_SAL_Fecha   ON dbo.SupportAuditLog (Fecha DESC);
END
GO

PRINT 'Soporte_IA.sql aplicado correctamente (aditivo, sin cambios destructivos).';
GO
