namespace WebApp.Api.Models;
public class PrescriptionSummary : Prescription
{
    public string MemberName { get; set; } = "";
    public string MemberEmail { get; set; } = "";
}