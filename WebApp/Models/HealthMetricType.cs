namespace WebApp.Api.Models;
public class HealthMetricType
{
    public short MetricTypeId { get; set; }
    public string MetricCode { get; set; } = null!;
    public string MetricName { get; set; } = null!;
    public string Unit { get; set; } = null!;
    public decimal? MinNormal { get; set; }
    public decimal? MaxNormal { get; set; }
    public string Description { get; set; } = "";
}