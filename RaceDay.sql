/*
    RaceDay Database Script
    Module: Programming 2A (PROGS212)
    Part 1 - System Planning and Database

    Database: RaceDayDB
    The schema is designed to match the ERD and API plan.
*/

IF DB_ID('RaceDayDB') IS NULL
BEGIN
    CREATE DATABASE RaceDayDB;
END;
GO

USE RaceDayDB;
GO

-- Remove tables in dependency order so the script can be tested repeatedly.
IF OBJECT_ID('dbo.Results', 'U') IS NOT NULL DROP TABLE dbo.Results;
IF OBJECT_ID('dbo.Enrollments', 'U') IS NOT NULL DROP TABLE dbo.Enrollments;
IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL DROP TABLE dbo.Events;
IF OBJECT_ID('dbo.Routes', 'U') IS NOT NULL DROP TABLE dbo.Routes;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
GO

CREATE TABLE dbo.Users
(
    UserID INT IDENTITY(1,1) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(120) NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role VARCHAR(20) NOT NULL CONSTRAINT CK_Users_Role
        CHECK (Role IN ('Organiser','Participant')),
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Users PRIMARY KEY (UserID),
    CONSTRAINT UQ_Users_Email UNIQUE (Email)
);
GO

CREATE TABLE dbo.Categories
(
    CategoryID INT IDENTITY(1,1) NOT NULL,
    CategoryName NVARCHAR(80) NOT NULL,
    Description NVARCHAR(255) NULL,

    CONSTRAINT PK_Categories PRIMARY KEY (CategoryID),
    CONSTRAINT UQ_Categories_CategoryName UNIQUE (CategoryName)
);
GO

CREATE TABLE dbo.Routes
(
    RouteID INT IDENTITY(1,1) NOT NULL,
    RouteName NVARCHAR(100) NOT NULL,
    StartLocation NVARCHAR(150) NOT NULL,
    FinishLocation NVARCHAR(150) NOT NULL,
    DistanceKm DECIMAL(6,2) NOT NULL,
    ElevationGainM INT NOT NULL CONSTRAINT DF_Routes_ElevationGainM DEFAULT 0,

    CONSTRAINT PK_Routes PRIMARY KEY (RouteID),
    CONSTRAINT CK_Routes_DistanceKm CHECK (DistanceKm > 0),
    CONSTRAINT CK_Routes_ElevationGainM CHECK (ElevationGainM >= 0)
);
GO

CREATE TABLE dbo.Events
(
    EventID INT IDENTITY(1,1) NOT NULL,
    EventName NVARCHAR(120) NOT NULL,
    EventDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    Location NVARCHAR(150) NOT NULL,
    Capacity INT NOT NULL,
    Status VARCHAR(20) NOT NULL CONSTRAINT DF_Events_Status DEFAULT 'Open',
    OrganizerID INT NOT NULL,
    CategoryID INT NOT NULL,
    RouteID INT NOT NULL,
    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Events_CreatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Events PRIMARY KEY (EventID),
    CONSTRAINT CK_Events_Capacity CHECK (Capacity > 0),
    CONSTRAINT CK_Events_Status CHECK (Status IN ('Open','Closed','Cancelled')),
    CONSTRAINT FK_Events_Organizer FOREIGN KEY (OrganizerID)
        REFERENCES dbo.Users(UserID),
    CONSTRAINT FK_Events_Category FOREIGN KEY (CategoryID)
        REFERENCES dbo.Categories(CategoryID),
    CONSTRAINT FK_Events_Route FOREIGN KEY (RouteID)
        REFERENCES dbo.Routes(RouteID)
);
GO

CREATE TABLE dbo.Enrollments
(
    EnrollmentID INT IDENTITY(1,1) NOT NULL,
    ParticipantID INT NOT NULL,
    EventID INT NOT NULL,
    EnrollmentDate DATETIME2 NOT NULL CONSTRAINT DF_Enrollments_EnrollmentDate DEFAULT SYSDATETIME(),
    Status VARCHAR(20) NOT NULL CONSTRAINT DF_Enrollments_Status DEFAULT 'Active',
    BibNumber INT NULL,

    CONSTRAINT PK_Enrollments PRIMARY KEY (EnrollmentID),
    CONSTRAINT UQ_Enrollments_ParticipantEvent UNIQUE (ParticipantID, EventID),
    CONSTRAINT UQ_Enrollments_BibNumber UNIQUE (BibNumber),
    CONSTRAINT CK_Enrollments_Status CHECK (Status IN ('Active','Cancelled','Completed')),
    CONSTRAINT CK_Enrollments_BibNumber CHECK (BibNumber IS NULL OR BibNumber > 0),
    CONSTRAINT FK_Enrollments_Participant FOREIGN KEY (ParticipantID)
        REFERENCES dbo.Users(UserID),
    CONSTRAINT FK_Enrollments_Event FOREIGN KEY (EventID)
        REFERENCES dbo.Events(EventID)
);
GO

