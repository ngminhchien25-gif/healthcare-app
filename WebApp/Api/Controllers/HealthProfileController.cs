using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApp.Api.Models;
namespace WebApp.Api.Controllers;

[Authorize]
[ApiController, Route("api/[controller]")]
public class HealthProfileController : BaseController
{
    [HttpGet]
    public HealthProfile GetProfile()
    {
        return Provider.HealthProfile.GetByMember(MemberId) ?? new HealthProfile { MemberId = MemberId };
    }

    [HttpPut]
    public int Save(HealthProfile obj)
    {
        if (obj.HeightCm != null && (obj.HeightCm < 50 || obj.HeightCm > 250)) return -2;
        if (obj.Gender < 0 || obj.Gender > 2) return -2;
        if (obj.BloodType != null && obj.BloodType.Trim().Length > 8) return -2;
        if (obj.MedicalHistory != null && obj.MedicalHistory.Length > 512) return -2;

        obj.MemberId = MemberId;
        obj.BloodType = string.IsNullOrWhiteSpace(obj.BloodType) ? null : obj.BloodType.Trim().ToUpper();
        obj.MedicalHistory = string.IsNullOrWhiteSpace(obj.MedicalHistory) ? null : obj.MedicalHistory.Trim();
        return Provider.HealthProfile.Save(obj);
    }
}