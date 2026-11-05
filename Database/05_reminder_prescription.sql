USE Healthcare;
GO
IF COL_LENGTH('Reminder', 'PrescriptionId') IS NULL
    ALTER TABLE Reminder ADD PrescriptionId INT NULL REFERENCES Prescription(PrescriptionId);
GO