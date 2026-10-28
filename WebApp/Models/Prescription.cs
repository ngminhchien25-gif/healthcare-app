namespace WebApp.Api.Models;
public class Prescription
{
    public int PrescriptionId { get; set; }
    public string MemberId { get; set; } = null!;
    public DateTime PrescribedDate { get; set; }
    public string? DoctorName { get; set; }
    public string? Note { get; set; }
    public short Status { get; set; }     
    public string? ReviewNote { get; set; }
    public DateTime CreatedAt { get; set; }
}