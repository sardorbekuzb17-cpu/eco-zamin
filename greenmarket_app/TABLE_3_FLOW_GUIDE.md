# 3-JADVAL: Foydalanuvchi Ma'lumotlarini Olish - Oqim Qo'llanmasi

## Umumiy Oqim

```
1-JADVAL: client_id + client_secret → access_token₁
   ↓
2-JADVAL: access_token₁ → session_id + access_token₂
   ↓
SDK: session_id → code (SDK'ni ishga tushirish)
   ↓
3-JADVAL: code + access_token₂ → user profile
```

---

## 3-JADVAL: Foydalanuvchi Ma'lumotlarini Olish

### So'rov

**Usul**: POST  
**Endpoint**: `/api/myid/get-user-info`  
**Authorization**: `Bearer {access_token}` (2-jadvaldan)

**Body**:
```json
{
  "code": "USER_CODE_FROM_SDK"
}
```

### Javob

**Muvaffaqiyatli (200 OK)**:
```json
{
  "success": true,
  "data": {
    "user_id": "507f1f77bcf86cd799439011",
    "pinfl": "12345678901234",
    "profile": {
      "pinfl": "12345678901234",
      "name": "Abdullayev Abdulla",
      "surname": "Abdullayev",
      "patronymic": "Abdullayevich",
      "birth_date": "1990-01-15",
      "gender": "M",
      "nationality": "UZ",
      "passport_number": "123456",
      "passport_series": "AA",
      "passport_issue_date": "2015-01-15",
      "passport_expiry_date": "2025-01-15",
      "passport_issuer": "Tashkent City",
      "address": "Tashkent, Mirabad District",
      "phone": "+998901234567",
      "email": "user@example.com"
    }
  }
}
```

**Xato (401 Unauthorized)**:
```json
{
  "detail": "Invalid token"
}
```

**Xato (400 Bad Request)**:
```json
{
  "success": false,
  "error": "Foydalanuvchi ma'lumotlarida validatsiya xatosi",
  "validation_errors": [
    "pinfl uzunligi 14 belgi bo'lishi kerak"
  ]
}
```

---

## Majburiy Maydonlar

| Maydon | Turi | Uzunligi | Tavsif |
|--------|------|----------|--------|
| `pinfl` | String | 14 | Shaxsiy identifikator |
| `name` | String | - | To'liq ism |
| `surname` | String | - | Familiyasi |
| `birth_date` | String | - | Tug'ilgan sana (YYYY-MM-DD) |
| `gender` | String | 1 | M (erkak) yoki F (ayol) |

---

## Ixtiyoriy Maydonlar

| Maydon | Turi | Tavsif |
|--------|------|--------|
| `patronymic` | String | Otasining ismi |
| `nationality` | String | Millati (ISO 3166-1 alpha-2) |
| `passport_number` | String | Pasport raqami |
| `passport_series` | String | Pasport seriyasi |
| `passport_issue_date` | String | Pasport berilgan sana |
| `passport_expiry_date` | String | Pasport muddati tugash sanasi |
| `passport_issuer` | String | Pasport bergan organ |
| `address` | String | Yashash manzili |
| `phone` | String | Telefon raqami |
| `email` | String | Email manzili |

---

## Dart'da Foydalanish

### 1-qadam: Access Token Olish
```dart
final table1 = await MyIdTableRequests.table1GetAccessToken(
  clientId: 'quyosh_24_sdk-...',
  clientSecret: 'JRgNV6Av8D...',
);

if (!table1['success']) {
  print('Xato: ${table1['error']}');
  return;
}

print('✅ Access token olindi');
```

### 2-qadam: Session Yaratish
```dart
final table2 = await MyIdTableRequests.table2CreateSession(
  accessToken: table1['access_token'],
);

if (!table2['success']) {
  print('Xato: ${table2['error']}');
  return;
}

print('✅ Session yaratildi: ${table2['session_id']}');
```

### 3-qadam: SDK'ni Ishga Tushirish
```dart
final result = await MyIdClient.start(
  config: MyIdConfig(
    sessionId: table2['session_id'],
    clientHash: 'YOUR_CLIENT_HASH',
    clientHashId: 'YOUR_CLIENT_HASH_ID',
    environment: MyIdEnvironment.DEV,
    entryType: MyIdEntryType.IDENTIFICATION,
  ),
);

if (result.isNotEmpty) {
  final code = result['code'];
  print('✅ SDK'dan code olindi: $code');
} else {
  print('❌ SDK xatosi');
  return;
}
```

