# Ứng dụng quản lý sức khỏe (Healthcare)

Đồ án môn Lập trình đa nền tảng, đề tài 16: Xây dựng ứng dụng quản lý sức khỏe.

Người dùng tra cứu thông tin thuốc, lưu đơn thuốc cá nhân, đặt lịch nhắc uống thuốc và lịch khám. Tài khoản Admin đóng vai dược sĩ: quản lý danh mục thuốc, thành viên và xác nhận đơn thuốc.

## Công nghệ

| Thành phần | Công nghệ |
|---|---|
| Ứng dụng | Flutter (Dart), chạy thử trên Windows desktop |
| Lưu trữ trên máy | SQLite (`sqflite`, `sqflite_common_ffi`) |
| API | ASP.NET Core Web API, .NET 10, Dapper |
| Cơ sở dữ liệu | SQL Server, database `Healthcare` |
| Xác thực | JWT, mật khẩu băm bằng BCrypt |

## Cấu trúc thư mục

```
MultiblePlatform/
├── WebApp/            API .NET 10: Api/Controllers, Models, Services, wwwroot
├── healthcare_app/    ứng dụng Flutter: lib/ gồm *_page.dart, *_repository.dart và các model
└── Database/          script SQL, chạy theo thứ tự số
```

Mã nguồn bám theo cấu trúc code mẫu của giảng viên:

- Backend: `SiteProvider` giữ các `XxxRepository` (Dapper), controller kế thừa `BaseController`, truy vấn đọc dùng SQL trực tiếp, thao tác có nghiệp vụ dùng stored procedure.
- Flutter: thư mục `lib/` phẳng, mỗi thực thể có model và repository dạng `static`, điều hướng bằng named route trong `main.dart`.

## Cài đặt và chạy

Yêu cầu: .NET SDK 10, Flutter SDK, SQL Server (instance `.`), Visual Studio với workload C++ cho Windows desktop.

1. Tạo cơ sở dữ liệu: chạy các script trong `Database/` theo thứ tự `00`, `03`, `04`, `05`, rồi các script của module A và B khi đã gộp vào `main`.
2. Kiểm tra `WebApp/appsettings.json`: khóa `ConnectionStrings:Healthcare` trỏ tới SQL Server của máy, mục `Jwt` giữ nguyên.
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
| SQLite trên điện thoại | Đã làm | Lưu bộ nhớ đệm nhóm thuốc, thuốc và các nhắc sắp tới, xem được khi mất mạng. Nhắc nhở lưu trên máy bị xóa khi đăng xuất |
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
| Xác thực người dùng qua email | 0.5 | Điểm cộng | Chưa làm |
| Quên mật khẩu | 0.5 | Điểm cộng | Chưa làm |
| Đăng nhập bằng Gmail, Facebook, Zalo | 3 × 0.5 | Điểm cộng | Chưa làm |

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
| Hiển thị danh mục sản phẩm | 0.25 | Bắt buộc | Đã làm. Cần kiểm thử lại sau khi chuyển lên trang chủ |
| Sản phẩm mới nhất có phân trang trên trang chủ | 0.5 | Bắt buộc | Đã làm. Cần kiểm thử lại |
| Sản phẩm theo danh mục, có phân trang | 0.25 | Bắt buộc | Đã làm. Cần kiểm thử lại |
| Tìm kiếm sản phẩm, có phân trang | 0.25 | Bắt buộc | Đã làm. Cần kiểm thử lại |
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
| Chức năng đặt hàng (checkout) | 0.5 | Bắt buộc | Đã làm. Màn hình riêng "Đặt đơn thuốc", cần kiểm thử lại |
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

Dự kiến: hồ sơ sức khỏe, nhập chỉ số theo ngày (cân nặng, huyết áp, nhịp tim, đường huyết), tính BMI, lịch sử và biểu đồ, Admin quản lý danh mục loại chỉ số. Chưa gộp vào `main`.

### Module B: luyện tập (Bảo)

Dự kiến: danh mục bài tập do Admin quản lý, nhật ký luyện tập, calo tiêu hao, thống kê theo tuần. Chưa gộp vào `main`.

## API chính

