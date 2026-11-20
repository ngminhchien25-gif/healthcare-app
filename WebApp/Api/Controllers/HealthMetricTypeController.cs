using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApp.Api.Models;
namespace WebApp.Api.Controllers;

[Authorize]
[ApiController, Route("api/[controller]")]
public class HealthMetricTypeController : BaseController
{
    static bool IsValid(HealthMetricType obj)
    {
        if (string.IsNullOrWhiteSpace(obj.MetricCode) || obj.MetricCode.Trim().Length > 32) return false;
        if (string.IsNullOrWhiteSpace(obj.MetricName) || obj.MetricName.Trim().Length > 64) return false;
        if (string.IsNullOrWhiteSpace(obj.Unit) || obj.Unit.Trim().Length > 32) return false;
        if (obj.Description != null && obj.Description.Length > 256) return false;
        if (obj.MinNormal != null && obj.MaxNormal != null && obj.MinNormal > obj.MaxNormal) return false;
        return true;
    }

    [HttpGet]
    public IEnumerable<HealthMetricType> GetMetricTypes()
    {
        return Provider.HealthMetricType.GetMetricTypes();
    }

    [HttpGet("{id}")]
    public HealthMetricType? GetMetricType(short id)
    {
        return Provider.HealthMetricType.GetMetricType(id);
    }

    [Authorize(Roles = "Admin"), HttpPost]
    public int Add(HealthMetricType obj)
    {
        if (!IsValid(obj)) return -2;
        obj.MetricCode = obj.MetricCode.Trim().ToUpper();
        obj.MetricName = obj.MetricName.Trim();
        obj.Unit = obj.Unit.Trim();
        obj.Description = obj.Description?.Trim() ?? "";
        return Provider.HealthMetricType.Add(obj);
    }

    [Authorize(Roles = "Admin"), HttpPut]
    public int Edit(HealthMetricType obj)
    {
        if (!IsValid(obj)) return -2;
        obj.MetricCode = obj.MetricCode.Trim().ToUpper();
        obj.MetricName = obj.MetricName.Trim();
        obj.Unit = obj.Unit.Trim();
        obj.Description = obj.Description?.Trim() ?? "";
        return Provider.HealthMetricType.Edit(obj);
    }

    [Authorize(Roles = "Admin"), HttpDelete("{id}")]
    public int Delete(short id)
    {
        HealthMetricType? item = Provider.HealthMetricType.GetMetricType(id);
        if (item == null) return 0;
        return Provider.HealthMetricType.Delete(id);
    }
}