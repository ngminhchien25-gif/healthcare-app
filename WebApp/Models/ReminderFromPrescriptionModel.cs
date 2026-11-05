namespace WebApp.Api.Models;
public class ReminderFromPrescriptionModel
{
    public int PrescriptionId { get; set; }
    public DateTime StartDate { get; set; }
    public short Days { get; set; }
    public List<string> Times { get; set; } = new List<string>(); 
}