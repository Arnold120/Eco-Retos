USE master
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'EcoRetos')
BEGIN
    ALTER DATABASE EcoRetos SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE EcoRetos;
END
GO

CREATE DATABASE EcoRetos;
GO

USE EcoRetos;
GO

CREATE TABLE Usuario (
    UsuarioId INT PRIMARY KEY IDENTITY(1,1),
    NombreUsuario NVARCHAR(200),
    Correo NVARCHAR(200),
    Contrasena NVARCHAR(255),
    Salt VARBINARY(256),
    Activo BIT DEFAULT 1,
    FechaRegistro DATETIME2 DEFAULT GETDATE()
);

CREATE UNIQUE INDEX IX_Usuario_Correo ON Usuario(Correo);
CREATE UNIQUE INDEX IX_Usuario_NombreUsuario ON Usuario(NombreUsuario);

CREATE TABLE Rol (
    RolId INT PRIMARY KEY IDENTITY(1,1),
    NombreRol NVARCHAR(100),
    Descripcion NVARCHAR(300)
);

CREATE UNIQUE INDEX IX_Rol_NombreRol ON Rol(NombreRol);

CREATE TABLE UsuarioRol (
    UsuarioRolId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    RolId INT,
    CONSTRAINT FK_UsuarioRol_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT FK_UsuarioRol_Rol FOREIGN KEY (RolId) REFERENCES Rol(RolId),
    CONSTRAINT UQ_UsuarioRol UNIQUE (UsuarioId, RolId)
);

CREATE INDEX IX_UsuarioRol_UsuarioId ON UsuarioRol(UsuarioId);
CREATE INDEX IX_UsuarioRol_RolId ON UsuarioRol(RolId);

CREATE TABLE Perfil (
    PerfilId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    Nombre NVARCHAR(100),
    Apellido NVARCHAR(100),
    Carnet NVARCHAR(50),
    CentroEducativo NVARCHAR(200),
    Grado NVARCHAR(100),
    FotoPerfil NVARCHAR(500),
    CONSTRAINT FK_Perfil_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT UQ_Perfil_Usuario UNIQUE (UsuarioId)
);

CREATE TABLE Categoria (
    CategoriaId INT PRIMARY KEY IDENTITY(1,1),
    NombreCategoria NVARCHAR(150),
    Descripcion NVARCHAR(500)
);

CREATE UNIQUE INDEX IX_Categoria_NombreCategoria ON Categoria(NombreCategoria);




SET IDENTITY_INSERT Categoria ON;
INSERT INTO Categoria (CategoriaId, NombreCategoria, Descripcion) VALUES
    (1, 'Reciclaje',
     'Acciones relacionadas con la separación, reutilización y correcta disposición de residuos.'),
    (2, 'Movilidad sostenible',
     'Acciones que promueven medios de transporte sostenibles y reducen el impacto ambiental.'),
    (3, 'Reforestación y biodiversidad',
     'Acciones relacionadas con la siembra de árboles, conservación de áreas verdes y biodiversidad.'),
    (4, 'Consumo responsable',
     'Acciones que promueven compras conscientes, reducción del consumo y disminución de residuos.'),
    (5, 'Eficiencia energética',
     'Acciones destinadas a reducir el consumo de energía y mejorar su aprovechamiento.'),
    (6, 'Alimentación sostenible',
     'Acciones relacionadas con hábitos alimentarios que reducen el impacto ambiental.'),
    (7, 'Economía circular y reparación',
     'Acciones que buscan reparar, reutilizar y extender la vida útil de productos y materiales.');
SET IDENTITY_INSERT Categoria OFF;
GO

CREATE TABLE Reto (
    RetoId INT PRIMARY KEY IDENTITY(1,1),
    Codigo NVARCHAR(50),
    CategoriaId INT NOT NULL,
    Titulo NVARCHAR(200),
    Descripcion NVARCHAR(MAX),
    Instrucciones NVARCHAR(MAX),


    ExperienciaRecompensa INT NOT NULL DEFAULT 0,
    MonedasRecompensa INT NOT NULL DEFAULT 0,
    Dificultad NVARCHAR(50),
    FechaInicio DATETIME2,
    FechaFin DATETIME2,
    Estado NVARCHAR(50) DEFAULT 'ACTIVO',
    CONSTRAINT FK_Reto_Categoria FOREIGN KEY (CategoriaId) REFERENCES Categoria(CategoriaId)
);




