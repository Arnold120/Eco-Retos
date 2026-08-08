
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'EcoRetosDB')
    CREATE DATABASE EcoRetosDB;
GO

USE EcoRetosDB;
GO

IF OBJECT_ID('dbo.UserAchievements', 'U') IS NOT NULL DROP TABLE dbo.UserAchievements;
IF OBJECT_ID('dbo.Achievements', 'U') IS NOT NULL DROP TABLE dbo.Achievements;
IF OBJECT_ID('dbo.AuditLog', 'U') IS NOT NULL DROP TABLE dbo.AuditLog;
IF OBJECT_ID('dbo.Posts', 'U') IS NOT NULL DROP TABLE dbo.Posts;
IF OBJECT_ID('dbo.VirtualGarden', 'U') IS NOT NULL DROP TABLE dbo.VirtualGarden;
IF OBJECT_ID('dbo.PlantShop', 'U') IS NOT NULL DROP TABLE dbo.PlantShop;
IF OBJECT_ID('dbo.Plants', 'U') IS NOT NULL DROP TABLE dbo.Plants;
IF OBJECT_ID('dbo.UserTrivia', 'U') IS NOT NULL DROP TABLE dbo.UserTrivia;
IF OBJECT_ID('dbo.Trivia', 'U') IS NOT NULL DROP TABLE dbo.Trivia;
IF OBJECT_ID('dbo.UserRetos', 'U') IS NOT NULL DROP TABLE dbo.UserRetos;
IF OBJECT_ID('dbo.Retos', 'U') IS NOT NULL DROP TABLE dbo.Retos;
IF OBJECT_ID('dbo.LoginStreak', 'U') IS NOT NULL DROP TABLE dbo.LoginStreak;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
GO


CREATE TABLE dbo.Users (
    UserId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(MAX) NOT NULL,  
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    ProfileImageUrl NVARCHAR(500),
    Bio NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE(),
    LastLoginAt DATETIME2 NULL,
    
    INDEX IX_Email (Email),
    INDEX IX_Username (Username)
);
GO

CREATE TABLE dbo.LoginStreak (
    StreakId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL UNIQUE,
    CurrentStreak INT DEFAULT 0,
    LongestStreak INT DEFAULT 0,
    LastLoginDate DATE NULL,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 DEFAULT GETUTCDATE(),
    
    FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    INDEX IX_UserId (UserId)
);
GO

CREATE TABLE dbo.Retos (
    RetoId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX),
    Category NVARCHAR(50) NOT NULL,
    Difficulty NVARCHAR(20) DEFAULT 'MEDIO',  
    RewardPoints INT DEFAULT 100,  
    RewardCoins INT DEFAULT 2,    
    ImageUrl NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    
    INDEX IX_Category (Category),
    INDEX IX_Difficulty (Difficulty),
    INDEX IX_IsActive (IsActive)
);
GO


CREATE TABLE dbo.UserRetos (
    UserRetoId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL,
    RetoId UNIQUEIDENTIFIER NOT NULL,
    IsCompleted BIT DEFAULT 0,
    CompletedDate DATETIME2 NULL,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    
    FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    FOREIGN KEY (RetoId) REFERENCES dbo.Retos(RetoId) ON DELETE CASCADE,
    UNIQUE (UserId, RetoId),
    INDEX IX_UserId (UserId),
    INDEX IX_IsCompleted (IsCompleted)
);
GO

CREATE TABLE dbo.Trivia (
    TriviaId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Question NVARCHAR(500) NOT NULL,
    OptionA NVARCHAR(200) NOT NULL,
    OptionB NVARCHAR(200) NOT NULL,
    OptionC NVARCHAR(200) NOT NULL,
    OptionD NVARCHAR(200) NOT NULL,
    CorrectAnswer CHAR(1) NOT NULL,  
    Difficulty NVARCHAR(20) NOT NULL,  
    GroupLetter CHAR(1) NOT NULL,  
    RewardPoints INT NOT NULL,  
    RewardCoins INT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    
    INDEX IX_Difficulty (Difficulty),
    INDEX IX_Group (GroupLetter)
);
GO

