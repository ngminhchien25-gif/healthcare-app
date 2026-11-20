using System.Data;
using Dapper;
namespace WebApp.Api.Models;
public class HealthProfileRepository : BaseRepository
{
    public HealthProfileRepository(IDbConnection connection) : base(connection) { }

    public HealthProfile? GetByMember(string memberId)
    {
        string sql = "SELECT * FROM HealthProfile WHERE MemberId = @memberId";
        return connection.QuerySingleOrDefault<HealthProfile>(sql, new { memberId });
    }

    public int Save(HealthProfile obj)
    {
        string sql = @"
            IF EXISTS (SELECT 1 FROM HealthProfile WHERE MemberId = @MemberId)
                UPDATE HealthProfile
                SET HeightCm = @HeightCm,
                    DateOfBirth = @DateOfBirth,
                    Gender = @Gender,
                    BloodType = @BloodType,
                    MedicalHistory = @MedicalHistory,
                    UpdatedAt = GETDATE()
                WHERE MemberId = @MemberId
            ELSE
                INSERT INTO HealthProfile (MemberId, HeightCm, DateOfBirth, Gender, BloodType, MedicalHistory, UpdatedAt)
                VALUES (@MemberId, @HeightCm, @DateOfBirth, @Gender, @BloodType, @MedicalHistory, GETDATE())";
        return connection.Execute(sql, obj);
    }
}