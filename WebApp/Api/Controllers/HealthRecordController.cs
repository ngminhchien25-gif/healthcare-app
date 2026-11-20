using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApp.Api.Models;
namespace WebApp.Api.Controllers;

[Authorize]
[ApiController, Route("api/[controller]")]
public class HealthRecordController : BaseController
{
    static bool IsValid(HealthRecord obj)
    {
        if (obj.MetricTypeId <= 0) return false;
        if (obj.Value <= 0 || obj.Value > 1000) return false;
        if (obj.SecondaryValue != null && (obj.SecondaryValue <= 0 || obj.SecondaryValue > 500)) return false;
        if (obj.MeasuredAt == default) return false;
        if (obj.Note != null && obj.Note.Length > 256) return false;
        return true;
    }

    [HttpGet]
    public PagedResult<HealthRecordInfo> GetRecords(short? metricTypeId, DateTime? fromDate, DateTime? toDate, int page = 1, int pageSize = 10)
    {
        return Provider.HealthRecord.GetRecords(MemberId, metricTypeId, fromDate, toDate, page, pageSize);
    }

    [HttpGet("latest")]
    public IEnumerable<HealthRecordInfo> GetLatest()
    {
        return Provider.HealthRecord.GetLatestByMetric(MemberId);
    }

    [HttpGet("chart")]
    public IEnumerable<HealthRecordInfo> GetChart(short metricTypeId, int days = 30)
    {
        if (days < 1) days = 7;
        if (days > 365) days = 365;
        return Provider.HealthRecord.GetChartData(MemberId, metricTypeId, days);
    }

    [HttpGet("bmi")]
    public BmiSummary GetBmi()
    {
        return Provider.HealthRecord.GetBmi(MemberId);
    }

    [HttpPost]
    public int Add(HealthRecord obj)
    {
        if (!IsValid(obj)) return -2;
        obj.MemberId = MemberId;
        obj.Note = string.IsNullOrWhiteSpace(obj.Note) ? null : obj.Note.Trim();
        return Provider.HealthRecord.Add(obj);
    }

    [HttpPut]
    public int Edit(HealthRecord obj)
    {
        if (!IsValid(obj)) return -2;
        obj.MemberId = MemberId;
        obj.Note = string.IsNullOrWhiteSpace(obj.Note) ? null : obj.Note.Trim();
        return Provider.HealthRecord.Edit(obj);
    }

    [HttpDelete("{id:int}")]
    public int Delete(int id)
    {
        return Provider.HealthRecord.Delete(id, MemberId);
    }
}