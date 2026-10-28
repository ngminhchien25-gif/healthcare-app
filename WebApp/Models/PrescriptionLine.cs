namespace WebApp.Api.Models;
public class PrescriptionLine
{
    public int? PrescriptionId { get; set; }
    public int MedicineId { get; set; }
    public string MedicineName { get; set; } = null!;
    public string? ImageUrl { get; set; }
    public string Unit { get; set; } = null!;
    public short Quantity { get; set; }
    public string? DosageNote { get; set; }
}