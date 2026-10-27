namespace WebApp.Api.Models;
public class LoginResuilt
{
    public bool Success {get; set;} 
    public string? Token {get; set;}
    public string Message {get; set;} = null!;
}