namespace WebApp.Api.Models;
public class PrescriptionAdminInfo
{
    public PrescriptionSummary Prescription { get; set; } = null!;
    public IEnumerable<PrescriptionLine> Lines { get; set; } = new List<PrescriptionLine>();
}