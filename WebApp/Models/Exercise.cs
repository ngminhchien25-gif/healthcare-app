namespace WebApp.Api.Models;
public class Exercise
{
    public int ExerciseId { get; set; }
    public string ExerciseName { get; set; } = null!;
    public string? Description { get; set; }
    public string? MuscleGroup { get; set; }
    public decimal CaloriesPerMinute { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
}
