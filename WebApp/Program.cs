using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using WebApp.Api.Models;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddAuthentication(p =>
{
    p.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    p.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(p =>
{
    p.TokenValidationParameters = new TokenValidationParameters
    {
        ValidAudience = builder.Configuration["Jwt:Audience"] ?? throw new KeyNotFoundException("Jwt:Audience"),
        ValidIssuer = builder.Configuration["Jwt:Issuer"] ?? throw new KeyNotFoundException("Jwt:Issuer"),
        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.ASCII.GetBytes(builder.Configuration["Jwt:SecretKey"] ?? throw new KeyNotFoundException("Jwt:SecretKey"))
        ),
        ValidateLifetime = true
    };
});
builder.Services.AddScoped<SiteProvider>();
builder.Services.AddMvc();
var app = builder.Build();
app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();
app.MapDefaultControllerRoute();

app.Run();