CREATE UNIQUE INDEX IX_Reto_Codigo ON Reto(Codigo);





CREATE INDEX IX_Reto_CategoriaId ON Reto(CategoriaId);
CREATE INDEX IX_Reto_Estado ON Reto(Estado);

CREATE TABLE UsuarioReto (
    UsuarioRetoId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    RetoId INT,
    Estado NVARCHAR(50) DEFAULT 'INICIADO',
    Evidencia NVARCHAR(500),
    MotivoRechazo NVARCHAR(300),
    PuntosObtenidos INT DEFAULT 0,
    FechaInicio DATETIME2 DEFAULT GETDATE(),
    FechaCompletado DATETIME2,
    CONSTRAINT FK_UsuarioReto_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT FK_UsuarioReto_Reto FOREIGN KEY (RetoId) REFERENCES Reto(RetoId),
    CONSTRAINT UQ_UsuarioReto UNIQUE (UsuarioId, RetoId)
);

CREATE INDEX IX_UsuarioReto_UsuarioId ON UsuarioReto(UsuarioId);
CREATE INDEX IX_UsuarioReto_RetoId ON UsuarioReto(RetoId);


CREATE INDEX IX_UsuarioReto_UsuarioReto ON UsuarioReto(UsuarioId, RetoId);

CREATE TABLE Trivia (
    TriviaId INT PRIMARY KEY IDENTITY(1,1),
    CategoriaId INT,
    Titulo NVARCHAR(200),
    Descripcion NVARCHAR(MAX),
    Dificultad NVARCHAR(50),
    PuntosMaximos INT DEFAULT 0,
    Estado NVARCHAR(50) DEFAULT 'ACTIVA',
    CONSTRAINT FK_Trivia_Categoria FOREIGN KEY (CategoriaId) REFERENCES Categoria(CategoriaId)
);

CREATE INDEX IX_Trivia_CategoriaId ON Trivia(CategoriaId);
CREATE INDEX IX_Trivia_Estado ON Trivia(Estado);

CREATE TABLE Pregunta (
    PreguntaId INT PRIMARY KEY IDENTITY(1,1),
    TriviaId INT,
    PreguntaTexto NVARCHAR(MAX),
    Puntos INT DEFAULT 1,
    CONSTRAINT FK_Pregunta_Trivia FOREIGN KEY (TriviaId) REFERENCES Trivia(TriviaId)
);

CREATE INDEX IX_Pregunta_TriviaId ON Pregunta(TriviaId);

CREATE TABLE OpcionRespuesta (
    OpcionId INT PRIMARY KEY IDENTITY(1,1),
    PreguntaId INT,
    TextoOpcion NVARCHAR(500),
    EsCorrecta BIT DEFAULT 0,
    CONSTRAINT FK_OpcionRespuesta_Pregunta FOREIGN KEY (PreguntaId) REFERENCES Pregunta(PreguntaId)
);

CREATE INDEX IX_OpcionRespuesta_PreguntaId ON OpcionRespuesta(PreguntaId);

CREATE TABLE IntentoTrivia (
    IntentoId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    TriviaId INT,
    Puntuacion INT DEFAULT 0,
    FechaInicio DATETIME2 DEFAULT GETDATE(),
    FechaFinalizacion DATETIME2,
    CONSTRAINT FK_IntentoTrivia_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT FK_IntentoTrivia_Trivia FOREIGN KEY (TriviaId) REFERENCES Trivia(TriviaId)
);

CREATE INDEX IX_IntentoTrivia_UsuarioId ON IntentoTrivia(UsuarioId);
CREATE INDEX IX_IntentoTrivia_TriviaId ON IntentoTrivia(TriviaId);

CREATE TABLE RespuestaUsuario (
    RespuestaId INT PRIMARY KEY IDENTITY(1,1),
    IntentoId INT,
    PreguntaId INT,
    OpcionId INT,
    EsCorrecta BIT DEFAULT 0,
    CONSTRAINT FK_RespuestaUsuario_Intento FOREIGN KEY (IntentoId) REFERENCES IntentoTrivia(IntentoId),
    CONSTRAINT FK_RespuestaUsuario_Pregunta FOREIGN KEY (PreguntaId) REFERENCES Pregunta(PreguntaId),
    CONSTRAINT FK_RespuestaUsuario_Opcion FOREIGN KEY (OpcionId) REFERENCES OpcionRespuesta(OpcionId)
);

CREATE INDEX IX_RespuestaUsuario_IntentoId ON RespuestaUsuario(IntentoId);

