# MyID SDK To'liq Integratsiya Qo'llanmasi

## Holat (2026-yil)

MyID SDK Flutter app'da to'liq integratsiyasi yakunlandi. Backend Vercel'da deploy qilindi.

## Tizim Arxitekturasi

```text
Flutter App (Android)
    ↓
MyID Native Service (Kotlin)
    ↓
MyID SDK (uz.myid.sdk.capture)
    ↓
MyID API (https://api.devmyid.uz)
    ↓
Backend (Vercel)
    ↓
Foydalanuvchi Ma'lumotlari
```

## Integratsiya Qadamlari

### 1. Android Konfiguratsiyasi

**build.gradle.kts (Project level):**
```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://artifactory.aigroup.uz:443/artifactory/myid/") }
    }
}
```

**build.gradle.kts (App level):**
```gradle
android {
    defaultConfig {
        minSdk = 21
        targetSdk = 36
    }
}

dependencies {
    implementation("uz.myid.sdk.capture:myid-capture-sdk:3.1.5")
}
```

**AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### 2. Flutter UI - Passport Ma'lumotlarini Kiritish

Test ekranida foydalanuvchi quyidagi ma'lumotlarni kiritadi:

- **Pasport Seriyasi:** AD, AA, va boshqalar
- **Pasport Raqami:** 1241744 kabi 7 raqamli raqam
- **Tug'ilgan Sana:** YYYY-MM-DD formatida (masalan: 1990-07-16)

### 3. Jarayon Oqimi

#### 1-Qadam: Session Yaratish
```
Flutter App → Backend → MyID API
```
Backend `/api/myid/create-session` endpoint'iga so'rov yuboradi va session_id + client_hash oladi.

#### 2-Qadam: Native SDK Ishga Tushirish
```
Flutter → Kotlin (MainActivity) → MyID SDK
```
Flutter `MethodChannel` orqali Kotlin'ga passport ma'lumotlarini yuboradi. Kotlin MyID SDK'ni ishga tushiradi.

#### 3-Qadam: Yuzni Skanerlash
```
MyID SDK → Kamera → Liveness Check
```
SDK avtomatik ravishda:
- Kamerani ochadi
- Foydalanuvchidan yuzni ko'rsatishni so'raydi
- Liveness check qiladi (jonli odam ekanligini tekshiradi)
- Yuzni pasport rasmiga solishtiradi

#### 4-Qadam: Kodni Backend'ga Yuborish
```
SDK → Flutter → Backend → MyID API
```
SDK muvaffaqiyatli bo'lsa, `code` qaytaradi. Flutter bu kodni backend'ga yuboradi.

#### 5-Qadam: Foydalanuvchi Ma'lumotlarini Olish
```
Backend → MyID API → Foydalanuvchi Ma'lumotlari
```
Backend kodni MyID API'ga yuboradi va foydalanuvchining to'liq ma'lumotlarini oladi:
- FISH (Familiya, Ism, Sharif)
- PINFL
- Tug'ilgan sana
- Jinsiyat
- Telefon raqami
- Email
- Rasm

### 4. Backend Endpoint'lari

#### Session Yaratish
**POST** `/api/myid/create-session`

Response:
```json
{
  "success": true,
  "session_id": "...",
  "access_token": "...",
  "client_hash": "..."
}
```

#### Kodni Tekshirish
**POST** `/api/myid/verify-code`

Request:
```json
{
  "code": "...",
  "session_id": "..."
}
```

Response:
```json
{
  "success": true,
  "profile": {
    "first_name": "Ism",
    "last_name": "Familiya",
    "pinfl": "12345678901234",
    "birth_date": "1990-07-16",
    "gender": "M",
    "phone_number": "+998901234567",
    "email": "user@example.com"
  },
  "reuid": "...",
  "comparison_value": 0.95
}
```

### 5. Flutter Services

