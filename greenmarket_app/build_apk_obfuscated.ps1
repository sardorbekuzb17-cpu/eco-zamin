# GreenMarket APK build (obfuscation bilan)

Write-Host "🔨 APK build qilmoqda (kod obfuscation yoqilgan)..." -ForegroundColor Green

flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

Write-Host "`n✅ Tayyor!" -ForegroundColor Green
Write-Host "📦 APK fayl: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Yellow
Write-Host "🔒 Kod obfuscate qilingan - hech kim o'qiy olmaydi!" -ForegroundColor Cyan
Write-Host "📊 Debug symbols: build\app\outputs\symbols (xatolarni tahlil qilish uchun)" -ForegroundColor Yellow
