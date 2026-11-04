using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApp.Api.Models;

namespace WebApp.Api.Controllers;
[Authorize(Roles = "Admin")]
[ApiController, Route("api/[controller]")]
public class PrescriptionAdminController : BaseController
{
    [HttpGet]
    public PagedResult<PrescriptionSummary> GetPrescriptions(string? keyword, short? status, DateTime? fromDate, DateTime? toDate, int page = 1, int pageSize = 10)
    {
        return Provider.Prescription.GetAllPrescriptions(keyword, status, fromDate, toDate, page, pageSize);
    }
    [HttpGet("{id:int}")]
    public PrescriptionAdminInfo? GetPrescription(int id)
    {
        PrescriptionSummary? item = Provider.Prescription.GetPrescriptionForAdmin(id);
        if (item == null) return null;
        return new PrescriptionAdminInfo { Prescription = item, Lines = Provider.Prescription.GetLines(id) };
    }
    [HttpPut("review")]
    public int Review(ReviewModel obj)
    {
        if (obj.Status < 0 || obj.Status > 2) return -2;
        string? note = string.IsNullOrWhiteSpace(obj.ReviewNote) ? null : obj.ReviewNote.Trim();
        if (note != null && note.Length > 256) return -2;
        if (obj.Status == 2 && note == null) return -3;
        return Provider.Prescription.Review(obj.PrescriptionId, obj.Status, note);
    }
}