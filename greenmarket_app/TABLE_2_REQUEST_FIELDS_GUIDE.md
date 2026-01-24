# 2-JADVAL: So'rov Maydonlari - To'liq Qo'llanma

## So'rov Maydonlari (Ixtiyoriy)

| Maydon | Turi | Majburiy | Tavsif |
|--------|------|---------|--------|
| `phone_number` | satr (min: 12, max: 13) \| null | Yo'q | Telefon raqami 998901234567 kabi formatda. + ixtiyoriy |
| `birth_date` | satr (YYYY-MM-DD) \| null | Yo'q | ISO formatida tug'ilgan sana |
| `is_resident` | bool \| null | Yo'q | Foydalanuvchi rezidentmi yoki yo'qmi (standart: rost) |
| `pass_data` | satr \| null | Yo'q | Pasport seriyasi va raqami |
| `threshold` | suzuvchi \| null | Yo'q | 0,5 dan 0,99 gacha |

---

## Maydon Tavsifları

### 1. phone_number
- **Turi**: String (ixtiyoriy)
- **Uzunligi**: 12-13 belgi
- **Format**: `998901234567` yoki `+998901234567`
- **Misol**: `998901234567`
- **Validatsiya**: `/^\+?998\d{9}$/`
- **Foydalanish**: Foydalanuvchining telefon raqamini oldindan to'ldirish

### 2. birth_date
- **Turi**: String (ixtiyoriy)
- **Format**: `YYYY-MM-DD` (ISO 8601)
- **Misol**: `1990-01-15`
- **Validatsiya**: `/^\d{4}-\d{2}-\d{2}$/`
- **Foydalanish**: Tug'ilgan sanani oldindan to'ldirish

### 3. is_resident
- **Turi**: Boolean (ixtiyoriy)
- **Qiymatlari**: `true` yoki `false`
- **Standart**: `true` (rost)
- **Misol**: `true`
- **Foydalanish**: Foydalanuvchi Uzbekistan rezidenti yoki yo'qligini ko'rsatish

### 4. pass_data
- **Turi**: String (ixtiyoriy)
- **Uzunligi**: 2+ belgi
- **Format**: Pasport seriyasi va raqami
- **Misol**: `AA123456`
- **Foydalanish**: Pasport ma'lumotlarini oldindan to'ldirish

### 5. threshold
- **Turi**: Number (ixtiyoriy)
- **Qiymati**: 0.5 - 0.99
- **Misol**: `0.85`
- **Foydalanish**: Yuz taqqoslash chegarasini o'rnatish

---

## Validatsiya Qoidalari

### phone_number Validatsiyasi
```dart
// ✅ To'g'ri
if (phoneNumber != null) {
  if (phoneNumber.isEmpty) {
    error: 'phone_number bo\'sh bo\'lmasligi kerak'
  }
  if (phoneNumber.length < 12 || phoneNumber.length > 13) {
    error: 'phone_number uzunligi 12-13 belgi bo\'lishi kerak'
  }
  if (!RegExp(r'^\+?998\d{9}$').hasMatch(phoneNumber)) {
    error: 'phone_number 998901234567 kabi formatda bo\'lishi kerak'
  }
}
```

### birth_date Validatsiyasi
```dart
// ✅ To'g'ri
if (birthDate != null) {
  if (birthDate.isEmpty) {
    error: 'birth_date bo\'sh bo\'lmasligi kerak'
  }
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birthDate)) {
    error: 'birth_date YYYY-MM-DD formatida bo\'lishi kerak'
  }
  try {
    DateTime.parse(birthDate);
  } catch (e) {
    error: 'birth_date to\'g\'ri sana bo\'lmasligi kerak'
  }
}
```

### pass_data Validatsiyasi
```dart
// ✅ To'g'ri
if (passData != null) {
  if (passData.isEmpty) {
    error: 'pass_data bo\'sh bo\'lmasligi kerak'
  }
  if (passData.length < 2) {
    error: 'pass_data kamita 2 belgidan iborat bo\'lishi kerak'
  }
}
```

### threshold Validatsiyasi
```dart
// ✅ To'g'ri
if (threshold != null) {
  if (threshold < 0.5 || threshold > 0.99) {
    error: 'threshold 0.5 dan 0.99 gacha bo\'lishi kerak'
  }
}
```

