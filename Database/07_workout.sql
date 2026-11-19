USE Healthcare;
GO

IF OBJECT_ID('Exercise', 'U') IS NULL
BEGIN
    CREATE TABLE Exercise(
        ExerciseId INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
        ExerciseName NVARCHAR(100) NOT NULL,
        Description NVARCHAR(512) NULL,
        MuscleGroup NVARCHAR(64) NULL,
        CaloriesPerMinute DECIMAL(8, 2) NOT NULL CHECK (CaloriesPerMinute >= 0),
        IsActive BIT NOT NULL CONSTRAINT DF_Exercise_IsActive DEFAULT 1,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_Exercise_CreatedAt DEFAULT SYSDATETIME()
    );
END
GO

IF OBJECT_ID('WorkoutLog', 'U') IS NULL
BEGIN
    CREATE TABLE WorkoutLog(
        WorkoutLogId INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
        MemberId NVARCHAR(32) NOT NULL REFERENCES Member(MemberId),
        ExerciseId INT NOT NULL REFERENCES Exercise(ExerciseId),
        WorkoutDate DATE NOT NULL,
        DurationMinutes SMALLINT NOT NULL CHECK (DurationMinutes > 0),
        CaloriesBurned DECIMAL(10, 2) NOT NULL,
        Note NVARCHAR(256) NULL,
        CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_WorkoutLog_CreatedAt DEFAULT SYSDATETIME()
    );
    CREATE INDEX IX_WorkoutLog_Member_WorkoutDate ON WorkoutLog(MemberId, WorkoutDate);
END
GO

IF NOT EXISTS (SELECT 1 FROM Exercise WHERE ExerciseName = N'Đi bộ')
    INSERT INTO Exercise(ExerciseName, Description, MuscleGroup, CaloriesPerMinute)
    VALUES (N'Đi bộ', N'Bài tập đi bộ với cường độ vừa phải.', N'Toàn thân', 3.50);
IF NOT EXISTS (SELECT 1 FROM Exercise WHERE ExerciseName = N'Đạp xe')
    INSERT INTO Exercise(ExerciseName, Description, MuscleGroup, CaloriesPerMinute)
    VALUES (N'Đạp xe', N'Bài tập đạp xe với cường độ vừa phải.', N'Chân', 6.00);
IF NOT EXISTS (SELECT 1 FROM Exercise WHERE ExerciseName = N'Chạy bộ')
    INSERT INTO Exercise(ExerciseName, Description, MuscleGroup, CaloriesPerMinute)
    VALUES (N'Chạy bộ', N'Bài tập chạy bộ với cường độ vừa phải.', N'Toàn thân', 8.00);
GO