CREATE TABLE dbo.UserTrivia (
    UserTriviaId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL,
    TriviaId UNIQUEIDENTIFIER NOT NULL,
    UserAnswer CHAR(1) NULL,
    IsCorrect BIT DEFAULT 0,
    AnsweredDate DATETIME2 DEFAULT GETUTCDATE(),
    
    FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    FOREIGN KEY (TriviaId) REFERENCES dbo.Trivia(TriviaId) ON DELETE CASCADE,
    INDEX IX_UserId (UserId),
    INDEX IX_IsCorrect (IsCorrect)
);
GO


CREATE TABLE dbo.Plants (
    PlantId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    ImageUrlStage1 NVARCHAR(500),  
    ImageUrlStage2 NVARCHAR(500),  
    ImageUrlStage3 NVARCHAR(500),  
    ImageUrlStage4 NVARCHAR(500), 
    GrowthDaysPerStage INT DEFAULT 7,
    RarityTier NVARCHAR(20) DEFAULT 'COMMON',  
    EnvironmentalFact NVARCHAR(MAX),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    
    INDEX IX_RarityTier (RarityTier)
);
GO


CREATE TABLE dbo.VirtualGarden (
    GardenPlantId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL,
    PlantId UNIQUEIDENTIFIER NOT NULL,
    CurrentStage INT DEFAULT 1,  
    Health INT DEFAULT 100,  
    IsAlive BIT DEFAULT 1,
    PlantedDate DATETIME2 DEFAULT GETUTCDATE(),
    LastWateredDate DATETIME2 DEFAULT GETUTCDATE(),
    HarvestedDate DATETIME2 NULL,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    
    FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    FOREIGN KEY (PlantId) REFERENCES dbo.Plants(PlantId),
    INDEX IX_UserId (UserId),
    INDEX IX_IsAlive (IsAlive)
);
GO


CREATE TABLE dbo.PlantShop (
    ShopItemId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    PlantId UNIQUEIDENTIFIER NOT NULL UNIQUE,
    CostCoins INT NOT NULL,
    Availability NVARCHAR(20) DEFAULT 'AVAILABLE',
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    
    FOREIGN KEY (PlantId) REFERENCES dbo.Plants(PlantId),
    INDEX IX_Availability (Availability)
);
GO


CREATE TABLE dbo.Achievements (
    AchievementId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Title NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    BadgeImageUrl NVARCHAR(500),
    Type NVARCHAR(50),  
    Requirement INT,  
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);
GO


CREATE TABLE dbo.UserAchievements (
    UserAchievementId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL,
    AchievementId UNIQUEIDENTIFIER NOT NULL,
    UnlockedDate DATETIME2 DEFAULT GETUTCDATE(),
    
    FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    FOREIGN KEY (AchievementId) REFERENCES dbo.Achievements(AchievementId),
    UNIQUE (UserId, AchievementId),
    INDEX IX_UserId (UserId)
);
GO


CREATE TABLE dbo.Posts (
    PostId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    UserId UNIQUEIDENTIFIER NOT NULL,
    Content NVARCHAR(MAX) NOT NULL,
    Likes INT DEFAULT 0,
    Comments INT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    
    FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    INDEX IX_UserId (UserId),
    INDEX IX_CreatedAt (CreatedAt)
);
GO


CREATE TABLE dbo.AuditLog (
    AuditId BIGINT PRIMARY KEY IDENTITY(1,1),
    UserId UNIQUEIDENTIFIER,
    Action NVARCHAR(100),
    TableName NVARCHAR(100),
    RecordId UNIQUEIDENTIFIER,
    OldValue NVARCHAR(MAX),
    NewValue NVARCHAR(MAX),
    IpAddress NVARCHAR(50),
    CreatedAt DATETIME2 DEFAULT GETUTCDATE(),
    
    INDEX IX_UserId (UserId),
    INDEX IX_CreatedAt (CreatedAt)
);
GO


