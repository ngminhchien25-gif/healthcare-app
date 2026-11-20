using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;
namespace WebApp.Api.Models;
public class HealthMetricTypeRepository : BaseRepository
{
    public HealthMetricTypeRepository(IDbConnection connection) : base(connection) { }

    public IEnumerable<HealthMetricType> GetMetricTypes()
    {
        return connection.Query<HealthMetricType>("SELECT * FROM HealthMetricType ORDER BY MetricTypeId ASC");
    }

    public HealthMetricType? GetMetricType(short id)
    {
        string sql = "SELECT * FROM HealthMetricType WHERE MetricTypeId = @id";
        return connection.QueryFirstOrDefault<HealthMetricType>(sql, new { id });
    }

    public int Add(HealthMetricType obj)
    {
        string sql = @"INSERT INTO HealthMetricType (MetricCode, MetricName, Unit, MinNormal, MaxNormal, Description)
                       VALUES (@MetricCode, @MetricName, @Unit, @MinNormal, @MaxNormal, @Description)";
        try
        {
            return connection.Execute(sql, obj);
        }
        catch (SqlException)
        {
            return -2;
        }
    }

    public int Edit(HealthMetricType obj)
    {
        string sql = @"UPDATE HealthMetricType
                       SET MetricCode = @MetricCode, MetricName = @MetricName, Unit = @Unit,
                           MinNormal = @MinNormal, MaxNormal = @MaxNormal, Description = @Description
                       WHERE MetricTypeId = @MetricTypeId";
        try
        {
            return connection.Execute(sql, obj);
        }
        catch (SqlException)
        {
            return -2;
        }
    }

    public int Delete(short id)
    {
        return connection.Execute("DeleteHealthMetricType", new { id }, commandType: CommandType.StoredProcedure);
    }
}