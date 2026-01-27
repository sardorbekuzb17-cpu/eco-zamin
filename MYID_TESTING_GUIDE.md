# MyID SDK Integratsiyasi - Test Qo'llanmasi

## Holat (2026-yil)

MyID SDK integratsiyasi Flutter app'da to'liq sozlandi. Backend Vercel'da deploy qilindi.

## Tizim Arxitekturasi

```
Flutter App (Android)
    ↓
MyID OAuth Service (Dart)
    ↓
MyID Backend (Vercel)
    ↓
MyID API (https://api.devmyid.uz)
```

## Backend Endpoint'lari

### 1. Session Yaratish
**URL:** `https://myid-backend.vercel.app/api/myid/create-session`
**Method:** POST
**Body:**
```json
{}
```
**Response:**
```json
{
  "success": true,
  "session_id": "...",
  "access_token": "...",
  "client_hash": "..."
}
```

### 2. Foydalanuvchi Ma'lumotlarini Olish
**URL:** `https://myid-backend.vercel.app/api/myid/get-user-info-with-images`
**Method:** POST
**Body:**
```json
{
  "session_id": "...",
  "code": "...",
  "base64_image": "..."
}
```

## Flutter App'da Test Qilish

### 1. Test Ekranini Ochish
- App'ni ishga tushiring
- "MyID Kirish" ekraniga o'ting
- "MyID orqali kirish" tugmasini bosing

### 2. Kutilayotgan Jarayon
1. **Sessiya yaratish** - Backend'dan session_id va client_hash olish
2. **MyID SDK ishga tushirish** - SDK oynasi ochiladi
3. **Identifikatsiya** - Foydalanuvchi yuzini skanerlaydi
4. **Ma'lumotlar olish** - Backend'dan foydalanuvchi ma'lumotlarini olish
5. **Muvaffaqiyat** - Foydalanuvchi ma'lumotlari ekranda ko'rsatiladi

### 3. Xatolarni Tekshirish
Agar xato chiqsa:
- Xato xabari ekranda ko'rsatiladi
- Loglar `flutter logs` orqali ko'rish mumkin

## Debugging

### Flutter Logs
```bash
flutter logs
```

### Backend Logs (Vercel)
Vercel dashboard'da `myid-backend` loyihasining logs'ini ko'ring.

### Asosiy Muammolar va Yechimi

#### 1. "Identifikatsiya bekor qilindi" xatosi
**Sabab:** Session ID noto'g'ri yoki vaqti tugagan
**Yechim:** 
- Backend'dan yangi session yaratish
- Session ID'ni darhol SDK'ga yuborish

#### 2. 404 xatosi
**Sabab:** Backend endpoint'i topilmadi
**Yechim:**
- Vercel deployment'ni tekshirish
- Endpoint URL'ni tekshirish

#### 3. Network xatosi
**Sabab:** Internet ulanishi yo'q yoki firewall bloklamoqda
**Yechim:**
- Internet ulanishini tekshirish
- VPN ishlatish (agar kerak bo'lsa)

## Credentials

**DEV Muhiti:**
- Host: `https://api.devmyid.uz`
- Client ID: `quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v`
- Client Secret: `JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP`

## Muhim Eslatmalar

1. **Real Device:** MyID SDK faqat real Android cihazda ishlaydi, emulator'da emas
2. **Camera:** Cihazda kamera bo'lishi kerak
3. **Internet:** Doimiy internet ulanishi kerak
4. **Session Vaqti:** Session ID 15 daqiqaga amal qiladi

## Keyingi Qadamlar

1. Production muhitiga o'tish
2. IP whitelist'ni sozlash
3. SSL sertifikatini tekshirish
4. Load testing qilish
