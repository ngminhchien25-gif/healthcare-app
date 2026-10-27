using System.Data;
using Dapper;

namespace WebApp.Api.Models;

public class SubCategoryRepository : BaseRepository
{
    public SubCategoryRepository(IDbConnection connection) : base(connection)
    {
    }
    public IEnumerable<SubCategory> GetSubCategories()
    {
        return connection.Query<SubCategory>("SELECT * FROM Subcategory");
    }
    public IEnumerable<SubCategory> GetSubCategories(short id)
    {
        string sql = "SELECT * FROM SubCategory WHERE CategoryId = @Id";
        return connection.Query<SubCategory>(sql, new {id});
    }
}