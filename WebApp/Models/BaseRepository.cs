using System.Data;
using Dapper;

namespace WebApp.Api.Models;
public abstract class BaseRepository
{
    protected IDbConnection connection;
    public BaseRepository(IDbConnection connection)
    {
        this.connection = connection;
    }
    protected PagedResult<T> QueryPaged<T>(string columns, string fromWhere, string orderBy, object? param, int page, int pageSize)
    {
        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 10;
        if (pageSize > 50) pageSize = 50;
        DynamicParameters p = new DynamicParameters(param);
        p.Add("Offset", (page - 1) * pageSize);
        p.Add("PageSize", pageSize);
        string sql = $"SELECT COUNT(*) FROM {fromWhere}; " +
                     $"SELECT {columns} FROM {fromWhere} ORDER BY {orderBy} OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;";
        using SqlMapper.GridReader reader = connection.QueryMultiple(sql, p);
        int total = reader.ReadSingle<int>();
        List<T> items = reader.Read<T>().ToList();
        return new PagedResult<T> { Items = items, Total = total, Page = page, PageSize = pageSize };
    }
}
    