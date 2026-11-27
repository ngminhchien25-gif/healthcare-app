# Ứng dụng quản lý sức khỏe (Healthcare)

Đồ án môn Lập trình đa nền tảng, đề tài 16: Xây dựng ứng dụng quản lý sức khỏe.

Ứng dụng gồm ba nhóm chức năng:

- **Thuốc và nhắc nhở (Module C):** tra cứu thông tin thuốc, lưu đơn thuốc cá nhân, đặt lịch nhắc uống thuốc và lịch khám. Tài khoản Admin đóng vai dược sĩ: quản lý danh mục thuốc, thành viên và xác nhận đơn thuốc.
- **Chỉ số cơ thể (Module A):** hồ sơ sức khỏe, nhập chỉ số theo ngày (cân nặng, huyết áp, nhịp tim, đường huyết), tính BMI, lịch sử và biểu đồ. Admin quản lý danh mục loại chỉ số.
- **Luyện tập (Module B):** danh mục bài tập do Admin quản lý, nhật ký luyện tập, calo tiêu hao ước tính, thống kê theo tuần.

Cả ba module đã nằm trong cùng một mã nguồn (API, ứng dụng Flutter, script SQL).

## Công nghệ

| Thành phần | Công nghệ |
|---|---|
| Ứng dụng | Flutter (Dart), chạy thử trên Windows desktop |
| Lưu trữ trên máy | SQLite (`sqflite`, `sqflite_common_ffi`) |
| API | ASP.NET Core Web API, .NET 10, Dapper |
| Cơ sở dữ liệu | SQL Server, database `Healthcare` |
| Xác thực | JWT, mật khẩu băm bằng BCrypt |
| Gửi email | MailKit (SMTP), dùng cho mã xác thực email và mã đặt lại mật khẩu |

Các package Flutter chính: `http`, `flutter_dotenv`, `flutter_secure_storage`, `file_picker`, `sqflite`, `sqflite_common_ffi`, `path`, `path_provider`. Biểu đồ chỉ số và thống kê tuần dựng bằng widget Flutter có sẵn, không dùng package biểu đồ.

## Cấu trúc thư mục

```
MultiblePlatform/
├── WebApp/            API .NET 10: Api/Controllers, Models, Services, wwwroot
├── healthcare_app/    ứng dụng Flutter: lib/ gồm *_page.dart, *_repository.dart và các model
├── Database/          script SQL, chạy theo thứ tự số
└── Docs/              báo cáo (ĐACK_LTĐNT.docx) và ghi chú thiết kế Module B (ModuleB_Notes.md)
```

Mã nguồn bám theo cấu trúc code mẫu của giảng viên:

- Backend: `SiteProvider` giữ các `XxxRepository` (Dapper), controller kế thừa `BaseController`, truy vấn đọc dùng SQL trực tiếp, thao tác có nghiệp vụ dùng stored procedure. `MemberId` luôn lấy từ JWT, không nhận từ client.
- Flutter: thư mục `lib/` phẳng, mỗi thực thể có model và repository dạng `static`, điều hướng bằng named route trong `main.dart`, menu trong `home_page.dart`. Mỗi module có khối riêng trong `main.dart`, `home_page.dart` và `SiteProvider.cs`.

## Cài đặt và chạy

Yêu cầu: .NET SDK 10, Flutter SDK, SQL Server (instance `.`), Visual Studio với workload C++ cho Windows desktop.

1. Tạo cơ sở dữ liệu: chạy các script trong `Database/` theo thứ tự `00`, `01`, `03`, `04`, `05`, `06`, `07` (không có script `02`). Các script đều kiểm tra tồn tại trước khi tạo nên chạy lại được.
2. Kiểm tra `WebApp/appsettings.json`:
   - `ConnectionStrings:Healthcare` trỏ tới SQL Server của máy.
   - Mục `Jwt` giữ nguyên.
   - Mục `Smtp` điền `User` và `Password` (ví dụ tài khoản Mailtrap sandbox) nếu muốn thử gửi mã email. Để trống thì API vẫn chạy, chỉ không gửi được email (lỗi được ghi ra console).
3. Chạy API:
   ```powershell
   cd WebApp
   dotnet watch run
   ```
   API lắng nghe tại `http://localhost:5114`.
4. Chạy ứng dụng:
   ```powershell
   cd healthcare_app
   Copy-Item .env.example .env
   flutter pub get
   flutter run -d windows
   ```
   `.env` có một khóa `API_URL` (mặc định `http://localhost:5114`).