| Nhóm | Đường dẫn | Quyền |
|---|---|---|
| Xác thực | `POST /api/auth/register`, `POST /api/auth/login`, `PUT /api/auth/password`, `GET /api/auth/me` | Công khai, riêng `password` và `me` cần đăng nhập |
| Thành viên | `GET /api/member`, `PUT /api/member/role`, `DELETE /api/member/{id}` | Admin |
| Nhóm thuốc | `GET /api/medicinecategory`; `POST`, `PUT`, `DELETE` | Đọc: công khai. Ghi: Admin |
| Thuốc | `GET /api/medicine` (nhóm, từ khóa, phân trang), `GET /api/medicine/{id}`, `GET /api/medicine/related/{id}`; `POST`, `PUT`, `DELETE` | Đọc: công khai. Ghi: Admin |
| Đơn thuốc đang soạn | `GET`, `POST`, `PUT`, `DELETE /api/prescription/cart`, `GET /api/prescription/cart/count` | Đăng nhập |
| Đơn thuốc | `POST /api/prescription/checkout`, `GET /api/prescription`, `GET /api/prescription/{id}` | Đăng nhập, chỉ thấy đơn của mình |
| Quản lý đơn thuốc | `GET /api/prescriptionadmin`, `GET /api/prescriptionadmin/{id}`, `PUT /api/prescriptionadmin/review` | Admin |
| Nhắc nhở | `GET /api/reminder`, `GET /api/reminder/upcoming`, `POST`, `PUT`, `PUT /api/reminder/done`, `DELETE /api/reminder/{id}`, `POST /api/reminder/from-prescription` | Đăng nhập, chỉ thấy nhắc của mình |

Các hàm trả mã kết quả dạng số theo quy ước của code mẫu: `1` thành công, `0` không tồn tại, số âm là các lỗi nghiệp vụ (ví dụ `-1` khi nhóm thuốc còn thuốc hoặc thuốc đã nằm trong đơn).

## Cơ sở dữ liệu

| Script | Nội dung |
|---|---|
| `00_healthcare_base.sql` | Database `Healthcare`, bảng `Member`, proc `AddMember` |
| `03_medicine_reminder.sql` | `MedicineCategory`, `Medicine`, `PrescriptionCart`, `Prescription`, `PrescriptionDetail`, `Reminder` và các proc `DeleteMedicineCategory`, `DeleteMedicine`, `AddPrescriptionCart`, `CheckoutPrescription` |
| `04_seed_medicines.sql` | Thêm 5 nhóm thuốc và khoảng 55 sản phẩm mẫu, không kèm liều dùng |
| `05_reminder_prescription.sql` | Thêm cột `PrescriptionId` cho bảng `Reminder` |

## Việc còn lại

- Gộp module A và B vào `main`, kiểm tra ba khối module trong `home_page.dart`, `main.dart`, `SiteProvider.cs`.
- Điểm cộng: quên mật khẩu, xác thực email, đăng nhập mạng xã hội, thanh toán VNPay và VietQR.
- Việt hóa trang đăng nhập và đăng ký.
- Kiểm thử lại các mục đánh dấu "cần kiểm thử lại" trên bản clone mới của `main`.
- Báo cáo và sơ đồ khi giảng viên yêu cầu.

## Hạn chế đã biết

- Vai trò `Customer` chưa được dùng.
- Ô nhập của Flutter trên Windows không nhận được chữ có dấu từ Unikey. Dùng bàn phím Vietnamese Telex có sẵn của Windows, hoặc gõ ở nơi khác rồi dán vào.
- Tạo nhắc từ cùng một đơn thuốc hai lần sẽ cho hai bộ nhắc, hệ thống không chặn trùng.
- Chưa có thông báo hệ thống; nhắc nhở hiển thị trong ứng dụng.
- Bản build release trên Windows cần đặt `sqlite3.dll` cạnh file `.exe`.
- Thông tin thuốc trong ứng dụng chỉ mang tính tham khảo, không thay thế tư vấn của bác sĩ hoặc dược sĩ.

## Làm việc nhóm

| Thành viên | Phụ trách |
|---|---|
| Chiến | Module C (thuốc, đơn thuốc, nhắc nhở), phần xác thực dùng chung |
| Danh | Module A (chỉ số cơ thể) |
| Bảo | Module B (luyện tập) |

- Mỗi việc làm trên nhánh riêng, gộp vào `main` bằng Pull Request.
- Mỗi module chỉ thêm code vào khối của mình trong `SiteProvider.cs`, `main.dart` và `home_page.dart`.
- Mỗi sáng chạy `git fetch` và `git merge origin/main` vào nhánh đang làm.