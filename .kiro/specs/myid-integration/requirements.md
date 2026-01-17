# MyID SDK Integratsiya - Talablar

## 1. Umumiy Ma'lumot

**Maqsad:** GreenMarket ilovasiga MyID SDK orqali foydalanuvchi identifikatsiyasi va verifikatsiyasini qo'shish.

**MyID API Versiyasi:** 3.1.41 (Flutter SDK)

**Muhit:** Test (api.devmyid.uz)

---

## 2. Foydalanuvchi Hikoyalari

### US-1: Birinchi Marta Kirish (Primary Request)
**Rol:** Yangi foydalanuvchi  
**Maqsad:** MyID orqali identifikatsiya qilish va to'liq profil ma'lumotlarini olish  
**Sabab:** Tizimga xavfsiz kirish va shaxsni tasdiqlash

**Qabul Mezonlari:**
- [ ] 1.1 Foydalanuvchi "MyID orqali kirish" tugmasini bosadi
- [ ] 1.2 Backend'dan session_id olinadi (10 daqiqa amal qiladi)
- [ ] 1.3 MyID SDK ochiladi va pasport ma'lumotlarini so'raydi
- [ ] 1.4 Foydalanuvchi pasport seriya/raqamini va tug'ilgan sanasini kiritadi
- [ ] 1.5 MyID SDK yuz identifikatsiyasini o'tkazadi (liveness check)
- [ ] 1.6 Muvaffaqiyatli bo'lsa, to'liq profil ma'lumotlari qaytadi:
  - PINFL
  - Ism, familiya, otasining ismi
  - Tug'ilgan sana
  - Pasport seriya/raqami
  - REUID (keyingi kirishlar uchun)
- [ ] 1.7 Ma'lumotlar xavfsiz saqlanadi (SharedPreferences)
- [ ] 1.8 Foydalanuvchi home sahifasiga o'tadi

### US-2: Qayta Kirish (Secondary Request - Kelajakda)
**Rol:** Mavjud foydalanuvchi  
**Maqsad:** REUID orqali tez kirish  
**Sabab:** Har safar pasport ma'lumotlarini kiritmaslik

**Qabul Mezonlari:**
- [ ] 2.1 Foydalanuvchi "MyID orqali kirish" tugmasini bosadi
- [ ] 2.2 Tizim saqlangan REUID'ni topadi
- [ ] 2.3 MyID SDK faqat yuz identifikatsiyasini o'tkazadi
- [ ] 2.4 Muvaffaqiyatli bo'lsa, comparison_value qaytadi
- [ ] 2.5 Foydalanuvchi home sahifasiga o'tadi

### US-3: Xato Holatlari
**Rol:** Foydalanuvchi  
**Maqsad:** Xatolarni tushunish va hal qilish  
**Sabab:** Yaxshi foydalanuvchi tajribasi

**Qabul Mezonlari:**
- [ ] 3.1 Session yaratishda xato - tushunarli xabar ko'rsatiladi
- [ ] 3.2 MyID SDK xatosi - xato kodi va tavsiya ko'rsatiladi
- [ ] 3.3 Pasport ma'lumotlari noto'g'ri - qayta urinish imkoniyati
- [ ] 3.4 Yuz identifikatsiyasi muvaffaqiyatsiz - qayta urinish imkoniyati
- [ ] 3.5 Session muddati tugagan (10 daqiqa) - yangi session yaratish

### US-4: Xavfsizlik Tekshiruvlari
**Rol:** Tizim  
**Maqsad:** Root/Jailbreak va emulator'larni aniqlash  
**Sabab:** MyID SDK xavfsizlik talablari

**Qabul Mezonlari:**
- [ ] 4.1 Ilova ochilganda root/jailbreak tekshiriladi
- [ ] 4.2 Root/jailbreak topilsa - ogohlantirish ko'rsatiladi
- [ ] 4.3 MyID SDK ishga tushishdan oldin emulator tekshiriladi
- [ ] 4.4 Emulator topilsa - xato xabari ko'rsatiladi
- [ ] 4.5 Haqiqiy qurilmada barcha funksiyalar ishlaydi

---

## 3. Texnik Talablar

### 3.0 Arxitektura
**⚠️ Muhim:** MyID API bilan barcha aloqa backend-to-backend bo'lishi kerak.

```
[Flutter App] 
    ↓ (HTTP)
[Bizning Backend - Node.js/Vercel]
    ↓ (HTTPS + Bearer Token)
[MyID API - api.devmyid.uz]
```

**Sabab:**
- Client credentials (client_id, client_secret) xavfsiz saqlanadi
- Bearer token backend'da cache qilinadi
- MyID API to'g'ridan-to'g'ri mobile app'dan chaqirilmaydi

### 3.1 Backend API

#### 3.1.1 Autentifikatsiya
**⚠️ Muhim:** Barcha API so'rovlar backend-to-backend formatida bo'lishi kerak.

- [ ] **Access Token Olish:**
  - POST `/api/v1/auth/clients/access-token`
  - **Input:** `{ client_id, client_secret }`
  - **Output:** `{ access_token, expires_in }`
  - **Autentifikatsiya:** Yo'q (bu endpoint faqat)
  - **Endpoint:** `https://api.devmyid.uz/api/v1/auth/clients/access-token`

- [ ] **Bearer Token:**
  - Barcha boshqa so'rovlar uchun kerak
  - Header: `Authorization: Bearer {access_token}`
  - Token muddati: `expires_in` (odatda 3600 sekund = 1 soat)
  - Token cache qilish: Muddati tugamaguncha qayta ishlatish