5. Tạo tài khoản Admin: đăng ký một tài khoản trong ứng dụng, chạy câu lệnh dưới đây rồi đăng nhập lại (vai trò nằm trong token).
   ```sql
   USE Healthcare;
   UPDATE Member SET Role = 2 WHERE Email = 'email-admin';
   ```

Vai trò: `0` Member, `1` Customer (chưa dùng), `2` Admin.

Ảnh tải lên được lưu trong `WebApp/wwwroot/medicines` và `WebApp/wwwroot/medicinecategories`, hai thư mục này không đưa vào Git.

## Quy đổi chức năng của bảng yêu cầu sang đề tài sức khỏe

| Bảng yêu cầu | Trong ứng dụng |
|---|---|
| Doanh mục | Nhóm thuốc |
| Sản phẩm | Thuốc |
| Giỏ hàng | Đơn thuốc đang soạn |
| Đặt hàng (checkout) | Đặt đơn thuốc |
| Đơn hàng | Đơn thuốc đã lưu |
| Admin cập nhật trạng thái đơn | Dược sĩ (Admin) xác nhận hoặc từ chối đơn, kèm ý kiến |

Ứng dụng không có giá và thanh toán vì thông tin này không phù hợp với việc quản lý sức khỏe cá nhân.

## Đối chiếu với yêu cầu của giảng viên

Nguồn: https://ceb.net.vn/flutter/requirement.html. Điểm ghi theo bảng yêu cầu, chưa gồm phần điểm dùng API.

### Công nghệ bắt buộc

| Yêu cầu | Tình trạng | Ghi chú |
|---|---|---|
| Flutter (Dart) | Đã làm | |
| SQLite trên điện thoại | Đã làm | Lưu bộ nhớ đệm nhóm thuốc, thuốc và các nhắc sắp tới, xem được khi mất mạng. Nhắc nhở lưu trên máy bị xóa khi đăng xuất. Module A và B không dùng SQLite |
| REST API C# .NET 10 và SQL Server | Đã làm | |

### Nhóm xác thực người dùng

| Chức năng | Điểm | Loại | Tình trạng |
|---|---|---|---|
| Đăng ký người dùng | 0.25 | Bắt buộc | Đã làm. Server luôn gán vai trò Member |
| Đăng nhập | 0.25 | Bắt buộc | Đã làm |
| Đổi mật khẩu | 0.25 | Bắt buộc | Đã làm. Mật khẩu mới tối thiểu 6 ký tự |
| Quản lý member | 0.25 | Bắt buộc | Đã làm. Tìm kiếm, phân trang, xóa |
| Quản lý role người dùng | 0.5 | Bắt buộc | Đã làm. Đổi role có hiệu lực sau khi người đó đăng nhập lại |
| Đăng xuất | 0.25 | Bắt buộc | Đã làm |
| Phân quyền Member và Admin | 0.5 | Bắt buộc | Đã làm. Kiểm tra ở API và ở menu |
| Xác thực người dùng qua email | 0.5 | Điểm cộng | Đã làm phần API (gửi và kiểm tra mã 6 số). Chưa có màn hình Flutter, đăng nhập chưa bắt buộc đã xác thực |
| Quên mật khẩu | 0.5 | Điểm cộng | Đã làm phần API (gửi mã, đặt lại mật khẩu). Chưa có màn hình Flutter |
| Đăng nhập bằng Gmail, Facebook, Zalo | 3 × 0.5 | Điểm cộng | Chưa làm |

Cách hoạt động của mã email (cùng bảng `EmailCode`, cột `Purpose`: `0` xác thực email, `1` đặt lại mật khẩu):

- Mã 6 số ngẫu nhiên, lưu dạng băm BCrypt, hiệu lực 10 phút.
- Chỉ gửi lại sau 60 giây; mã mới làm mã cũ chưa dùng hết hiệu lực.
- Nhập sai quá 5 lần thì mã bị khóa.
- Các endpoint gửi mã luôn trả `1` dù email có tồn tại hay không, để không lộ email nào đã đăng ký.
- Đặt lại mật khẩu thành công thì đồng thời đánh dấu email đã xác nhận. Tài khoản có sẵn trước khi thêm cột `EmailConfirmed` được đặt là đã xác nhận.

### Quản lý danh mục (nhóm thuốc), dành cho Admin

