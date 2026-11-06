namespace WebApp.Api.Models;
public class VerifyEmailModel
{
    public string Email { get; set; } = null!;
    public string Code { get; set; } = null!;
}