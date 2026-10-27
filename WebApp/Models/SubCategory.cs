namespace WebApp.Api.Models;
public class SubCategory
{
    public short SubCategoryId { get; set; }
    public short CategoryId { get; set; }
    public string SubCategoryName { get; set; } = null!;
    public string Title { get; set; } = null!;
    public string Description { get; set; } = null!;
    public string ImageUrl { get; set; } = null!;
}