| Chức năng | Điểm | Loại | Tình trạng |
|---|---|---|---|
| Hiển thị danh mục | 0.25 | Bắt buộc | Đã làm |
| Thêm danh mục | 0.25 | Bắt buộc | Đã làm |
| Xóa danh mục | 0.25 | Bắt buộc | Đã làm |
| Kiểm tra danh mục còn sản phẩm trước khi xóa | 0.25 | Bắt buộc | Đã làm |
| Sửa danh mục | 0.25 | Bắt buộc | Đã làm |
| Upload hình ảnh cho cả 3 trường hợp (thêm, xóa, sửa) | 0.75 | Điểm cộng | Đã làm |

### Quản lý sản phẩm (thuốc) theo từng danh mục

| Chức năng | Điểm | Loại | Tình trạng |
|---|---|---|---|
| Hiển thị sản phẩm có phân trang | 0.5 | Bắt buộc | Đã làm. Lọc theo nhóm, tìm kiếm |
| Thêm sản phẩm, bắt buộc có ảnh | 0.5 | Bắt buộc | Đã làm |
| Xóa sản phẩm, xóa cả ảnh | 0.5 | Bắt buộc | Đã làm |
| Sửa sản phẩm, đổi ảnh thì xóa ảnh cũ | 0.5 | Bắt buộc | Đã làm |
| Kiểm tra sản phẩm có trong đơn hàng trước khi xóa | 0.5 | Điểm cộng | Đã làm |

### Hiển thị sản phẩm trên trang chủ

| Chức năng | Điểm | Loại | Tình trạng |
|---|---|---|---|
| Hiển thị danh mục sản phẩm | 0.25 | Bắt buộc | Đã làm |
| Sản phẩm mới nhất có phân trang trên trang chủ | 0.5 | Bắt buộc | Đã làm |
| Sản phẩm theo danh mục, có phân trang | 0.25 | Bắt buộc | Đã làm |
| Tìm kiếm sản phẩm, có phân trang | 0.25 | Bắt buộc | Đã làm |
| Chi tiết sản phẩm | 0.25 | Bắt buộc | Đã làm |
| Sản phẩm liên quan, có phân trang | 0.25 | Điểm cộng | Đã làm |

Khách chưa đăng nhập xem được danh mục, thuốc và chi tiết thuốc.

### Quản lý giỏ hàng (đơn thuốc đang soạn)

| Chức năng | Điểm | Loại | Tình trạng |
|---|---|---|---|
| Đặt nút thêm vào giỏ hàng | 0.25 | Bắt buộc | Đã làm |
| Thêm sản phẩm vào giỏ hàng | 0.25 | Bắt buộc | Đã làm |
| Hiển thị số lượng sản phẩm trên icon giỏ hàng | 0.25 | Bắt buộc | Đã làm |
| Hiển thị giỏ hàng | 0.25 | Bắt buộc | Đã làm |
| Cập nhật số lượng trên giỏ hàng | 0.5 | Bắt buộc | Đã làm |
| Xóa sản phẩm trên giỏ hàng | 0.25 | Bắt buộc | Đã làm |
| Chức năng đặt hàng (checkout) | 0.5 | Bắt buộc | Đã làm. Màn hình riêng "Đặt đơn thuốc" |
| Hiển thị chi tiết đơn hàng | 0.25 | Bắt buộc | Đã làm |
| Tìm kiếm đơn hàng | 0.25 | Điểm cộng | Đã làm. Tìm theo bác sĩ, ghi chú, khoảng ngày kê |
| Thanh toán online VNPay, VietQR | 2 × 0.5 | Điểm cộng | Chưa làm. Ứng dụng chưa có giá |

### Quản lý đơn hàng (đơn thuốc), dành cho Admin

| Chức năng | Điểm | Loại | Tình trạng |
|---|---|---|---|
| Hiển thị danh sách đơn hàng | 0.25 | Bắt buộc | Đã làm |
| Cập nhật trạng thái đơn hàng | 0.5 | Bắt buộc | Đã làm. Chờ xác nhận, Đã xác nhận, Từ chối |
| Tìm kiếm đơn hàng | 0.25 | Điểm cộng | Đã làm. Tìm theo thành viên, email, bác sĩ, ghi chú |
| Lọc đơn hàng theo ngày | 0.25 | Điểm cộng | Đã làm. Có thêm lọc theo trạng thái |

## Chức năng riêng của đề tài

Bảng yêu cầu ghi rõ chức năng ngoài bảng phải giải trình để quy đổi điểm. Các chức năng dưới đây thuộc phạm vi sức khỏe.