CREATE TABLE Material (
    MaterialId INT PRIMARY KEY IDENTITY(1,1),
    NombreMaterial NVARCHAR(150),
    Descripcion NVARCHAR(500),
    Tipo NVARCHAR(100),

    PrecioMonedas INT DEFAULT 0,
    CantidadDisponible INT DEFAULT 0,
    Imagen NVARCHAR(500),
    Estado NVARCHAR(50) DEFAULT 'DISPONIBLE'
);

CREATE INDEX IX_Material_Estado ON Material(Estado);

CREATE TABLE Inventario (
    InventarioId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    MaterialId INT,
    Cantidad INT DEFAULT 0,
    CONSTRAINT FK_Inventario_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT FK_Inventario_Material FOREIGN KEY (MaterialId) REFERENCES Material(MaterialId),
    CONSTRAINT UQ_Inventario UNIQUE (UsuarioId, MaterialId)
);

CREATE INDEX IX_Inventario_UsuarioId ON Inventario(UsuarioId);

CREATE TABLE Compra (
    CompraId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,

    TotalMonedas INT,
    FechaCompra DATETIME2 DEFAULT GETDATE(),

    ClaveIdempotencia NVARCHAR(120),
    CONSTRAINT FK_Compra_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId)
);

CREATE INDEX IX_Compra_UsuarioId ON Compra(UsuarioId);

CREATE UNIQUE INDEX UX_Compra_Idempotencia
ON Compra(UsuarioId, ClaveIdempotencia)
WHERE ClaveIdempotencia IS NOT NULL;

CREATE TABLE DetalleCompra (
    DetalleCompraId INT PRIMARY KEY IDENTITY(1,1),
    CompraId INT,
    MaterialId INT,
    Cantidad INT,

    PrecioUnitarioMonedas INT,
    CONSTRAINT FK_DetalleCompra_Compra FOREIGN KEY (CompraId) REFERENCES Compra(CompraId),
    CONSTRAINT FK_DetalleCompra_Material FOREIGN KEY (MaterialId) REFERENCES Material(MaterialId)
);

CREATE INDEX IX_DetalleCompra_CompraId ON DetalleCompra(CompraId);

CREATE TABLE Publicacion (
    PublicacionId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    Contenido NVARCHAR(MAX),
    Imagen NVARCHAR(500),
    Tipo NVARCHAR(50) DEFAULT 'GENERAL',
    FechaPublicacion DATETIME2 DEFAULT GETDATE(),
    Estado NVARCHAR(50) DEFAULT 'PUBLICADA',
    Ubicacion NVARCHAR(200),
    Categoria NVARCHAR(50),

    CompartidoDeId INT,

    CompartidoEliminado BIT NOT NULL DEFAULT 0,

    Visibilidad NVARCHAR(20) NOT NULL DEFAULT 'PUBLICO',
    Editada BIT NOT NULL DEFAULT 0,
    FechaEdicion DATETIME2,
    CONSTRAINT FK_Publicacion_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),


    CONSTRAINT FK_Publicacion_Compartida FOREIGN KEY (CompartidoDeId) REFERENCES Publicacion(PublicacionId) ON DELETE NO ACTION
);

CREATE INDEX IX_Publicacion_UsuarioId ON Publicacion(UsuarioId);
CREATE INDEX IX_Publicacion_Estado ON Publicacion(Estado);
CREATE INDEX IX_Publicacion_Estado_Fecha ON Publicacion(Estado, FechaPublicacion DESC);
CREATE INDEX IX_Publicacion_CompartidoDeId ON Publicacion(CompartidoDeId);
CREATE INDEX IX_Publicacion_Visibilidad ON Publicacion(Visibilidad, Estado);

CREATE TABLE PublicacionMultimedia (
    MultimediaId INT PRIMARY KEY IDENTITY(1,1),
    PublicacionId INT NOT NULL,
    Url NVARCHAR(500) NOT NULL,
    Tipo NVARCHAR(20) NOT NULL DEFAULT 'imagen',
    Duracion NVARCHAR(20),

    Poster NVARCHAR(500),
    Orden INT NOT NULL DEFAULT 0,
    FechaCreacion DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_PublicacionMultimedia_Publicacion FOREIGN KEY (PublicacionId) REFERENCES Publicacion(PublicacionId) ON DELETE CASCADE,
    CONSTRAINT CK_PublicacionMultimedia_Tipo CHECK (Tipo IN ('imagen', 'video'))
);

