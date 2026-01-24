# 3-JADVAL: Foydalanuvchi Ma'lumotlarini Olish - To'liq Spesifikatsiya

## API Spesifikatsiyasi

### Usul
```
GET
```

### Yakuniy Nuqta
```
{myid_host}/api/v1/sdk/data?code={code}
```

### Kontent Turi
```
application/json
```

### Avtorizatsiya
```
Bearer {access_token}
```
(2-jadvaldan olingan access_token)

---

## So'rov Strukturi

### Header'lar
```http
GET /api/v1/sdk/data?code=USER_CODE HTTP/1.1
Host: api.devmyid.uz
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

### Query Parametrlari
| Parametr | Turi | Majburiy | Tavsif |
|----------|------|---------|--------|
| `code` | satr | ✅ HA | SDK'dan olingan kod |

---

## Javob Strukturi

### Muvaffaqiyatli Javob (200 OK)
```json
{
  "pinfl": "12345678901234",
  "name": "Abdullayev Abdulla",
  "surname": "Abdullayev",
  "patronymic": "Abdullayevich",
  "birth_date": "1990-01-15",
  "gender": "M",
  "nationality": "UZ",
  "passport_number": "AA123456",
  "passport_series": "AA",
  "passport_issue_date": "2015-01-15",
  "passport_expiry_date": "2025-01-15",
  "passport_issuer": "Tashkent City",
  "address": "Tashkent, Mirabad District",
  "phone": "+998901234567",
  "email": "user@example.com"
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
  "detail": "Code parameter is required"
}
```

---

## Majburiy Maydonlar

### 1. pinfl
- **Turi**: String
- **Uzunligi**: 14 belgi
- **Format**: Raqamlar
- **Misol**: `12345678901234`
- **Tavsif**: Shaxsiy identifikator raqami

### 2. name
- **Turi**: String
- **Misol**: `Abdullayev Abdulla`
- **Tavsif**: Foydalanuvchining to'liq ismi

### 3. surname
- **Turi**: String
- **Misol**: `Abdullayev`
- **Tavsif**: Familiyasi

### 4. patronymic
- **Turi**: String
- **Misol**: `Abdullayevich`
- **Tavsif**: Otasining ismi

### 5. birth_date
- **Turi**: String (YYYY-MM-DD)
- **Misol**: `1990-01-15`
- **Tavsif**: Tug'ilgan sana

### 6. gender
- **Turi**: String
- **Qiymatlari**: `M` (erkak) yoki `F` (ayol)
- **Misol**: `M`
- **Tavsif**: Jinsiyati

### 7. nationality
- **Turi**: String
- **Misol**: `UZ`
- **Tavsif**: Millati (ISO 3166-1 alpha-2)

### 8. passport_number
- **Turi**: String
- **Misol**: `123456`
- **Tavsif**: Pasport raqami

### 9. passport_series
- **Turi**: String
- **Misol**: `AA`
- **Tavsif**: Pasport seriyasi

### 10. passport_issue_date
- **Turi**: String (YYYY-MM-DD)
- **Misol**: `2015-01-15`
- **Tavsif**: Pasport berilgan sana

### 11. passport_expiry_date
- **Turi**: String (YYYY-MM-DD)
- **Misol**: `2025-01-15`
- **Tavsif**: Pasport muddati tugash sanasi

### 12. passport_issuer
- **Turi**: String
- **Misol**: `Tashkent City`
- **Tavsif**: Pasport bergan organ

### 13. address
- **Turi**: String
- **Misol**: `Tashkent, Mirabad District`
- **Tavsif**: Yashash manzili

### 14. phone
- **Turi**: String
- **Misol**: `+998901234567`
- **Tavsif**: Telefon raqami

### 15. email
- **Turi**: String
- **Misol**: `user@example.com`
- **Tavsif**: Email manzili

---

## Foydalanish Misoli

### Dart'da (Flutter)
```dart
// 1-jadvaldan token olish
final table1 = await MyIdTableRequests.table1GetAccessToken(
  clientId: 'quyosh_24_sdk-...',
  clientSecret: 'JRgNV6Av8D...',
);

// 2-jadvalda session yaratish
final table2 = await MyIdTableRequests.table2CreateSession(
  accessToken: table1['access_token'],
);

// SDK'dan code olish (SDK'ni ishga tushirish kerak)
// final code = await MyIdClient.start(...);

// 3-jadvalda foydalanuvchi ma'lumotlarini olish
final table3 = await MyIdTableRequests.table3GetUserData(
  code: 'USER_CODE',
  accessToken: table2['access_token'],
);

if (table3['success']) {
  print('✅ Foydalanuvchi ma\'lumotlari olindi');
  print('PINFL: ${table3['profile']['pinfl']}');
  print('Ism: ${table3['profile']['name']}');
} else {
  print('❌ Xato: ${table3['error']}');
}
```

### cURL'da
```bash
curl -X GET "https://api.devmyid.uz/api/v1/sdk/data?code=USER_CODE" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json"
```

### JavaScript'da
```javascript
const response = await fetch(
  'https://api.devmyid.uz/api/v1/sdk/data?code=USER_CODE',
  {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
  }
);

const userData = await response.json();
console.log('PINFL:', userData.pinfl);
console.log('Ism:', userData.name);
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
  "detail": "Code parameter is required"
}
```
**Sabab**: `code` parametri yo'q

### 404 Not Found
```json
{
  "detail": "User not found"
}
```
**Sabab**: Foydalanuvchi topilmadi

### 500 Internal Server Error
```json
{
  "detail": "Internal server error"
}
```
**Sabab**: Server xatosi

---

## Qo'shimcha Eslatmalar

1. **Code Parametri**: SDK'dan olingan kod
2. **Access Token**: 2-jadvaldan olingan token
3. **Token Muddati**: Access token muddati tugamasligi kerak
4. **Pasport Muddati**: Pasport muddati tugagan bo'lishi mumkin

---

**Oxirgi yangilash**: 2025-01-23  
**Versiya**: 1.0.0