### Module C: thuốc, đơn thuốc, nhắc nhở

| Chức năng | Tình trạng |
|---|---|
| Thông tin thuốc chung (mô tả, lưu ý), kèm ghi chú chỉ mang tính tham khảo | Đã làm |
| Đơn thuốc cá nhân: ngày kê, bác sĩ kê đơn, ghi chú, liều dùng do người dùng nhập theo chỉ định của bác sĩ | Đã làm |
| Dược sĩ xác nhận hoặc từ chối đơn kèm ý kiến, người dùng xem trạng thái và ý kiến | Đã làm |
| Xem danh mục thuốc khi mất mạng nhờ SQLite | Đã làm |
| Nhắc nhở uống thuốc và lịch khám: thêm, sửa, xóa, đánh dấu đã xong, lọc theo loại và trạng thái, tìm kiếm, phân trang | Đã làm |
| Mục "Nhắc sắp tới" trên trang chủ, nhắc quá hạn hiển thị màu đỏ | Đã làm |
| Tạo lịch nhắc uống thuốc từ đơn đã xác nhận, người dùng chọn ngày bắt đầu, số ngày và các giờ trong ngày | Đã làm |
| Xem các nhắc sắp tới khi mất mạng nhờ SQLite | Đã làm |

### Module A: chỉ số cơ thể (Danh)

| Chức năng | Tình trạng |
|---|---|
| Admin quản lý danh mục loại chỉ số (mã, tên, đơn vị, khoảng bình thường, mô tả): xem, thêm, sửa, xóa. Có sẵn 4 loại: cân nặng, huyết áp, nhịp tim, đường huyết | Đã làm |
| Chặn xóa loại chỉ số đã có bản ghi (stored procedure `DeleteHealthMetricType` trả `-1`) | Đã làm |
| Hồ sơ sức khỏe cá nhân, mỗi thành viên một hồ sơ: chiều cao, ngày sinh, giới tính, nhóm máu, tiền sử bệnh | Đã làm |
| Nhập, sửa, xóa chỉ số theo ngày, chỉ số huyết áp có thêm giá trị thứ hai (`SecondaryValue`), có ghi chú | Đã làm |
| Lịch sử chỉ số: lọc theo loại chỉ số và khoảng ngày, phân trang | Đã làm |
| Chỉ số mới nhất của từng loại | Đã làm |
| Biểu đồ chỉ số theo số ngày gần nhất (1 đến 365 ngày) | Đã làm |
| Tính BMI từ cân nặng mới nhất và chiều cao trong hồ sơ, phân loại theo ngưỡng 18.5, 25, 30 | Đã làm |

Kiểm tra dữ liệu ở API: giá trị chỉ số lớn hơn 0 và không quá 1000, giá trị thứ hai không quá 500, ghi chú tối đa 256 ký tự. Hồ sơ và chỉ số luôn gắn với `MemberId` trong token.

### Module B: luyện tập (Bảo)

| Chức năng | Tình trạng |
|---|---|
| Admin quản lý danh mục bài tập (tên, mô tả, nhóm cơ, calo mỗi phút, ẩn hoặc hiện). Member đã đăng nhập được xem. Có sẵn 3 bài mẫu: đi bộ, đạp xe, chạy bộ | Đã làm |
| Chặn xóa bài tập đã có trong nhật ký; Admin có thể đặt bài tập ngừng hoạt động để ẩn khỏi Member mà vẫn giữ lịch sử | Đã làm |
| Nhật ký luyện tập: thêm, sửa, xóa, xem chi tiết, lọc theo ngày, phân trang | Đã làm |
| Calo tiêu hao tính ở server khi tạo hoặc sửa: calo mỗi phút × số phút, làm tròn 2 chữ số, lưu cố định trong nhật ký nên sửa danh mục sau này không đổi lịch sử. Đây là số ước tính | Đã làm |
| Thống kê tuần: nhận ngày bất kỳ, quy về thứ Hai, trả tổng buổi, phút, calo, đủ 7 ngày (kể cả ngày không tập) và tổng hợp theo bài tập | Đã làm |

Kiểm tra dữ liệu: thời lượng lớn hơn 0, bài tập phải tồn tại và đang hoạt động, ngày tập không vượt ngày hiện tại, chỉ thao tác trên nhật ký của chính mình. Chi tiết thiết kế nằm trong `Docs/ModuleB_Notes.md`.

## API chính

