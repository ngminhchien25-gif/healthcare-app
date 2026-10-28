namespace WebApp.Api.Models;
public class CheckoutModel
{
    public DateTime PrescribedDate { get; set; }
    public string? DoctorName { get; set; }
    public string? Note { get; set; }
}