using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using WebApp.Api.Models;
using WebApp.Services;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddCors(options => options.AddPolicy("LocalFlutter", policy =>
    policy.SetIsOriginAllowed(origin =>
    {
        if (!Uri.TryCreate(origin, UriKind.Absolute, out Uri? uri)) return false;
        bool localHost = uri.Host.Equals("localhost", StringComparison.OrdinalIgnoreCase)
            || uri.Host.Equals("127.0.0.1", StringComparison.OrdinalIgnoreCase)
            || uri.Host.Equals("::1", StringComparison.OrdinalIgnoreCase);
        return uri.IsLoopback && localHost && (uri.Scheme == "http" || uri.Scheme == "https");
    })
    .AllowAnyHeader()
    .AllowAnyMethod()));
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
builder.Services.AddScoped<EmailService>();
builder.Services.AddScoped<SiteProvider>();
builder.Services.AddScoped<EmailService>();
builder.Services.AddControllers();
var app = builder.Build();
app.UseStaticFiles();
app.UseRouting();
app.UseCors("LocalFlutter");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
