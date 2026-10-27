using Microsoft.AspNetCore.Mvc;
using WebApp.Models;

namespace WebApp.Api.Models;
[ApiController, Route("api/[controller]")]
public class CategoryController : BaseController
{
    public IEnumerable<Category> GetCategory()
    {
        return Provider.Category.GetCategory();
    }
    [HttpGet("{id}")]
    public Category? GetCategory(short id)
    {
        return Provider.Category.GetCategory(id);
    }
    [HttpPost]
    public int Add(Category obj)
    {
        return Provider.Category.Add(obj);
    }
    [HttpPut]
    public int Edit(Category obj)
    {
        return Provider.Category.Edit(obj);
    }
    [HttpDelete("{id}")]
    public int Delete(short id)
    {
        return Provider.Category.Delete(id);
    }
}