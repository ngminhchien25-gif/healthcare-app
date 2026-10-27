namespace WebApp.Api.Models;
public class MedicineCategory
{
    public short MedicineCategoryId { get; set; }
    public string MedicineCategoryName { get; set; } = null!;
    public string Description { get; set; } = "";
    public string? Icon { get; set; }
}