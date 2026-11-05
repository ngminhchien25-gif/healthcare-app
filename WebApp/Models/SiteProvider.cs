namespace WebApp.Api.Models;
public class SiteProvider : BaseProvider
{
    public SiteProvider(IConfiguration configuration) : base(configuration){
    }
    MemberRepository? member;
    public MemberRepository Member => member ??= new MemberRepository(Connection);
    // ===== Module C: thuốc và nhắc nhở =====
    MedicineCategoryRepository? medicineCategory;
    public MedicineCategoryRepository MedicineCategory => medicineCategory ??= new MedicineCategoryRepository(Connection);
    MedicineRepository? medicine;
    public MedicineRepository Medicine => medicine ??= new MedicineRepository(Connection);
    PrescriptionRepository? prescription;
    public PrescriptionRepository Prescription => prescription ??= new PrescriptionRepository(Connection);
    ReminderRepository? reminder;
    public ReminderRepository Reminder => reminder ??= new ReminderRepository(Connection);
}