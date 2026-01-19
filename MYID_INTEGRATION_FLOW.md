# MyID Rasmiy Integratsiya Oqimi

## Umumiy Ko'rinish

MyID integratsiyasi 3 ta asosiy komponentdan iborat:

1. **Backend (Node.js)** - Bizning server
2. **Mobile App (Flutter)** - Foydalanuvchi ilovasi
3. **MyID Backend** - MyID serveri

## To'liq Oqim Diagrammasi

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   Mobile    │         │   Backend   │         │    MyID     │
│     App     │         │  (Node.js)  │         │   Backend   │
└──────┬──────┘         └──────┬──────┘         └──────┬──────┘
       │                       │                       │
       │ 1. Pasport ma'lumotlari                      │
       ├──────────────────────>│                       │
       │                       │                       │
       │                       │ 2. Access Token so'rovi
       │                       ├──────────────────────>│
       │                       │                       │
       │                       │ 3. Access Token       │
       │                       │<──────────────────────┤
       │                       │                       │
       │                       │ 4. Session yaratish   │
       │                       ├──────────────────────>│
       │                       │                       │
       │                       │ 5. Session ID         │
       │                       │<──────────────────────┤
       │                       │                       │
       │ 6. Session ID         │                       │
       │<──────────────────────┤                       │
       │                       │                       │
       │ 7. SDK ishga tushirish│                       │
       │ (session_id bilan)    │                       │
       │                       │                       │
       │ 8. Yuz skanerlash     │                       │
       │ (MyID SDK)            │                       │
       │                       │                       │
       │ 9. Code + Rasmlar     │                       │
       ├──────────────────────>│                       │
       │                       │                       │
       │                       │ 10. Profil so'rovi    │
       │                       │    (code bilan)       │
       │                       ├──────────────────────>│
       │                       │                       │
       │                       │ 11. Profil ma'lumotlari
       │                       │<──────────────────────┤
       │                       │                       │
       │                       │ 12. Ma'lumotlarni saqlash
       │                       │    (rasmlar bilan)    │
       │                       │                       │
       │ 13. Profil ma'lumotlari                      │
       │<──────────────────────┤                       │
       │                       │                       │
```

## Backend Majburiyatlari

### 1. Autentifikatsiya ✅
- [x] Access token olish va saqlash
- [x] Barcha API so'rovlariga token qo'shish
- [x] Token muddatini boshqarish

### 2. Session Boshqarish ✅
- [x] Pasport ma'lumotlari bilan session yaratish
- [x] Session ID ni mobile app'ga qaytarish
- [x] Session muddatini kuzatish

### 3. Ma'lumotlarni Qayta Ishlash ✅
- [x] SDK'dan code va rasmlarni qabul qilish
- [x] Code bilan profil ma'lumotlarini olish
- [x] Rasmlarni ma'lumotlar bazasiga saqlash
- [x] Javobni tasdiqlash va qayta ishlash

### 4. Xavfsizlik ✅
- [x] Shaxsiy ma'lumotlarni shifrlash
- [x] HTTPS orqali aloqa
- [x] Client secret'ni yashirish
- [x] Rate limiting

## Mobile App Oqimi

### 1. Pasport Ma'lumotlarini Kiritish ✅
```dart
// Foydalanuvchidan pasport ma'lumotlarini olish
final passportData = {
  'pass_data': 'AA1234567',
  'birth_date': '1990-01-01',
};
```

### 2. Backend'dan Session ID Olish ✅
```dart
final response = await http.post(
  Uri.parse('$backendUrl/api/myid/create-simple-session-complete'),
  body: json.encode(passportData),
);

final sessionId = response.data['session_id'];
```

### 3. SDK ni Ishga Tushirish ✅
```dart
final config = MyIdConfig(
  sessionId: sessionId,
  clientHash: clientHash,
  clientHashId: clientHashId,
  environment: MyIdEnvironment.DEBUG,
  entryType: MyIdEntryType.IDENTIFICATION,
  locale: MyIdLocale.UZBEK,
);

final result = await MyIdClient.start(
  config: config,
  iosAppearance: const MyIdIOSAppearance(),
);
```

### 4. Code va Rasmlarni Backend'ga Yuborish ✅
```dart
final userInfoResponse = await http.post(
  Uri.parse('$backendUrl/api/myid/get-user-info-with-images'),
  body: json.encode({
    'code': result.code,
    'comparison_value': result.comparisonValue,
    'face_image': result.faceImage,
    'passport_image': result.passportImage,
  }),
);
```

### 5. Profil Ma'lumotlarini Saqlash ✅
```dart
final userData = {
  'pinfl': result.code,
  'profile': userInfo['profile'],
  'verified': true,
  'timestamp': DateTime.now().toIso8601String(),
  'auth_method': 'simple_authorization',
};

await prefs.setString('user_data', json.encode(userData));
```

## MyID Backend Jarayonlari

### 1. Session Yaratish
MyID backend pasport ma'lumotlari bilan session yaratadi:
```
POST /api/v1/oauth2/session
Authorization: Bearer {access_token}

Body:
{
  "grant_type": "simple_authorization",
  "scope": "address,contacts,doc_data,common_data,doc_files",
  "pass_data": "AA1234567",
  "birth_date": "1990-01-01"
}

