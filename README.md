Sau khi clone về
cd health-app
Copy-Item healthcare_app\.env.example healthcare_app\.env
cd healthcare_app 
flutter pub get 
cd ..
cd WebApp 
dotnet restore
chạy sql
git checkout -b feature/reminder    # bạn (module C)
git checkout -b feature/metrics     # Danh (module A)
git checkout -b feature/workout     # Bảo (module B)