# MyID Backend

Sodda MyID SDK integratsiyasi uchun backend serveri.

## Papka Strukturasi

```
myid-backend/
├─ .env              # Environment o'zgaruvchilari
├─ .gitignore        # Git'dan e'tibor qilmaydigan fayllar
├─ index.js          # Asosiy server fayli
├─ package.json      # NPM paketlari
└─ README.md         # Bu fayl
```

## O'rnatish

```bash
cd myid-backend
npm install
```

## Ishga Tushirish

**Development rejimida:**
```bash
npm run dev
```

**Production rejimida:**
```bash
npm start
```

Server `http://localhost:3000` da ishga tushadi.

## API Endpointlari

### 1. Access Token Olish
```
POST /api/v1/access-token
```

**Javob:**
```json
{
  "success": true,
  "access_token": "...",
  "expires_in": 3600
}
```

### 2. Session Yaratish
```
POST /api/v1/session
Content-Type: application/json

{
  "access_token": "..."
}
```

**Javob:**
```json
{
  "success": true,
  "session_id": "...",
  "access_token": "...",
  "expires_in": 3600,
  "token_type": "Bearer"
}
```

### 3. Foydalanuvchi Ma'lumotlari
```
POST /api/v1/user-data
Content-Type: application/json

{
  "code": "...",
  "access_token": "..."
}
```

**Javob:**
```json
{
  "success": true,
  "profile": {
    "pinfl": "...",
    "name": "...",
    "surname": "...",
    "birth_date": "...",
    "gender": "M/F",
    "phone_number": "...",
    "email": "..."
  }
}
```

### 4. Health Check
```
GET /health
```

## Environment O'zgaruvchilari

`.env` faylida quyidagilarni sozlang:

```
PORT=3000
NODE_ENV=development
CLIENT_ID=your_client_id
CLIENT_SECRET=your_client_secret
MYID_HOST=https://api.devmyid.uz
```

## Qo'llanma

1. **Access token olish:**
   ```bash
   curl -X POST http://localhost:3000/api/v1/access-token
   ```

2. **Session yaratish:**
   ```bash
   curl -X POST http://localhost:3000/api/v1/session \
     -H "Content-Type: application/json" \
     -d '{"access_token":"..."}'
   ```

3. **Foydalanuvchi ma'lumotlari:**
   ```bash
   curl -X POST http://localhost:3000/api/v1/user-data \
     -H "Content-Type: application/json" \
     -d '{"code":"...","access_token":"..."}'
   ```

## Xatolar

Barcha xatolar quyidagi formatda qaytariladi:

```json
{
  "success": false,
  "error": "Xato tavsifi",
  "validation_errors": ["Xato 1", "Xato 2"]
}
```

## Litsenziya

ISC
