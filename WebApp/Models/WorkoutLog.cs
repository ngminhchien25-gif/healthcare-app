namespace WebApp.Api.Models;
public class WorkoutLog
{
    public int WorkoutLogId { get; set; }
    public string? MemberId { get; set; }
    public int ExerciseId { get; set; }
    public string? ExerciseName { get; set; }
    public DateTime WorkoutDate { get; set; }
    public short DurationMinutes { get; set; }
    public decimal CaloriesBurned { get; set; }
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class WorkoutLogForm
{
    public int WorkoutLogId { get; set; }
    public int ExerciseId { get; set; }
    public DateTime WorkoutDate { get; set; }
    public short DurationMinutes { get; set; }
    public string? Note { get; set; }
}

public class WorkoutDailyStat
{
    public DateTime WorkoutDate { get; set; }
    public int SessionCount { get; set; }
    public int TotalMinutes { get; set; }
    public decimal TotalCalories { get; set; }
}

public class WorkoutExerciseStat
{
    public int ExerciseId { get; set; }
    public string ExerciseName { get; set; } = null!;
    public int SessionCount { get; set; }
    public int TotalMinutes { get; set; }
    public decimal TotalCalories { get; set; }
}

public class WorkoutWeeklyStats
{
    public DateTime WeekStart { get; set; }
    public DateTime WeekEnd { get; set; }
    public int TotalSessions { get; set; }
    public int TotalMinutes { get; set; }
    public decimal TotalCalories { get; set; }
    public List<WorkoutDailyStat> Days { get; set; } = new();
    public List<WorkoutExerciseStat> Exercises { get; set; } = new();
}

public class WorkoutTotals
{
    public int TotalSessions { get; set; }
    public int TotalMinutes { get; set; }
    public decimal TotalCalories { get; set; }
}
