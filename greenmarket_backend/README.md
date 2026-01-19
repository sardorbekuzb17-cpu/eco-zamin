# GreenMarket MyID Backend API

MyID SDK integratsiyasi uchun backend server.

## O'rnatish

```bash
npm install
```

## Environment Variables Sozlash

`.env` faylini yarating va quyidagi o'zgaruvchilarni sozlang:

```bash
# MyID Credentials
CLIENT_ID=your_client_id_here
CLIENT_SECRET=your_client_secret_here
MYID_HOST=https://api.myid.uz

# Server Configuration
PORT=3000
NODE_ENV=development

# Encryption Key (AES-256)
# 64 ta hex belgi (32 byte) bo'lishi kerak
# Yangi kalit yaratish uchun:
# node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
ENCRYPTION_KEY=your_64_character_hex_encryption_key_here
```

**Muhim:** Production muhitida `ENCRYPTION_KEY` ni xavfsiz joyda saqlang (AWS Secrets Manager, Azure Key Vault, va h.k.)

## Ishga tushirish

```bash
npm start
```

Yoki development rejimida:

```bash
npm run dev
```

Server `http://localhost:3000` da ishga tushadi.

## Xavfsizlik Xususiyatlari

### 1. Maxfiy Ma'lumotlarni Shifrlash

Backend AES-256-CBC algoritmi yordamida maxfiy ma'lumotlarni shifrlaydi:

- **Pasport raqami** (pass_data) - Shifrlangan formatda saqlanadi
- **PINFL** - Shifrlangan formatda saqlanadi
- **client_secret** - Hech qachon API javoblarida qaytarilmaydi

### 2. HTTPS Protokoli

Barcha MyID API so'rovlari HTTPS protokoli orqali yuboriladi. HTTP so'rovlar rad etiladi.

### 3. Qayta Urinish Mexanizmi

Tarmoq xatoliklari va timeout'lar uchun eksponensial backoff bilan avtomatik qayta urinish:

- Maksimal 3 marta qayta urinish
- Har bir urinish orasida kutish vaqti 2 baravar oshadi
- Maksimal kutish vaqti: 8 soniya

### 4. Token Cache

Access token'lar xotirada saqlanadi va 7 kun davomida qayta ishlatiladi. Token muddati tugashidan 5 daqiqa oldin avtomatik yangilanadi.

## API Endpoints

### 1. Bo'sh Session yaratish
```
POST /api/myid/create-session
```

Response:
```json
{
  "data": {
    "session_id": "uuid",
    "expires_in": 3600
  }
}
```

### 2. SDK'dan code bilan foydalanuvchi ma'lumotlarini olish
```
POST /api/myid/sdk/get-user-data
Body: { "code": "myid_code" }
```

Response:
```json
{
  "success": true,
  "data": {
    "profile": {
      "first_name": "Sardor",
      "last_name": "Aliyev",
      "pass_data": "AA1234567",
      "pinfl": "12345678901234"
    },
    "comparison_value": 0.95
  }
}
```

**Eslatma:** Ma'lumotlar bazasida `pass_data` va `pinfl` shifrlangan formatda saqlanadi.

### 3. Barcha foydalanuvchilarni ko'rish
```
GET /api/users?page=1&limit=10&status=active
```

Response:
```json
{
  "success": true,
  "data": {
    "users": [...],
    "pagination": {
      "total": 100,
      "page": 1,
      "limit": 10,
      "totalPages": 10
    },
    "stats": {
      "total_users": 100,
      "today_registrations": 5
    }
  }
}
```

### 4. Bitta foydalanuvchini ko'rish
```
GET /api/users/:id
```

Response:
```json
{
  "success": true,
  "user": {
    "id": 1,
    "profile_data": {
      "first_name": "Sardor",
      "pass_data": "AA1234567",
      "pinfl": "12345678901234"
    }
  }
}
```

**Eslatma:** API javobida maxfiy ma'lumotlar avtomatik deshifrlangan holda qaytariladi.

## Testlar

Barcha testlarni ishga tushirish:

```bash
npm test
```

Faqat shifrlash testlarini ishga tushirish:

```bash
npm test -- encryption.test.js
```

Test coverage ko'rish:

```bash
npm run test:coverage
```

## Muhim Xavfsizlik Talablari

Production muhitida:

1. ✅ **HTTPS ishlatish** - Barcha so'rovlar HTTPS orqali
2. ✅ **Maxfiy ma'lumotlarni shifrlash** - AES-256 bilan shifrlash
3. ✅ **client_secret himoyasi** - API javoblarida qaytarilmaydi
4. ⚠️ **Rate limiting** - Qo'shilishi kerak (vazifa 4.3)
5. ✅ **Token cache** - 7 kun davomida qayta ishlatish
6. ✅ **Xato boshqaruvi** - Qayta urinish mexanizmi
7. ✅ **Loglar** - Barcha xatolar log qilinadi

## Vercel ga deploy qilish

```bash
vercel
```

Yoki GitHub Actions orqali avtomatik deploy qilish mumkin.

**Muhim:** Vercel'da environment variables'ni sozlashni unutmang:
- `CLIENT_ID`
- `CLIENT_SECRET`
- `ENCRYPTION_KEY`
- `MYID_HOST`
