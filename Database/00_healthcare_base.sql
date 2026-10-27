IF DB_ID('Healthcare') IS NULL CREATE DATABASE Healthcare;
GO
USE Healthcare;
GO
CREATE TABLE Member(
    MemberId NVARCHAR(32) NOT NULL PRIMARY KEY,
    GivenName NVARCHAR(16) NOT NULL,
    Surname NVARCHAR(16),
    Email NVARCHAR(64) NOT NULL UNIQUE,
    Password NVARCHAR(128) NOT NULL,
    Role SMALLINT NOT NULL DEFAULT 0
);
GO
CREATE PROC AddMember(
    @MemberId NVARCHAR(32),
    @GivenName NVARCHAR(16),
    @Surname NVARCHAR(16),
    @Email NVARCHAR(64),
    @Password NVARCHAR(128),
    @Role SMALLINT
)
AS
    IF NOT EXISTS(SELECT * FROM Member WHERE MemberId = @MemberId OR Email = @Email)
        INSERT INTO Member(MemberId, GivenName, Surname, Email, Password, Role) VALUES
        (@MemberId, @GivenName, @Surname, @Email, @Password, @Role);
GO