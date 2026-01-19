# GreenMarket APK Urnatish Qo'llanma

## APK Fayli

**Joylashuvi**: `greenmarket_app/build/app/outputs/flutter-apk/app-release.apk`
**Hajmi**: 126.0 MB
**Versiya**: Release

## Urnatish Usullari

### 1️⃣ ADB (Android Debug Bridge) Orqali

```bash
# Device'ni ulanish
adb devices

# APK'ni urnatish
adb install greenmarket_app/build/app/outputs/flutter-apk/app-release.apk

# Yoki qayta urnatish (eski versiyani o'chirish)
adb install -r greenmarket_app/build/app/outputs/flutter-apk/app-release.apk
```

### 2️⃣ File Manager Orqali (Manual)

1. APK faylini USB orqali device'ga ko'chirish
2. Device'da File Manager'ni ochish
3. APK faylini topish va bosish
4. "O'rnatish" tugmasini bosish
5. Tasdiqlab, o'rnatishni kutish

### 3️⃣ Android Studio Orqali

1. Android Studio'ni ochish
2. `greenmarket_app` proyektini ochish
3. **Run** → **Run 'app'** (yoki Shift+F10)
4. Device'ni tanlash
5. O'rnatish va ishga tushirish

## Talab Qilinadigan Shartlar

- ✅ Android 5.0 (API 21) yoki undan yuqori
- ✅ 126 MB bo'sh joy
- ✅ Internet ulanishi (MyID API uchun)

## Xususiyatlar

### MyID Integratsiyasi
- ✅ 4 ta login variant
- ✅ SDK Direct
- ✅ Simple Authorization
- ✅ Empty Session
- ✅ Passport Session

### Backend Ulanishi
- ✅ Vercel API: `https://greenmarket-backend-lilac.vercel.app`
- ✅ MyID DEV: `https://api.devmyid.uz`

## Muammolar va Hal Qilish

### "Unknown sources" Xatosi
1. Settings → Security
2. "Unknown sources" yoki "Install unknown apps" ni yoqish
3. APK'ni qayta urnatish

### "App not installed" Xatosi
1. Eski versiyani o'chirish: `adb uninstall com.example.greenmarket_app`
2. APK'ni qayta urnatish

### "Insufficient storage" Xatosi
1. Device'da bo'sh joy yaratish (126 MB kerak)
2. Keraksiz app'larni o'chirish

## Testlash

Urnatishdan so'ng:

1. App'ni ochish
2. Login screen'da 4 ta variant ko'rish
3. MyID SDK Direct'ni tanlash
4. MyID'ga kirish
5. Home screen'da foydalanuvchi ma'lumotlarini ko'rish

## Vercel Environment Variables

Backend to'g'ri ishlashi uchun Vercel'da quyidagi variables'larni sozlash kerak:

```
MYID_CLIENT_ID = quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v
MYID_CLIENT_SECRET = JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP
MYID_HOST = https://api.devmyid.uz
MONGODB_URI = mongodb://localhost:27017/greenmarket
```

## Qo'shimcha Buyruqlar

```bash
# APK'ni o'chirish
adb uninstall com.example.greenmarket_app

# Device'da app'ni ishga tushirish
adb shell am start -n com.example.greenmarket_app/.MainActivity

# App'ni log'larini ko'rish
adb logcat | grep greenmarket

# Device'dan APK'ni yuklab olish
adb pull /data/app/com.example.greenmarket_app-*/base.apk ./app.apk
```

## Keyingi Qadamlar

1. ✅ APK build qilindi
2. ⏳ Device'ga urnatish
3. ⏳ MyID login'ni test qilish
4. ⏳ Backend API'ni test qilish
5. ⏳ Production build qilish

---

**Yaratilgan**: 2026-01-20
**Versiya**: 1.0.0
**Status**: Release Ready
