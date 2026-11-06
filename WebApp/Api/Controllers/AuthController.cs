using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebApp.Services;
namespace WebApp.Api.Models;
[ApiController, Route("api/[controller]")]
public class AuthController : BaseController
{
    async Task SendCodeAsync(Member member, short purpose)
    {
        string? code = Provider.EmailCode.CreateCode(member.MemberId!, purpose);
        if (code == null) return;
        EmailService mail = HttpContext.RequestServices.GetRequiredService<EmailService>();
        string subject = purpose == 0 ? "Mã xác thực email" : "Mã đặt lại mật khẩu";
        string body = purpose == 0
            ? $"Mã xác thực email của bạn là {code}. Mã có hiệu lực trong 10 phút."
            : $"Mã đặt lại mật khẩu của bạn là {code}. Mã có hiệu lực trong 10 phút. Nếu bạn không yêu cầu, hãy bỏ qua email này.";
        try
        {
            await mail.SendAsync(member.Email, subject, body);
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
        }
    }

    [HttpPost("register")]
    public async Task<int> Add(Member obj)
    {
        ModelState.Remove(nameof(obj.MemberId));
        if (ModelState.IsValid)
        {
            obj.Role = Role.Member; 
            int ret = Provider.Member.Add(obj);
            if (ret > 0) await SendCodeAsync(obj, 0);
            return ret;
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

    [HttpPost("verify-email/send")]
    public async Task<int> SendVerifyEmail(EmailModel obj)
    {
        Member? member = Provider.Member.GetMemberByEmail(obj.Email.Trim());
        if (member != null && !Provider.EmailCode.IsConfirmed(member.MemberId!))
        {
            await SendCodeAsync(member, 0);
        }
        return 1;
    }
    [HttpPost("verify-email")]
    public int VerifyEmail(VerifyEmailModel obj)
    {
        Member? member = Provider.Member.GetMemberByEmail(obj.Email.Trim());
        if (member == null) return -1;
        int ret = Provider.EmailCode.Verify(member.MemberId!, 0, obj.Code.Trim());
        if (ret == 1) Provider.EmailCode.ConfirmEmail(member.MemberId!);
        return ret;
    }
    [HttpPost("forgot-password")]
    public async Task<int> ForgotPassword(EmailModel obj)
    {
        Member? member = Provider.Member.GetMemberByEmail(obj.Email.Trim());
        if (member != null)
        {
            await SendCodeAsync(member, 1);
        }
        return 1;
    }
    [HttpPost("reset-password")]
    public int ResetPassword(ResetPasswordModel obj)
    {
        if (obj.NewPassword.Length < 6) return -2;
        Member? member = Provider.Member.GetMemberByEmail(obj.Email.Trim());
        if (member == null) return -1;
        int ret = Provider.EmailCode.Verify(member.MemberId!, 1, obj.Code.Trim());
        if (ret == 1)
        {
            Provider.EmailCode.ResetPassword(member.MemberId!, obj.NewPassword);
            Provider.EmailCode.ConfirmEmail(member.MemberId!); 
        }
        return ret;
    }
}