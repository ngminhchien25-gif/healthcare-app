# Module B — Luyện tập

## Rà soát

### Git và phạm vi hiện tại

- Nhánh triển khai: `feature/module-b-training`, tạo từ `origin/main` sau khi fetch.
- Trước khi tạo nhánh, workspace ở `main`, commit `a20c71e`; không có stash.
- Các remote branch lúc rà soát: `origin/main`, `origin/feature/home-checkout`, `origin/feature/reminder`, `origin/feature/reminder-api`. Không thấy Module B trong các ref đã rà soát.
- `Docs/ĐACK_LTĐNT.docx` đã tồn tại và chưa được theo dõi bởi Git; giữ nguyên file này.
- `main` có xác thực, thuốc, đơn thuốc và nhắc nhở. Không có bảng, model, controller, route hoặc package Flutter về bài tập/luyện tập.
- Không triển khai hoặc phụ thuộc Module A.

### Quy ước được rút ra từ code

- SQL Server dùng `INT IDENTITY` cho ID phần lớn bảng; `Member.MemberId` là `NVARCHAR(32)` và được tham chiếu làm khóa ngoại.
- Controller nằm dưới `WebApp/Api/Controllers`, khai báo `[ApiController, Route("api/[controller]")]`; xác thực bằng `[Authorize]`, Admin bằng `[Authorize(Roles = "Admin")]`.
- `BaseController.MemberId` lấy ID từ claim `ClaimTypes.NameIdentifier` (fallback `nameid`). Controller không nhận MemberId từ client để quyết định quyền sở hữu.
- SQL/Dapper repository nằm trong `WebApp/Models`, kế thừa `BaseRepository`, dùng connection từ `SiteProvider`. `SiteProvider` hiện giữ các repository theo property lazy.
- Flutter repository dùng `http` và `ApiHelper.headers()` để gắn Bearer token; route khai báo trong `healthcare_app/lib/main.dart`, menu/truy cập từ `home_page.dart`.
- SQLite (`LocalDatabase`) hiện cache nhóm thuốc, thuốc và nhắc nhở; không có quy ước bắt buộc phải cache mọi module. Module B sẽ dùng API/SQL Server, không thêm SQLite offline cho nhật ký tập luyện trong phạm vi này.
- Không cần package biểu đồ: thống kê sẽ trình bày bằng widget Flutter có sẵn.

## Quyết định thiết kế

1. Bảng `Exercise` lưu danh mục do Admin quản lý; mọi Member đã đăng nhập được xem danh mục. Dùng `ExerciseId INT IDENTITY`, `ExerciseName NVARCHAR(100)`, `Description NVARCHAR(512) NULL`, `MuscleGroup NVARCHAR(64) NULL`, `CaloriesPerMinute DECIMAL(8,2)`, `IsActive BIT`, `CreatedAt DATETIME2`.
2. Bảng `WorkoutLog` lưu buổi tập của Member: `WorkoutLogId INT IDENTITY`, `MemberId NVARCHAR(32)` FK, `ExerciseId INT` FK, `WorkoutDate DATE`, `DurationMinutes SMALLINT CHECK > 0`, `CaloriesBurned DECIMAL(10,2)`, `Note NVARCHAR(256) NULL`, `CreatedAt DATETIME2`. Ràng buộc FK ngăn xóa bài tập đã được dùng trong lịch sử; API xóa danh mục sẽ trả kết quả không thành công khi có log tham chiếu (không cascade/xóa mềm). Admin có thể đặt bài tập thành không hoạt động để ẩn khỏi danh sách Member mà vẫn giữ lịch sử.
3. Calo mỗi buổi được tính phía server lúc tạo/sửa: `Exercise.CaloriesPerMinute * DurationMinutes`, làm tròn hai chữ số theo kiểu `DECIMAL(10,2)`, lưu thành snapshot trong `WorkoutLog.CaloriesBurned`. Thay đổi danh mục về sau không sửa lịch sử đã ghi. Đây là ước tính, không phải đo lường sinh lý.
4. Thống kê tuần được tính từ `WorkoutLog` bằng truy vấn, không tạo bảng tổng hợp. Endpoint nhận ngày bất kỳ trong tuần, chuẩn hóa về thứ Hai; khoảng lấy dữ liệu là `[Monday, next Monday)`. Response có tổng buổi/phút/calo, đủ 7 ngày kể cả ngày 0 và tổng hợp theo bài tập.
5. Tất cả thao tác nhật ký buộc lấy `MemberId` từ JWT và giới hạn query/update/delete theo MemberId. Tạo/sửa kiểm tra bài tập tồn tại và đang hoạt động, thời lượng hợp lệ, ngày không vượt ngày hiện tại, bản ghi thuộc người dùng hiện tại.
6. API danh mục: `GET /api/exercise`, `GET /api/exercise/{id}` cho người dùng có JWT; `POST /api/exercise`, `PUT /api/exercise`, `DELETE /api/exercise/{id}` chỉ Admin. Admin có thể truyền `includeInactive=true` để xem bài tập đã ẩn.
7. API nhật ký dự kiến: `GET /api/workoutlog` (lọc ngày/phân trang), `GET /api/workoutlog/{id}`, `POST /api/workoutlog`, `PUT /api/workoutlog`, `DELETE /api/workoutlog/{id}`, `GET /api/workoutlog/stats/weekly?weekStart=YYYY-MM-DD`; tất cả yêu cầu JWT và chỉ thao tác dữ liệu của chính Member.
8. Giao diện: Member xem danh mục bài tập, danh sách nhật ký và form thêm/sửa, màn hình thống kê tuần; Admin có màn hình quản lý danh mục. Biểu đồ tuần dựng bằng widget Flutter có sẵn. Thêm route trong `main.dart`, mục Member/Admin trong `home_page.dart`, menu Admin chỉ hiện khi role là `Admin`.
9. Script SQL mới phải chạy lặp an toàn, tạo bảng theo thứ tự `Exercise` rồi `WorkoutLog`, sau các script hiện có. Không chỉnh schema Module A.

