namespace WebApp.Api.Models;
public class SiteProvider : BaseProvider
{
    public SiteProvider(IConfiguration configuration) : base(configuration){
    }
    CategoryRepository? category;
    public CategoryRepository Category => category ??= new CategoryRepository(Connection);
    SubCategoryRepository? subCategory;
    public SubCategoryRepository SubCategory => subCategory ??= new SubCategoryRepository(Connection);
    MemberRepository? member;
    public MemberRepository Member => member ??= new MemberRepository(Connection);
    BikeRepository? bike;
    public BikeRepository Bike => bike ??= new BikeRepository(Connection);
}