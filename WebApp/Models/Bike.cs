using System.Security.Cryptography.X509Certificates;

namespace WebApp.Api.Models;
public class Bike
{
    public int BikeId { get; set;}
    public short SubCategoryId { get; set;}
    public string BikeName { get; set;} = null!;
    public string ImageUrl { get; set;} = null!;
    public decimal Price { get; set;}
    public string? Frame { get; set;}
    public string? Weight { get; set;}
    public string? Drivetrain { get; set;}
    public string? Wheels { get; set;}
    public string? Fork { get; set;}
    public string? RearShock { get; set;}
    public string? Tires { get; set;}
    public string? Brakes { get; set;}
}