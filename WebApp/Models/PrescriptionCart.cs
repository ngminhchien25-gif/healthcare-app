namespace WebApp.Api.Models;
public class PrescriptionCart
{
    public string? MemberId { get; set; }
    public int MedicineId { get; set; }
    public short Quantity { get; set; }
    public string? DosageNote { get; set; }
}