---

## Foydalanish Misollari

### 1. Bo'sh Session (Hech qanday maydon yo'q)
```dart
final result = await MyIdTableRequests.table2CreateSession(
  accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);
```

**So'rov body:**
```json
{}
```

---

### 2. Pasport Bilan Session
```dart
final result = await MyIdTableRequestsWithFields.table2CreateSessionWithPassport(
  accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  passData: 'AA123456',
  birthDate: '1990-01-15',
);
```

**So'rov body:**
```json
{
  "pass_data": "AA123456",
  "birth_date": "1990-01-15"
}
```

---

### 3. Barcha Maydonlar Bilan Session
```dart
final result = await MyIdTableRequestsWithFields.table2CreateSessionWithFields(
  accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  phoneNumber: '998901234567',
  birthDate: '1990-01-15',
  isResident: true,
  passData: 'AA123456',
  threshold: 0.85,
);
```

**So'rov body:**
```json
{
  "phone_number": "998901234567",
  "birth_date": "1990-01-15",
  "is_resident": true,
  "pass_data": "AA123456",
  "threshold": 0.85
}
```

---

### 4. Faqat Telefon va Sana Bilan
```dart
final result = await MyIdTableRequestsWithFields.table2CreateSessionWithFields(
  accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  phoneNumber: '998901234567',
  birthDate: '1990-01-15',
);
```

**So'rov body:**
```json
{
  "phone_number": "998901234567",
  "birth_date": "1990-01-15"
}
```

---

## Eslatmalar

### Passport Ma'lumotlari Bilan Session
Agar sessiya passport ma'lumotlari (`pass_data` yoki `pinfl`) bilan yaratilsa:
- SDK birinchi sahifani o'tkazib yuboradi
- To'g'ridan to'g'ridan yuz suratiga olishga o'tadi
- Foydalanuvchi pasport ma'lumotlarini qayta kiritmasligi kerak

### Telefon Raqami Formati
- `998901234567` (+ yo'q)
- `+998901234567` (+ bilan)
- Ikkalasi ham qabul qilinadi

### Tug'ilgan Sana Formati
- Faqat `YYYY-MM-DD` format qabul qilinadi
- Misol: `1990-01-15` (to'g'ri)
- Misol: `15-01-1990` (noto'g'ri)
- Misol: `1990/01/15` (noto'g'ri)

### Yuz Taqqoslash Chegarasi
- Minimum: `0.5` (50%)
- Maksimum: `0.99` (99%)
- Standart: `0.85` (85%)

---

## Xato Javoblar

### Validatsiya Xatosi
```json
{
  "success": false,
  "error": "So'rov maydonlarida validatsiya xatosi",
  "validation_errors": [
    "phone_number uzunligi 12-13 belgi bo'lishi kerak",
    "birth_date YYYY-MM-DD formatida bo'lishi kerak"
  ]
}
```

### Backend Xatosi
```json
{
  "success": false,
  "error": "Backend xatosi: 400",
  "details": "..."
}
```

---

## Test Qilish

### Dart'da Test
```dart
// 1-jadvaldan token olish
final table1 = await MyIdTableRequests.table1GetAccessToken(
  clientId: 'quyosh_24_sdk-...',
  clientSecret: 'JRgNV6Av8D...',
);

// 2-jadvalda session yaratish (maydonlar bilan)
final table2 = await MyIdTableRequestsWithFields.table2CreateSessionWithFields(
  accessToken: table1['access_token'],
  phoneNumber: '998901234567',
  birthDate: '1990-01-15',
  isResident: true,
  passData: 'AA123456',
  threshold: 0.85,
);

if (table2['success']) {
  print('✅ Session yaratildi: ${table2['session_id']}');
} else {
  print('❌ Xato: ${table2['error']}');
}
```

### cURL'da Test
```bash
curl -X POST https://greenmarket-backend-lilac.vercel.app/api/myid/create-session-with-fields \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "998901234567",
    "birth_date": "1990-01-15",
    "is_resident": true,
    "pass_data": "AA123456",
    "threshold": 0.85
  }'
```

---

**Oxirgi yangilash**: 2025-01-23  
**Versiya**: 1.0.0
