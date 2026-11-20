USE Healthcare;
GO

-- 1. Danh mục loại chỉ số sức khỏe (Admin quản lý)
IF OBJECT_ID('HealthMetricType', 'U') IS NULL
BEGIN
    CREATE TABLE HealthMetricType(
        MetricTypeId SMALLINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        MetricCode NVARCHAR(32) NOT NULL UNIQUE,
        MetricName NVARCHAR(64) NOT NULL,
        Unit NVARCHAR(32) NOT NULL,
        MinNormal DECIMAL(8,2) NULL,
        MaxNormal DECIMAL(8,2) NULL,
        Description NVARCHAR(256) NOT NULL DEFAULT N''
    );

    INSERT INTO HealthMetricType (MetricCode, MetricName, Unit, MinNormal, MaxNormal, Description) VALUES
    (N'WEIGHT', N'Cân nặng', N'kg', 40.00, 100.00, N'Cân nặng cơ thể dùng để theo dõi thể trạng và tính BMI'),
    (N'BLOOD_PRESSURE', N'Huyết áp', N'mmHg', 90.00, 120.00, N'Chỉ số huyết áp tâm thu / tâm trương'),
    (N'HEART_RATE', N'Nhịp tim', N'bpm', 60.00, 100.00, N'Nhịp tim lúc nghỉ ngơi (nhịp/phút)'),
    (N'BLOOD_SUGAR', N'Đường huyết', N'mmol/L', 3.90, 5.60, N'Chỉ số đường huyết lúc đói');
END
GO

-- 2. Hồ sơ sức khỏe cá nhân của thành viên
IF OBJECT_ID('HealthProfile', 'U') IS NULL
BEGIN
    CREATE TABLE HealthProfile(
        MemberId NVARCHAR(32) NOT NULL PRIMARY KEY,
        HeightCm DECIMAL(5,2) NULL,
        DateOfBirth DATE NULL,
        Gender SMALLINT NOT NULL DEFAULT 0,
        BloodType NVARCHAR(8) NULL,
        MedicalHistory NVARCHAR(512) NULL,
        UpdatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_HealthProfile_Member FOREIGN KEY (MemberId) REFERENCES Member(MemberId) ON DELETE CASCADE
    );
END
GO

-- 3. Nhật ký chỉ số sức khỏe theo ngày
IF OBJECT_ID('HealthRecord', 'U') IS NULL
BEGIN
    CREATE TABLE HealthRecord(
        RecordId INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        MemberId NVARCHAR(32) NOT NULL,
        MetricTypeId SMALLINT NOT NULL,
        Value DECIMAL(8,2) NOT NULL,
        SecondaryValue DECIMAL(8,2) NULL,
        MeasuredAt DATETIME NOT NULL DEFAULT GETDATE(),
        Note NVARCHAR(256) NULL,
        CONSTRAINT FK_HealthRecord_Member FOREIGN KEY (MemberId) REFERENCES Member(MemberId) ON DELETE CASCADE,
        CONSTRAINT FK_HealthRecord_MetricType FOREIGN KEY (MetricTypeId) REFERENCES HealthMetricType(MetricTypeId)
    );
    CREATE INDEX IX_HealthRecord_Member_Date ON HealthRecord(MemberId, MeasuredAt DESC);
END
GO

-- Stored Procedure xóa loại chỉ số (giống DeleteMedicineCategory)
IF OBJECT_ID('DeleteHealthMetricType', 'P') IS NOT NULL
    DROP PROC DeleteHealthMetricType;
GO
CREATE PROC DeleteHealthMetricType(@id SMALLINT)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM HealthRecord WHERE MetricTypeId = @id)
        RETURN -1;
    DELETE FROM HealthMetricType WHERE MetricTypeId = @id;
END
GO