using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApp.Api.Models;

namespace WebApp.Api.Controllers;
[Authorize]
[ApiController, Route("api/[controller]")]
public class WorkoutLogController : BaseController
{
    static bool IsValid(WorkoutLogForm obj)
    {
        return obj.ExerciseId > 0 && obj.DurationMinutes is > 0 and <= 1440 &&
            obj.WorkoutDate != default && obj.WorkoutDate.Date <= DateTime.Today &&
            (obj.Note == null || obj.Note.Length <= 256);
    }

    [HttpGet]
    public PagedResult<WorkoutLog> Get(DateTime? fromDate, DateTime? toDate, int page = 1, int pageSize = 10)
    {
        if (fromDate != null && toDate != null && fromDate.Value.Date > toDate.Value.Date)
            return new PagedResult<WorkoutLog> { Items = Array.Empty<WorkoutLog>(), Page = page, PageSize = pageSize };
        return Provider.WorkoutLog.GetLogs(MemberId, fromDate, toDate, page, pageSize);
    }

    [HttpGet("stats/weekly")]
    public WorkoutWeeklyStats GetWeeklyStats(DateTime? weekStart)
    {
        return Provider.WorkoutLog.GetWeeklyStats(MemberId, weekStart ?? DateTime.Today);
    }

    [HttpGet("{id:int}")]
    public WorkoutLog? Get(int id) => Provider.WorkoutLog.GetLog(id, MemberId);

    [HttpPost]
    public int Add(WorkoutLogForm obj)
    {
        if (!ModelState.IsValid || !IsValid(obj)) return -2;
        decimal? rate = Provider.WorkoutLog.GetCaloriesPerMinute(obj.ExerciseId, true);
        if (rate == null) return 0;
        obj.Note = Clean(obj.Note);
        return Provider.WorkoutLog.Add(MemberId, obj, rate.Value);
    }

    [HttpPut]
    public int Edit(WorkoutLogForm obj)
    {
        if (!ModelState.IsValid || obj.WorkoutLogId < 1 || !IsValid(obj)) return -2;
        WorkoutLog? existing = Provider.WorkoutLog.GetLog(obj.WorkoutLogId, MemberId);
        if (existing == null) return 0;
        bool mustBeActive = obj.ExerciseId != existing.ExerciseId;
        decimal? rate = Provider.WorkoutLog.GetCaloriesPerMinute(obj.ExerciseId, mustBeActive);
        if (rate == null) return 0;
        obj.Note = Clean(obj.Note);
        return Provider.WorkoutLog.Edit(MemberId, obj, rate.Value);
    }

    [HttpDelete("{id:int}")]
    public int Delete(int id) => Provider.WorkoutLog.Delete(id, MemberId);

    static string? Clean(string? value) => string.IsNullOrWhiteSpace(value) ? null : value.Trim();
}