CREATE TABLE dbo.Results
(
    ResultID INT IDENTITY(1,1) NOT NULL,
    EnrollmentID INT NOT NULL,
    FinishTime TIME NOT NULL,
    Position INT NOT NULL,
    RecordedAt DATETIME2 NOT NULL CONSTRAINT DF_Results_RecordedAt DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Results PRIMARY KEY (ResultID),
    CONSTRAINT UQ_Results_Enrollment UNIQUE (EnrollmentID),
    CONSTRAINT CK_Results_Position CHECK (Position > 0),
    CONSTRAINT FK_Results_Enrollment FOREIGN KEY (EnrollmentID)
        REFERENCES dbo.Enrollments(EnrollmentID)
);
GO

/*
    Sample data
    Minimum required by the brief:
    - 2 Organisers
    - 2 Participants
    - 3 Events
    - categories for each event
    - sample enrolments
*/

INSERT INTO dbo.Users (FirstName, LastName, Email, PasswordHash, Role)
VALUES
('Thabo', 'Mokoena', 'thabo.organiser@raceday.test', 'HASHED_PASSWORD_1', 'Organiser'),
('Lerato', 'Dlamini', 'lerato.organiser@raceday.test', 'HASHED_PASSWORD_2', 'Organiser'),
('Anele', 'Mokoena', 'anele.participant@raceday.test', 'HASHED_PASSWORD_3', 'Participant'),
('Sipho', 'Nkosi', 'sipho.participant@raceday.test', 'HASHED_PASSWORD_4', 'Participant');
GO

INSERT INTO dbo.Categories (CategoryName, Description)
VALUES
('5 KM Fun Run', 'Short community running event'),
('10 KM Road Race', 'Competitive 10 kilometre road race'),
('21 KM Half Marathon', 'Half marathon road running event');
GO

INSERT INTO dbo.Routes (RouteName, StartLocation, FinishLocation, DistanceKm, ElevationGainM)
VALUES
('Pretoria Central 5K', 'Church Square', 'Church Square', 5.00, 45),
('Pretoria East 10K', 'Menlyn Park', 'Menlyn Park', 10.00, 120),
('Tshwane Half Marathon', 'Union Buildings', 'Union Buildings', 21.10, 210);
GO

INSERT INTO dbo.Events
    (EventName, EventDate, StartTime, Location, Capacity, Status, OrganizerID, CategoryID, RouteID)
VALUES
('Pretoria Spring Fun Run', '2026-10-10', '07:00', 'Pretoria Central', 500, 'Open', 1, 1, 1),
('Tshwane 10K Road Race', '2026-10-24', '06:30', 'Pretoria East', 800, 'Open', 2, 2, 2),
('Capital City Half Marathon', '2026-11-14', '06:00', 'Union Buildings', 1000, 'Open', 1, 3, 3);
GO

INSERT INTO dbo.Enrollments
    (ParticipantID, EventID, EnrollmentDate, Status, BibNumber)
VALUES
(3, 1, '2026-09-01T10:00:00', 'Active', 101),
(3, 2, '2026-09-01T10:15:00', 'Active', 102),
(4, 2, '2026-09-01T11:00:00', 'Active', 103),
(4, 3, '2026-09-01T11:20:00', 'Active', 104);
GO

INSERT INTO dbo.Results (EnrollmentID, FinishTime, Position)
VALUES
(1, '00:31:42', 25),
(2, '01:02:34', 12);
GO

-- Quick checks for testing in SSMS
SELECT * FROM dbo.Users;
SELECT * FROM dbo.Categories;
SELECT * FROM dbo.Routes;
SELECT * FROM dbo.Events;
SELECT * FROM dbo.Enrollments;
SELECT * FROM dbo.Results;
GO
