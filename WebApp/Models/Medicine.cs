namespace WebApp.Api.Models;
public class Medicine
{
    public int MedicineId { get; set; }
    public short MedicineCategoryId { get; set; }
    public string MedicineName { get; set; } = null!;
    public string? ImageUrl { get; set; }
    public string Unit { get; set; } = null!;
    public string? Description { get; set; }
    public string? Precaution { get; set; }
    public DateTime CreatedAt { get; set; }
}