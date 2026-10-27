namespace WebApp.Api.Models;
public class MemberSummary
{
    public string MemberId { get; set; } = null!;
    public string GivenName { get; set; } = null!;
    public string? Surname { get; set; }
    public string Email { get; set; } = null!;
    public Role Role { get; set; }
}