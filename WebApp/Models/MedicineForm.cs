namespace WebApp.Api.Models;
public class MedicineForm
{
    public int MedicineId { get; set; }
    public short MedicineCategoryId { get; set; }
    public string MedicineName { get; set; } = null!;
    public string Unit { get; set; } = null!;
    public string? Description { get; set; }
    public string? Precaution { get; set; }
    public IFormFile? File { get; set; }
}