## Danh sách bảng/cột dự kiến

### Exercise

| Cột | Kiểu | Ràng buộc/ý nghĩa |
|---|---|---|
| ExerciseId | INT | PK, IDENTITY |
| ExerciseName | NVARCHAR(100) | NOT NULL |
| Description | NVARCHAR(512) | NULL |
| MuscleGroup | NVARCHAR(64) | NULL |
| CaloriesPerMinute | DECIMAL(8,2) | NOT NULL, không âm |
| IsActive | BIT | NOT NULL, mặc định 1 |
| CreatedAt | DATETIME2 | NOT NULL, mặc định SYSDATETIME() |

### WorkoutLog

| Cột | Kiểu | Ràng buộc/ý nghĩa |
|---|---|---|
| WorkoutLogId | INT | PK, IDENTITY |
| MemberId | NVARCHAR(32) | FK tới Member, NOT NULL |
| ExerciseId | INT | FK tới Exercise, NOT NULL |
| WorkoutDate | DATE | NOT NULL |
| DurationMinutes | SMALLINT | NOT NULL, CHECK > 0 |
| CaloriesBurned | DECIMAL(10,2) | NOT NULL, snapshot tính tại server |
| Note | NVARCHAR(256) | NULL |
| CreatedAt | DATETIME2 | NOT NULL, mặc định SYSDATETIME() |

## Endpoint và quyền dự kiến

| Method | Path | Quyền |
|---|---|---|
| GET | `/api/exercise` | JWT Member/Admin |
| GET | `/api/exercise/{id}` | JWT Member/Admin |
| POST | `/api/exercise` | Admin |
| PUT | `/api/exercise` | Admin |
| DELETE | `/api/exercise/{id}` | Admin; chặn nếu đã có lịch sử |
| GET | `/api/workoutlog` | JWT, chỉ dữ liệu của chủ token |
| GET | `/api/workoutlog/{id}` | JWT, chỉ bản ghi của chủ token |
| POST | `/api/workoutlog` | JWT; MemberId lấy từ token |
| PUT | `/api/workoutlog` | JWT; chỉ bản ghi của chủ token |
| DELETE | `/api/workoutlog/{id}` | JWT; chỉ bản ghi của chủ token |
| GET | `/api/workoutlog/stats/weekly` | JWT, chỉ dữ liệu của chủ token |

## Tệp đã thêm và sửa

### SQL

- Thêm `Database/07_workout.sql` — tạo hai bảng và dữ liệu mẫu; có kiểm tra tồn tại trước khi tạo.

### Backend

- Thêm `WebApp/Models/Exercise.cs`, `ExerciseRepository.cs`, `WorkoutLog.cs`, `WorkoutLogRepository.cs`.
- Thêm `WebApp/Api/Controllers/ExerciseController.cs` và `WorkoutLogController.cs`.
- Sửa `WebApp/Models/SiteProvider.cs` để đăng ký hai repository mới.

### Flutter

