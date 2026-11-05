using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;

namespace WebApp.Api.Models;
public class ReminderRepository : BaseRepository
{
    public ReminderRepository(IDbConnection connection) : base(connection) { }

    public PagedResult<Reminder> GetReminders(string memberId, short? type, bool? isDone, string? keyword, DateTime? fromDate, DateTime? toDate, int page, int pageSize)
    {
        List<string> conditions = new List<string> { "MemberId = @MemberId" };
        if (type != null) conditions.Add("ReminderType = @Type");
        if (isDone != null) conditions.Add("IsDone = @IsDone");
        if (!string.IsNullOrWhiteSpace(keyword)) conditions.Add("(Title LIKE @Pattern OR Note LIKE @Pattern)");
        if (fromDate != null) conditions.Add("RemindAt >= @FromDate");
        if (toDate != null) conditions.Add("RemindAt < @ToDateNext");
        string fromWhere = "Reminder WHERE " + string.Join(" AND ", conditions);
        return QueryPaged<Reminder>("*", fromWhere, "IsDone ASC, RemindAt ASC, ReminderId ASC",
            new
            {
                MemberId = memberId,
                Type = type,
                IsDone = isDone,
                Pattern = "%" + keyword?.Trim() + "%",
                FromDate = fromDate?.Date,
                ToDateNext = toDate?.Date.AddDays(1)
            }, page, pageSize);
    }
    public IEnumerable<Reminder> GetUpcoming(string memberId, int limit)
    {
        string sql = "SELECT TOP (@limit) * FROM Reminder WHERE MemberId = @memberId AND IsDone = 0 ORDER BY RemindAt ASC, ReminderId ASC";
        return connection.Query<Reminder>(sql, new { memberId, limit });
    }
    public Reminder? GetReminder(int id, string memberId)
    {
        string sql = "SELECT * FROM Reminder WHERE ReminderId = @id AND MemberId = @memberId";
        return connection.QuerySingleOrDefault<Reminder>(sql, new { id, memberId });
    }
    public int Add(Reminder obj)
    {
        string sql = "INSERT INTO Reminder (MemberId, Title, ReminderType, RemindAt, Note, MedicineId) VALUES (@MemberId, @Title, @ReminderType, @RemindAt, @Note, @MedicineId)";
        try
        {
            return connection.Execute(sql, obj);
        }
        catch (SqlException)
        {
            return -2;
        }
    }
    public int Edit(Reminder obj)
    {
        string sql = "UPDATE Reminder SET Title = @Title, ReminderType = @ReminderType, RemindAt = @RemindAt, Note = @Note, MedicineId = @MedicineId WHERE ReminderId = @ReminderId AND MemberId = @MemberId";
        try
        {
            return connection.Execute(sql, obj);
        }
        catch (SqlException)
        {
            return -2;
        }
    }
    public int SetDone(int id, string memberId, bool isDone)
    {
        string sql = "UPDATE Reminder SET IsDone = @isDone WHERE ReminderId = @id AND MemberId = @memberId";
        return connection.Execute(sql, new { id, memberId, isDone });
    }
    public int Delete(int id, string memberId)
    {
        return connection.Execute("DELETE FROM Reminder WHERE ReminderId = @id AND MemberId = @memberId", new { id, memberId });
    }
    public int CreateFromPrescription(string memberId, int prescriptionId, DateTime startDate, int days, List<TimeOnly> times)
    {
        short? status = connection.QuerySingleOrDefault<short?>(
            "SELECT Status FROM Prescription WHERE PrescriptionId = @prescriptionId AND MemberId = @memberId",
            new { prescriptionId, memberId });
        if (status == null) return 0;
        if (status != 1) return -4;
        List<string> names = connection.Query<string>(
            @"SELECT m.MedicineName + ISNULL(N' (' + d.DosageNote + N')', N'')
              FROM PrescriptionDetail d JOIN Medicine m ON d.MedicineId = m.MedicineId
              WHERE d.PrescriptionId = @prescriptionId ORDER BY m.MedicineName",
            new { prescriptionId }).ToList();
        string note = string.Join("; ", names);
        if (note.Length > 256) note = note.Substring(0, 253) + "...";
        List<object> rows = new List<object>();
        for (int d = 0; d < days; d++)
        {
            foreach (TimeOnly t in times)
            {
                rows.Add(new
                {
                    memberId,
                    prescriptionId,
                    Title = $"Uống thuốc theo đơn #{prescriptionId}",
                    RemindAt = startDate.Date.AddDays(d).Add(t.ToTimeSpan()),
                    Note = note
                });
            }
        }
        if (connection.State != ConnectionState.Open) connection.Open();
        using IDbTransaction tx = connection.BeginTransaction();
        try
        {
            connection.Execute(
                "INSERT INTO Reminder (MemberId, Title, ReminderType, RemindAt, Note, PrescriptionId) VALUES (@memberId, @Title, 0, @RemindAt, @Note, @prescriptionId)",
                rows, tx);
            tx.Commit();
            return rows.Count;
        }
        catch
        {
            tx.Rollback();
            throw;
        }
    }
}