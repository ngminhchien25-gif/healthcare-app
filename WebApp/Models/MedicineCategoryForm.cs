namespace WebApp.Api.Models;
public class MedicineCategoryForm
{
    public short MedicineCategoryId { get; set; }
    public string MedicineCategoryName { get; set; } = null!;
    public string? Description { get; set; }
    public IFormFile? File { get; set; }
}