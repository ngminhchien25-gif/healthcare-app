using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApp.Api.Models;
using WebApp.Services;

namespace WebApp.Api.Controllers;
[Authorize]
[ApiController, Route("api/[controller]")]
public class MedicineController : BaseController
{
    const string Folder = "medicines";
    [AllowAnonymous, HttpGet]
    public PagedResult<Medicine> GetMedicines(short? categoryId, string? keyword, int page = 1, int pageSize = 10)
    {
        return Provider.Medicine.GetMedicines(categoryId, keyword, page, pageSize);
    }
    [AllowAnonymous, HttpGet("{id:int}")]
    public Medicine? GetMedicine(int id)
    {
        return Provider.Medicine.GetMedicine(id);
    }
    [AllowAnonymous, HttpGet("related/{id:int}")]
    public PagedResult<Medicine> GetRelated(int id, int page = 1, int pageSize = 6)
    {
        Medicine? item = Provider.Medicine.GetMedicine(id);
        if (item == null) return new PagedResult<Medicine> { Page = page, PageSize = pageSize };
        return Provider.Medicine.GetRelated(id, item.MedicineCategoryId, page, pageSize);
    }
    [Authorize(Roles = "Admin"), HttpPost]
    public async Task<int> Add([FromForm] MedicineForm obj)
    {
        if (!ModelState.IsValid) return -2;
        if (obj.File == null) return -3;
        string? image = await FileHelper.SaveAsync(obj.File, Folder, Env);
        if (image == null) return -3;
        int ret = Provider.Medicine.Add(new Medicine
        {
            MedicineCategoryId = obj.MedicineCategoryId,
            MedicineName = obj.MedicineName.Trim(),
            ImageUrl = image,
            Unit = obj.Unit.Trim(),
            Description = obj.Description,
            Precaution = obj.Precaution
        });
        if (ret <= 0) FileHelper.Delete(image, Folder, Env);
        return ret;
    }
    [Authorize(Roles = "Admin"), HttpPut]
    public async Task<int> Edit([FromForm] MedicineForm obj)
    {
        if (!ModelState.IsValid) return -2;
        Medicine? old = Provider.Medicine.GetMedicine(obj.MedicineId);
        if (old == null) return 0;
        string? image = old.ImageUrl;
        string? newImage = null;
        if (obj.File != null)
        {
            newImage = await FileHelper.SaveAsync(obj.File, Folder, Env);
            if (newImage == null) return -3;
            image = newImage;
        }
        int ret = Provider.Medicine.Edit(new Medicine
        {
            MedicineId = obj.MedicineId,
            MedicineCategoryId = obj.MedicineCategoryId,
            MedicineName = obj.MedicineName.Trim(),
            ImageUrl = image,
            Unit = obj.Unit.Trim(),
            Description = obj.Description,
            Precaution = obj.Precaution
        });
        if (newImage != null)
        {
            FileHelper.Delete(ret > 0 ? old.ImageUrl : newImage, Folder, Env);
        }
        return ret;
    }
    [Authorize(Roles = "Admin"), HttpDelete("{id}")]
    public int Delete(int id)
    {
        Medicine? item = Provider.Medicine.GetMedicine(id);
        if (item == null) return 0;
        int ret = Provider.Medicine.Delete(id);
        if (ret > 0) FileHelper.Delete(item.ImageUrl, Folder, Env);
        return ret;
    }
}