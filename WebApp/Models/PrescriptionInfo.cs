namespace WebApp.Api.Models;
public class PrescriptionInfo
{
    public Prescription Prescription { get; set; } = null!;
    public IEnumerable<PrescriptionLine> Lines { get; set; } = new List<PrescriptionLine>();
}