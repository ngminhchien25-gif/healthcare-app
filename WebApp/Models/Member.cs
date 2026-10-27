namespace WebApp.Api.Models;

public class Member
{
    public string? MemberId { get; set; }
    public string GivenName { get; set; } = null!;
    public string? Surname { get; set; }
    public string Email { get; set; } = null!;
    public string Password { get; set; } = null!;
    public Role Role { get; set; }
}