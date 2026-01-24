# 2-JADVAL: Session Yaratish - To'liq Spesifikatsiya

## API Spesifikatsiyasi

### Usul
```
POST
```

### Yakuniy Nuqta
```
{myid_host}/api/v2/sdk/sessions
```

### Kontent Turi
```
application/json
```

### Avtorizatsiya
```
Bearer {access_token}
```
(1-jadvaldan olingan access_token)

---

## So'rov Strukturi

### Header'lar
```http
POST /api/v2/sdk/sessions HTTP/1.1
Host: api.devmyid.uz
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

### Body (Bo'sh Session)
```json
{}
```

### Body (Pasport Bilan)
```json
{
  "pass_data": "AA123456",
  "birth_date": "1990-01-15"
}
```

### Body (Pasport Maydonlari Bilan)
```json
{
  "phone_number": "+998901234567",
  "birth_date": "1990-01-15",
  "is_resident": true,
  "pass_data": "AA123456",
  "threshold": 0.85
}
```

---

## So'rov Maydonlari (Ixtiyoriy)

| Maydon | Turi | Majburiy | Tavsif |
|--------|------|---------|--------|
| `phone_number` | satr (min_len=12, max_len=13) \| null | Yo'q | Telefon raqami 998901234567 kabi formatda. + ixtiyoriy |
| `birth_date` | satr (YYYY-MM-KD) \| null | Yo'q | ISO formatida tug'ilgan sana |
| `is_resident` | bool \| null | Yo'q | Foydalanuvchi rezidentmi yoki yo'qmi (standart: rost) |
| `pass_data` | satr \| null | Yo'q | Pasport seriyasi va raqami |
| `threshold` | suzuvchi \| null | Yo'q | 0,5 dan 0,99 gacha |

### Eslatma
Agar sessiya passport ma'lumotlari (pass_data yoki pinfl) bilan yaratilsa, SDK birinchi sahifani o'tkazib yuboradi va to'g'ridan to'g'ridan to'g'ri yuzniga suratsga olishga o'tadi (quyidagi ekran).

---

## Javob Strukturi

### Muvaffaqiyatli Javob (200 OK)
```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c",
  "expires_in": 604800,
  "token_type": "Bearer"
}
```

### Xato Javob (401 Unauthorized)
```json
{
  "detail": "Invalid token"
}
```

### Xato Javob (400 Bad Request)
```json
{
  "detail": "Invalid session parameters"
}
```

---

## Majburiy Maydonlar

### 1. session_id
- **Turi**: String (UUID)
- **Uzunligi**: 36 belgi
- **Format**: RFC 4122 (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
- **Misol**: `550e8400-e29b-41d4-a716-446655440000`
- **Majburiy**: ✅ HA
- **Foydalanish**: SDK'ga session_id sifatida o'tkaziladi

### 2. access_token
- **Turi**: String (JWT)
- **Uzunligi**: 512+ belgi
- **Format**: `header.payload.signature` (3 ta nuqta)
- **Misol**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c`
- **Majburiy**: ✅ HA
- **Foydalanish**: Keyingi barcha API so'rovlariga `Authorization: Bearer {access_token}` header'ida kiritiladi

### 3. expires_in
- **Turi**: Number (soniya)
- **Qiymati**: > 0
- **Misol**: `604800` (7 kun)
- **Majburiy**: ✅ HA
- **Foydalanish**: Token muddatini tekshirish uchun

### 4. token_type
- **Turi**: String
- **Qiymati**: `Bearer`
- **Uzunligi**: 50 belgi max
- **Majburiy**: ✅ HA
- **Foydalanish**: Authorization header'da token turini ko'rsatish uchun

---

## Validatsiya Qoidalari

### session_id Validatsiyasi
```dart
// ✅ To'g'ri
if (sessionId == null || sessionId.isEmpty) {
  error: 'session_id majburiy'
}
if (sessionId is! String) {
  error: 'session_id string bo\'lishi kerak'
}
if (sessionId.length != 36) {
  error: 'session_id uzunligi 36 belgi bo\'lishi kerak'
}
```

