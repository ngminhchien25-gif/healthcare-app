using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApp.Api.Models;

namespace WebApp.Api.Controllers;
[Authorize(Roles = "Admin")]
[ApiController, Route("api/[controller]")]
public class MemberController : BaseController
{
    [HttpGet]
    public PagedResult<MemberSummary> GetMembers(string? keyword, int page = 1, int pageSize = 10)
    {
        return Provider.Member.GetMembers(keyword, page, pageSize);
    }
    [HttpPut("role")]
    public int SetRole(SetRoleModel obj)
    {
        if (!Enum.IsDefined(obj.Role)) return -2;
        if (obj.MemberId == MemberId) return -3;
        return Provider.Member.SetRole(obj.MemberId, obj.Role);
    }
    [HttpDelete("{id}")]
    public int Delete(string id)
    {
        if (id == MemberId) return -3;
        return Provider.Member.DeleteMember(id);
    }
}