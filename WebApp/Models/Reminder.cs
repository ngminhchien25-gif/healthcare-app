namespace WebApp.Api.Models;
public class Reminder
{
    public int ReminderId { get; set; }
    public string? MemberId { get; set; }
    public string Title { get; set; } = null!;
    public short ReminderType { get; set; }   
    public DateTime RemindAt { get; set; }
    public string? Note { get; set; }
    public bool IsDone { get; set; }
    public int? MedicineId { get; set; }
    public int? PrescriptionId { get; set; }
}