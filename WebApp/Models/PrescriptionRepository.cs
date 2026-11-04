using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;

namespace WebApp.Api.Models;
public class PrescriptionRepository : BaseRepository
{
    public PrescriptionRepository(IDbConnection connection) : base(connection) { }

    public int AddCart(PrescriptionCart obj)
    {
        try
        {
            return connection.Execute("AddPrescriptionCart", obj, commandType: CommandType.StoredProcedure);
        }
        catch (SqlException)
        {
            return -2;
        }
    }
    public IEnumerable<PrescriptionLine> GetCart(string memberId)
    {
        string sql = @"SELECT c.MedicineId, m.MedicineName, m.ImageUrl, m.Unit, c.Quantity, c.DosageNote
                       FROM PrescriptionCart c JOIN Medicine m ON c.MedicineId = m.MedicineId
                       WHERE c.MemberId = @memberId ORDER BY m.MedicineName";
        return connection.Query<PrescriptionLine>(sql, new { memberId });
    }
    public int CountCart(string memberId)
    {
        return connection.ExecuteScalar<int>("SELECT COUNT(*) FROM PrescriptionCart WHERE MemberId = @memberId", new { memberId });
    }
    public int UpdateCart(PrescriptionCart obj)
    {
        string sql = "UPDATE PrescriptionCart SET Quantity = @Quantity, DosageNote = @DosageNote WHERE MemberId = @MemberId AND MedicineId = @MedicineId";
        return connection.Execute(sql, obj);
    }
    public int RemoveCart(string memberId, int medicineId)
    {
        return connection.Execute("DELETE FROM PrescriptionCart WHERE MemberId = @memberId AND MedicineId = @medicineId", new { memberId, medicineId });
    }
    public int ClearCart(string memberId)
    {
        return connection.Execute("DELETE FROM PrescriptionCart WHERE MemberId = @memberId", new { memberId });
    }

    public int Checkout(string memberId, CheckoutModel obj)
    {
        return connection.ExecuteScalar<int>("CheckoutPrescription",
            new { memberId, PrescribedDate = obj.PrescribedDate.Date, obj.DoctorName, obj.Note },
            commandType: CommandType.StoredProcedure);
    }

    public PagedResult<Prescription> GetPrescriptions(string memberId, string? keyword, DateTime? fromDate, DateTime? toDate, int page, int pageSize)
    {
        List<string> conditions = new List<string> { "MemberId = @MemberId" };
        if (!string.IsNullOrWhiteSpace(keyword)) conditions.Add("(DoctorName LIKE @Pattern OR Note LIKE @Pattern)");
        if (fromDate != null) conditions.Add("PrescribedDate >= @FromDate");
        if (toDate != null) conditions.Add("PrescribedDate <= @ToDate");
        string fromWhere = "Prescription WHERE " + string.Join(" AND ", conditions);
        return QueryPaged<Prescription>("*", fromWhere, "CreatedAt DESC, PrescriptionId DESC",
            new { MemberId = memberId, Pattern = "%" + keyword?.Trim() + "%", FromDate = fromDate?.Date, ToDate = toDate?.Date },
            page, pageSize);
    }
    public Prescription? GetPrescription(int id, string memberId)
    {
        string sql = "SELECT * FROM Prescription WHERE PrescriptionId = @id AND MemberId = @memberId";
        return connection.QuerySingleOrDefault<Prescription>(sql, new { id, memberId });
    }
    public IEnumerable<PrescriptionLine> GetLines(int id)
    {
        string sql = @"SELECT d.PrescriptionId, d.MedicineId, m.MedicineName, m.ImageUrl, m.Unit, d.Quantity, d.DosageNote
                       FROM PrescriptionDetail d JOIN Medicine m ON d.MedicineId = m.MedicineId
                       WHERE d.PrescriptionId = @id ORDER BY m.MedicineName";
        return connection.Query<PrescriptionLine>(sql, new { id });
    }
        // ===== Admin (dược sĩ) =====
    const string AdminColumns = @"p.PrescriptionId, p.MemberId, p.PrescribedDate, p.DoctorName, p.Note, p.Status, p.ReviewNote, p.CreatedAt,
        ISNULL(m.Surname + N' ', N'') + m.GivenName AS MemberName, m.Email AS MemberEmail";
    const string AdminFrom = "Prescription p JOIN Member m ON p.MemberId = m.MemberId";
    public PagedResult<PrescriptionSummary> GetAllPrescriptions(string? keyword, short? status, DateTime? fromDate, DateTime? toDate, int page, int pageSize)
    {
        List<string> conditions = new List<string>();
        if (!string.IsNullOrWhiteSpace(keyword)) conditions.Add("(m.Email LIKE @Pattern OR m.GivenName LIKE @Pattern OR m.Surname LIKE @Pattern OR p.DoctorName LIKE @Pattern OR p.Note LIKE @Pattern)");
        if (status != null) conditions.Add("p.Status = @Status");
        if (fromDate != null) conditions.Add("p.PrescribedDate >= @FromDate");
        if (toDate != null) conditions.Add("p.PrescribedDate <= @ToDate");
        string fromWhere = AdminFrom;
        if (conditions.Count > 0) fromWhere += " WHERE " + string.Join(" AND ", conditions);
        return QueryPaged<PrescriptionSummary>(AdminColumns, fromWhere, "p.CreatedAt DESC, p.PrescriptionId DESC",
            new { Pattern = "%" + keyword?.Trim() + "%", Status = status, FromDate = fromDate?.Date, ToDate = toDate?.Date },
            page, pageSize);
    }
    public PrescriptionSummary? GetPrescriptionForAdmin(int id)
    {
        string sql = $"SELECT {AdminColumns} FROM {AdminFrom} WHERE p.PrescriptionId = @id";
        return connection.QuerySingleOrDefault<PrescriptionSummary>(sql, new { id });
    }
    public int Review(int id, short status, string? reviewNote)
    {
        return connection.Execute("UPDATE Prescription SET Status = @status, ReviewNote = @reviewNote WHERE PrescriptionId = @id",
            new { id, status, reviewNote });
    }
}