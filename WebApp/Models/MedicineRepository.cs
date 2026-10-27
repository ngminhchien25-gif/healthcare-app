using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;

namespace WebApp.Api.Models;
public class MedicineRepository : BaseRepository
{
    public MedicineRepository(IDbConnection connection) : base(connection) { }
    public PagedResult<Medicine> GetMedicines(short? categoryId, string? keyword, int page, int pageSize)
    {
        List<string> conditions = new List<string>();
        if (categoryId != null) conditions.Add("MedicineCategoryId = @CategoryId");
        if (!string.IsNullOrWhiteSpace(keyword)) conditions.Add("(MedicineName LIKE @Pattern OR Description LIKE @Pattern)");
        string fromWhere = "Medicine";
        if (conditions.Count > 0) fromWhere += " WHERE " + string.Join(" AND ", conditions);
        return QueryPaged<Medicine>("*", fromWhere, "CreatedAt DESC, MedicineId DESC",
            new { CategoryId = categoryId, Pattern = "%" + keyword?.Trim() + "%" }, page, pageSize);
    }
    public Medicine? GetMedicine(int id)
    {
        string sql = "SELECT * FROM Medicine WHERE MedicineId = @id";
        return connection.QuerySingleOrDefault<Medicine>(sql, new { id });
    }
    public PagedResult<Medicine> GetRelated(int id, short categoryId, int page, int pageSize)
    {
        return QueryPaged<Medicine>("*", "Medicine WHERE MedicineCategoryId = @CategoryId AND MedicineId <> @Id",
            "CreatedAt DESC, MedicineId DESC", new { id, categoryId }, page, pageSize);
    }
    public int Add(Medicine obj)
    {
        string sql = "INSERT INTO Medicine (MedicineCategoryId, MedicineName, ImageUrl, Unit, Description, Precaution) VALUES (@MedicineCategoryId, @MedicineName, @ImageUrl, @Unit, @Description, @Precaution)";
        try
        {
            return connection.Execute(sql, obj);
        }
        catch (SqlException)
        {
            return -2;
        }
    }
    public int Edit(Medicine obj)
    {
        string sql = "UPDATE Medicine SET MedicineCategoryId = @MedicineCategoryId, MedicineName = @MedicineName, ImageUrl = @ImageUrl, Unit = @Unit, Description = @Description, Precaution = @Precaution WHERE MedicineId = @MedicineId";
        try
        {
            return connection.Execute(sql, obj);
        }
        catch (SqlException)
        {
            return -2;
        }
    }
    public int Delete(int id)
    {
        return connection.Execute("DeleteMedicine", new { id }, commandType: CommandType.StoredProcedure);
    }
}