Response:
{
  "session_id": "...",
  "expires_in": 3600
}
```

### 2. Foydalanuvchi Identifikatsiyasi
SDK orqali yuz skanerlash va identifikatsiya:
- Foydalanuvchi yuzini skanerlaydi
- Pasport ma'lumotlari bilan solishtiradi
- Code va rasmlarni qaytaradi

### 3. Profil Ma'lumotlarini Tayyorlash
Code bilan profil ma'lumotlarini qaytaradi:
```
GET /api/v1/users/me
Authorization: Bearer {access_token}

Response:
{
  "profile": {
    "first_name": "...",
    "last_name": "...",
    "middle_name": "...",
    "birth_date": "...",
    "pinfl": "...",
    ...
  }
}
```

## Ma'lumotlar Strukturasi

### Backend'da Saqlangan Ma'lumotlar
```javascript
{
  id: 1,
  myid_code: "14 raqamli PINFL",
  profile_data: "shifrlangan profil ma'lumotlari",
  comparison_value: 0.95, // Yuz taqqoslash natijasi
  face_image: "base64 yuz rasmi",
  passport_image: "base64 pasport rasmi",
  registered_at: "2025-01-19T10:30:00Z",
  last_login: "2025-01-19T10:30:00Z",
  status: "active",
  auth_method: "simple_authorization"
}
```

### Mobile App'da Saqlangan Ma'lumotlar
```dart
{
  "pinfl": "14 raqamli PINFL",
  "profile": {
    "first_name": "...",
    "last_name": "...",
    ...
  },
  "verified": true,
  "timestamp": "2025-01-19T10:30:00Z",
  "auth_method": "simple_authorization"
}
```

## Xavfsizlik Choralari

### 1. HTTPS ✅
Barcha aloqalar HTTPS orqali amalga oshiriladi.

### 2. Shifrlash ✅
Shaxsiy ma'lumotlar backend'da shifrlangan holda saqlanadi:
```javascript
const encryptedData = encryptSensitiveData(profileData);
```

### 3. Token Boshqarish ✅
- Access token 1 soat amal qiladi
- Token faqat backend'da saqlanadi
- Mobile app token'ni ko'rmaydi

### 4. Rate Limiting ✅
API so'rovlari cheklangan:
- 1 daqiqada maksimal 10 so'rov

### 5. Client Secret Yashirish ✅
Client secret faqat backend'da saqlanadi va hech qachon mobile app'ga yuborilmaydi.

## Xatoliklarni Boshqarish

### 1. Access Token Xatosi
```
Xato: Access token olishda xato
Sabab: Credentials noto'g'ri yoki muddati tugagan
Yechim: Credentials'ni tekshiring
```

### 2. Session Xatosi
```
Xato: Session yaratishda xato
Sabab: Pasport ma'lumotlari noto'g'ri
Yechim: Pasport ma'lumotlarini to'g'ri kiriting
```

### 3. SDK Xatosi (103)
```
Xato: Session is expired
Sabab: Session muddati tugagan
Yechim: Jarayonni qaytadan boshlang
```

### 4. Profil Xatosi
```
Xato: Profil olishda xato
Sabab: Code noto'g'ri yoki muddati tugagan
Yechim: SDK'ni qaytadan ishga tushiring
```

## Test Qilish

### 1. Backend Test
```bash
# Access token olish
curl -X POST https://greenmarket-backend-lilac.vercel.app/api/myid/create-simple-session-complete \
  -H "Content-Type: application/json" \
  -d '{"pass_data":"AA1234567","birth_date":"1990-01-01"}'
```

### 2. Mobile App Test
1. Ilovani oching
2. "MyID orqali kirish" tugmasini bosing
3. Pasport ma'lumotlarini kiriting
4. SDK'ni ishga tushiring
5. Yuzingizni skanerlang
6. Profil ma'lumotlarini ko'ring

## Monitoring

### Backend Loglar
Vercel dashboard'da real-time loglarni kuzating:
```
📤 [1/2] Access token olinmoqda...
✅ [1/2] Access token olindi
📤 [2/2] Simple session yaratilmoqda...
✅ [2/2] Simple session yaratildi
📞 SDK'dan code va rasmlar olindi
✅ Foydalanuvchi saqlandi: 1
```

### Mobile App Loglar
```
🔵 [1/4] Backend orqali session yaratilmoqda...
✅ [1/4] Session yaratildi: abc123...
🔵 [2/4] SDK ishga tushirilmoqda...
✅ [2/4] SDK natija: code=12345678901234
🔵 [3/4] Backend orqali profil olinmoqda...
✅ [3/4] Profil ma'lumotlari olindi
✅ [4/4] Muvaffaqiyatli yakunlandi!
```

## Keyingi Qadamlar

1. ✅ Backend'da rasmlarni saqlash
2. ✅ Mobile app'da rasmlarni yuborish
3. ⏳ APK build qilish va test qilish
4. ⏳ Production muhitiga o'tkazish
5. ⏳ Real foydalanuvchilar bilan test qilish

---

**Sana:** 2025-01-19  
**Versiya:** 2.0  
**Mualliflar:** GreenMarket Development Team