#### 3.1.2 Session Yaratish
- [ ] POST `/api/v2/sdk/sessions` (MyID API)
  - **Authorization:** `Bearer {access_token}`
  - **Input:** `{}` (bo'sh obyekt yoki pasport ma'lumotlari)
  - **Output:** `{ session_id, expires_in }`
  - **Endpoint:** `https://api.devmyid.uz/api/v2/sdk/sessions`
  
- [ ] POST `/api/myid/create-session` (bizning backend'imiz)
  - **Input:** `{}` (bo'sh obyekt)
  - **Output:** `{ session_id, expires_in }`
  - **Backend:** MyID API'ga Bearer token bilan so'rov yuboradi

### 3.2 MyID SDK Konfiguratsiya
- [ ] Client ID: `quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v`
- [ ] Client Hash ID: `ac6d0f4a-5d5b-44e3-a865-9159a3146a8c`
- [ ] Client Hash: RSA public key (mavjud)
- [ ] Environment: `MyIdEnvironment.PRODUCTION` (test uchun)
- [ ] Entry Type: `MyIdEntryType.IDENTIFICATION` (to'liq profil uchun)
- [ ] Locale: `MyIdLocale.UZBEK`

### 3.3 Ma'lumotlar Saqlash
- [ ] SharedPreferences'da saqlash:
  ```json
  {
    "user_id": "PINFL",
    "full_name": "Ism Familiya",
    "first_name": "Ism",
    "last_name": "Familiya",
    "middle_name": "Otasining ismi",
    "birth_date": "YYYY-MM-DD",
    "passport_series": "AA",
    "passport_number": "1234567",
    "pinfl": "12345678901234",
    "reuid": "xxx-xxx-xxx",
    "verified": true,
    "timestamp": "ISO8601"
  }
  ```

### 3.4 Xavfsizlik

#### 3.4.1 Asosiy Xavfsizlik
- [ ] HTTPS faqat
- [ ] Ma'lumotlarni shifrlash (flutter_secure_storage)
- [ ] Session timeout (10 daqiqa)
- [ ] REUID muddati (oy/yil oxiri)

#### 3.4.2 Root va Emulator Tekshiruvi (MAJBURIY)
**⚠️ Muhim:** MyID SDK root va emulator tekshiruvlarini o'zi qilmaydi. Biz parent app'da qilishimiz kerak.

- [ ] **Root tekshiruvi:**
  - Android: Root access borligini aniqlash
  - iOS: Jailbreak borligini aniqlash
  - Root/Jailbreak topilsa: MyID SDK ishga tushmaydi
  
- [ ] **Emulator tekshiruvi:**
  - Android: Emulator'da ishlamaydi
  - iOS: Simulator'da ishlamaydi
  - Emulator topilsa: MyID SDK ishga tushmaydi

- [ ] **Xavfsizlik xabarlari:**
  - Root topilsa: "Xavfsizlik: Qurilma root qilingan. MyID ishlamaydi."
  - Emulator topilsa: "Xavfsizlik: Emulator'da ishlamaydi. Haqiqiy qurilmada sinab ko'ring."

---

## 4. Cheklovlar va Qoidalar

### 4.1 MyID API Cheklovlari
- Session 10 daqiqa amal qiladi
- REUID oy/yil oxirigacha amal qiladi (shartnomaga bog'liq)
- Har bir session pul turadi (production'da)

### 4.2 Platform Talablari
- **Android:** API 21+ (Android 5.0+)
- **iOS:** iOS 13.0+
- **Kamera ruxsati:** Yuz identifikatsiyasi uchun

### 4.3 Xato Kodlari
- `101` - Foydalanuvchi bekor qildi
- `102` - Kamera ruxsati yo'q
- `103` - Server/SDK xatosi
- `122` - Foydalanuvchi bloklangan

---

## 5. Qabul Qilinish Mezonlari

### 5.1 Funksional
- [ ] Foydalanuvchi MyID orqali muvaffaqiyatli kirishi mumkin
- [ ] To'liq profil ma'lumotlari olinadi va saqlanadi
- [ ] Xato holatlari to'g'ri qayta ishlanadi
- [ ] Session timeout to'g'ri ishlaydi

### 5.2 Texnik
- [ ] MyID SDK to'g'ri integratsiya qilingan
- [ ] Backend API ishlaydi (404 xato hal qilingan)
- [ ] Ma'lumotlar xavfsiz saqlanadi
- [ ] Loglar to'g'ri yoziladi

### 5.3 Foydalanuvchi Tajribasi
- [ ] Loading indikatorlari ko'rsatiladi
- [ ] Xato xabarlari tushunarli
- [ ] Qayta urinish imkoniyati bor
- [ ] Jarayon 2 daqiqadan kam vaqt oladi

---

## 6. Keyingi Qadamlar

1. **MyID Support bilan bog'lanish** - To'g'ri endpoint'larni aniqlash
2. **Backend'ni yangilash** - To'g'ri endpoint'dan foydalanish
3. **Test qilish** - Barcha flow'larni test qilish
4. **Production'ga o'tish** - Test muvaffaqiyatli bo'lgandan keyin

---

## 7. Texnik Qarzlar

- [ ] Backend 404 xatosi - MyID support bilan hal qilish kerak
- [ ] REUID flow'i hali implement qilinmagan
- [ ] Error handling'ni yaxshilash kerak
- [ ] Logging'ni qo'shish kerak
- [ ] Root/Jailbreak detection library qo'shish kerak
- [ ] Emulator detection library qo'shish kerak

---

## 8. Havola va Resurslar

- MyID SDK: `../myid-3.1.41`
- MyID Docs: https://docs.myid.uz
- MyID Support: @myid_support (Telegram)
- Backend: https://greenmarket-backend-lilac.vercel.app
