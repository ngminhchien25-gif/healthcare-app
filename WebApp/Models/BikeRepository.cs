using System.Data;
using Dapper;

namespace WebApp.Api.Models;

public class BikeRepository : BaseRepository
{
    public BikeRepository(IDbConnection connection) : base(connection)
    {
    }
    public IEnumerable<Bike> GetBikes()
    {
        return connection.Query<Bike>("SELECT * FROM Bike");
    }
    public IEnumerable<Bike> GetBikesByCategory(short id)
    {
        string sql = "SELECT * FROM Bike JOIN SubCategory ON Bike.SubCategoryId = SubCategory.SubCategoryId AND CategoryId = @Id";
        return connection.Query<Bike>(sql, new {id});
    }
    public IEnumerable<Bike> GetBikesBySubCategories(short[] ids)
    {
        return connection.Query<Bike>("SELECT * FROM Bike WHERE SubCategoryId in @Ids", new {ids});
    }
    public Bike? GetBike(int id)
    {
        string sql = "SELECT * FROM Bike WHERE BikeId = @Id";
        return connection.QuerySingleOrDefault<Bike>(sql, new{id});
    }
    public IEnumerable<Bike> GetBikesRelation(int id, short subCategoryId)
    {
        string sql = "SELECT * FROM Bike WHERE BikeId <> @Id AND SubCategoryId = @SubCategoryId";
        return connection.Query<Bike>(sql, new{id, subCategoryId});
    }
}