CREATE PROCEDURE dbo.sp_RegisterUser
    @Username NVARCHAR(50),
    @Email NVARCHAR(100),
    @PasswordHash NVARCHAR(MAX),
    @FirstName NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @UserId UNIQUEIDENTIFIER = NEWID();
        
        IF EXISTS (SELECT 1 FROM dbo.Users WHERE Email = @Email OR Username = @Username)
            THROW 51000, 'Email or Username already exists', 1;
        
        INSERT INTO dbo.Users (UserId, Username, Email, PasswordHash, FirstName, CreatedAt)
        VALUES (@UserId, @Username, @Email, @PasswordHash, @FirstName, GETUTCDATE());
        
        INSERT INTO dbo.LoginStreak (StreakId, UserId, CurrentStreak, LongestStreak)
        VALUES (NEWID(), @UserId, 0, 0);
        
        COMMIT TRANSACTION;
        SELECT @UserId AS UserId;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO


CREATE PROCEDURE dbo.sp_GetUserByEmail
    @Email NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        UserId, Username, Email, PasswordHash, FirstName, LastName,
        ProfileImageUrl, IsActive, CreatedAt, LastLoginAt
    FROM dbo.Users
    WHERE Email = @Email AND IsActive = 1;
END;
GO


CREATE PROCEDURE dbo.sp_UpdateLoginStreak
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @LastLoginDate DATE = (SELECT CAST(LastLoginDate AS DATE) FROM dbo.LoginStreak WHERE UserId = @UserId);
    DECLARE @TodayDate DATE = CAST(GETUTCDATE() AS DATE);
    DECLARE @NewStreak INT;
    
   
    SET @NewStreak = CASE 
        WHEN @LastLoginDate IS NULL THEN 1
        WHEN DATEDIFF(DAY, @LastLoginDate, @TodayDate) = 1 THEN (SELECT CurrentStreak FROM dbo.LoginStreak WHERE UserId = @UserId) + 1
        WHEN DATEDIFF(DAY, @LastLoginDate, @TodayDate) > 1 THEN 1
        ELSE (SELECT CurrentStreak FROM dbo.LoginStreak WHERE UserId = @UserId)
    END;
    
    UPDATE dbo.LoginStreak
    SET 
        CurrentStreak = @NewStreak,
        LongestStreak = CASE WHEN @NewStreak > LongestStreak THEN @NewStreak ELSE LongestStreak END,
        LastLoginDate = @TodayDate,
        UpdatedAt = GETUTCDATE()
    WHERE UserId = @UserId;
    
    UPDATE dbo.Users
    SET LastLoginAt = GETUTCDATE(), UpdatedAt = GETUTCDATE()
    WHERE UserId = @UserId;
END;
GO


CREATE PROCEDURE dbo.sp_CompleteReto
    @UserId UNIQUEIDENTIFIER,
    @RetoId UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @RewardPoints INT, @RewardCoins INT;
        DECLARE @RetoCount INT;
        
        SELECT @RewardPoints = RewardPoints, @RewardCoins = RewardCoins 
        FROM dbo.Retos 
        WHERE RetoId = @RetoId;
        
       
        INSERT INTO dbo.UserRetos (UserId, RetoId, IsCompleted, CompletedDate)
        VALUES (@UserId, @RetoId, 1, GETUTCDATE());
        
     
        INSERT INTO dbo.AuditLog (UserId, Action, TableName, RecordId, NewValue, CreatedAt)
        VALUES (@UserId, 'RETO_COMPLETED', 'Retos', @RetoId, 
                'Points: ' + CAST(@RewardPoints AS NVARCHAR) + ', Coins: ' + CAST(@RewardCoins AS NVARCHAR), 
                GETUTCDATE());
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO


