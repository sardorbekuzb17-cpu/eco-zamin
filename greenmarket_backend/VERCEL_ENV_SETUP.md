# Vercel Environment Variables Sozlash

Vercel dashboard'da quyidagi environment variables'larni qo'shish kerak:

## 1. Vercel Dashboard'ga kirish
- https://vercel.com/dashboard ga o'ting
- `greenmarket-api` proyektini tanlang

## 2. Settings → Environment Variables
- **Settings** tab'ni bosing
- **Environment Variables** bo'limiga o'ting

## 3. Quyidagi variables'larni qo'shing

### MyID Credentials
```
MYID_CLIENT_ID = quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v
MYID_CLIENT_SECRET = JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP
MYID_HOST = https://api.devmyid.uz
```

### MongoDB
```
MONGODB_URI = mongodb://localhost:27017/greenmarket
```

## 4. Har bir variable uchun:
- **Name** va **Value** kiriting
- **Environment** tanlang: Production, Preview, Development
- **Save** bosing

## 5. Deploy qilish
- O'zgarishlar saqlanganidan so'ng, Vercel avtomatik ravishda redeploy qiladi
- Deployment tugagunini kutaylik (2-3 daqiqa)

## 6. Test qilish
```bash
npm test -- __tests__/myid-endpoints.test.js
```

## Muammolar
- Agar hali ham "Incorrect client_id or client_secret" xatosi bo'lsa, credentials'larni qayta tekshiring
- Agar "Cannot POST /api/..." xatosi bo'lsa, vercel.json routing'ni tekshiring
