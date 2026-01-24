# MyID SDK To'liq Integratsiya Qo'llanmasi

## ✅ Nima Qilindi?

MyID SDK integratsiyasi to'liq tuzatildi va to'g'ri sozlandi. Quyida barcha o'zgarishlar va sozlamalar ko'rsatilgan.

---

## 🔧 Backend Sozlamalari

### 1. Environment Variables (.env)

Backend `.env` faylida quyidagi o'zgarishlar qilindi:

```env
PORT=5000
NODE_ENV=development

# MongoDB
MONGODB_URI=mongodb://localhost:27017/greenmarket

# JWT
JWT_SECRET=greenmarket_secret_key_2024
JWT_EXPIRE=30d

# MyID Credentials (DEV muhiti)
CLIENT_ID=quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v
CLIENT_SECRET=JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP

# MyID API Host (DEV muhiti)
MYID_HOST=https://api.devmyid.uz

# Encryption Key
ENCRYPTION_KEY=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
```

### 2. Backend API Endpoints

Backend quyidagi endpoint'larni taqdim etadi:

#### a) Sessiya Yaratish
```
POST /api/myid/create-session
```

**Javob:**
```json
{
  "success": true,
  "data": {
    "session_id": "uuid-string",
    "expires_in": 3600
  }
}
```

#### b) Foydalanuvchi Ma'lumotlarini Olish
```
POST /api/myid/get-user-info
Body: { "code": "user-code" }
```

**Javob:**
```json
{
  "success": true,
  "data": {
    "user_id": "mongodb-id",
    "pinfl": "12345678901234",
    "profile": { ... }
  }
}
```

---

## 📱 Flutter Ilovasida Sozlamalari

### 1. MyID Konfiguratsiyasi

`greenmarket_app/lib/config/myid_config.dart`:

```dart
class MyIDConfig {
  // DEV muhiti
  static const String baseUrl = 'https://api.devmyid.uz';
  
  // Credentials
  static const String clientId = 'quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v';
  static const String clientSecret = 'JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP';
  static const String clientHashId = 'ac6d0f4a-5d5b-44e3-a865-9159a3146a8c';
  
  // Client Hash (o'zgartirmang)
  static const String clientHash = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5wQYaS8i1b0Rj5wuJLhI
yDuTW/WoWB/kRbJCBHFLyFTxETADNa/CU+xw0moN9X10+MVD5kRMinMRQpGUVCrU
XjUAEjwbdaCSLR6suRYI1EfDMQ5XFdJsfkAlNzZyyfBlif4OA4qxaMtdyvJCa/8n
wHn2KC89BNhqBQMre7iLaW8Z9bArSulSxBJzbzPjd7Jkg4ccQ47bVyjEKBcu/1KX
Ud/audUr1WsUpBf9yvgSTDRG2cuVXpMGEBJAqrsCS3RtIt7pEnGtr5FsB+UmBec9
Ei97fK2LcVfWpc/m7WjWMz3mku/pmhSjC6Vl6dlOrP1dv/fJkhfh3axzXtZoxgV1
QwIDAQAB
-----END PUBLIC KEY-----''';
}
```

### 2. To'liq Autentifikatsiya Oqimi

Yangi fayl yaratildi: `greenmarket_app/lib/services/myid_complete_flow.dart`

Bu fayl quyidagi qadamlarni bajaradi:

1. Backend'dan sessiya olish
2. MyID SDK'ni sessiya bilan ishga tushirish
3. Foydalanuvchi ma'lumotlarini olish
4. Natijani qaytarish

**Foydalanish:**

```dart
import 'package:greenmarket_app/services/myid_complete_flow.dart';

final result = await MyIdCompleteFlow.completeAuthFlow(
  onStatusUpdate: (status) {
    print('Status: $status');
  },
);

if (result['success'] == true) {
  print('Muvaffaqiyatli: ${result['user_data']}');
} else {
  print('Xatolik: ${result['error']}');
}
```

---

## 🚀 Test Qilish

### 1. Backend'ni Ishga Tushirish

```bash
cd greenmarket_backend
npm install
npm start
```

Backend `http://localhost:5000` da ishga tushadi.

### 2. Flutter Ilovasini Build Qilish

```bash
cd greenmarket_app
flutter pub get
flutter build apk --release
```

### 3. Telefoniga O'rnatish

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### 4. Test Qilish