### 4-qadam: Foydalanuvchi Ma'lumotlarini Olish
```dart
final table3 = await MyIdTableRequests.table3GetUserData(
  code: code,
  accessToken: table2['access_token'],
);

if (!table3['success']) {
  print('Xato: ${table3['error']}');
  return;
}

final profile = table3['profile'];
print('✅ Foydalanuvchi ma\'lumotlari olindi');
print('PINFL: ${profile['pinfl']}');
print('Ism: ${profile['name']}');
print('Familiya: ${profile['surname']}');
print('Tug\'ilgan sana: ${profile['birth_date']}');
print('Jinsiyati: ${profile['gender']}');
```

---

## Barcha Jadvallarni Ketma-ketlik Bilan Bajarish

```dart
final result = await MyIdTableRequests.executeAllTables(
  clientId: 'quyosh_24_sdk-...',
  clientSecret: 'JRgNV6Av8D...',
  code: 'USER_CODE_FROM_SDK',
  onStatusUpdate: (status) {
    print(status);
    // UI'da status ko'rsatish
  },
);

if (result['success']) {
  print('✅ Barcha jadvallar muvaffaqiyatli bajarildi');
  
  final profile = result['table3']['profile'];
  print('Foydalanuvchi: ${profile['name']}');
  print('PINFL: ${profile['pinfl']}');
} else {
  print('❌ Xato: ${result['error']}');
}
```

---

## Validatsiya Qoidalari

### PINFL Validatsiyasi
- **Uzunligi**: Aniq 14 belgi
- **Format**: Faqat raqamlar
- **Misol**: `12345678901234`

### Name Validatsiyasi
- **Turi**: String
- **Bo'sh bo'lmasligi**: Majburiy
- **Misol**: `Abdullayev Abdulla`

### Surname Validatsiyasi
- **Turi**: String
- **Bo'sh bo'lmasligi**: Majburiy
- **Misol**: `Abdullayev`

### Birth Date Validatsiyasi
- **Format**: YYYY-MM-DD
- **Misol**: `1990-01-15`

### Gender Validatsiyasi
- **Qiymatlari**: `M` yoki `F`
- **Misol**: `M`

---

## Xato Javoblar

### 401 Unauthorized
**Sabab**: Access token noto'g'ri yoki muddati tugagan

**Yechim**:
1. 1-jadvaldan yangi access_token olish
2. 2-jadvalda yangi session yaratish
3. SDK'ni qayta ishga tushirish

### 400 Bad Request
**Sabab**: Foydalanuvchi ma'lumotlarida validatsiya xatosi

**Yechim**:
1. Validatsiya xatolarini ko'rish
2. MyID API'dan to'g'ri ma'lumotlar olinganligini tekshirish

### 404 Not Found
**Sabab**: Foydalanuvchi topilmadi

**Yechim**:
1. Code parametri to'g'ri ekanligini tekshirish
2. SDK'dan yangi code olish

---

## Debug Chiqarish

Muvaffaqiyatli so'rov:
```
📤 [3-JADVAL] Foydalanuvchi ma'lumotlari so'rovi yuborilmoqda...
   Code: USER_CODE...
   Token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
📥 [3-JADVAL] Javob olindi: 200
✅ [3-JADVAL] Validatsiya o'tdi
   PINFL: 12345678901234
   Ism: Abdullayev Abdulla
   Familiya: Abdullayev
✅ [3-JADVAL] Foydalanuvchi ma'lumotlari olindi
```

---

## Test Qilish

### cURL'da
```bash
curl -X POST https://greenmarket-backend-lilac.vercel.app/api/myid/get-user-info \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{"code": "USER_CODE"}'
```

### Postman'da
1. Method: POST
2. URL: `https://greenmarket-backend-lilac.vercel.app/api/myid/get-user-info`
3. Headers:
   - `Authorization: Bearer {access_token}`
   - `Content-Type: application/json`
4. Body:
   ```json
   {
     "code": "USER_CODE"
   }
   ```

---

**Oxirgi yangilash**: 2025-01-23  
**Versiya**: 1.0.0
