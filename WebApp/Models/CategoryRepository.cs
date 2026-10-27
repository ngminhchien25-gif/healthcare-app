using System.Data;
using Dapper;
using WebApp.Models;

namespace WebApp.Api.Models;
    public class CategoryRepository : BaseRepository
    {
        public CategoryRepository(IDbConnection connection) : base(connection){
        }
        public IEnumerable<Category> GetCategory()
        {
            return connection.Query<Category>("SELECT * FROM Category");
        }
        public int Add(Category obj)
        {
        String sql = "INSERT INTO Category (CategoryName, Title, Description, Icon) VALUES (@CategoryName, @Title, @Description, @Icon)";
        return connection.Execute(sql, obj);
        }
        public Category? GetCategory(short id)
        {
            String sql = "SELECT * FROM Category WHERE CategoryId = @id";
            return connection.QueryFirstOrDefault<Category>(sql, new { id });
        }
        public int Edit(Category obj)
        {
            String sql = "UPDATE Category SET CategoryName = @CategoryName, Title = @Title, Description = @Description, Icon = @Icon WHERE CategoryId = @CategoryId";
            return connection.Execute(sql, obj);
        }
        public int Delete(short id)
        {
            return connection.Execute("DeleteCategory", new { id }, commandType: CommandType.StoredProcedure);
        }
    }