### access_token Validatsiyasi
```dart
// ✅ To'g'ri
if (accessToken == null || accessToken.isEmpty) {
  error: 'access_token majburiy'
}
if (accessToken is! String) {
  error: 'access_token string bo\'lishi kerak'
}
if (accessToken.length < 512) {
  error: 'access_token 512 belgidan ko\'p bo\'lishi kerak'
}
if (!accessToken.contains('.')) {
  error: 'access_token JWT format bo\'lishi kerak'
}
```

### expires_in Validatsiyasi
```dart
// ✅ To'g'ri
if (expiresIn == null) {
  error: 'expires_in majburiy'
}
if (expiresIn is! int && expiresIn is! num) {
  error: 'expires_in raqam bo\'lishi kerak'
}
if ((expiresIn as num) <= 0) {
  error: 'expires_in musbat raqam bo\'lishi kerak'
}
```

### token_type Validatsiyasi
```dart
// ✅ To'g'ri
if (tokenType == null || tokenType.isEmpty) {
  error: 'token_type majburiy'
}
if (tokenType is! String) {
  error: 'token_type string bo\'lishi kerak'
}
if (tokenType.length > 50) {
  error: 'token_type 50 belgidan ko\'p bo\'lmasligi kerak'
}
if (tokenType != 'Bearer') {
  error: 'token_type "Bearer" bo\'lishi kerak'
}
```

---

## Foydalanish Misoli

### Dart'da (Flutter)
```dart
// 1-jadvaldan access_token olish
final table1Result = await MyIdTableRequests.table1GetAccessToken(
  clientId: 'quyosh_24_sdk-...',
  clientSecret: 'JRgNV6Av8D...',
);

if (!table1Result['success']) {
  print('Xato: ${table1Result['error']}');
  return;
}

// 2-jadvalda session yaratish
final table2Result = await MyIdTableRequests.table2CreateSession(
  accessToken: table1Result['access_token'],
);

if (!table2Result['success']) {
  print('Xato: ${table2Result['error']}');
  return;
}

// ✅ Muvaffaqiyat
print('Session ID: ${table2Result['session_id']}');
print('Access Token: ${table2Result['access_token']}');
```

### cURL'da
```bash
curl -X POST https://api.devmyid.uz/api/v2/sdk/sessions \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{}'
```

### JavaScript'da
```javascript
const response = await fetch('https://api.devmyid.uz/api/v2/sdk/sessions', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${accessToken}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({}),
});

const data = await response.json();
console.log('Session ID:', data.session_id);
console.log('Access Token:', data.access_token);
```

---

## Xato Javoblar

### 401 Unauthorized
```json
{
  "detail": "Invalid token"
}
```
**Sabab**: Access token noto'g'ri yoki muddati tugagan

### 400 Bad Request
```json
{
  "detail": "Invalid session parameters"
}
```
**Sabab**: So'rov parametrlari noto'g'ri

### 500 Internal Server Error
```json
{
  "detail": "Internal server error"
}
```
**Sabab**: Server xatosi

---

## Qo'shimcha Eslatmalar

1. **Token Muddati**: Access token muddati tugamasligi kerak
2. **Session Muddati**: Session ID muddati tugamasligi kerak (expires_in soniya)
3. **JWT Format**: Access token 3 ta nuqta bilan ajratilgan 3 qismdan iborat bo'lishi kerak
4. **UUID Format**: Session ID RFC 4122 standartiga muvofiq bo'lishi kerak
5. **Token Oqimi**: 2-jadvaldan olingan access_token keyingi barcha so'rovlarda kiritilishi kerak

---

## Test Qilish

### Backend'ni ishga tushirish
```bash
cd greenmarket_backend
npm start
```

### Flutter ilovasini ishga tushirish
```bash
cd greenmarket_app
flutter run
```

### Test ekranida
1. "1-JADVAL" tugmasini bosing (access_token olish)
2. "2-JADVAL" tugmasini bosing (session yaratish)
3. Debug chiqarish'da javobni ko'ring

---

**Oxirgi yangilash**: 2025-01-23  
**Versiya**: 1.0.0  
**Manbaa**: MyID API Dokumentatsiyasi
