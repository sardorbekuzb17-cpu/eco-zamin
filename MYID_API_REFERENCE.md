# MyID API Reference

## Session Natijasini Olish

### Endpoint
```
GET /api/v2/sdk/sessions/{session_id}
```

### Response Format
```json
{
  "code": "string | null",
  "status": "in_progress | closed | expired",
  "attempts": [
    {
      "job_id": "uuid4",
      "timestamp": "2025-05-27T12:34:56Z",
      "reason": "string | null",
      "reason_code": "int | null"
    }
  ]
}
```

### Status Qiymatlari
- `in_progress` - Jarayon davom etmoqda
- `closed` - Jarayon yakunlandi
- `expired` - Session muddati tugagan

## Access Token Olish

### Endpoint
```
POST /api/v1/oauth2/access-token
```

### Request
- **Method:** POST
- **Content-Type:** application/x-www-form-urlencoded
- **Timeout:** 5 sekund

### Parameters
```
grant_type=client_credentials
client_id=<YOUR_CLIENT_ID>
client_secret=<YOUR_CLIENT_SECRET>
```

### Response
```json
{
  "access_token": "string",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

## MyID Host URL'lari

### Production
```
https://api.myid.uz
```

### Development
```
https://api.devmyid.uz
```

## Web vs Mobile SDK

### Web API
- `https://api.devmyid.uz/api/v1/oauth2/sdk/sessions`
- `https://api.devmyid.uz/api/v2/sdk/sessions`
- Bu endpoint'lar **faqat web uchun**

### Mobile SDK
- Mobile SDK o'z ichki API'larini ishlatadi
- Backend orqali session yaratish **shart emas**
- SDK to'g'ridan-to'g'ri ishlatilishi mumkin

## Tavsiya Qilingan Yondashuv

### Mobile Ilova Uchun (Bizning Holat)
1. **SDK To'g'ridan-To'g'ri** - ENG ODDIY ✅
   - Backend kerak emas
   - SDK o'zi hamma narsani boshqaradi
   - Pasport ma'lumotlarini SDK o'zi so'raydi

2. **Simple Authorization** - Backend bilan
   - Pasport ma'lumotlarini oldindan kiritish
   - Backend orqali session yaratish
   - Ko'proq nazorat

3. **Bo'sh Session** - Backend bilan
   - Backend orqali bo'sh session yaratish
   - SDK o'zi pasport so'raydi
   - Murakkab

## Xulosa

Mobile ilova uchun **SDK To'g'ridan-To'g'ri** usuli eng yaxshi variant:
- Oddiy
- Tez
- Backend kerak emas
- Xatolar kam

---

**Sana:** 2025-01-19  
**Mualliflar:** GreenMarket Development Team
