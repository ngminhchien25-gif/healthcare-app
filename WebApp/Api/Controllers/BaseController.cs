using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;

namespace WebApp.Api.Models;
public abstract class BaseController : ControllerBase
{
    SiteProvider? provider;
    protected SiteProvider Provider => provider ??= HttpContext.RequestServices.GetRequiredService<SiteProvider>();
    protected IWebHostEnvironment Env => HttpContext.RequestServices.GetRequiredService<IWebHostEnvironment>();
    protected string MemberId => User.FindFirstValue(ClaimTypes.NameIdentifier)
        ?? User.FindFirstValue("nameid")
        ?? throw new UnauthorizedAccessException("MemberId");
}