| Nhóm | Đường dẫn | Quyền |
|---|---|---|
| Xác thực | `POST /api/auth/register`, `POST /api/auth/login`, `PUT /api/auth/password`, `GET /api/auth/me` | Công khai, riêng `password` và `me` cần đăng nhập |
| Email và quên mật khẩu | `POST /api/auth/verify-email/send`, `POST /api/auth/verify-email`, `POST /api/auth/forgot-password`, `POST /api/auth/reset-password` | Công khai |
| Thành viên | `GET /api/member`, `PUT /api/member/role`, `DELETE /api/member/{id}` | Admin |
| Nhóm thuốc | `GET /api/medicinecategory`; `POST`, `PUT`, `DELETE` | Đọc: công khai. Ghi: Admin |
| Thuốc | `GET /api/medicine` (nhóm, từ khóa, phân trang), `GET /api/medicine/{id}`, `GET /api/medicine/related/{id}`; `POST`, `PUT`, `DELETE` | Đọc: công khai. Ghi: Admin |
| Đơn thuốc đang soạn | `GET`, `POST`, `PUT`, `DELETE /api/prescription/cart`, `DELETE /api/prescription/cart/{medicineId}`, `GET /api/prescription/cart/count` | Đăng nhập |
| Đơn thuốc | `POST /api/prescription/checkout`, `GET /api/prescription`, `GET /api/prescription/{id}` | Đăng nhập, chỉ thấy đơn của mình |
| Quản lý đơn thuốc | `GET /api/prescriptionadmin`, `GET /api/prescriptionadmin/{id}`, `PUT /api/prescriptionadmin/review` | Admin |
| Nhắc nhở | `GET /api/reminder`, `GET /api/reminder/upcoming`, `GET /api/reminder/{id}`, `POST`, `PUT`, `PUT /api/reminder/done`, `DELETE /api/reminder/{id}`, `POST /api/reminder/from-prescription` | Đăng nhập, chỉ thấy nhắc của mình |
| Loại chỉ số (Module A) | `GET /api/healthmetrictype`, `GET /api/healthmetrictype/{id}`; `POST`, `PUT`, `DELETE` | Đọc: đăng nhập. Ghi: Admin |
| Hồ sơ sức khỏe (Module A) | `GET /api/healthprofile`, `PUT /api/healthprofile` | Đăng nhập, chỉ hồ sơ của mình |
| Chỉ số sức khỏe (Module A) | `GET /api/healthrecord` (loại, khoảng ngày, phân trang), `GET /api/healthrecord/latest`, `GET /api/healthrecord/chart`, `GET /api/healthrecord/bmi`, `POST`, `PUT`, `DELETE /api/healthrecord/{id}` | Đăng nhập, chỉ dữ liệu của mình |
| Bài tập (Module B) | `GET /api/exercise`, `GET /api/exercise/{id}`; `POST`, `PUT`, `DELETE /api/exercise/{id}` | Đọc: đăng nhập. Ghi: Admin |
| Nhật ký luyện tập (Module B) | `GET /api/workoutlog` (khoảng ngày, phân trang), `GET /api/workoutlog/{id}`, `POST`, `PUT`, `DELETE /api/workoutlog/{id}`, `GET /api/workoutlog/stats/weekly` | Đăng nhập, chỉ nhật ký của mình |

Các hàm trả mã kết quả dạng số theo quy ước của code mẫu: `1` thành công, `0` không tồn tại, số âm là các lỗi nghiệp vụ (ví dụ `-1` khi nhóm thuốc còn thuốc, thuốc đã nằm trong đơn, loại chỉ số còn bản ghi; `-2` khi dữ liệu không hợp lệ).

## Giao diện Flutter

| Route | Màn hình | Ai dùng |
|---|---|---|
| `/` | Trang chủ: lời chào, menu theo module, mục "Nhắc sắp tới", số thuốc trong đơn đang soạn | Tất cả |
| `/login`, `/register`, `/change-password` | Đăng nhập, đăng ký, đổi mật khẩu | Khách / Member |
| `/members` | Quản lý thành viên | Admin |
| `/medicines`, `/medicine-detail` | Tra cứu thuốc, chi tiết thuốc | Tất cả |
| `/prescription-cart`, `/prescription-checkout`, `/prescriptions`, `/prescription-detail` | Soạn, đặt và xem đơn thuốc | Member |
| `/reminders`, `/reminder-form`, `/reminder-from-prescription` | Nhắc nhở | Member |
| `/medicine-categories`, `/medicine-manage`, `/prescription-admin` | Quản lý nhóm thuốc, thuốc, duyệt đơn | Admin |
| `/health-records`, `/health-record-form`, `/health-profile`, `/health-chart` | Chỉ số, hồ sơ sức khỏe, biểu đồ | Member |
| `/health-metric-types`, `/health-metric-type-form` | Quản lý loại chỉ số | Admin |
| `/exercises` | Danh mục bài tập (Member xem, Admin quản lý) | Member / Admin |
| `/workouts`, `/workout-form`, `/workout-weekly` | Nhật ký luyện tập, thêm hoặc sửa, thống kê tuần | Member |

