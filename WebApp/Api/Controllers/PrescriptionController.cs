using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApp.Api.Models;

namespace WebApp.Api.Controllers;
[Authorize]
[ApiController, Route("api/[controller]")]
public class PrescriptionController : BaseController
{
    [HttpGet("cart")]
    public IEnumerable<PrescriptionLine> GetCart()
    {
        return Provider.Prescription.GetCart(MemberId);
    }
    [HttpGet("cart/count")]
    public int CountCart()
    {
        return Provider.Prescription.CountCart(MemberId);
    }
    [HttpPost("cart")]
    public int AddCart(PrescriptionCart obj)
    {
        if (obj.Quantity < 1 || obj.Quantity > 1000) return -2;
        if (obj.DosageNote != null && obj.DosageNote.Length > 128) return -2;
        obj.MemberId = MemberId;
        return Provider.Prescription.AddCart(obj);
    }
    [HttpPut("cart")]
    public int UpdateCart(PrescriptionCart obj)
    {
        if (obj.Quantity < 1 || obj.Quantity > 1000) return -2;
        if (obj.DosageNote != null && obj.DosageNote.Length > 128) return -2;
        obj.MemberId = MemberId;
        return Provider.Prescription.UpdateCart(obj);
    }
    [HttpDelete("cart/{medicineId:int}")]
    public int RemoveCart(int medicineId)
    {
        return Provider.Prescription.RemoveCart(MemberId, medicineId);
    }
    [HttpDelete("cart")]
    public int ClearCart()
    {
        return Provider.Prescription.ClearCart(MemberId);
    }

    [HttpPost("checkout")]
    public int Checkout(CheckoutModel obj)
    {
        if (obj.PrescribedDate == default || obj.PrescribedDate.Date > DateTime.Today) return -2;
        if (obj.DoctorName != null && obj.DoctorName.Length > 64) return -2;
        if (obj.Note != null && obj.Note.Length > 256) return -2;
        return Provider.Prescription.Checkout(MemberId, obj);
    }

    [HttpGet]
    public PagedResult<Prescription> GetPrescriptions(string? keyword, DateTime? fromDate, DateTime? toDate, int page = 1, int pageSize = 10)
    {
        return Provider.Prescription.GetPrescriptions(MemberId, keyword, fromDate, toDate, page, pageSize);
    }
    [HttpGet("{id:int}")]
    public PrescriptionInfo? GetPrescription(int id)
    {
        Prescription? item = Provider.Prescription.GetPrescription(id, MemberId);
        if (item == null) return null;
        return new PrescriptionInfo { Prescription = item, Lines = Provider.Prescription.GetLines(id) };
    }
}