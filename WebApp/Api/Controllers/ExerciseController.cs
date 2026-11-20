using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApp.Api.Models;

namespace WebApp.Api.Controllers;
[Authorize]
[ApiController, Route("api/[controller]")]
public class ExerciseController : BaseController
{
    static bool IsValid(Exercise obj) =>
        !string.IsNullOrWhiteSpace(obj.ExerciseName) && obj.ExerciseName.Trim().Length <= 100 &&
        (obj.Description == null || obj.Description.Length <= 512) &&
        (obj.MuscleGroup == null || obj.MuscleGroup.Length <= 64) &&
        obj.CaloriesPerMinute >= 0 && obj.CaloriesPerMinute <= 999999.99m;

    [HttpGet]
    public PagedResult<Exercise> Get(string? keyword, bool includeInactive = false, int page = 1, int pageSize = 10)
    {
        return Provider.Exercise.GetExercises(keyword, includeInactive && User.IsInRole("Admin"), page, pageSize);
    }

    [HttpGet("{id:int}")]
    public Exercise? Get(int id)
    {
        Exercise? item = Provider.Exercise.GetExercise(id);
        return item != null && (item.IsActive || User.IsInRole("Admin")) ? item : null;
    }

    [Authorize(Roles = "Admin"), HttpPost]
    public int Add(Exercise obj)
    {
        if (!ModelState.IsValid || !IsValid(obj)) return -2;
        obj.ExerciseName = obj.ExerciseName.Trim();
        obj.Description = Clean(obj.Description);
        obj.MuscleGroup = Clean(obj.MuscleGroup);
        return Provider.Exercise.Add(obj);
    }

    [Authorize(Roles = "Admin"), HttpPut]
    public int Edit(Exercise obj)
    {
        if (!ModelState.IsValid || obj.ExerciseId < 1 || !IsValid(obj)) return -2;
        if (Provider.Exercise.GetExercise(obj.ExerciseId) == null) return 0;
        obj.ExerciseName = obj.ExerciseName.Trim();
        obj.Description = Clean(obj.Description);
        obj.MuscleGroup = Clean(obj.MuscleGroup);
        return Provider.Exercise.Edit(obj);
    }

    [Authorize(Roles = "Admin"), HttpDelete("{id:int}")]
    public int Delete(int id)
    {
        if (Provider.Exercise.GetExercise(id) == null) return 0;
        return Provider.Exercise.Delete(id);
    }

    static string? Clean(string? value) => string.IsNullOrWhiteSpace(value) ? null : value.Trim();
}