1. Ilovani oching
2. Login ekraniga o'ting
3. "MyID orqali kirish" tugmasini bosing
4. Jarayon qadamlari ko'rsatiladi:
   - ✅ Backend'dan sessiya olinmoqda...
   - ✅ MyID SDK ishga tushirilmoqda...
   - ✅ Foydalanuvchi ma'lumotlari olinmoqda...
   - ✅ Autentifikatsiya muvaffaqiyatli

---

## 🔍 Muammolarni Hal Qilish

### Muammo 1: "Session is expired" (103 xatosi)

**Sabab:** Credentials noto'g'ri yoki DEV muhiti sozlanmagan

**Yechim:**
1. `.env` faylida `MYID_HOST=https://api.devmyid.uz` ekanligini tekshiring
2. `CLIENT_ID` va `CLIENT_SECRET` to'g'ri ekanligini tekshiring
3. Backend'ni qayta ishga tushiring

### Muammo 2: Backend bilan aloqa xatosi

**Sabab:** Backend URL noto'g'ri yoki backend ishlamayapti

**Yechim:**
1. Backend `http://localhost:5000` da ishga tushganini tekshiring
2. Flutter ilovasida backend URL to'g'ri ekanligini tekshiring
3. Network xatoliklarini debug console'da ko'ring

### Muammo 3: SDK xatosi

**Sabab:** SDK konfiguratsiyasi noto'g'ri

**Yechim:**
1. `clientHash` va `clientHashId` to'g'ri ekanligini tekshiring
2. `environment: MyIdEnvironment.DEBUG` sozlanganini tekshiring
3. MyID SDK versiyasini tekshiring (3.1.41)

---

## 📊 Integratsiya Diagrammasi

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Ilovasi                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  MyIdCompleteFlow.completeAuthFlow()                │   │
│  └──────────────────────────────────────────────────────┘   │
│                          │                                   │
│                          ▼                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  1. Backend'dan sessiya olish                        │   │
│  │     POST /api/myid/create-session                   │   │
│  └──────────────────────────────────────────────────────┘   │
│                          │                                   │
│                          ▼                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  2. MyID SDK'ni ishga tushirish                      │   │
│  │     MyIdClient.start(sessionId)                     │   │
│  └──────────────────────────────────────────────────────┘   │
│                          │                                   │
│                          ▼                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  3. Foydalanuvchi ma'lumotlarini olish              │   │
│  │     POST /api/myid/get-user-info                    │   │
│  └──────────────────────────────────────────────────────┘   │
│                          │                                   │
│                          ▼                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  4. Natijani qaytarish                              │   │
│  │     { success: true, user_data: {...} }            │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    Backend Server                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  /api/myid/create-session                           │   │
│  │  - Access token olish                               │   │
│  │  - Sessiya yaratish                                 │   │
│  └──────────────────────────────────────────────────────┘   │
│                          │                                   │
│                          ▼                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  /api/myid/get-user-info                            │   │
│  │  - Foydalanuvchi ma'lumotlarini olish               │   │
│  │  - MongoDB'da saqlash                               │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    MyID API (DEV)                           │
│                  https://api.devmyid.uz                     │
│  - Access token olish                                       │
│  - Sessiya yaratish                                         │
│  - Foydalanuvchi ma'lumotlarini olish                       │
└─────────────────────────────────────────────────────────────┘
```

---

## ✨ Keyingi Qadamlar

1. **Production muhitiga o'tish:**
   - `MYID_HOST=https://api.myid.uz` ga o'zgartiring
   - Production credentials'ni qo'shing

2. **Xavfsizlik:**
   - Credentials'ni environment variables'da saqlang
   - HTTPS protokolini ishlatish
   - Token cache'ni xavfsiz saqlash

3. **Monitoring:**
   - Backend logs'ni tekshiring
   - MyID API xatoliklarini qayd qiling
   - Foydalanuvchi ma'lumotlarini tekshiring

---

## 📞 Aloqa

Agar muammolar bo'lsa:
1. MYID_ERROR_REPORT.md'ni tekshiring
2. Backend logs'ni ko'ring
3. Flutter debug console'ni ko'ring
4. MyID support bilan bog'lanish

---

**Sana:** 2025-01-23  
**Status:** ✅ To'liq integratsiya qilindi  
**Muhit:** DEV (api.devmyid.uz)
