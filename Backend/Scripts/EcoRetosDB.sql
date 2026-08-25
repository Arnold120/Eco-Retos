USE master
GO

CREATE DATABASE EcoRetos
GO

USE EcoRetos
GO

CREATE TABLE Usuario (
    UsuarioId INT PRIMARY KEY IDENTITY(1,1),
    NombreUsuario NVARCHAR(200),
    Correo NVARCHAR(200) UNIQUE,
    Contrasena NVARCHAR(255),
    Salt VARBINARY(256),
    FechaRegistro DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE Rol (
    RolId INT PRIMARY KEY IDENTITY(1,1),
    NombreRol NVARCHAR(100) UNIQUE,
    Descripcion NVARCHAR(300)
);

CREATE TABLE UsuarioRol (
    UsuarioRolId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    RolId INT,
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    FOREIGN KEY (RolId) REFERENCES Rol(RolId),
    UNIQUE (UsuarioId, RolId)
);

CREATE TABLE Perfil (
    PerfilId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT UNIQUE,
    Nombre NVARCHAR(100),
    Apellido NVARCHAR(100),
    Carnet NVARCHAR(50),
    CentroEducativo NVARCHAR(200),
    Grado NVARCHAR(100),
    FotoPerfil NVARCHAR(500),
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId)
);

CREATE TABLE Categoria (
    CategoriaId INT PRIMARY KEY IDENTITY(1,1),
    NombreCategoria NVARCHAR(150) UNIQUE,
    Descripcion NVARCHAR(500)
);

CREATE TABLE Reto (
    RetoId INT PRIMARY KEY IDENTITY(1,1),
    CategoriaId INT,
    Titulo NVARCHAR(200),
    Descripcion NVARCHAR(MAX),
    Instrucciones NVARCHAR(MAX),
    Puntos INT DEFAULT 0,
    Dificultad NVARCHAR(50),
    FechaInicio DATETIME2,
    FechaFin DATETIME2,
    Estado NVARCHAR(50) DEFAULT 'ACTIVO',
    FOREIGN KEY (CategoriaId) REFERENCES Categoria(CategoriaId)
);

CREATE TABLE UsuarioReto (
    UsuarioRetoId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    RetoId INT,
    Estado NVARCHAR(50) DEFAULT 'INICIADO',
    Evidencia NVARCHAR(500),
    PuntosObtenidos INT DEFAULT 0,
    FechaInicio DATETIME2 DEFAULT GETDATE(),
    FechaCompletado DATETIME2,
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    FOREIGN KEY (RetoId) REFERENCES Reto(RetoId),
    UNIQUE (UsuarioId, RetoId)
);

CREATE TABLE Trivia (
    TriviaId INT PRIMARY KEY IDENTITY(1,1),
    CategoriaId INT,
    Titulo NVARCHAR(200),
    Descripcion NVARCHAR(MAX),
    Dificultad NVARCHAR(50),
    PuntosMaximos INT DEFAULT 0,
    Estado NVARCHAR(50) DEFAULT 'ACTIVA',
    FOREIGN KEY (CategoriaId) REFERENCES Categoria(CategoriaId)
);

CREATE TABLE Pregunta (
    PreguntaId INT PRIMARY KEY IDENTITY(1,1),
    TriviaId INT,
    PreguntaTexto NVARCHAR(MAX),
    Puntos INT DEFAULT 1,
    FOREIGN KEY (TriviaId) REFERENCES Trivia(TriviaId)
);

CREATE TABLE OpcionRespuesta (
    OpcionId INT PRIMARY KEY IDENTITY(1,1),
    PreguntaId INT,
    TextoOpcion NVARCHAR(500),
    EsCorrecta BIT DEFAULT 0,
    FOREIGN KEY (PreguntaId) REFERENCES Pregunta(PreguntaId)
);

CREATE TABLE IntentoTrivia (
    IntentoId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    TriviaId INT,
    Puntuacion INT DEFAULT 0,
    FechaInicio DATETIME2 DEFAULT GETDATE(),
    FechaFinalizacion DATETIME2,
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    FOREIGN KEY (TriviaId) REFERENCES Trivia(TriviaId)
);

CREATE TABLE RespuestaUsuario (
    RespuestaId INT PRIMARY KEY IDENTITY(1,1),
    IntentoId INT,
    PreguntaId INT,
    OpcionId INT,
    EsCorrecta BIT DEFAULT 0,
    FOREIGN KEY (IntentoId) REFERENCES IntentoTrivia(IntentoId),
    FOREIGN KEY (PreguntaId) REFERENCES Pregunta(PreguntaId),
    FOREIGN KEY (OpcionId) REFERENCES OpcionRespuesta(OpcionId)
);

