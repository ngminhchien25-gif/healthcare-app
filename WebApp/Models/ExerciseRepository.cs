using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;

namespace WebApp.Api.Models;
public class ExerciseRepository : BaseRepository
{
    public ExerciseRepository(IDbConnection connection) : base(connection) { }

    public PagedResult<Exercise> GetExercises(string? keyword, bool includeInactive, int page, int pageSize)
    {
        List<string> conditions = new();
        if (!includeInactive) conditions.Add("IsActive = 1");
        if (!string.IsNullOrWhiteSpace(keyword)) conditions.Add("(ExerciseName LIKE @Pattern OR MuscleGroup LIKE @Pattern)");
        string fromWhere = "Exercise" + (conditions.Count == 0 ? "" : " WHERE " + string.Join(" AND ", conditions));
        return QueryPaged<Exercise>("*", fromWhere, "ExerciseName, ExerciseId",
            new { Pattern = "%" + keyword?.Trim() + "%" }, page, pageSize);
    }

    public Exercise? GetExercise(int id)
    {
        return connection.QuerySingleOrDefault<Exercise>("SELECT * FROM Exercise WHERE ExerciseId = @id", new { id });
    }

    public int Add(Exercise obj)
    {
        return connection.Execute(
            "INSERT INTO Exercise (ExerciseName, Description, MuscleGroup, CaloriesPerMinute) VALUES (@ExerciseName, @Description, @MuscleGroup, @CaloriesPerMinute)", obj);
    }

    public int Edit(Exercise obj)
    {
        return connection.Execute(
            "UPDATE Exercise SET ExerciseName = @ExerciseName, Description = @Description, MuscleGroup = @MuscleGroup, CaloriesPerMinute = @CaloriesPerMinute, IsActive = @IsActive WHERE ExerciseId = @ExerciseId", obj);
    }

    public int Delete(int id)
    {
        try
        {
            return connection.Execute("DELETE FROM Exercise WHERE ExerciseId = @id", new { id });
        }
        catch (SqlException)
        {
            return -1;
        }
    }
}
