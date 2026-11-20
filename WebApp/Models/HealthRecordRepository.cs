using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;
namespace WebApp.Api.Models;
public class HealthRecordRepository : BaseRepository
{
    public HealthRecordRepository(IDbConnection connection) : base(connection) { }

    public PagedResult<HealthRecordInfo> GetRecords(string memberId, short? metricTypeId, DateTime? fromDate, DateTime? toDate, int page, int pageSize)
    {
        List<string> conditions = new List<string> { "r.MemberId = @MemberId" };
        if (metricTypeId != null) conditions.Add("r.MetricTypeId = @MetricTypeId");
        if (fromDate != null) conditions.Add("r.MeasuredAt >= @FromDate");
        if (toDate != null) conditions.Add("r.MeasuredAt < @ToDateNext");

        string fromWhere = "HealthRecord r JOIN HealthMetricType t ON r.MetricTypeId = t.MetricTypeId WHERE " + string.Join(" AND ", conditions);
        string columns = "r.*, t.MetricCode, t.MetricName, t.Unit, t.MinNormal, t.MaxNormal";

        return QueryPaged<HealthRecordInfo>(columns, fromWhere, "r.MeasuredAt DESC, r.RecordId DESC",
            new
            {
                MemberId = memberId,
                MetricTypeId = metricTypeId,
                FromDate = fromDate?.Date,
                ToDateNext = toDate?.Date.AddDays(1)
            }, page, pageSize);
    }

    public IEnumerable<HealthRecordInfo> GetChartData(string memberId, short metricTypeId, int days)
    {
        DateTime fromDate = DateTime.Today.AddDays(-days);
        string sql = @"SELECT r.*, t.MetricCode, t.MetricName, t.Unit, t.MinNormal, t.MaxNormal
                       FROM HealthRecord r
                       JOIN HealthMetricType t ON r.MetricTypeId = t.MetricTypeId
                       WHERE r.MemberId = @memberId AND r.MetricTypeId = @metricTypeId AND r.MeasuredAt >= @fromDate
                       ORDER BY r.MeasuredAt ASC, r.RecordId ASC";
        return connection.Query<HealthRecordInfo>(sql, new { memberId, metricTypeId, fromDate });
    }

    public IEnumerable<HealthRecordInfo> GetLatestByMetric(string memberId)
    {
        string sql = @"
            WITH Ranked AS (
                SELECT r.*, t.MetricCode, t.MetricName, t.Unit, t.MinNormal, t.MaxNormal,
                       ROW_NUMBER() OVER (PARTITION BY r.MetricTypeId ORDER BY r.MeasuredAt DESC, r.RecordId DESC) AS rn
                FROM HealthRecord r
                JOIN HealthMetricType t ON r.MetricTypeId = t.MetricTypeId
                WHERE r.MemberId = @memberId
            )
            SELECT RecordId, MemberId, MetricTypeId, Value, SecondaryValue, MeasuredAt, Note,
                   MetricCode, MetricName, Unit, MinNormal, MaxNormal
            FROM Ranked WHERE rn = 1
            ORDER BY MetricTypeId ASC";
        return connection.Query<HealthRecordInfo>(sql, new { memberId });
    }

    public BmiSummary GetBmi(string memberId)
    {
        decimal? heightCm = connection.QuerySingleOrDefault<decimal?>(
            "SELECT HeightCm FROM HealthProfile WHERE MemberId = @memberId", new { memberId });

        var latestWeight = connection.QueryFirstOrDefault<(decimal Value, DateTime MeasuredAt)?>(
            @"SELECT TOP 1 r.Value, r.MeasuredAt
              FROM HealthRecord r
              JOIN HealthMetricType t ON r.MetricTypeId = t.MetricTypeId
              WHERE r.MemberId = @memberId AND t.MetricCode = 'WEIGHT'
              ORDER BY r.MeasuredAt DESC, r.RecordId DESC", new { memberId });

        BmiSummary result = new BmiSummary
        {
            HeightCm = heightCm,
            WeightKg = latestWeight?.Value,
            MeasuredAt = latestWeight?.MeasuredAt
        };

        if (heightCm != null && heightCm > 0 && latestWeight != null && latestWeight.Value.Value > 0)
        {
            decimal hMeter = heightCm.Value / 100m;
            decimal bmi = Math.Round(latestWeight.Value.Value / (hMeter * hMeter), 1);
            result.Bmi = bmi;
            if (bmi < 18.5m) result.Category = "Thiếu cân";
            else if (bmi < 25.0m) result.Category = "Bình thường";
            else if (bmi < 30.0m) result.Category = "Thừa cân";
            else result.Category = "Béo phì";
        }
        return result;
    }

    public int Add(HealthRecord obj)
    {
        string sql = @"INSERT INTO HealthRecord (MemberId, MetricTypeId, Value, SecondaryValue, MeasuredAt, Note)
                       VALUES (@MemberId, @MetricTypeId, @Value, @SecondaryValue, @MeasuredAt, @Note)";
        try
        {
            return connection.Execute(sql, obj);
        }
        catch (SqlException)
        {
            return -2;
        }
    }

    public int Edit(HealthRecord obj)
    {
        string sql = @"UPDATE HealthRecord
                       SET MetricTypeId = @MetricTypeId, Value = @Value, SecondaryValue = @SecondaryValue,
                           MeasuredAt = @MeasuredAt, Note = @Note
                       WHERE RecordId = @RecordId AND MemberId = @MemberId";
        try
        {
            return connection.Execute(sql, obj);
        }
        catch (SqlException)
        {
            return -2;
        }
    }

    public int Delete(int id, string memberId)
    {
        return connection.Execute("DELETE FROM HealthRecord WHERE RecordId = @id AND MemberId = @memberId", new { id, memberId });
    }
}