Menu Admin chỉ hiện khi vai trò trong token là `Admin`.

## Cơ sở dữ liệu

| Script | Nội dung |
|---|---|
| `00_healthcare_base.sql` | Database `Healthcare`, bảng `Member`, proc `AddMember` |
| `01_module_a_health.sql` | `HealthMetricType` (kèm 4 loại chỉ số mẫu), `HealthProfile`, `HealthRecord`, proc `DeleteHealthMetricType` |
| `03_medicine_reminder.sql` | `MedicineCategory`, `Medicine`, `PrescriptionCart`, `Prescription`, `PrescriptionDetail`, `Reminder` và các proc `DeleteMedicineCategory`, `DeleteMedicine`, `AddPrescriptionCart`, `CheckoutPrescription` |
| `04_seed_medicines.sql` | Thêm 5 nhóm thuốc và khoảng 55 sản phẩm mẫu, không kèm liều dùng |
| `05_reminder_prescription.sql` | Thêm cột `PrescriptionId` cho bảng `Reminder` |
| `06_email_auth.sql` | Thêm cột `Member.EmailConfirmed` (tài khoản có sẵn được đặt là đã xác nhận), bảng `EmailCode` |
| `07_workout.sql` | `Exercise`, `WorkoutLog` và 3 bài tập mẫu |

## Kiểm thử

Các chức năng của cả ba module đã được nhóm kiểm thử thủ công trên máy (API, giao diện Flutter và SQL Server). Checklist kiểm thử Module B nằm trong `Docs/ModuleB_Notes.md`. Chưa có dự án kiểm thử tự động.

## Việc còn lại

- Làm màn hình Flutter cho xác thực email và quên mật khẩu (API đã có), quyết định có bắt buộc xác thực email khi đăng nhập hay không.
- Điểm cộng chưa làm: đăng nhập mạng xã hội, thanh toán VNPay và VietQR.
- Việt hóa trang đăng nhập và đăng ký (hiện còn nhãn tiếng Anh).
- Báo cáo và sơ đồ khi giảng viên yêu cầu.

## Hạn chế đã biết

- Vai trò `Customer` chưa được dùng.
- Ô nhập của Flutter trên Windows không nhận được chữ có dấu từ Unikey. Dùng bàn phím Vietnamese Telex có sẵn của Windows, hoặc gõ ở nơi khác rồi dán vào.
- Tạo nhắc từ cùng một đơn thuốc hai lần sẽ cho hai bộ nhắc, hệ thống không chặn trùng.
- Chưa có thông báo hệ thống; nhắc nhở hiển thị trong ứng dụng.
- Module A và B không có bản lưu offline; chỉ Module C (nhóm thuốc, thuốc, nhắc sắp tới) dùng SQLite.
- Calo luyện tập và BMI chỉ là số ước tính, không thay thế đo lường hay tư vấn y tế.
- Thông tin thuốc trong ứng dụng chỉ mang tính tham khảo, không thay thế tư vấn của bác sĩ hoặc dược sĩ.
- Bản build release trên Windows cần đặt `sqlite3.dll` cạnh file `.exe`.
- `appsettings.json` đang chứa khóa JWT mẫu dùng chung cho cả nhóm. Khi triển khai thật phải đổi khóa và không đưa thông tin SMTP thật vào Git.

## Làm việc nhóm

| Thành viên | Phụ trách |
|---|---|
| Chiến | Module C (thuốc, đơn thuốc, nhắc nhở), phần xác thực dùng chung |
| Danh | Module A (chỉ số cơ thể) |
| Bảo | Module B (luyện tập) |

- Mỗi việc làm trên nhánh riêng, gộp vào `main` bằng Pull Request.
- Mỗi module chỉ thêm code vào khối của mình trong `SiteProvider.cs`, `main.dart` và `home_page.dart`.
- Mỗi sáng chạy `git fetch` và `git merge origin/main` vào nhánh đang làm.
