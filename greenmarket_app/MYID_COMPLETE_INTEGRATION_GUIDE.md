# MyID To'liq Integratsiya Qo'llanmasi

## Umumiy Ma'lumot

Bu qo'llanma GreenMarket ilovasiga MyID SDK'ni to'liq integratsiya qilish uchun mo'ljallangan. Integratsiya 3 ta jadval orqali amalga oshiriladi:

1. **1-JADVAL**: Access Token Olish
2. **2-JADVAL**: Session Yaratish
3. **3-JADVAL**: Foydalanuvchi Ma'lumotlarini Olish

---

## Arxitektura

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Ilova                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  MyIdTableRequests (1, 2, 3-jadvallar)              │   │
│  │  MyIdTableRequestsWithFields (2-jadval maydonlar)   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                  Backend (Node.js)                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  /api/myid/get-access-token (1-jadval)             │   │
│  │  /api/myid/create-session (2-jadval)               │   │
│  │  /api/myid/create-session-with-fields (2-jadval)   │   │
│  │  /api/myid/get-user-info (3-jadval)                │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                   MyID API                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  /api/v1/auth/clients/access-token                 │   │
│  │  /api/v2/sdk/sessions                              │   │
│  │  /api/v1/users/me                                  │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Fayllar Ro'yxati

### Flutter Servislar
- `lib/services/myid_table_requests.dart` - 1, 2, 3-jadvallar
- `lib/services/myid_table_requests_with_fields.dart` - 2-jadval maydonlar bilan

### Flutter Ekranlar
- `lib/screens/myid_complete_test_screen.dart` - Test ekrani
- `lib/screens/myid_successful_login_screen.dart` - Muvaffaqiyatli kirish ekrani
- `lib/screens/myid_profile_screen.dart` - Profil ekrani

### Backend Endpoint'lar
- `POST /api/myid/get-access-token` - 1-jadval
- `POST /api/myid/create-session` - 2-jadval (bo'sh)
- `POST /api/myid/create-session-with-passport` - 2-jadval (pasport bilan)
- `POST /api/myid/create-session-with-fields` - 2-jadval (maydonlar bilan)
- `POST /api/myid/get-user-info` - 3-jadval

### Dokumentatsiya
- `TABLE_2_SPECIFICATION.md` - 2-jadval spesifikatsiyasi
- `TABLE_2_VALIDATION_GUIDE.md` - 2-jadval validatsiyasi
- `TABLE_2_REQUEST_FIELDS_GUIDE.md` - 2-jadval maydonlari
- `TABLE_3_SPECIFICATION.md` - 3-jadval spesifikatsiyasi
- `TABLE_3_FLOW_GUIDE.md` - 3-jadval oqimi

---

## Ishga Tushirish

### 1-qadam: Backend'ni Ishga Tushirish

```bash
cd greenmarket_backend
npm install
npm start
```

Backend `http://localhost:3000` da ishga tushadi.

### 2-qadam: Flutter Ilovasini Ishga Tushirish

```bash
cd greenmarket_app
flutter pub get
flutter run
```

### 3-qadam: Test Ekraniga O'tish

Test ekraniga o'tish uchun:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MyIdCompleteTestScreen(),
  ),
);
```

---

## Test Qilish

### Test Ekranida

1. **"Barcha Jadvallarni Test Qilish"** tugmasini bosing
2. Loglarni ko'ring:
   - ✅ 1-JADVAL: Access token olindi
   - ✅ 2-JADVAL: Session yaratildi
   - ✅ 3-JADVAL: Foydalanuvchi ma'lumotlari olindi

3. Muvaffaqiyatli bo'lsa, profil ekraniga o'tadi

### cURL'da

#### 1-JADVAL
```bash
curl -X POST http://localhost:3000/api/myid/get-access-token \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v",
    "client_secret": "JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP"
  }'
```

#### 2-JADVAL
```bash
curl -X POST http://localhost:3000/api/myid/create-session \
  -H "Authorization: Bearer {access_token}" \
  -H "Content-Type: application/json" \
  -d '{}'
```

#### 3-JADVAL
```bash
curl -X POST http://localhost:3000/api/myid/get-user-info \
  -H "Authorization: Bearer {access_token}" \
  -H "Content-Type: application/json" \
  -d '{"code": "test_code"}'
```

---

## Credentials

```
client_id: quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v
client_secret: JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP
Environment: DEV (https://api.devmyid.uz)
```

---

## Oqim

### 1-JADVAL: Access Token Olish

**So'rov**:
```dart
final result = await MyIdTableRequests.table1GetAccessToken(
  clientId: 'quyosh_24_sdk-...',
  clientSecret: 'JRgNV6Av8D...',
);
```

**Javob**:
```json
{
  "success": true,
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600,
  "token_type": "Bearer"
}
```

### 2-JADVAL: Session Yaratish

**So'rov**:
```dart
final result = await MyIdTableRequests.table2CreateSession(
  accessToken: table1['access_token'],
);
```

**Javob**:
```json
{
  "success": true,
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 604800,
  "token_type": "Bearer"
}
```

### 3-JADVAL: Foydalanuvchi Ma'lumotlarini Olish

**So'rov**:
```dart
final result = await MyIdTableRequests.table3GetUserData(
  code: 'USER_CODE_FROM_SDK',
  accessToken: table2['access_token'],
);
```

**Javob**:
```json
{
  "success": true,
  "profile": {
    "pinfl": "12345678901234",
    "name": "Abdullayev Abdulla",
    "surname": "Abdullayev",
    "birth_date": "1990-01-15",
    "gender": "M",
    "phone": "+998901234567",
    "email": "user@example.com"
  }
}
```

---

## Xato Hal Qilish

### 401 Unauthorized
**Sabab**: Access token noto'g'ri yoki muddati tugagan

**Yechim**:
1. 1-jadvaldan yangi access_token olish
2. 2-jadvalda yangi session yaratish

### 400 Bad Request
**Sabab**: So'rov parametrlari noto'g'ri

**Yechim**:
1. Validatsiya xatolarini ko'rish
2. Parametrlarni tekshirish

### 500 Internal Server Error
**Sabab**: Server xatosi

**Yechim**:
1. Backend loglarini ko'rish
2. MyID API'ga ulanishni tekshirish

---

## Qo'shimcha Eslatmalar

1. **Token Muddati**: Access token muddati tugamasligi kerak
2. **Session Muddati**: Session ID muddati tugamasligi kerak
3. **SDK Integration**: 2-jadvaldan olingan session_id SDK'ga o'tkaziladi
4. **Code Parametri**: SDK'dan olingan code 3-jadvalda ishlatiladi
5. **Validatsiya**: Barcha maydonlar validatsiya qilinadi

---

## Keyingi Qadamlar

1. ✅ 1-jadval (Access Token) - Tayyor
2. ✅ 2-jadval (Session) - Tayyor
3. ✅ 3-jadval (Foydalanuvchi Ma'lumotlari) - Tayyor
4. ⏳ SDK Integration - Haqiqiy SDK bilan test qilish kerak
5. ⏳ Production Deployment - Production muhitiga joylashtirish

---

## Foydalanish Misoli

```dart
// 1. Test ekraniga o'tish
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MyIdCompleteTestScreen(),
  ),
);

// 2. "Barcha Jadvallarni Test Qilish" tugmasini bosing
// 3. Loglarni ko'ring
// 4. Muvaffaqiyatli bo'lsa, profil ekraniga o'tadi
```

---

**Oxirgi yangilash**: 2025-01-23  
**Versiya**: 1.0.0  
**Status**: ✅ Tayyor
