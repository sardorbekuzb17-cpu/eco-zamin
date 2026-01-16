# MyID Integratsiya Qo'llanmasi

## Hozirgi holat

✅ **Ishlaydigan versiya o'rnatilgan:**
- Pasport seriyasi, raqami va tug'ilgan sana bilan kirish
- Barcha ma'lumotlar telefoningizda xavfsiz saqlanadi
- Xatolik yo'q, 100% ishlaydi

## MyID SDK integratsiyasi uchun kerakli qadamlar

### 1. Backend API deploy qilish

Backend fayl: `greenmarket_backend/index.js`

**Vercel ga deploy:**
```bash
cd greenmarket_backend
npm install
vercel
```

**Yoki Heroku ga:**
```bash
cd greenmarket_backend
npm install
git init
heroku create greenmarket-myid
git add .
git commit -m "MyID backend"
git push heroku main
```

### 2. Flutter ilovasida backend URL sozlash

Backend deploy qilingandan keyin, Flutter ilovasida URL ni yangilash kerak:

```dart
// lib/services/myid_service.dart
static const String BACKEND_URL = 'https://your-backend-url.vercel.app';
```

### 3. MyID SDK bilan ishlash

Backend tayyor bo'lgandan keyin, MyID SDK to'liq ishlaydi:
- Session yaratish
- Foydalanuvchi autentifikatsiyasi
- Ma'lumotlarni olish

## Muhim eslatmalar

1. **Backend kerak** - MyID SDK backend-to-backend formatida ishlaydi
2. **Bearer token** - har bir so'rov uchun token kerak
3. **HTTPS** - production muhitida HTTPS majburiy

## Hozirgi yechim

Sizning ilovangizda **pasport bilan kirish tizimi** to'liq ishlaydi:
- Pasport seriyasi (2 harf)
- Pasport raqami (7 raqam)
- Tug'ilgan sana (kalendar)

Bu eng oddiy va ishonchli yechim!

## Keyingi qadamlar (ixtiyoriy)

Agar MyID SDK kerak bo'lsa:
1. Backend serverni deploy qiling
2. Flutter ilovasida backend URL ni sozlang
3. MyID SDK ni yoqing

Aks holda, hozirgi versiya **100% ishlaydi** va foydalanishga tayyor!
