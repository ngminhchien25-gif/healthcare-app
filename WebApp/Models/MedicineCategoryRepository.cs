using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;

namespace WebApp.Api.Models;
public class MedicineCategoryRepository : BaseRepository
{
    public MedicineCategoryRepository(IDbConnection connection) : base(connection) { }
    public IEnumerable<MedicineCategory> GetMedicineCategories()
    {
        return connection.Query<MedicineCategory>("SELECT * FROM MedicineCategory ORDER BY MedicineCategoryName");
    }
    public MedicineCategory? GetMedicineCategory(short id)
    {
        string sql = "SELECT * FROM MedicineCategory WHERE MedicineCategoryId = @id";
        return connection.QueryFirstOrDefault<MedicineCategory>(sql, new { id });
    }
    public int Add(MedicineCategory obj)
    {
        string sql = "INSERT INTO MedicineCategory (MedicineCategoryName, Description, Icon) VALUES (@MedicineCategoryName, @Description, @Icon)";
        return connection.Execute(sql, obj);
    }
    public int Edit(MedicineCategory obj)
    {
        string sql = "UPDATE MedicineCategory SET MedicineCategoryName = @MedicineCategoryName, Description = @Description, Icon = @Icon WHERE MedicineCategoryId = @MedicineCategoryId";
        return connection.Execute(sql, obj);
    }
    public int Delete(short id)
    {
        return connection.Execute("DeleteMedicineCategory", new { id }, commandType: CommandType.StoredProcedure);
    }
}