CREATE PROCEDURE dbo.sp_AnswerTrivia
    @UserId UNIQUEIDENTIFIER,
    @TriviaId UNIQUEIDENTIFIER,
    @UserAnswer CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CorrectAnswer CHAR(1), @IsCorrect BIT, @RewardPoints INT;
    
    SELECT @CorrectAnswer = CorrectAnswer, @RewardPoints = RewardPoints 
    FROM dbo.Trivia 
    WHERE TriviaId = @TriviaId;
    
    SET @IsCorrect = CASE WHEN @UserAnswer = @CorrectAnswer THEN 1 ELSE 0 END;
    
    INSERT INTO dbo.UserTrivia (UserId, TriviaId, UserAnswer, IsCorrect, AnsweredDate)
    VALUES (@UserId, @TriviaId, @UserAnswer, @IsCorrect, GETUTCDATE());
    
    SELECT @IsCorrect AS IsCorrect, 
           @RewardPoints AS RewardPoints,
           @CorrectAnswer AS CorrectAnswer;
END;
GO

INSERT INTO dbo.Plants (PlantId, Name, GrowthDaysPerStage, RarityTier)
VALUES
    (NEWID(), 'Suculenta', 7, 'COMMON'),
    (NEWID(), 'Flor Eco', 8, 'COMMON'),
    (NEWID(), 'Helecho', 9, 'RARE'),
    (NEWID(), 'Arbusto', 10, 'RARE'),
    (NEWID(), 'Árbol pequeño', 12, 'LEGENDARY');
GO


INSERT INTO dbo.Retos (RetoId, Title, Description, Difficulty, RewardPoints, RewardCoins, IsActive)
VALUES
    (NEWID(), 'Carrito con botella', 'Construye un carrito ecológico', 'MEDIO', 120, 2, 1),
    (NEWID(), 'Maceta reciclada', 'Crea una maceta de botella', 'FACIL', 100, 1, 1),
    (NEWID(), 'Portalápices', 'Organizador con botellas', 'FACIL', 90, 1, 1),
    (NEWID(), 'Molino decorativo', 'Molino con CD viejo', 'DIFICIL', 180, 3, 1),
    (NEWID(), 'Casa para plantas', 'Casa maceta con Tetra Pak', 'DIFICIL', 200, 3, 1),
    (NEWID(), 'Comedero de aves', 'Comedero para pájaros', 'MEDIO', 160, 2, 1),
    (NEWID(), 'Organizador escritorio', 'Organizador de cartón', 'MEDIO', 140, 2, 1);
GO


INSERT INTO dbo.Trivia (TriviaId, Question, OptionA, OptionB, OptionC, OptionD, CorrectAnswer, Difficulty, GroupLetter, RewardPoints, RewardCoins)
VALUES
    (NEWID(), '¿Qué material se puede reciclar fácilmente?', 'Botella plástica', 'Comida dañada', 'Papel sucio', 'Aceite usado', 'A', 'facil', 'A', 10, 1),
    (NEWID(), '¿Cuál acción ayuda al ambiente?', 'Tirar basura', 'Separar residuos', 'Quemar plástico', 'Usar más bolsas', 'B', 'facil', 'A', 10, 1),
    (NEWID(), '¿Qué debemos hacer con botellas vacías?', 'Reutilizarla', 'Botarla en calle', 'Quemarla', 'Enterrarla', 'A', 'facil', 'A', 10, 1),
    (NEWID(), '¿Qué hábito ahorra agua?', 'Cerrar el grifo', 'Lavar con manguera', 'Dejar el grifo abierto', 'Usar agua sin control', 'A', 'facil', 'A', 10, 1),
    (NEWID(), '¿Cuál es residuo orgánico?', 'Cáscara de fruta', 'Botella plástica', 'Lata', 'Vidrio', 'A', 'facil', 'A', 10, 1);
GO