- Thêm model/repository: `exercise.dart`, `workout_log.dart`, `workout_repository.dart`.
- Thêm màn hình: `exercise_page.dart`, `workout_page.dart`, `workout_form_page.dart`, `workout_weekly_page.dart`.
- Sửa `main.dart` để khai báo route `/exercises`, `/workouts`, `/workout-form`, `/workout-weekly`.
- Sửa `home_page.dart`: Member truy cập danh mục, nhật ký và thống kê; Admin có thêm mục quản lý bài tập trong menu role Admin.

## Thứ tự triển khai / chạy script

1. Chạy toàn bộ schema nền hiện tại theo hướng dẫn repo (đặc biệt `00_healthcare_base.sql` để có `Member`).
2. Chạy `Database/07_workout.sql` sau khi database `Healthcare` và bảng `Member` tồn tại. Script tạo `Exercise`, `WorkoutLog` theo thứ tự FK và thêm các bài tập mẫu.
3. Backend — model, repository truy vấn Dapper, controller, đăng ký repository trong `SiteProvider`.
4. Flutter — model, repository, màn hình/route và mục điều hướng.
5. Build backend, chạy analyzer và checklist kiểm thử thủ công. Không tuyên bố runtime SQL Server thành công nếu môi trường không chạy được.

## Checklist kiểm thử thủ công

- [ ] Member/Admin đăng nhập; request không token bị từ chối ở endpoint cần JWT.
- [ ] Member đọc danh mục; Member không tạo/sửa/xóa danh mục.
- [ ] Admin thêm, sửa, xóa bài tập chưa được dùng; xóa bài tập đã có log bị chặn.
- [ ] Member tạo, xem, sửa, xóa nhật ký của mình.
- [ ] Member A không đọc/sửa/xóa log của Member B kể cả khi biết ID.
- [ ] Thời lượng bằng 0/âm, bài tập không tồn tại/ngừng hoạt động, ngày tương lai bị từ chối.
- [ ] Calo lưu đúng phép tính và giữ nguyên sau khi Admin sửa CaloriesPerMinute.
- [ ] Thống kê tuần trả đủ 7 ngày, ngày rỗng bằng 0, tổng hợp đúng theo bài tập.
- [ ] Kiểm tra biên thứ Hai và Chủ nhật; tuần không có dữ liệu.
- [ ] Xác nhận menu Admin chỉ hiện cho role `Admin`.

## Điểm cần chú ý khi tích hợp với main/Module A

- Có thể xung đột ở `main.dart`, `home_page.dart`, `SiteProvider.cs` và thứ tự script SQL; khi gộp giữ riêng block/route của từng module.
- Không dùng hoặc sửa bảng/endpoint Module A. Khi Module A xuất hiện, so sánh tên route, quy tắc role và claim MemberId trước khi hợp nhất.
- Các file cấu hình `.env`, `appsettings.json` và secrets của máy không thuộc thay đổi Module B.
- Kiểm tra encoding tiếng Việt trong file Dart khi merge; chuỗi UI mới dùng tiếng Việt có dấu.

## Theo dõi triển khai

- Các endpoint đúng như bảng thiết kế phía trên đã được triển khai; endpoint nhật ký đều dùng MemberId từ JWT.
- Route/màn hình thực tế: `/exercises` (Member xem, Admin quản lý), `/workouts` (nhật ký), `/workout-form` (thêm/sửa), `/workout-weekly` (thống kê tuần).
- `dotnet build --no-restore`: thành công, 0 lỗi. Lần build đầy đủ đầu tiên có một nullable warning ở `WebApp/Services/EmailService.cs` (không thuộc Module B); build kế tiếp báo 0 warning do incremental build.
- `flutter analyze`: không hoàn tất trong môi trường Windows này. Lần chạy đầu yêu cầu bật Developer Mode để tạo symlink plugin; lần thử `flutter analyze --no-pub` dừng do analysis server nhận JSON LSP bị cắt. Chạy `dart analyze` trực tiếp: không có lỗi Module B; còn 1 warning `.env` không tồn tại và 6 info lint trong file cũ.
- Workspace không có thư mục test Dart/backend test project tương ứng cho module; chưa có kiểm thử runtime với SQL Server.
- Chưa chạy SQL trên SQL Server và chưa kiểm tra UI runtime/API end-to-end.
- Không có thay đổi package. Không commit `.env`, secrets hay file `Docs/ĐACK_LTĐNT.docx` có sẵn.
- Checklist thủ công phía trên là đề xuất, chưa đánh dấu mục nào đã thực hiện.
