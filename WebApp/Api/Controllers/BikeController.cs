using Microsoft.AspNetCore.Mvc;
using WebApp.Api.Models;

namespace WebApp.Api.Controllers;
[ApiController, Route("api/[controller]")]
public class BikeController : BaseController
{
    [HttpGet]
    public IEnumerable<Bike> GetBikes()
    {
        return Provider.Bike.GetBikes();
    }
    [HttpGet("{id}")]
    public IEnumerable<Bike> GetBikesByCategory(short id)
    {
        return Provider.Bike.GetBikesByCategory(id);
    }
    [HttpPost]
    public IEnumerable<Bike> GetBikesBySubCategories(short[] ids)
    {
        return Provider.Bike.GetBikesBySubCategories(ids);
    }
    [HttpGet("details/{id}")]
    public Bike? GetBike(int id)
    {
        return Provider.Bike.GetBike(id);
    }
    [HttpGet("relation/{id}/{subCategoryId}")]
    public IEnumerable<Bike> GetBikesRelation(int id, short subCategoryId)
    {
        return Provider.Bike.GetBikesRelation(id, subCategoryId);
    }
}