#### MyIdOAuthService
- `createSession()` - Session yaratish
- `identifyUser()` - Native SDK orqali identifikatsiya
- `getUserProfile()- Foydalanuvchi ma'lumotlarini olish
- `completeAuthFlow()` - To'liq jarayon

#### MyIdNativeService
- `startMyIdSDK()` - Kotlin orqali SDK'ni chaqirish

#### MyIdCodeVerificationService
- `verifyCode()` - Kodni backend'ga yuborish

### 6. Kotlin Platform Channel

**MainActivity.kt:**
```kotlin
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.greenmarket/myid")
    .setMethodCallHandler { call, result ->
        when (call.method) {
            "startMyIdSDK" -> {
                val series = call.argument<String>("passportSeries")
                val number = call.argument<String>("passportNumber")
                val birthDate = call.argument<String>("birthDate")
                startMyId(series!!, number!!, birthDate!!)
            }
        }
    }
```

## Credentials (DEV Muhiti)

- **Host:** `https://api.devmyid.uz`
- **Client ID:** `quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v`
- **Client Secret:** `JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP`

## Test Qilish

### 1. Test Ekranini Ochish
- App'ni ishga tushiring
- "MyID Kirish" ekraniga o'ting

### 2. Ma'lumotlarni Kiritish
- Pasport seriyasi: `AD`
- Pasport raqami: `1241744`
- Tug'ilgan sana: `1990-07-16`

### 3. Tugmasini Bosish
- "MyID orqali kirish" tugmasini bosing

### 4. Kutilayotgan Natija
1. Sessiya yaratiladi
2. MyID SDK oynasi ochiladi
3. Kamera avtomatik ochiladi
4. Yuzni skanerlash so'raladi
5. Liveness check qilinadi
6. Yuz solishtirish qilinadi
7. Muvaffaqiyatli bo'lsa, foydalanuvchi ma'lumotlari ko'rsatiladi

## Xatolarni Tuzatish

### "Identifikatsiya bekor qilindi" xatosi
- Session ID vaqti tugagan bo'lishi mumkin
- Qayta urining

### "Kamera ruxsati yo'q" xatosi
- AndroidManifest.xml'da `CAMERA` ruxsati bor-yo'qligini tekshiring
- App sozlamalarida kamera ruxsatini bering

### "Network xatosi" xatosi
- Internet ulanishini tekshiring
- VPN ishlatib ko'ring

### "SDK topilmadi" xatosi
- MyID repository'si build.gradle'da qo'shilganligini tekshiring
- `flutter clean` va `flutter pub get` qilip ko'ring

## Muhim Eslatmalar

1. **Real Device:** MyID SDK faqat real Android cihazda ishlaydi, emulator'da emas
2. **Camera:** Cihazda kamera bo'lishi kerak
3. **Internet:** Doimiy internet ulanishi kerak
4. **Session Vaqti:** Session ID 15 daqiqaga amal qiladi
5. **Client Secret:** Faqat backend'da saqlash kerak, Flutter kodida emas
6. **Liveness Check:** SDK avtomatik ravishda jonli odam ekanligini tekshiradi

## Keyingi Qadamlar

1. Production muhitiga o'tish
2. IP whitelist'ni MyID'da sozlash
3. SSL sertifikatini tekshirish
4. Load testing qilish
5. User acceptance testing (UAT)

## Foydalanuvchi Ma'lumotlarini Saqlash

Muvaffaqiyatli identifikatsiyadan so'ng, foydalanuvchi ma'lumotlarini:
- Local database'ga saqlash
- Secure storage'ga saqlash
- Backend'da saqlash

Tavsiya etiladi.

## Xavfsizlik Bo'yicha Maslahatlar

1. Client Secret'ni environment variable'da saqlash
2. HTTPS'dan foydalanish
3. Token'larni secure storage'da saqlash
4. Rate limiting qo'llash
5. Input validation qilish
6. Error messages'da sensitive ma'lumot ko'rsatmaslik
