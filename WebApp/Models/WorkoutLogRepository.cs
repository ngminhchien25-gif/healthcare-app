using System.Data;
using Dapper;

namespace WebApp.Api.Models;
public class WorkoutLogRepository : BaseRepository
{
    public WorkoutLogRepository(IDbConnection connection) : base(connection) { }

    const string LogColumns = "w.WorkoutLogId, w.MemberId, w.ExerciseId, e.ExerciseName, w.WorkoutDate, w.DurationMinutes, w.CaloriesBurned, w.Note, w.CreatedAt";

    public PagedResult<WorkoutLog> GetLogs(string memberId, DateTime? fromDate, DateTime? toDate, int page, int pageSize)
    {
        List<string> conditions = new() { "w.MemberId = @MemberId" };
        if (fromDate != null) conditions.Add("w.WorkoutDate >= @FromDate");
        if (toDate != null) conditions.Add("w.WorkoutDate <= @ToDate");
        string fromWhere = "WorkoutLog w JOIN Exercise e ON w.ExerciseId = e.ExerciseId WHERE " + string.Join(" AND ", conditions);
        return QueryPaged<WorkoutLog>(LogColumns, fromWhere, "w.WorkoutDate DESC, w.WorkoutLogId DESC",
            new { MemberId = memberId, FromDate = fromDate?.Date, ToDate = toDate?.Date }, page, pageSize);
    }

    public WorkoutLog? GetLog(int id, string memberId)
    {
        string sql = $"SELECT {LogColumns} FROM WorkoutLog w JOIN Exercise e ON w.ExerciseId = e.ExerciseId WHERE w.WorkoutLogId = @id AND w.MemberId = @memberId";
        return connection.QuerySingleOrDefault<WorkoutLog>(sql, new { id, memberId });
    }

    public decimal? GetCaloriesPerMinute(int exerciseId, bool activeOnly)
    {
        string active = activeOnly ? " AND IsActive = 1" : "";
        return connection.QuerySingleOrDefault<decimal?>(
            "SELECT CaloriesPerMinute FROM Exercise WHERE ExerciseId = @exerciseId" + active, new { exerciseId });
    }

    static decimal Calories(decimal rate, short minutes) => Math.Round(rate * minutes, 2, MidpointRounding.AwayFromZero);

    public int Add(string memberId, WorkoutLogForm form, decimal rate)
    {
        return connection.Execute(
            "INSERT INTO WorkoutLog (MemberId, ExerciseId, WorkoutDate, DurationMinutes, CaloriesBurned, Note) VALUES (@MemberId, @ExerciseId, @WorkoutDate, @DurationMinutes, @CaloriesBurned, @Note)",
            new { MemberId = memberId, form.ExerciseId, WorkoutDate = form.WorkoutDate.Date, form.DurationMinutes, CaloriesBurned = Calories(rate, form.DurationMinutes), Note = Clean(form.Note) });
    }

    public int Edit(string memberId, WorkoutLogForm form, decimal rate)
    {
        return connection.Execute(
            "UPDATE WorkoutLog SET ExerciseId = @ExerciseId, WorkoutDate = @WorkoutDate, DurationMinutes = @DurationMinutes, CaloriesBurned = @CaloriesBurned, Note = @Note WHERE WorkoutLogId = @WorkoutLogId AND MemberId = @MemberId",
            new { MemberId = memberId, form.WorkoutLogId, form.ExerciseId, WorkoutDate = form.WorkoutDate.Date, form.DurationMinutes, CaloriesBurned = Calories(rate, form.DurationMinutes), Note = Clean(form.Note) });
    }

    static string? Clean(string? note) => string.IsNullOrWhiteSpace(note) ? null : note.Trim();

    public int Delete(int id, string memberId)
    {
        return connection.Execute("DELETE FROM WorkoutLog WHERE WorkoutLogId = @id AND MemberId = @memberId", new { id, memberId });
    }

    public WorkoutWeeklyStats GetWeeklyStats(string memberId, DateTime requestedDate)
    {
        DateTime weekStart = requestedDate.Date.AddDays(-(((int)requestedDate.DayOfWeek + 6) % 7));
        DateTime weekEnd = weekStart.AddDays(7);
        const string filter = "MemberId = @MemberId AND WorkoutDate >= @WeekStart AND WorkoutDate < @WeekEnd";
        WorkoutTotals totals = connection.QuerySingle<WorkoutTotals>(
            $"SELECT COUNT(*) AS TotalSessions, COALESCE(SUM(DurationMinutes), 0) AS TotalMinutes, COALESCE(SUM(CaloriesBurned), 0) AS TotalCalories FROM WorkoutLog WHERE {filter}",
            new { MemberId = memberId, WeekStart = weekStart, WeekEnd = weekEnd });
        List<WorkoutDailyStat> days = connection.Query<WorkoutDailyStat>(
            $"SELECT WorkoutDate, COUNT(*) AS SessionCount, SUM(DurationMinutes) AS TotalMinutes, SUM(CaloriesBurned) AS TotalCalories FROM WorkoutLog WHERE {filter} GROUP BY WorkoutDate",
            new { MemberId = memberId, WeekStart = weekStart, WeekEnd = weekEnd }).ToList();
        List<WorkoutExerciseStat> exercises = connection.Query<WorkoutExerciseStat>(
            $"SELECT w.ExerciseId, e.ExerciseName, COUNT(*) AS SessionCount, SUM(w.DurationMinutes) AS TotalMinutes, SUM(w.CaloriesBurned) AS TotalCalories FROM WorkoutLog w JOIN Exercise e ON w.ExerciseId = e.ExerciseId WHERE w.MemberId = @MemberId AND w.WorkoutDate >= @WeekStart AND w.WorkoutDate < @WeekEnd GROUP BY w.ExerciseId, e.ExerciseName ORDER BY e.ExerciseName",
            new { MemberId = memberId, WeekStart = weekStart, WeekEnd = weekEnd }).ToList();
        Dictionary<DateTime, WorkoutDailyStat> byDate = days.ToDictionary(d => d.WorkoutDate.Date);
        return new WorkoutWeeklyStats
        {
            WeekStart = weekStart,
            WeekEnd = weekEnd.AddDays(-1),
            TotalSessions = totals.TotalSessions,
            TotalMinutes = totals.TotalMinutes,
            TotalCalories = totals.TotalCalories,
            Days = Enumerable.Range(0, 7).Select(i => byDate.TryGetValue(weekStart.AddDays(i), out WorkoutDailyStat? stat)
                ? stat
                : new WorkoutDailyStat { WorkoutDate = weekStart.AddDays(i) }).ToList(),
            Exercises = exercises
        };
    }
}
