# GreenMarket versiyani yangilash va deploy qilish scripti

Write-Host "🚀 GreenMarket versiya yangilash boshlandi..." -ForegroundColor Green

# 1. Dart scriptni ishga tushirish
Write-Host "`n📝 version.js faylini yangilamoqda..." -ForegroundColor Cyan
Set-Location scripts
dart run sync_version.dart
Set-Location ..

# 2. Flutter pub get
Write-Host "`n📦 Dependencies yuklanmoqda..." -ForegroundColor Cyan
flutter pub get

# 3. Version API ni deploy qilish
Write-Host "`n🌐 Version API ni Vercel ga deploy qilmoqda..." -ForegroundColor Cyan
Set-Location ..\greenmarket_api
vercel --prod
Set-Location ..\greenmarket_app

# 4. AAB build qilish (obfuscation bilan)
Write-Host "`n🔨 AAB build qilmoqda (kod obfuscation yoqilgan)..." -ForegroundColor Cyan
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols

# 5. Natija
Write-Host "`n✅ Tayyor!" -ForegroundColor Green
Write-Host "📦 AAB fayl: build\app\outputs\bundle\release\app-release.aab" -ForegroundColor Yellow
Write-Host "🌐 Version API yangilandi va deploy qilindi" -ForegroundColor Yellow
Write-Host "`n📤 Endi Google Play Console ga yuklashingiz mumkin!" -ForegroundColor Cyan
