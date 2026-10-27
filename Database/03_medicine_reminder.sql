CREATE DATABASE Healthcare;
USE Healthcare;
GO
CREATE TABLE MedicineCategory(
    MedicineCategoryId SMALLINT NOT NULL PRIMARY KEY IDENTITY(1, 1),
    MedicineCategoryName NVARCHAR(64) NOT NULL,
    Description NVARCHAR(512) NOT NULL DEFAULT N'',
    Icon VARCHAR(64) NULL
);
GO
CREATE TABLE Medicine(
    MedicineId INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
    MedicineCategoryId SMALLINT NOT NULL REFERENCES MedicineCategory(MedicineCategoryId),
    MedicineName NVARCHAR(128) NOT NULL,
    ImageUrl VARCHAR(64) NULL,
    Unit NVARCHAR(32) NOT NULL,
    Description NVARCHAR(1024) NULL,
    Precaution NVARCHAR(512) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO
CREATE TABLE PrescriptionCart(
    MemberId NVARCHAR(32) NOT NULL REFERENCES Member(MemberId),
    MedicineId INT NOT NULL REFERENCES Medicine(MedicineId),
    Quantity SMALLINT NOT NULL CHECK (Quantity > 0),
    DosageNote NVARCHAR(128) NULL,
    PRIMARY KEY (MemberId, MedicineId)
);
GO
CREATE TABLE Prescription(
    PrescriptionId INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
    MemberId NVARCHAR(32) NOT NULL REFERENCES Member(MemberId),
    PrescribedDate DATE NOT NULL,
    DoctorName NVARCHAR(64) NULL,
    Note NVARCHAR(256) NULL,
    Status SMALLINT NOT NULL DEFAULT 0, 
    ReviewNote NVARCHAR(256) NULL,     
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO
CREATE TABLE PrescriptionDetail(
    PrescriptionId INT NOT NULL REFERENCES Prescription(PrescriptionId),
    MedicineId INT NOT NULL REFERENCES Medicine(MedicineId),
    Quantity SMALLINT NOT NULL,
    DosageNote NVARCHAR(128) NULL,
    PRIMARY KEY (PrescriptionId, MedicineId)
);
GO
CREATE TABLE Reminder(
    ReminderId INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
    MemberId NVARCHAR(32) NOT NULL REFERENCES Member(MemberId),
    Title NVARCHAR(128) NOT NULL,
    ReminderType SMALLINT NOT NULL DEFAULT 0, 
    RemindAt DATETIME2 NOT NULL,
    Note NVARCHAR(256) NULL,
    IsDone BIT NOT NULL DEFAULT 0,
    MedicineId INT NULL REFERENCES Medicine(MedicineId) ON DELETE SET NULL
);
GO
CREATE PROC DeleteMedicineCategory(
    @Id SMALLINT
)
AS
    IF NOT EXISTS(SELECT * FROM Medicine WHERE MedicineCategoryId = @Id)
        DELETE FROM MedicineCategory WHERE MedicineCategoryId = @Id;
GO
CREATE PROC DeleteMedicine(
    @Id INT
)
AS
    IF NOT EXISTS(SELECT * FROM PrescriptionDetail WHERE MedicineId = @Id)
    BEGIN
        DELETE FROM PrescriptionCart WHERE MedicineId = @Id;
        DELETE FROM Medicine WHERE MedicineId = @Id;
    END
GO
CREATE PROC AddPrescriptionCart(
    @MemberId NVARCHAR(32),
    @MedicineId INT,
    @Quantity SMALLINT,
    @DosageNote NVARCHAR(128)
)
AS
    IF EXISTS(SELECT * FROM PrescriptionCart WHERE MemberId = @MemberId AND MedicineId = @MedicineId)
        UPDATE PrescriptionCart SET Quantity = Quantity + @Quantity,
            DosageNote = ISNULL(@DosageNote, DosageNote)
        WHERE MemberId = @MemberId AND MedicineId = @MedicineId;
    ELSE
        INSERT INTO PrescriptionCart(MemberId, MedicineId, Quantity, DosageNote)
        VALUES (@MemberId, @MedicineId, @Quantity, @DosageNote);
GO
CREATE PROC CheckoutPrescription(
    @MemberId NVARCHAR(32),
    @PrescribedDate DATE,
    @DoctorName NVARCHAR(64),
    @Note NVARCHAR(256)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF NOT EXISTS(SELECT * FROM PrescriptionCart WHERE MemberId = @MemberId)
    BEGIN
        SELECT 0;
        RETURN;
    END
    DECLARE @Id INT;
    BEGIN TRAN;
    INSERT INTO Prescription(MemberId, PrescribedDate, DoctorName, Note)
        VALUES (@MemberId, @PrescribedDate, @DoctorName, @Note);
    SET @Id = SCOPE_IDENTITY();
    INSERT INTO PrescriptionDetail(PrescriptionId, MedicineId, Quantity, DosageNote)
        SELECT @Id, MedicineId, Quantity, DosageNote
        FROM PrescriptionCart WHERE MemberId = @MemberId;
    DELETE FROM PrescriptionCart WHERE MemberId = @MemberId;
    COMMIT;
    SELECT @Id;
END
GO
INSERT INTO MedicineCategory(MedicineCategoryName, Description) VALUES
    (N'Giảm đau - hạ sốt', N'Nhóm thuốc thường dùng khi đau hoặc sốt'),
    (N'Vitamin và khoáng chất', N'Nhóm bổ sung vitamin, khoáng chất'),
    (N'Tiêu hóa', N'Nhóm thuốc hỗ trợ đường tiêu hóa');
INSERT INTO Medicine(MedicineCategoryId, MedicineName, Unit, Description) VALUES
    (1, N'Paracetamol 500mg', N'viên', N'Thuốc giảm đau, hạ sốt thông dụng'),
    (2, N'Vitamin C 500mg', N'viên', N'Bổ sung vitamin C'),
    (3, N'Men tiêu hóa', N'gói', N'Hỗ trợ tiêu hóa');
GO