namespace WebApp.Api.Models;
public class HealthRecord
{
    public int RecordId { get; set; }
    public string? MemberId { get; set; }
    public short MetricTypeId { get; set; }
    public decimal Value { get; set; }
    public decimal? SecondaryValue { get; set; }
    public DateTime MeasuredAt { get; set; }
    public string? Note { get; set; }
}

public class HealthRecordInfo : HealthRecord
{
    public string MetricCode { get; set; } = null!;
    public string MetricName { get; set; } = null!;
    public string Unit { get; set; } = null!;
    public decimal? MinNormal { get; set; }
    public decimal? MaxNormal { get; set; }
}

public class BmiSummary
{
    public decimal? HeightCm { get; set; }
    public decimal? WeightKg { get; set; }
    public decimal? Bmi { get; set; }
    public string Category { get; set; } = "Chưa đủ dữ liệu";
    public DateTime? MeasuredAt { get; set; }
}