CREATE INDEX IX_PublicacionMultimedia_Publicacion ON PublicacionMultimedia(PublicacionId, Orden);

CREATE TABLE Comentario (
    ComentarioId INT PRIMARY KEY IDENTITY(1,1),
    PublicacionId INT,
    UsuarioId INT,
    ComentarioTexto NVARCHAR(MAX),
    FechaComentario DATETIME2 DEFAULT GETDATE(),

    ComentarioPadreId INT,
    Editado BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Comentario_Publicacion FOREIGN KEY (PublicacionId) REFERENCES Publicacion(PublicacionId),
    CONSTRAINT FK_Comentario_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT FK_Comentario_Padre FOREIGN KEY (ComentarioPadreId) REFERENCES Comentario(ComentarioId)
);

CREATE INDEX IX_Comentario_PublicacionId ON Comentario(PublicacionId);
CREATE INDEX IX_Comentario_Padre ON Comentario(ComentarioPadreId);

CREATE TABLE Reaccion (
    ReaccionId INT PRIMARY KEY IDENTITY(1,1),
    PublicacionId INT,
    ComentarioId INT,
    UsuarioId INT NOT NULL,
    Tipo NVARCHAR(20) NOT NULL DEFAULT 'ME_GUSTA',
    Fecha DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Reaccion_Publicacion FOREIGN KEY (PublicacionId) REFERENCES Publicacion(PublicacionId) ON DELETE CASCADE,
    CONSTRAINT FK_Reaccion_Comentario FOREIGN KEY (ComentarioId) REFERENCES Comentario(ComentarioId) ON DELETE CASCADE,
    CONSTRAINT FK_Reaccion_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT CK_Reaccion_Objetivo CHECK (
        (PublicacionId IS NOT NULL AND ComentarioId IS NULL) OR
        (PublicacionId IS NULL AND ComentarioId IS NOT NULL)
    )
);

CREATE UNIQUE INDEX UQ_Reaccion_Publicacion_Usuario ON Reaccion(PublicacionId, UsuarioId) WHERE PublicacionId IS NOT NULL;
CREATE UNIQUE INDEX UQ_Reaccion_Comentario_Usuario ON Reaccion(ComentarioId, UsuarioId) WHERE ComentarioId IS NOT NULL;
CREATE INDEX IX_Reaccion_Publicacion ON Reaccion(PublicacionId);
CREATE INDEX IX_Reaccion_Comentario ON Reaccion(ComentarioId);

