namespace WebApp.Api.Models;
public class HealthProfile
{
    public string? MemberId { get; set; }
    public decimal? HeightCm { get; set; }
    public DateTime? DateOfBirth { get; set; }
    public short Gender { get; set; }
    public string? BloodType { get; set; }
    public string? MedicalHistory { get; set; }
    public DateTime? UpdatedAt { get; set; }
}