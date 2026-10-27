using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
namespace WebApp.Api.Models;
[ApiController, Route("api/[controller]")]
public class AuthController : BaseController
{
    [HttpPost("register")]
    public int Add(Member obj)
    {
        ModelState.Remove(nameof(obj.MemberId));
        if (ModelState.IsValid)
        {
            obj.Role = Role.Member; 
            return Provider.Member.Add(obj);
        }
        return -2;
    }
    [HttpPost("login")]
    public LoginResuilt Login(LoginModel obj)
    {
        LoginResuilt resuilt = Provider.Member.Login(obj, HttpContext.RequestServices.GetRequiredService<IConfiguration>());
        return resuilt;
    }
    [Authorize, HttpGet("me")]
    public object Me()
    {
        return new { MemberId, Role = User.FindFirstValue(ClaimTypes.Role) };
    }
    [Authorize, HttpPut("password")]
    public int ChangePassword(ChangePasswordModel obj)
    {
        if (obj.NewPassword.Length < 6) return -2;
        return Provider.Member.ChangePassword(MemberId, obj);
    }
}