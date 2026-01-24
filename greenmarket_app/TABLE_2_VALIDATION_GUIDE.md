# 2-JADVAL: Session Yaratish - Validatsiya Qo'llanmasi

## Umumiy Ma'lumot

2-jadval MyID API'dan session yaratadi va majburiy maydonlarni validatsiya qiladi. 2-jadvaldan olingan `access_token` keyingi barcha API so'rovlariga kiritilishi kerak.

## Token Oqimi

```
1-JADVAL: client_id + client_secret → access_token₁
   ↓
2-JADVAL: access_token₁ → session_id + access_token₂
   ↓
3-JADVAL: code + access_token₂ → user profile
```

## So'rov Strukturi

```dart
POST /api/myid/create-session
Authorization: Bearer {access_token}
Content-Type: application/json

{}
```

## Javob Strukturi (MAJBURIY MAYDONLAR)

### 1. session_id
- **Turi**: String (UUID)
- **Uzunligi**: 36 belgi
- **Format**: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- **Misol**: `550e8400-e29b-41d4-a716-446655440000`
- **Majburiy**: ✅ HA

### 2. expires_in
- **Turi**: Number (soniya)
- **Qiymati**: > 0
- **Misol**: `3600` (1 soat)
- **Majburiy**: ✅ HA

### 3. token_type
- **Turi**: String
- **Qiymati**: `Bearer`
- **Uzunligi**: 50 belgi max
- **Majburiy**: ✅ HA

### 4. access_token (KEYINGI SO'ROVLAR UCHUN)
- **Turi**: String (JWT)
- **Uzunligi**: 512+ belgi
- **Format**: `header.payload.signature` (3 ta nuqta)
- **Misol**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c`
- **Majburiy**: ✅ HA
- **Foydalanish**: Keyingi barcha API so'rovlariga `Authorization: Bearer {access_token}` header'ida kiritiladi

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

### access_token Validatsiyasi
```dart
// ✅ To'g'ri
if (newAccessToken == null || newAccessToken.isEmpty) {
  error: 'access_token majburiy'
}
if (newAccessToken is! String) {
  error: 'access_token string bo\'lishi kerak'
}
if (newAccessToken.length < 512) {
  error: 'access_token 512 belgidan ko\'p bo\'lishi kerak'
}
if (!newAccessToken.contains('.')) {
  error: 'access_token JWT format bo\'lishi kerak'
}
```

## Xato Javoblar

### Validatsiya Xatosi
```json
{
  "success": false,
  "error": "Session javobida validatsiya xatosi",
  "validation_errors": [
    "session_id majburiy",
    "expires_in musbat raqam bo'lishi kerak"
  ]
}
```

### Backend Xatosi
```json
{
  "success": false,
  "error": "Backend xatosi: 500",
  "details": "..."
}
```

## Foydalanish Misoli

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
  if (table2Result['validation_errors'] != null) {
    for (final error in table2Result['validation_errors']) {
      print('  - $error');
    }
  }
  return;
}

// 3-jadvalda foydalanuvchi ma'lumotlarini olish (2-jadvaldan olingan token bilan)
final table3Result = await MyIdTableRequests.table3GetUserData(
  code: 'user-code',
  accessToken: table2Result['access_token'],  // ← 2-jadvaldan olingan token
);

if (!table3Result['success']) {
  print('Xato: ${table3Result['error']}');
  return;
}

// ✅ Muvaffaqiyat
print('Foydalanuvchi: ${table3Result['profile']}');
```

## Barcha Jadvallarni Ketma-ketlik Bilan Bajarish

```dart
final result = await MyIdTableRequests.executeAllTables(
  clientId: 'quyosh_24_sdk-...',
  clientSecret: 'JRgNV6Av8D...',
  code: 'user-code',
  onStatusUpdate: (status) {
    print(status);
    // UI'da status ko'rsatish
  },
);

if (result['success']) {
  print('✅ Barcha jadvallar muvaffaqiyatli bajarildi');
  print('Foydalanuvchi: ${result['table3']['profile']}');
} else {
  print('❌ Xato: ${result['error']}');
}
```

## Debug Chiqarish

Validatsiya o'tganda quyidagi debug xabarlari ko'rinadi:

```
✅ [2-JADVAL] Session yaratildi va validatsiya o'tdi
   Session ID: 550e8400-e29b-41d4-a716-446655440000
   Amal qilish muddati: 3600 soniya
   Token turi: Bearer
   Access token uzunligi: 1024
```

## Qo'shimcha Eslatmalar

1. **Access Token Muddati**: Table 1'dan olingan access_token'ning muddati tugamasligi kerak
2. **Session Muddati**: Table 2'dan olingan session_id'ning muddati tugamasligi kerak
3. **JWT Format**: Access token 3 ta nuqta bilan ajratilgan 3 qismdan iborat bo'lishi kerak
4. **UUID Format**: Session ID RFC 4122 standartiga muvofiq bo'lishi kerak
5. **Token Oqimi**: 2-jadvaldan olingan access_token keyingi barcha so'rovlarda kiritilishi kerak

## Test Qilish

```bash
# Backend'ni ishga tushirish
cd greenmarket_backend
npm start

# Flutter ilovasini ishga tushirish
cd greenmarket_app
flutter run

# Test ekranida "Barcha Jadvallar" tugmasini bosish
```

---

**Oxirgi yangilash**: 2025-01-23  
**Versiya**: 2.0.0
