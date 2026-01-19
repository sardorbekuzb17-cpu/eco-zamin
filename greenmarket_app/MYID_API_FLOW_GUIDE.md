# MyID API Flow - To'liq Qo'llanma

## 📋 Umumiy Ma'lumot

Bu qo'llanma **MyID API Flow** ni to'liq amalga oshirish bo'yicha ko'rsatmalar beradi. Bu usul MyID'ning rasmiy dokumentatsiyasiga to'liq mos keladi va SDK'dan farqli ravishda backend orqali to'g'ridan-to'g'ri API bilan ishlaydi.

## 🔄 SDK Flow vs API Flow

### SDK Flow (Eski - Ishlamayapti)
- ❌ SDK o'zi sessiya yaratadi
- ❌ SDK o'zi MyID serveriga murojaat qiladi
- ❌ 103 "Bad Request" xatosi beradi
- ❌ Credentials SDK uchun emas

### API Flow (Yangi - Ishlaydi) ✅
- ✅ Backend to'g'ridan-to'g'ri API bilan ishlaydi
- ✅ Mobile faqat pasport va selfie yuboradi
- ✅ Dokumentatsiyaga to'liq mos
- ✅ Credentials API uchun

## 🏗️ Arxitektura

```
Mobile App (Flutter)
    ↓
    1. Pasport + Selfie
    ↓
Backend (Node.js/Express)
    ↓
    2. Access Token olish
    ↓
    3. Verifikatsiya so'rovi (job_id olish)
    ↓
    4. Natija olish (0.5s kutish)
    ↓
MyID API (https://api.myid.uz)
```

## 📁 Fayllar

### Backend
- `greenmarket_backend/index.js` - Express server
  - `/api/myid/api-flow/get-access-token` - Access token olish
  - `/api/myid/api-flow/submit-verification` - Verifikatsiya so'rovi
  - `/api/myid/api-flow/get-result` - Natija olish
  - `/api/myid/api-flow/complete` - To'liq flow (bitta so'rovda)

### Mobile
- `greenmarket_app/lib/screens/myid_api_flow_screen.dart` - API Flow ekrani
- `greenmarket_app/lib/main.dart` - Route: `/api-flow`
- `greenmarket_app/pubspec.yaml` - Dependencies: `image_picker`, `camera`
- `greenmarket_app/android/app/src/main/AndroidManifest.xml` - Kamera ruxsati

## 🔑 Credentials

```dart
// Backend (greenmarket_backend/index.js)
const CLIENT_ID = 'quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v';
const CLIENT_SECRET = 'JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP';
const USERNAME = 'quyosh_24_sdk';
const PASSWORD = 'JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP';
```

## 🚀 Ishga Tushirish

### 1. Backend Deploy
```bash
cd greenmarket_backend
vercel --prod
```

Backend URL: `https://greenmarket-backend-lilac.vercel.app`

### 2. Mobile Build
```bash
cd greenmarket_app
flutter pub get
flutter build apk --release
```

APK joyi: `greenmarket_app/build/app/outputs/flutter-apk/app-release.apk`

### 3. Install
```bash
adb install -r greenmarket_app/build/app/outputs/flutter-apk/app-release.apk
```

## 📱 Foydalanish

1. Ilovani oching
2. "MyID orqali kirish" tugmasini bosing
3. "API Flow (Tavsiya etiladi)" tugmasini bosing
4. Pasport seriya va raqamini kiriting (masalan: `AA1234567`)
5. Tug'ilgan sanani kiriting (format: `YYYY-MM-DD`, masalan: `1990-01-01`)
6. "Selfie oling" tugmasini bosing
7. Kamera ochiladi - yuzingizni to'g'ri oldinga qaratib selfie oling
8. "Tasdiqlash" tugmasini bosing
9. Kutish... (3-5 soniya)
10. Muvaffaqiyatli bo'lsa, Home sahifasiga o'tadi

## 📸 Selfie Talablari

MyID dokumentatsiyasiga ko'ra:

- ✅ Yuz to'liq ko'rinishi kerak
- ✅ Yaxshi yoritilgan joy
- ✅ Ko'zlar ochiq
- ✅ Bosh to'g'ri (aylanish 10° dan kam)
- ✅ Surat hajmi: 300 KB - 1.5 MB
- ✅ Format: JPG, JPEG, PNG
- ✅ Sifat: 100%
- ❌ Ko'zoynaksiz
- ❌ Bir nechta yuz bo'lmasligi kerak
- ❌ Xira yoki qorong'i surat emas

