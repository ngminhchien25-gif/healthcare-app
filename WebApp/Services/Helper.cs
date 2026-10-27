using System.Diagnostics;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using WebApp.Api.Models;

namespace WebApp.Services;
public static class Helper
{
    public static string GenerateToken(Member obj, IConfiguration configuration)
    {
        List<Claim> claims = new List<Claim> 
        {
            new Claim(ClaimTypes.NameIdentifier, obj.MemberId!),
            new Claim(ClaimTypes.Name, string.IsNullOrEmpty(obj.Surname)?obj.GivenName:obj.Surname+""+obj.GivenName),
            new Claim(ClaimTypes.Email, obj.Email),
            new Claim(ClaimTypes.GivenName, obj.GivenName),
            new Claim(ClaimTypes.Role, obj.Role.ToString()),
        };
        if (!string.IsNullOrEmpty(obj.Surname)) claims.Add(new Claim(ClaimTypes.Surname, obj.Surname));
        JwtSecurityTokenHandler handler = new JwtSecurityTokenHandler();
        SymmetricSecurityKey key = new SymmetricSecurityKey(Encoding.ASCII.GetBytes(configuration["Jwt:SecretKey"]??throw new KeyNotFoundException("Jwt:SecretKey")));
        JwtSecurityToken token = new JwtSecurityToken(
            issuer: configuration["Jwt:Issuer"],
            audience: configuration["Jwt:Audience"],
            claims: claims,
            expires: DateTime.Now.AddDays(int.Parse(configuration["Jwt:Expires"]??throw new KeyNotFoundException("Jwt:Expires"))),
            signingCredentials: new SigningCredentials(key, SecurityAlgorithms.HmacSha256Signature)
        );
        return handler.WriteToken(token);
    }
}