CREATE TABLE Seguimiento (
    SeguidorId INT NOT NULL,
    SeguidoId INT NOT NULL,
    Fecha DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_Seguimiento PRIMARY KEY (SeguidorId, SeguidoId),
    CONSTRAINT FK_Seguimiento_Seguidor FOREIGN KEY (SeguidorId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT FK_Seguimiento_Seguido FOREIGN KEY (SeguidoId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT CK_Seguimiento_NoPropio CHECK (SeguidorId <> SeguidoId)
);

CREATE INDEX IX_Seguimiento_Seguido ON Seguimiento(SeguidoId);

CREATE TABLE Guardado (
    UsuarioId INT NOT NULL,
    PublicacionId INT NOT NULL,
    Fecha DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_Guardado PRIMARY KEY (UsuarioId, PublicacionId),
    CONSTRAINT FK_Guardado_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT FK_Guardado_Publicacion FOREIGN KEY (PublicacionId) REFERENCES Publicacion(PublicacionId) ON DELETE CASCADE
);

CREATE INDEX IX_Guardado_Usuario ON Guardado(UsuarioId, Fecha DESC);

CREATE TABLE Denuncia (
    DenunciaId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT NOT NULL,
    PublicacionId INT,
    ComentarioId INT,
    Motivo NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(500),
    Estado NVARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    Fecha DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Denuncia_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT FK_Denuncia_Publicacion FOREIGN KEY (PublicacionId) REFERENCES Publicacion(PublicacionId) ON DELETE SET NULL,
    CONSTRAINT FK_Denuncia_Comentario FOREIGN KEY (ComentarioId) REFERENCES Comentario(ComentarioId) ON DELETE SET NULL,
    CONSTRAINT CK_Denuncia_Objetivo CHECK (PublicacionId IS NOT NULL OR ComentarioId IS NOT NULL)
);

CREATE INDEX IX_Denuncia_Estado ON Denuncia(Estado, Fecha DESC);

CREATE TABLE Conversacion (
    ConversacionId INT PRIMARY KEY IDENTITY(1,1),
    FechaCreacion DATETIME2 NOT NULL DEFAULT GETDATE(),
    FechaUltimoMensaje DATETIME2
);

CREATE TABLE ConversacionParticipante (
    ConversacionId INT NOT NULL,
    UsuarioId INT NOT NULL,
    FechaUltimoLeido DATETIME2,
    CONSTRAINT PK_ConversacionParticipante PRIMARY KEY (ConversacionId, UsuarioId),
    CONSTRAINT FK_ConversacionParticipante_Conversacion FOREIGN KEY (ConversacionId) REFERENCES Conversacion(ConversacionId) ON DELETE CASCADE,
    CONSTRAINT FK_ConversacionParticipante_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId)
);

CREATE INDEX IX_ConversacionParticipante_Usuario ON ConversacionParticipante(UsuarioId);

CREATE TABLE Mensaje (
    MensajeId INT PRIMARY KEY IDENTITY(1,1),
    ConversacionId INT NOT NULL,
    RemitenteId INT NOT NULL,
    Contenido NVARCHAR(MAX) NOT NULL,
    Fecha DATETIME2 NOT NULL DEFAULT GETDATE(),
    Leido BIT NOT NULL DEFAULT 0,
    CONSTRAINT FK_Mensaje_Conversacion FOREIGN KEY (ConversacionId) REFERENCES Conversacion(ConversacionId) ON DELETE CASCADE,
    CONSTRAINT FK_Mensaje_Remitente FOREIGN KEY (RemitenteId) REFERENCES Usuario(UsuarioId)
);

CREATE INDEX IX_Mensaje_Conversacion_Fecha ON Mensaje(ConversacionId, Fecha);
CREATE INDEX IX_Mensaje_NoLeidos ON Mensaje(ConversacionId, Leido, RemitenteId);

CREATE TABLE Insignia (
    InsigniaId INT PRIMARY KEY IDENTITY(1,1),
    NombreInsignia NVARCHAR(150),
    Descripcion NVARCHAR(500),
    Requisito NVARCHAR(500),
    Imagen NVARCHAR(500),

    MonedasRecompensa INT DEFAULT 0
);

CREATE UNIQUE INDEX IX_Insignia_NombreInsignia ON Insignia(NombreInsignia);

CREATE TABLE UsuarioInsignia (
    UsuarioInsigniaId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    InsigniaId INT,
    FechaObtencion DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_UsuarioInsignia_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT FK_UsuarioInsignia_Insignia FOREIGN KEY (InsigniaId) REFERENCES Insignia(InsigniaId),
    CONSTRAINT UQ_UsuarioInsignia UNIQUE (UsuarioId, InsigniaId)
);

CREATE INDEX IX_UsuarioInsignia_UsuarioId ON UsuarioInsignia(UsuarioId);




CREATE TABLE HistorialPuntos (
    HistorialId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    CategoriaId INT,
    Puntos INT,
    Tipo NVARCHAR(50),
    Descripcion NVARCHAR(500),
    Fecha DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_HistorialPuntos_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT FK_HistorialPuntos_Categoria FOREIGN KEY (CategoriaId) REFERENCES Categoria(CategoriaId)
);

CREATE INDEX IX_HistorialPuntos_UsuarioId ON HistorialPuntos(UsuarioId);
CREATE INDEX IX_HistorialPuntos_CategoriaId ON HistorialPuntos(CategoriaId);




CREATE TABLE Monedero (
    MonederoId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT NOT NULL,
    Saldo INT NOT NULL DEFAULT 0,
    FechaActualizacion DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Monedero_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT UQ_Monedero_Usuario UNIQUE (UsuarioId),
    CONSTRAINT CK_Monedero_Saldo CHECK (Saldo >= 0)
);

CREATE INDEX IX_Monedero_UsuarioId ON Monedero(UsuarioId);





CREATE TABLE HistorialMonedas (
    HistorialMonedaId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT NOT NULL,
    CategoriaId INT,
    Cantidad INT NOT NULL,
    Tipo NVARCHAR(50) NOT NULL,
    Descripcion NVARCHAR(500) NOT NULL,
    SaldoResultante INT NOT NULL,
    ClaveIdempotencia NVARCHAR(120),
    Fecha DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_HistorialMonedas_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT FK_HistorialMonedas_Categoria FOREIGN KEY (CategoriaId) REFERENCES Categoria(CategoriaId),
    CONSTRAINT CK_HistorialMonedas_Cantidad CHECK (Cantidad <> 0)
);

CREATE INDEX IX_HistorialMonedas_UsuarioId_Fecha ON HistorialMonedas(UsuarioId, Fecha DESC);
CREATE INDEX IX_HistorialMonedas_CategoriaId ON HistorialMonedas(CategoriaId);
CREATE UNIQUE INDEX UX_HistorialMonedas_Idempotencia
ON HistorialMonedas(UsuarioId, ClaveIdempotencia)
WHERE ClaveIdempotencia IS NOT NULL;






CREATE TABLE RecompensaReclamada (
    RecompensaId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT NOT NULL,
    Clave NVARCHAR(120) NOT NULL,
    Tipo NVARCHAR(50) NOT NULL,
    Fecha DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_RecompensaReclamada_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT UQ_RecompensaReclamada UNIQUE (UsuarioId, Clave)
);

CREATE INDEX IX_RecompensaReclamada_UsuarioId ON RecompensaReclamada(UsuarioId);

CREATE TABLE Racha (
    RachaId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    FechaAcceso DATE,
    NumeroRacha INT DEFAULT 1,
    CONSTRAINT FK_Racha_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT UQ_Racha UNIQUE (UsuarioId, FechaAcceso)
);

CREATE INDEX IX_Racha_UsuarioId ON Racha(UsuarioId);

CREATE TABLE Recurso (
    RecursoId INT PRIMARY KEY IDENTITY(1,1),
    CategoriaId INT,
    Titulo NVARCHAR(200),
    Descripcion NVARCHAR(MAX),
    Tipo NVARCHAR(50),
    URL NVARCHAR(500),
    FechaPublicacion DATETIME2 DEFAULT GETDATE(),
    Estado NVARCHAR(50) DEFAULT 'ACTIVO',
    CONSTRAINT FK_Recurso_Categoria FOREIGN KEY (CategoriaId) REFERENCES Categoria(CategoriaId)
);

CREATE INDEX IX_Recurso_CategoriaId ON Recurso(CategoriaId);
CREATE INDEX IX_Recurso_Estado ON Recurso(Estado);

CREATE TABLE Notificacion (
    NotificacionId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    Titulo NVARCHAR(200),
    Mensaje NVARCHAR(MAX),
    Tipo NVARCHAR(50),
    Leida BIT DEFAULT 0,
    Fecha DATETIME2 DEFAULT GETDATE(),


    ReferenciaTipo NVARCHAR(30),
    ReferenciaId INT,

    ActorUsuarioId INT,
    CONSTRAINT FK_Notificacion_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT FK_Notificacion_Actor FOREIGN KEY (ActorUsuarioId) REFERENCES Usuario(UsuarioId)
);

CREATE INDEX IX_Notificacion_UsuarioId ON Notificacion(UsuarioId);
CREATE INDEX IX_Notificacion_Leida ON Notificacion(UsuarioId, Leida);
CREATE INDEX IX_Notificacion_Referencia ON Notificacion(Tipo, ReferenciaId);

CREATE TABLE Progreso (
    ProgresoId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,

    Experiencia INT NOT NULL DEFAULT 0,
    RetosCompletados INT DEFAULT 0,
    TriviasCompletadas INT DEFAULT 0,
    InsigniasObtenidas INT DEFAULT 0,
    PublicacionesRealizadas INT DEFAULT 0,
    MaterialesObtenidos INT DEFAULT 0,
    NivelActual INT DEFAULT 1,
    PorcentajeProgreso DECIMAL(5,2) DEFAULT 0,
    CONSTRAINT FK_Progreso_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT UQ_Progreso_Usuario UNIQUE (UsuarioId)
);

CREATE TABLE Jardin (
    JardinId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    NivelJardin INT DEFAULT 1,
    Plantas INT DEFAULT 0,
    Arboles INT DEFAULT 0,
    Flores INT DEFAULT 0,
    PuntosJardin INT DEFAULT 0,
    CONSTRAINT FK_Jardin_Usuario FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    CONSTRAINT UQ_Jardin_Usuario UNIQUE (UsuarioId)
);

INSERT INTO Rol (NombreRol, Descripcion) VALUES
    ('ESTUDIANTE', 'Rol predeterminado para estudiantes registrados.'),
    ('ADMIN', 'Administrador del sistema con acceso total.');

GO

PRINT 'Base de datos EcoRetos creada correctamente con todas las tablas y datos iniciales.';
GO