## 🔍 API Flow Qadamlari

### 1-QADAM: Access Token Olish
```javascript
POST https://api.myid.uz/api/v1/oauth2/access-token
Content-Type: application/x-www-form-urlencoded

grant_type=password
username=quyosh_24_sdk
password=...
client_id=...
```

**Javob:**
```json
{
  "access_token": "...",
  "expires_in": 3600,
  "token_type": "Bearer",
  "scope": "address,contacts,doc_data,common_data",
  "refresh_token": "..."
}
```

### 2-QADAM: Verifikatsiya So'rovi
```javascript
POST https://api.myid.uz/api/v1/authentication/simple-inplace-authentication-request-task
Authorization: Bearer {ACCESS_TOKEN}
Content-Type: application/json

{
  "pass_data": "AA1234567",
  "birth_date": "1990-01-01",
  "photo_from_camera": {
    "front": "data:image/jpeg;base64,..."
  },
  "agreed_on_terms": true,
  "client_id": "...",
  "threshold": 0.5,
  "is_resident": true
}
```

**Javob:**
```json
{
  "job_id": "g055b0e2-a967-5698-b664-77407b3a6eec"
}
```

### 3-QADAM: Natija Olish (0.5s kutish)
```javascript
POST https://api.myid.uz/api/v1/authentication/simple-inplace-authentication-request-status?job_id=...
Authorization: Bearer {ACCESS_TOKEN}
```

**Javob (Muvaffaqiyatli):**
```json
{
  "response_id": "...",
  "result_code": 1,
  "result_note": "Barcha tekshiruvlar muvaffaqiyatli o'tdi",
  "comparison_value": 0.95,
  "profile": {
    "common_data": {
      "first_name": "...",
      "last_name": "...",
      "pinfl": "...",
      ...
    },
    "doc_data": { ... },
    "contacts": { ... },
    "address": { ... }
  }
}
```

## ❌ Xato Kodlari

| Kod | Tavsif |
|-----|--------|
| 1   | ✅ Muvaffaqiyatli |
| 2   | Pasport ma'lumotlari noto'g'ri |
| 3   | Hayotiylikni tasdiqlay olmadi |
| 4   | Tanib bo'lmadi |
| 14  | Yuzni ajratib bo'lmadi |
| 17  | Yuzlarni solishtirish xatosi |
| 20  | Yomon yoki xira tasvir |
| 21  | Yuz to'liq ramkada emas |
| 22  | Kadrda bir nechta yuzlar |
| 26  | Ko'zlar yumilgan |
| 27  | Bosh aylanishi aniqlandi |

## 🐛 Debugging

### Backend Logs
```bash
# Vercel logs
vercel logs https://greenmarket-backend-lilac.vercel.app
```

### Mobile Logs
```bash
# Android logcat
adb logcat | grep flutter
```

### Test Backend Locally
```bash
cd greenmarket_backend
npm install
node index.js
# Server: http://localhost:3000
```

## 📊 Natija

API Flow muvaffaqiyatli amalga oshirildi! Endi:

1. ✅ Backend to'g'ridan-to'g'ri MyID API bilan ishlaydi
2. ✅ Mobile kamera bilan selfie oladi
3. ✅ Pasport + selfie backend'ga yuboriladi
4. ✅ Backend MyID'dan foydalanuvchi ma'lumotlarini oladi
5. ✅ Foydalanuvchi Home sahifasiga o'tadi

## 🔗 Foydali Havolalar

- MyID API Dokumentatsiyasi: [Sizning yuborgan PDF]
- Backend: https://greenmarket-backend-lilac.vercel.app
- MyID Production: https://api.myid.uz
- MyID Support: +998 71 202 22 02, support@myid.uz

## 📝 Keyingi Qadamlar

1. ✅ API Flow test qilish (real pasport bilan)
2. ⏳ Xato xabarlarini yaxshilash
3. ⏳ Loading animatsiyalarini yaxshilash
4. ⏳ Selfie sifatini tekshirish (ML Kit)
5. ⏳ Production'ga deploy qilish

---

**Muallif:** Kiro AI Assistant  
**Sana:** 2026-01-18  
**Versiya:** 1.0.0
