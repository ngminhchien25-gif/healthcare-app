namespace WebApp.Api.Models;
public class SetRoleModel
{
    public string MemberId { get; set; } = null!;
    public Role Role { get; set; }
}