CREATE TABLE Material (
    MaterialId INT PRIMARY KEY IDENTITY(1,1),
    NombreMaterial NVARCHAR(150),
    Descripcion NVARCHAR(500),
    Tipo NVARCHAR(100),
    PrecioPuntos INT DEFAULT 0,
    CantidadDisponible INT DEFAULT 0,
    Imagen NVARCHAR(500),
    Estado NVARCHAR(50) DEFAULT 'DISPONIBLE'
);

CREATE TABLE Inventario (
    InventarioId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    MaterialId INT,
    Cantidad INT DEFAULT 0,
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    FOREIGN KEY (MaterialId) REFERENCES Material(MaterialId),
    UNIQUE (UsuarioId, MaterialId)
);

CREATE TABLE Compra (
    CompraId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    TotalPuntos INT,
    FechaCompra DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId)
);

CREATE TABLE DetalleCompra (
    DetalleCompraId INT PRIMARY KEY IDENTITY(1,1),
    CompraId INT,
    MaterialId INT,
    Cantidad INT,
    PrecioUnitario INT,
    FOREIGN KEY (CompraId) REFERENCES Compra(CompraId),
    FOREIGN KEY (MaterialId) REFERENCES Material(MaterialId)
);

CREATE TABLE Publicacion (
    PublicacionId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    Contenido NVARCHAR(MAX),
    Imagen NVARCHAR(500),
    Tipo NVARCHAR(50) DEFAULT 'GENERAL',
    FechaPublicacion DATETIME2 DEFAULT GETDATE(),
    Estado NVARCHAR(50) DEFAULT 'PUBLICADA',
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId)
);

CREATE TABLE Comentario (
    ComentarioId INT PRIMARY KEY IDENTITY(1,1),
    PublicacionId INT,
    UsuarioId INT,
    ComentarioTexto NVARCHAR(MAX),
    FechaComentario DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (PublicacionId) REFERENCES Publicacion(PublicacionId),
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId)
);

CREATE TABLE Insignia (
    InsigniaId INT PRIMARY KEY IDENTITY(1,1),
    NombreInsignia NVARCHAR(150) UNIQUE,
    Descripcion NVARCHAR(500),
    Requisito NVARCHAR(500),
    Imagen NVARCHAR(500),
    PuntosRecompensa INT DEFAULT 0
);

CREATE TABLE UsuarioInsignia (
    UsuarioInsigniaId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    InsigniaId INT,
    FechaObtencion DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    FOREIGN KEY (InsigniaId) REFERENCES Insignia(InsigniaId),
    UNIQUE (UsuarioId, InsigniaId)
);

CREATE TABLE HistorialPuntos (
    HistorialId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    Puntos INT,
    Tipo NVARCHAR(50),
    Descripcion NVARCHAR(500),
    Fecha DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId)
);

CREATE TABLE Racha (
    RachaId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    FechaAcceso DATE,
    NumeroRacha INT DEFAULT 1,
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId),
    UNIQUE (UsuarioId, FechaAcceso)
);

CREATE TABLE Recurso (
    RecursoId INT PRIMARY KEY IDENTITY(1,1),
    CategoriaId INT,
    Titulo NVARCHAR(200),
    Descripcion NVARCHAR(MAX),
    Tipo NVARCHAR(50),
    URL NVARCHAR(500),
    FechaPublicacion DATETIME2 DEFAULT GETDATE(),
    Estado NVARCHAR(50) DEFAULT 'ACTIVO',
    FOREIGN KEY (CategoriaId) REFERENCES Categoria(CategoriaId)
);

CREATE TABLE Notificacion (
    NotificacionId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT,
    Titulo NVARCHAR(200),
    Mensaje NVARCHAR(MAX),
    Tipo NVARCHAR(50),
    Leida BIT DEFAULT 0,
    Fecha DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId)
);

CREATE TABLE Progreso (
    ProgresoId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT UNIQUE,
    RetosCompletados INT DEFAULT 0,
    TriviasCompletadas INT DEFAULT 0,
    InsigniasObtenidas INT DEFAULT 0,
    PublicacionesRealizadas INT DEFAULT 0,
    MaterialesObtenidos INT DEFAULT 0,
    NivelActual INT DEFAULT 1,
    PorcentajeProgreso DECIMAL(5,2) DEFAULT 0,
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId)
);

CREATE TABLE Jardin (
    JardinId INT PRIMARY KEY IDENTITY(1,1),
    UsuarioId INT UNIQUE,
    NivelJardin INT DEFAULT 1,
    Plantas INT DEFAULT 0,
    Arboles INT DEFAULT 0,
    Flores INT DEFAULT 0,
    PuntosJardin INT DEFAULT 0,
    FOREIGN KEY (UsuarioId) REFERENCES Usuario(UsuarioId)
);