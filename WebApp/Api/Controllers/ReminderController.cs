using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApp.Api.Models;

namespace WebApp.Api.Controllers;
[Authorize]
[ApiController, Route("api/[controller]")]
public class ReminderController : BaseController
{
    static bool IsValid(Reminder obj)
    {
        if (string.IsNullOrWhiteSpace(obj.Title) || obj.Title.Trim().Length > 128) return false;
        if (obj.ReminderType < 0 || obj.ReminderType > 2) return false;
        if (obj.RemindAt == default) return false;
        if (obj.Note != null && obj.Note.Length > 256) return false;
        return true;
    }

    [HttpGet]
    public PagedResult<Reminder> GetReminders(short? type, bool? isDone, string? keyword, DateTime? fromDate, DateTime? toDate, int page = 1, int pageSize = 10)
    {
        return Provider.Reminder.GetReminders(MemberId, type, isDone, keyword, fromDate, toDate, page, pageSize);
    }
    [HttpGet("upcoming")]
    public IEnumerable<Reminder> GetUpcoming(int limit = 5)
    {
        if (limit < 1) limit = 1;
        if (limit > 50) limit = 50;
        return Provider.Reminder.GetUpcoming(MemberId, limit);
    }
    [HttpGet("{id:int}")]
    public Reminder? GetReminder(int id)
    {
        return Provider.Reminder.GetReminder(id, MemberId);
    }
    [HttpPost]
    public int Add(Reminder obj)
    {
        if (!IsValid(obj)) return -2;
        obj.MemberId = MemberId;
        obj.Title = obj.Title.Trim();
        return Provider.Reminder.Add(obj);
    }
    [HttpPut]
    public int Edit(Reminder obj)
    {
        if (!IsValid(obj)) return -2;
        obj.MemberId = MemberId;
        obj.Title = obj.Title.Trim();
        return Provider.Reminder.Edit(obj);
    }
    [HttpPut("done")]
    public int SetDone(ReminderDoneModel obj)
    {
        return Provider.Reminder.SetDone(obj.ReminderId, MemberId, obj.IsDone);
    }
    [HttpDelete("{id:int}")]
    public int Delete(int id)
    {
        return Provider.Reminder.Delete(id, MemberId);
    }
    [HttpPost("from-prescription")]
    public int CreateFromPrescription(ReminderFromPrescriptionModel obj)
    {
        if (obj.Days < 1 || obj.Days > 30) return -2;
        if (obj.Times.Count < 1 || obj.Times.Count > 6) return -2;
        HashSet<TimeOnly> times = new HashSet<TimeOnly>();
        foreach (string t in obj.Times)
        {
            if (!TimeOnly.TryParseExact(t, "HH:mm", out TimeOnly time)) return -2;
            times.Add(time);
        }
        if (times.Count != obj.Times.Count) return -2; 
        return Provider.Reminder.CreateFromPrescription(
            MemberId, obj.PrescriptionId, obj.StartDate.Date, obj.Days, times.OrderBy(t => t).ToList());
    }
}