namespace WebApp.Models
{
    public class Category
    {
        public short CategoryId { get; set; }
        public string CategoryName { get; set; } = null!;
        public string Title { get; set; } = null!;
        public string Description { get; set; } = null!;
        public string Icon { get; set; } = null!;
    }
}