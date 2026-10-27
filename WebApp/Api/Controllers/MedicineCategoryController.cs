using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApp.Api.Models;
using WebApp.Services;

namespace WebApp.Api.Controllers;
[Authorize]
[ApiController, Route("api/[controller]")]
public class MedicineCategoryController : BaseController
{
    const string Folder = "medicinecategories";
    [HttpGet]
    public IEnumerable<MedicineCategory> GetMedicineCategories()
    {
        return Provider.MedicineCategory.GetMedicineCategories();
    }
    [HttpGet("{id}")]
    public MedicineCategory? GetMedicineCategory(short id)
    {
        return Provider.MedicineCategory.GetMedicineCategory(id);
    }
    [Authorize(Roles = "Admin"), HttpPost]
    public async Task<int> Add([FromForm] MedicineCategoryForm obj)
    {
        if (!ModelState.IsValid) return -2;
        string? icon = null;
        if (obj.File != null)
        {
            icon = await FileHelper.SaveAsync(obj.File, Folder, Env);
            if (icon == null) return -3;
        }
        int ret = Provider.MedicineCategory.Add(new MedicineCategory
        {
            MedicineCategoryName = obj.MedicineCategoryName.Trim(),
            Description = obj.Description ?? "",
            Icon = icon
        });
        if (ret <= 0) FileHelper.Delete(icon, Folder, Env);
        return ret;
    }
    [Authorize(Roles = "Admin"), HttpPut]
    public async Task<int> Edit([FromForm] MedicineCategoryForm obj)
    {
        if (!ModelState.IsValid) return -2;
        MedicineCategory? old = Provider.MedicineCategory.GetMedicineCategory(obj.MedicineCategoryId);
        if (old == null) return 0;
        string? icon = old.Icon;
        string? newIcon = null;
        if (obj.File != null)
        {
            newIcon = await FileHelper.SaveAsync(obj.File, Folder, Env);
            if (newIcon == null) return -3;
            icon = newIcon;
        }
        int ret = Provider.MedicineCategory.Edit(new MedicineCategory
        {
            MedicineCategoryId = obj.MedicineCategoryId,
            MedicineCategoryName = obj.MedicineCategoryName.Trim(),
            Description = obj.Description ?? "",
            Icon = icon
        });
        if (newIcon != null)
        {
            FileHelper.Delete(ret > 0 ? old.Icon : newIcon, Folder, Env);
        }
        return ret;
    }
    [Authorize(Roles = "Admin"), HttpDelete("{id}")]
    public int Delete(short id)
    {
        MedicineCategory? item = Provider.MedicineCategory.GetMedicineCategory(id);
        if (item == null) return 0;
        int ret = Provider.MedicineCategory.Delete(id);
        if (ret > 0) FileHelper.Delete(item.Icon, Folder, Env);
        return ret;
    }
}