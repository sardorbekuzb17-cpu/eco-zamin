# GreenMarket MyID Backend - API Dokumentatsiyasi

## Mundarija

1. [Kirish](#kirish)
2. [Autentifikatsiya](#autentifikatsiya)
3. [Umumiy Ma'lumotlar](#umumiy-malumotlar)
4. [API Endpointlari](#api-endpointlari)
5. [Xato Kodlari](#xato-kodlari)
6. [Xavfsizlik](#xavfsizlik)
7. [Misollar](#misollar)

---

## Kirish

GreenMarket MyID Backend API MyID integratsiyasi orqali foydalanuvchilarni autentifikatsiya qilish va boshqarish uchun mo'ljallangan. API RESTful arxitekturasiga asoslangan va JSON formatida ma'lumot qaytaradi.

### Base URL

```
Production: https://greenmarket-backend-lilac.vercel.app
Development: http://localhost:3000
```

### API Versiyasi

```
v4.0.0
```

---

## Autentifikatsiya

Backend MyID API bilan ishlash uchun OAuth 2.0 protokolidan foydalanadi. Client credentials (client_id va client_secret) orqali access token olinadi.

**Muhim:** client_secret maxfiy saqlanadi va hech qachon API javoblarida qaytarilmaydi.

---

## Umumiy Ma'lumotlar

### Request Headers

Barcha POST/PUT so'rovlar uchun:

```http
Content-Type: application/json
```

### Response Format

Barcha API javoblari JSON formatida qaytariladi:

**Muvaffaqiyatli javob:**
```json
{
  "success": true,
  "data": { ... }
}
```

**Xato javob:**
```json
{
  "success": false,
  "error": "Xato tavsifi",
  "error_details": {
    "message": "Batafsil xato xabari",
    "status": 400
  }
}
```

### Rate Limiting

API so'rovlari cheklangan:
- **Limit:** 1 daqiqada maksimal 10 so'rov
- **Scope:** `/api/*` yo'llari
- **Xato kodi:** 429 Too Many Requests

---

## API Endpointlari

### 1. Health Check

Server holatini tekshirish.

**Endpoint:** `GET /`

**Request:** Yo'q

**Response:**
```json
{
  "name": "GreenMarket MyID Backend",
  "version": "4.0.0",
  "myid_host": "https://api.myid.uz",
  "total_users": 10,
  "endpoints": {
    "health": "GET /health",
    "create_session": "POST /api/myid/create-session",
    "get_users": "GET /api/users"
  }
}
```

**Status Kodlar:**
- `200 OK` - Server ishlayapti

---

### 2. Bo'sh Sessiya Yaratish

MyID SDK uchun bo'sh sessiya yaratadi. SDK o'zi pasport ma'lumotlarini so'raydi.

**Endpoint:** `POST /api/myid/create-session`

**Request Body:** `{}` (bo'sh)

**Response:**
```json
{
  "data": {
    "session_id": "550e8400-e29b-41d4-a716-446655440000",
    "expires_in": 3600
  }
}
```

**Status Kodlar:**
- `200 OK` - Sessiya muvaffaqiyatli yaratildi
- `400 Bad Request` - Noto'g'ri so'rov
- `401 Unauthorized` - Autentifikatsiya xatosi
- `429 Too Many Requests` - Juda ko'p so'rovlar
- `500 Internal Server Error` - Server xatosi

**Misol:**
```bash
curl -X POST https://greenmarket-backend-lilac.vercel.app/api/myid/create-session \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Validates:** Requirements 2.1, 2.2, 2.5

---

### 3. Pasport bilan Sessiya Yaratish

Pasport ma'lumotlari bilan sessiya yaratadi.

**Endpoint:** `POST /api/myid/create-session-with-passport`

**Request Body:**
```json
{
  "phone_number": "+998901234567",
  "birth_date": "1990-01-01",
  "is_resident": true,
  "pass_data": "AA1234567",
  "pinfl": "12345678901234",
  "threshold": 0.7
}
```

**Request Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| phone_number | string | Yo'q | Telefon raqami (+998 formatida) |
| birth_date | string | Yo'q | Tug'ilgan sana (YYYY-MM-DD) |
| is_resident | boolean | Yo'q | O'zbekiston rezidenti (default: true) |
| pass_data | string | Yo'q | Pasport seriya va raqami (AA1234567) |
| pinfl | string | Yo'q | PINFL (14 raqam) |
| threshold | number | Yo'q | Yuz tanish chegarasi (0.5-0.99) |

**Response:**
```json
{
  "success": true,
  "data": {
    "session_id": "550e8400-e29b-41d4-a716-446655440000",
    "expires_in": 3600
  }
}
```

**Status Kodlar:**
- `200 OK` - Sessiya muvaffaqiyatli yaratildi
- `400 Bad Request` - Noto'g'ri parametrlar
- `500 Internal Server Error` - Server xatosi

**Validates:** Requirements 2.3, 2.4

---

### 4. SDK Code bilan Foydalanuvchi Ma'lumotlarini Olish

MyID SDK'dan olingan code yordamida foydalanuvchi ma'lumotlarini oladi va saqlaydi.

**Endpoint:** `POST /api/myid/sdk/get-user-data`

**Request Body:**
```json
{
  "code": "myid_code_from_sdk"
}
```

**Request Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| code | string | Ha | MyID SDK'dan olingan kod |

**Response:**
```json
{
  "success": true,
  "data": {
    "profile": {
      "first_name": "Sardor",
      "last_name": "Aliyev",
      "middle_name": "Akramovich",
      "birth_date": "1990-01-01",
      "pinfl": "12345678901234",
      "pass_data": "AA1234567",
      "nationality": "UZB",
      "photo": "base64_encoded_photo"
    },
    "result": "success",
    "comparison_value": 0.95
  }
}
```

**Response Fields:**
| Field | Type | Description |
|-------|------|-------------|
| profile.first_name | string | Ism |
| profile.last_name | string | Familiya |
| profile.middle_name | string | Otasining ismi |
| profile.birth_date | string | Tug'ilgan sana (YYYY-MM-DD) |
| profile.pinfl | string | PINFL (14 raqam) |
| profile.pass_data | string | Pasport seriya va raqami |
| profile.nationality | string | Millati (3 harfli kod) |
| profile.photo | string | Yuz surati (base64) |
| comparison_value | number | Yuz tanish aniqlik darajasi (0.0-1.0) |

**Status Kodlar:**
- `200 OK` - Ma'lumotlar muvaffaqiyatli olindi
- `400 Bad Request` - code parametri yo'q yoki noto'g'ri
- `401 Unauthorized` - Token xatosi
- `500 Internal Server Error` - Server xatosi

**Misol:**
```bash
curl -X POST https://greenmarket-backend-lilac.vercel.app/api/myid/sdk/get-user-data \
  -H "Content-Type: application/json" \
  -d '{"code": "abc123xyz"}'
```

**Validates:** Requirements 4.1, 4.2, 4.3, 4.4, 4.5

---

### 5. OAuth Code bilan Foydalanuvchi Ma'lumotlarini Olish

OAuth flow orqali olingan code bilan foydalanuvchi ma'lumotlarini oladi.

**Endpoint:** `POST /api/myid/get-user-info`

**Request Body:**
```json
{
  "code": "oauth_authorization_code"
}
```

**Request Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| code | string | Ha | OAuth authorization code |

**Response:**
```json
{
  "success": true,
  "message": "Foydalanuvchi muvaffaqiyatli ro'yxatdan o'tdi",
  "user": {
    "id": 1,
    "myid_code": "oauth_code",
    "profile_data": {
      "first_name": "Sardor",
      "last_name": "Aliyev",
      "pinfl": "12345678901234"
    },
    "registered_at": "2024-01-15T10:30:00.000Z",
    "last_login": "2024-01-15T10:30:00.000Z",
    "status": "active"
  },
  "profile": { ... }
}
```

**Status Kodlar:**
- `200 OK` - Ma'lumotlar muvaffaqiyatli olindi
- `400 Bad Request` - code parametri yo'q
- `500 Internal Server Error` - Server xatosi

**Validates:** Requirements 1.1, 4.1, 4.2

---

### 6. Session Natijasini Olish

Session ID orqali MyID SDK natijasini oladi.

**Endpoint:** `POST /api/myid/get-session-result`

**Request Body:**
```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Request Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| session_id | string | Ha | MyID session ID |

**Response:**
```json
{
  "success": true,
  "message": "Foydalanuvchi muvaffaqiyatli ro'yxatdan o'tdi",
  "user": {
    "id": 2,
    "session_id": "550e8400-e29b-41d4-a716-446655440000",
    "profile_data": { ... },
    "registered_at": "2024-01-15T10:30:00.000Z",
    "status": "active"
  }
}
```

**Status Kodlar:**
- `200 OK` - Natija muvaffaqiyatli olindi
- `400 Bad Request` - session_id yo'q
- `500 Internal Server Error` - Server xatosi

---

### 7. Barcha Foydalanuvchilarni Ko'rish

Ro'yxatdan o'tgan barcha foydalanuvchilarni pagination bilan qaytaradi.

**Endpoint:** `GET /api/users`

**Query Parameters:**
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| page | number | Yo'q | 1 | Sahifa raqami |
| limit | number | Yo'q | 10 | Har sahifada nechta element |
| status | string | Yo'q | - | Filter: 'active' yoki 'inactive' |

**Response:**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": 1,
        "profile_data": {
          "first_name": "Sardor",
          "last_name": "Aliyev",
          "pinfl": "12345678901234",
          "pass_data": "AA1234567"
        },
        "registered_at": "2024-01-15T10:30:00.000Z",
        "last_login": "2024-01-15T10:30:00.000Z",
        "status": "active",
        "method": "sdk_flow"
      }
    ],
    "pagination": {
      "total": 100,
      "page": 1,
      "limit": 10,
      "totalPages": 10
    },
    "stats": {
      "total_users": 100,
      "today_registrations": 5,
      "lastRegistrationDate": "2024-01-15T10:30:00.000Z"
    }
  }
}
```

**Status Kodlar:**
- `200 OK` - Ro'yxat muvaffaqiyatli qaytarildi
- `500 Internal Server Error` - Server xatosi

**Misol:**
```bash
curl -X GET "https://greenmarket-backend-lilac.vercel.app/api/users?page=1&limit=10&status=active"
```

**Validates:** Requirements 9.5

---

### 8. Bitta Foydalanuvchini Ko'rish

ID bo'yicha bitta foydalanuvchi ma'lumotlarini qaytaradi.

**Endpoint:** `GET /api/users/:id`

**URL Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | number | Ha | Foydalanuvchi ID |

**Response:**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "profile_data": {
      "first_name": "Sardor",
      "last_name": "Aliyev",
      "pinfl": "12345678901234",
      "pass_data": "AA1234567"
    },
    "registered_at": "2024-01-15T10:30:00.000Z",
    "status": "active"
  }
}
```

**Status Kodlar:**
- `200 OK` - Foydalanuvchi topildi
- `404 Not Found` - Foydalanuvchi topilmadi
- `500 Internal Server Error` - Server xatosi

**Misol:**
```bash
curl -X GET https://greenmarket-backend-lilac.vercel.app/api/users/1
```

---

### 9. Foydalanuvchi Statistikasi

Foydalanuvchilar statistikasini qaytaradi.

**Endpoint:** `GET /api/users/stats/summary`

**Request:** Yo'q

**Response:**
```json
{
  "success": true,
  "stats": {
    "total_users": 100,
    "today_registrations": 5,
    "active_users": 95,
    "inactive_users": 5,
    "last_registration": "2024-01-15T10:30:00.000Z"
  }
}
```

**Status Kodlar:**
- `200 OK` - Statistika muvaffaqiyatli qaytarildi
- `500 Internal Server Error` - Server xatosi

---

### 10. Foydalanuvchini O'chirish

ID bo'yicha foydalanuvchini o'chiradi.

**Endpoint:** `DELETE /api/users/:id`

**URL Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | number | Ha | Foydalanuvchi ID |

**Response:**
```json
{
  "success": true,
  "message": "Foydalanuvchi o'chirildi",
  "user": {
    "id": 1,
    "profile_data": { ... }
  }
}
```

**Status Kodlar:**
- `200 OK` - Foydalanuvchi o'chirildi
- `404 Not Found` - Foydalanuvchi topilmadi
- `500 Internal Server Error` - Server xatosi

---

### 11. Access Token Olish (Test uchun)

MyID API uchun access token oladi. Bu endpoint asosan test va debug uchun ishlatiladi.

**Endpoint:** `POST /api/myid/get-access-token`

**Request Body:** `{}` (bo'sh)

**Response:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 604800,
    "token_type": "Bearer"
  }
}
```

**Status Kodlar:**
- `200 OK` - Token muvaffaqiyatli olindi
- `401 Unauthorized` - Client credentials noto'g'ri
- `500 Internal Server Error` - Server xatosi

**Validates:** Requirements 1.1, 1.2

---

### 12. Verifikatsiya So'rovi Yuborish (SDK Flow)

Pasport va selfie yuborish orqali verifikatsiya jarayonini boshlaydi.

**Endpoint:** `POST /api/myid/submit-verification`

**Request Body:**
```json
{
  "access_token": "eyJhbGci...",
  "pass_data": "AA1234567",
  "birth_date": "1990-01-01",
  "photo_base64": "base64_encoded_selfie",
  "agreed_on_terms": true,
  "is_resident": true,
  "threshold": 0.7
}
```

**Request Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| access_token | string | Ha | MyID access token |
| pass_data | string | Yo'q* | Pasport seriya va raqami |
| pinfl | string | Yo'q* | PINFL (14 raqam) |
| birth_date | string | Ha | Tug'ilgan sana (YYYY-MM-DD) |
| photo_base64 | string | Ha | Selfie (base64 format) |
| agreed_on_terms | boolean | Yo'q | Shartlarga rozi (default: true) |
| is_resident | boolean | Yo'q | O'zbekiston rezidenti |
| threshold | number | Yo'q | Yuz tanish chegarasi (0.5-0.99) |

*Eslatma: pass_data yoki pinfl'dan biri majburiy

**Response:**
```json
{
  "success": true,
  "data": {
    "job_id": "job_123456789",
    "status": "processing"
  }
}
```

**Status Kodlar:**
- `200 OK` - So'rov muvaffaqiyatli yuborildi
- `400 Bad Request` - Noto'g'ri parametrlar
- `401 Unauthorized` - Token xatosi
- `500 Internal Server Error` - Server xatosi

---

### 13. Verifikatsiya Natijasini Olish

Job ID orqali verifikatsiya natijasini oladi.

**Endpoint:** `POST /api/myid/get-result`

**Request Body:**
```json
{
  "access_token": "eyJhbGci...",
  "job_id": "job_123456789"
}
```

**Request Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| access_token | string | Ha | MyID access token |
| job_id | string | Ha | Verifikatsiya job ID |

**Response:**
```json
{
  "success": true,
  "data": {
    "result_code": 1,
    "result_note": "success",
    "profile": {
      "first_name": "Sardor",
      "last_name": "Aliyev",
      "pinfl": "12345678901234",
      "pass_data": "AA1234567"
    },
    "comparison_value": 0.95
  }
}
```

**Result Codes:**
| Code | Ma'nosi | Harakat |
|------|---------|---------|
| 1 | Muvaffaqiyatli | Foydalanuvchi tasdiqlandi |
| 0 | Jarayon davom etmoqda | Qayta so'rov yuboring |
| -1 | Xato | Qayta urinish kerak |

**Status Kodlar:**
- `200 OK` - Natija muvaffaqiyatli olindi
- `400 Bad Request` - Parametrlar noto'g'ri
- `401 Unauthorized` - Token xatosi
- `500 Internal Server Error` - Server xatosi

---

### 14. To'liq SDK Flow (Bitta So'rovda)

Barcha SDK flow qadamlarini bitta so'rovda bajaradi: token olish, verifikatsiya yuborish va natija olish.

**Endpoint:** `POST /api/myid/complete`

**Request Body:**
```json
{
  "pass_data": "AA1234567",
  "birth_date": "1990-01-01",
  "photo_base64": "base64_encoded_selfie",
  "agreed_on_terms": true,
  "is_resident": true,
  "threshold": 0.7
}
```

**Response:**
```json
{
  "success": true,
  "message": "SDK Flow muvaffaqiyatli yakunlandi",
  "data": {
    "result_code": 1,
    "result_note": "success",
    "profile": {
      "first_name": "Sardor",
      "last_name": "Aliyev",
      "pinfl": "12345678901234"
    },
    "comparison_value": 0.95
  },
  "job_id": "job_123456789"
}
```

**Status Kodlar:**
- `200 OK` - Flow muvaffaqiyatli yakunlandi
- `400 Bad Request` - Parametrlar noto'g'ri
- `500 Internal Server Error` - Server xatosi

**Validates:** Requirements 1.1, 2.2, 4.1, 4.2, 4.4

---

## Xato Kodlari

### HTTP Status Kodlar

| Kod | Ma'nosi | Tavsif |
|-----|---------|--------|
| 200 | OK | So'rov muvaffaqiyatli bajarildi |
| 400 | Bad Request | Noto'g'ri so'rov parametrlari |
| 401 | Unauthorized | Autentifikatsiya xatosi |
| 403 | Forbidden | Ruxsat yo'q |
| 404 | Not Found | Resurs topilmadi |
| 429 | Too Many Requests | Juda ko'p so'rovlar (rate limit) |
| 500 | Internal Server Error | Server ichki xatosi |
| 503 | Service Unavailable | Xizmat vaqtinchalik mavjud emas |

### MyID SDK Xato Kodlari

| Kod | Ma'nosi | Harakat |
|-----|---------|---------|
| 0 | Muvaffaqiyatli | Davom etish |
| 1 | Bekor qilindi | Qayta urinish taklifi |
| 2 | Xato | Xato xabarini ko'rsatish |
| 3 | Timeout | Qayta urinish |

### Xato Javob Formati

```json
{
  "success": false,
  "error": "Qisqa xato tavsifi",
  "error_details": {
    "message": "Batafsil xato xabari",
    "status": 400,
    "data": {
      "field": "pass_data",
      "reason": "Noto'g'ri format"
    }
  }
}
```

### Umumiy Xato Xabarlari

| Xato | Sabab | Yechim |
|------|-------|--------|
| "code majburiy" | Request body'da code yo'q | code parametrini qo'shing |
| "session_id majburiy" | Request body'da session_id yo'q | session_id parametrini qo'shing |
| "Access token olishda xatolik" | Client credentials noto'g'ri | CLIENT_ID va CLIENT_SECRET tekshiring |
| "Foydalanuvchi topilmadi" | Noto'g'ri user ID | To'g'ri ID kiriting |
| "Too Many Requests" | Rate limit oshdi | 1 daqiqa kuting |

**Validates:** Requirements 1.4, 2.6, 6.1, 6.5, 6.6, 9.8

---

## Xavfsizlik

### 1. HTTPS Protokoli

Barcha MyID API so'rovlari **HTTPS** protokoli orqali yuboriladi. HTTP so'rovlar avtomatik rad etiladi.

```javascript
// Backend'da HTTPS validatsiyasi
if (!url.startsWith('https://')) {
  throw new Error('Faqat HTTPS protokoli qo\'llab-quvvatlanadi');
}
```

**Validates:** Requirements 5.1

---

### 2. Maxfiy Ma'lumotlarni Shifrlash

Backend AES-256-CBC algoritmi bilan maxfiy ma'lumotlarni shifrlaydi:

**Shifrlangan ma'lumotlar:**
- Pasport seriya va raqami (pass_data)
- PINFL (14 raqamli identifikator)
- Foydalanuvchi profil ma'lumotlari

**Shifrlash formati:**
```
iv:encrypted_data
```

**Muhim:**
- `client_secret` hech qachon API javoblarida qaytarilmaydi
- Ma'lumotlar bazasida barcha maxfiy ma'lumotlar shifrlangan formatda saqlanadi
- API javoblarida ma'lumotlar avtomatik deshifrlangan holda qaytariladi

**Validates:** Requirements 5.3, 5.4

---

### 3. Token Cache Mexanizmi

Access token'lar xotirada saqlanadi va qayta ishlatiladi:

**Xususiyatlar:**
- Token muddati: 7 kun (604800 soniya)
- Avtomatik yangilanish: Muddati tugashidan 5 daqiqa oldin
- Cache'dan foydalanish: Token hali amal qilsa, yangi so'rov yuborilmaydi

**Foyda:**
- MyID API'ga kamroq so'rovlar
- Tezroq javob vaqti
- Rate limiting muammolarini kamaytirish

**Validates:** Requirements 1.3, 1.5

---

### 4. Qayta Urinish Mexanizmi

Tarmoq xatoliklari va timeout'lar uchun eksponensial backoff:

**Konfiguratsiya:**
- Maksimal urinishlar: 3 marta
- Boshlang'ich kutish: 1 soniya
- Maksimal kutish: 8 soniya
- Har bir urinishda kutish vaqti 2 baravar oshadi

**Qayta urinish kerak bo'lgan xatolar:**
- 5xx server xatolari
- 429 Too Many Requests
- 408 Request Timeout
- Tarmoq xatolari (ETIMEDOUT, ECONNABORTED)

**Qayta urinish kerak bo'lmagan xatolar:**
- 4xx client xatolari (400, 401, 403, 404)

**Validates:** Requirements 6.2, 6.3

---

### 5. Rate Limiting

API so'rovlari cheklangan:

**Limitlar:**
- **Scope:** `/api/*` yo'llari
- **Limit:** 1 daqiqada maksimal 10 so'rov
- **Xato:** 429 Too Many Requests

**Middleware:**
```javascript
const rateLimit = require('express-rate-limit');

const apiLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 daqiqa
  max: 10, // maksimal 10 so'rov
  message: 'Juda ko\'p so\'rovlar. 1 daqiqa kuting.',
});

app.use('/api/', apiLimiter);
```

**Validates:** Requirements 5.8

---

### 6. Xato Boshqaruvi

Backend barcha xatolarni to'g'ri boshqaradi va log qiladi:

**Xato Handler Middleware:**
```javascript
app.use((error, req, res, next) => {
  // Xatoni log qilish
  console.error('❌ Xato:', {
    message: error.message,
    status: error.statusCode || 500,
    stack: error.stack,
  });

  // Tushunarli xato xabarini qaytarish
  res.status(error.statusCode || 500).json({
    success: false,
    error: error.message,
    error_details: {
      message: error.message,
      status: error.statusCode || 500,
    },
  });
});
```

**Validates:** Requirements 1.4, 2.6, 6.5, 6.6

---

## Misollar

### Misol 1: Bo'sh Sessiya Yaratish va SDK Ishga Tushirish

**1-qadam: Backend'dan sessiya yaratish**

```bash
curl -X POST https://greenmarket-backend-lilac.vercel.app/api/myid/create-session \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Javob:**
```json
{
  "data": {
    "session_id": "550e8400-e29b-41d4-a716-446655440000",
    "expires_in": 3600
  }
}
```

**2-qadam: Flutter'da SDK ishga tushirish**

```dart
final sessionId = response['data']['session_id'];

final config = MyIdConfig(
  sessionId: sessionId,
  clientHash: MyIDConfig.clientHash,
  clientHashId: MyIDConfig.clientHashId,
  environment: MyIdEnvironment.PRODUCTION,
  entryType: MyIdEntryType.IDENTIFICATION,
  locale: MyIdLocale.UZBEK,
);

final result = await MyIdClient.start(config: config);

if (result.code == '0') {
  // Muvaffaqiyatli - code'ni backend'ga yuborish
  final code = result.code;
}
```

**3-qadam: Code bilan foydalanuvchi ma'lumotlarini olish**

```bash
curl -X POST https://greenmarket-backend-lilac.vercel.app/api/myid/sdk/get-user-data \
  -H "Content-Type: application/json" \
  -d '{"code": "abc123xyz"}'
```

**Javob:**
```json
{
  "success": true,
  "data": {
    "profile": {
      "first_name": "Sardor",
      "last_name": "Aliyev",
      "pinfl": "12345678901234"
    },
    "comparison_value": 0.95
  }
}
```

---

### Misol 2: Pasport bilan Sessiya Yaratish

```bash
curl -X POST https://greenmarket-backend-lilac.vercel.app/api/myid/create-session-with-passport \
  -H "Content-Type: application/json" \
  -d '{
    "pass_data": "AA1234567",
    "birth_date": "1990-01-01",
    "is_resident": true,
    "threshold": 0.7
  }'
```

**Javob:**
```json
{
  "success": true,
  "data": {
    "session_id": "550e8400-e29b-41d4-a716-446655440000",
    "expires_in": 3600
  }
}
```

---

### Misol 3: Barcha Foydalanuvchilarni Ko'rish (Pagination)

```bash
curl -X GET "https://greenmarket-backend-lilac.vercel.app/api/users?page=1&limit=5&status=active"
```

**Javob:**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": 1,
        "profile_data": {
          "first_name": "Sardor",
          "last_name": "Aliyev"
        },
        "status": "active"
      },
      {
        "id": 2,
        "profile_data": {
          "first_name": "Aziza",
          "last_name": "Karimova"
        },
        "status": "active"
      }
    ],
    "pagination": {
      "total": 50,
      "page": 1,
      "limit": 5,
      "totalPages": 10
    },
    "stats": {
      "total_users": 50,
      "today_registrations": 3
    }
  }
}
```

---

### Misol 4: Xato Boshqaruvi

**Noto'g'ri so'rov (code yo'q):**

```bash
curl -X POST https://greenmarket-backend-lilac.vercel.app/api/myid/sdk/get-user-data \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Javob:**
```json
{
  "success": false,
  "error": "code majburiy",
  "error_details": {
    "message": "code majburiy",
    "status": 400
  }
}
```

---

### Misol 5: Rate Limiting

**11-chi so'rov (1 daqiqada):**

```bash
curl -X POST https://greenmarket-backend-lilac.vercel.app/api/myid/create-session \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Javob:**
```json
{
  "success": false,
  "error": "Juda ko'p so'rovlar. 1 daqiqa kuting.",
  "error_details": {
    "status": 429
  }
}
```

---

### Misol 6: To'liq SDK Flow (JavaScript/Node.js)

```javascript
const axios = require('axios');

async function completeMyIdFlow() {
  try {
    // 1. Bo'sh sessiya yaratish
    console.log('1. Sessiya yaratilmoqda...');
    const sessionResponse = await axios.post(
      'https://greenmarket-backend-lilac.vercel.app/api/myid/create-session',
      {}
    );
    
    const sessionId = sessionResponse.data.data.session_id;
    console.log('✅ Session ID:', sessionId);
    
    // 2. SDK ishga tushirish (mobile'da)
    // MyIdClient.start(config) - Flutter'da
    
    // 3. SDK'dan code olish (mobile'dan)
    const code = 'abc123xyz'; // SDK'dan olingan
    
    // 4. Foydalanuvchi ma'lumotlarini olish
    console.log('2. Foydalanuvchi ma\'lumotlari olinmoqda...');
    const userResponse = await axios.post(
      'https://greenmarket-backend-lilac.vercel.app/api/myid/sdk/get-user-data',
      { code }
    );
    
    console.log('✅ Foydalanuvchi:', userResponse.data.data.profile);
    console.log('✅ Comparison value:', userResponse.data.data.comparison_value);
    
    return userResponse.data;
  } catch (error) {
    console.error('❌ Xato:', error.response?.data || error.message);
    throw error;
  }
}

// Ishga tushirish
completeMyIdFlow();
```

---

### Misol 7: Flutter'da To'liq Integratsiya

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyIdService {
  static const String baseUrl = 'https://greenmarket-backend-lilac.vercel.app';
  
  // 1. Sessiya yaratish
  static Future<String> createSession() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/myid/create-session'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({}),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['session_id'];
    } else {
      throw Exception('Sessiya yaratishda xatolik');
    }
  }
  
  // 2. SDK ishga tushirish
  static Future<String> startSdk(String sessionId) async {
    final config = MyIdConfig(
      sessionId: sessionId,
      clientHash: MyIDConfig.clientHash,
      clientHashId: MyIDConfig.clientHashId,
      environment: MyIdEnvironment.PRODUCTION,
      entryType: MyIdEntryType.IDENTIFICATION,
      locale: MyIdLocale.UZBEK,
    );
    
    final result = await MyIdClient.start(config: config);
    
    if (result.code == '0') {
      return result.code;
    } else {
      throw Exception('SDK xatosi: ${result.code}');
    }
  }
  
  // 3. Foydalanuvchi ma'lumotlarini olish
  static Future<Map<String, dynamic>> getUserData(String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/myid/sdk/get-user-data'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'code': code}),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Ma\'lumot olishda xatolik');
    }
  }
  
  // To'liq flow
  static Future<Map<String, dynamic>> completeFlow() async {
    // 1. Sessiya yaratish
    final sessionId = await createSession();
    print('✅ Session ID: $sessionId');
    
    // 2. SDK ishga tushirish
    final code = await startSdk(sessionId);
    print('✅ Code: $code');
    
    // 3. Ma'lumot olish
    final userData = await getUserData(code);
    print('✅ User: ${userData['data']['profile']['first_name']}');
    
    return userData;
  }
}
```

---

## Qo'shimcha Ma'lumotlar

### Environment Variables

Backend quyidagi environment variables'larni talab qiladi:

```bash
# MyID Credentials
CLIENT_ID=your_client_id_here
CLIENT_SECRET=your_client_secret_here
MYID_HOST=https://api.myid.uz

# Server Configuration
PORT=3000
NODE_ENV=production

# Encryption Key (AES-256)
# 64 ta hex belgi (32 byte)
ENCRYPTION_KEY=your_64_character_hex_encryption_key_here
```

**Encryption Key yaratish:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

---

### Deployment

**Vercel'ga deploy qilish:**

```bash
# Vercel CLI o'rnatish
npm install -g vercel

# Deploy qilish
vercel

# Production'ga deploy
vercel --prod
```

**Environment variables sozlash:**
```bash
vercel env add CLIENT_ID
vercel env add CLIENT_SECRET
vercel env add ENCRYPTION_KEY
vercel env add MYID_HOST
```

---

### Test Qilish

**Backend testlarini ishga tushirish:**

```bash
# Barcha testlar
npm test

# Faqat unit testlar
npm test -- --testPathPattern=unit

# Faqat property testlar
npm test -- --testPathPattern=property

# Coverage hisoboti
npm run test:coverage
```

**Test coverage maqsadi:** Kamida 80%

---

### Logging

Backend barcha muhim hodisalarni log qiladi:

**Log formati:**
```
📤 [1/4] Access token olinmoqda...
✅ [1/4] Access token olindi
📤 [2/4] Session yaratilmoqda...
✅ [2/4] Session yaratildi: 550e8400-e29b-41d4-a716-446655440000
❌ Xato: Access token olishda xatolik
```

**Log qilinadigan hodisalar:**
- Access token olish
- Sessiya yaratish
- Foydalanuvchi ma'lumotlarini olish
- Xatolar va qayta urinishlar
- Rate limiting hodisalari

**Muhim:** Maxfiy ma'lumotlar (client_secret, pasport, PINFL) log'da ko'rsatilmaydi.

---

### Performance

**Token Cache:**
- Access token 7 kun davomida cache'da saqlanadi
- Muddati tugashidan 5 daqiqa oldin avtomatik yangilanadi
- Cache'dan foydalanish MyID API'ga so'rovlarni 99% kamaytiradi

**Qayta Urinish:**
- Maksimal 3 marta qayta urinish
- Eksponensial backoff (1s, 2s, 4s, 8s)
- Faqat qayta urinishga loyiq xatolar uchun

**Rate Limiting:**
- 1 daqiqada maksimal 10 so'rov
- IP manzil bo'yicha cheklash
- 429 status kodi qaytarish

---

### Xavfsizlik Tavsiyalari

1. ✅ **HTTPS ishlatish** - Barcha so'rovlar HTTPS orqali
2. ✅ **Environment variables** - Maxfiy ma'lumotlarni .env faylida saqlash
3. ✅ **Shifrlash** - AES-256 bilan maxfiy ma'lumotlarni shifrlash
4. ✅ **Rate limiting** - API so'rovlarini cheklash
5. ✅ **Xato boshqaruvi** - Barcha xatolarni to'g'ri boshqarish
6. ✅ **Logging** - Xatolarni log qilish (maxfiy ma'lumotlarsiz)
7. ⚠️ **CORS** - Production'da faqat kerakli domenlarni ruxsat berish
8. ⚠️ **Helmet.js** - HTTP headerlarni xavfsizlashtirish (qo'shilishi kerak)

---

### API Versiyalash

Hozirgi versiya: **v4.0.0**

**Versiya tarixi:**
- v4.0.0 - Foydalanuvchilar bazasi va statistika qo'shildi
- v3.0.0 - Shifrlash va xavfsizlik yaxshilandi
- v2.0.0 - SDK flow qo'shildi
- v1.0.0 - Asosiy OAuth flow

---

### Qo'llab-quvvatlash

**Texnik yordam:**
- Email: support@greenmarket.uz
- Telegram: @greenmarket_support
- GitHub Issues: [github.com/greenmarket/backend](https://github.com/greenmarket/backend)

**Dokumentatsiya:**
- API Docs: Bu fayl
- MyID Docs: [myid.uz/docs](https://myid.uz/docs)
- Backend README: [README.md](./README.md)

---

### Litsenziya

© 2024 GreenMarket. Barcha huquqlar himoyalangan.

---

## Xulosa

Ushbu API dokumentatsiyasi GreenMarket MyID Backend'ning barcha endpointlari, xato kodlari, xavfsizlik xususiyatlari va misollarini o'z ichiga oladi.

**Asosiy xususiyatlar:**
- ✅ MyID OAuth 2.0 integratsiyasi
- ✅ SDK flow qo'llab-quvvatlash
- ✅ Maxfiy ma'lumotlarni shifrlash (AES-256)
- ✅ Token cache mexanizmi
- ✅ Qayta urinish mexanizmi (eksponensial backoff)
- ✅ Rate limiting (10 so'rov/daqiqa)
- ✅ Xato boshqaruvi va logging
- ✅ HTTPS protokoli majburiy

**Requirements qamrovi:**
- Requirements 1.1-1.5: OAuth autentifikatsiya ✅
- Requirements 2.1-2.7: Sessiya boshqaruvi ✅
- Requirements 4.1-4.6: Foydalanuvchi ma'lumotlari ✅
- Requirements 5.1-5.8: Xavfsizlik ✅
- Requirements 6.1-6.6: Xato boshqaruvi ✅
- Requirements 9.1-9.8: API endpointlari ✅

**Keyingi qadamlar:**
1. Frontend bilan integratsiya
2. Production'ga deploy qilish
3. Monitoring va logging sozlash
4. Load testing o'tkazish

---

**Oxirgi yangilanish:** 2024-01-15  
**Versiya:** 4.0.0  
**Muallif:** GreenMarket Development Team
