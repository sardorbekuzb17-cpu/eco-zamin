# GreenMarket MyID Backend API

MyID SDK integratsiyasi uchun backend server.

## O'rnatish

```bash
npm install
```

## Ishga tushirish

```bash
npm start
```

Yoki development rejimida:

```bash
npm run dev
```

Server `http://localhost:3000` da ishga tushadi.

## API Endpoints

### 1. Session yaratish
```
POST /api/myid/create-session
```

Response:
```json
{
  "success": true,
  "session_id": "uuid",
  "data": {}
}
```

### 2. Foydalanuvchi ma'lumotlarini olish
```
POST /api/myid/get-user-info
Body: { "code": "myid_code" }
```

Response:
```json
{
  "success": true,
  "user": {
    "profile": {},
    "pinfl": "",
    "comparison_value": ""
  }
}
```

## Muhim

Bu backend API MyID kompaniyasining rasmiy API'si bilan ishlaydi. Production muhitida:

1. HTTPS ishlatish kerak
2. Rate limiting qo'shish kerak
3. Xavfsizlik sozlamalarini kuchaytirish kerak
4. Loglarni to'g'ri boshqarish kerak

## Vercel ga deploy qilish

```bash
vercel
```

Yoki GitHub Actions orqali avtomatik deploy qilish mumkin.
