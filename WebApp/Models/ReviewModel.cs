namespace WebApp.Api.Models;
public class ReviewModel
{
    public int PrescriptionId { get; set; }
    public short Status { get; set; }    
    public string? ReviewNote { get; set; }
}