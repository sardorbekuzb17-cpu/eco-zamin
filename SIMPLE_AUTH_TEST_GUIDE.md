# Simple Authorization Test Qo'llanmasi

## Hozirgi Holat

Simple Authorization oqimi to'liq amalga oshirildi va test qilishga tayyor.

## Amalga Oshirilgan O'zgarishlar

### 1. Yangi Ekran: `myid_simple_auth_screen.dart`
**Joylashuv:** `greenmarket_app/lib/screens/myid_simple_auth_screen.dart`

**Funksiyalar:**
- Pasport seriyasi va raqamini kiritish (masalan: AA1234567)
- Tug'ilgan sanani tanlash (YYYY-MM-DD formatida)
- 5 bosqichli jarayon:
  1. Access token olish (client credentials)
  2. Pasport bilan session yaratish
  3. MyID SDK ni ishga tushirish
  4. Code bilan profil ma'lumotlarini olish
  5. Ma'lumotlarni saqlash va home ekraniga o'tish

### 2. Backend Endpoint'lar: `greenmarket_backend/index.js`

#### Endpoint 1: Access Token Olish
```
POST https://greenmarket-backend-lilac.vercel.app/api/myid/get-access-token
Content-Type: application/json

Response:
{
  "success": true,
  "data": {
    "access_token": "...",
    "expires_in": 3600
  }
}
```

#### Endpoint 2: Simple Session Yaratish
```
POST https://greenmarket-backend-lilac.vercel.app/api/myid/create-simple-session
Content-Type: application/json

Body:
{
  "access_token": "...",
  "pass_data": "AA1234567",
  "birth_date": "1990-01-01"
}

Response:
{
  "success": true,
  "data": {
    "session_id": "...",
    "expires_in": 3600
  }
}
```

### 3. Route Sozlamalari: `main.dart`
```dart
routes: {
  '/simple-auth': (context) => const MyIdSimpleAuthScreen(),
  // ... boshqa route'lar
}
```

### 4. Login Ekrani: `myid_main_login_screen.dart`
"MyID orqali kirish" tugmasi `/simple-auth` ga yo'naltiradi.

## Test Qilish Bosqichlari

### 1. APK ni Build Qilish

```powershell
cd greenmarket_app
flutter clean
flutter pub get
flutter build apk --release
```

APK joylashuvi: `greenmarket_app/build/app/outputs/flutter-apk/app-release.apk`

### 2. Qurilmaga O'rnatish

```powershell
# USB orqali
adb install -r greenmarket_app/build/app/outputs/flutter-apk/app-release.apk

# Yoki faylni qurilmaga ko'chirib, qo'lda o'rnatish
```

### 3. Ilovani Ochish va Test Qilish

1. **Ilovani oching**
2. **Login ekranida "MyID orqali kirish" tugmasini bosing**
3. **Simple Authorization ekrani ochiladi**
4. **Pasport ma'lumotlarini kiriting:**
   - Pasport: AA1234567 (yoki haqiqiy pasport)
   - Tug'ilgan sana: 1990-01-01 (yoki haqiqiy sana)
5. **"Davom etish" tugmasini bosing**
6. **Jarayon bosqichlarini kuzating:**
   - Bosqich 1/5: Access token olinmoqda...
   - Bosqich 2/5: Session yaratilmoqda...
   - Bosqich 3/5: MyID SDK ishga tushirilmoqda...
   - Bosqich 4/5: Profil ma'lumotlari olinmoqda...
   - Bosqich 5/5: Ma'lumotlar saqlanmoqda...
7. **MyID SDK oynasi ochiladi** - bu yerda yuzingizni skanerlang
8. **Muvaffaqiyatli bo'lsa, home ekraniga o'tasiz**

## Kutilayotgan Natijalar

### ✅ Muvaffaqiyatli Holat:
1. Access token olinadi
2. Session yaratiladi
3. MyID SDK ochiladi
4. Yuz skanerlash muvaffaqiyatli bo'ladi
5. Profil ma'lumotlari olinadi
6. Home ekraniga o'tiladi

### ❌ Xato Holatlari:

#### Xato 1: Access Token Olinmadi
```
Xato: Access token olishda xato: ...
```
**Sabab:** Backend bilan aloqa yo'q yoki credentials noto'g'ri
**Yechim:** Internet aloqasini tekshiring, backend ishlab turganini tekshiring

#### Xato 2: Session Yaratilmadi
```
Xato: Session yaratishda xato: ...
```
**Sabab:** Pasport ma'lumotlari noto'g'ri yoki MyID API xatosi
**Yechim:** Pasport ma'lumotlarini to'g'ri kiritganingizni tekshiring

#### Xato 3: SDK Ishlamadi (103 xatolik)
```
PlatformException(103, Session is expired, null, null)
```
**Sabab:** Session muddati tugagan yoki noto'g'ri
**Yechim:** Bu xatolik hali ham chiqsa, MyID jamoasiga murojaat qiling

#### Xato 4: Profil Olinmadi
```
Xato: Profil olishda xato: ...
```
**Sabab:** Code noto'g'ri yoki MyID API xatosi
**Yechim:** Jarayonni qaytadan boshlang

## Debug Qilish

### Loglarni Ko'rish (Android)

```powershell
adb logcat | Select-String "flutter"
```

### Backend Loglarini Ko'rish

Vercel dashboard'da:
1. https://vercel.com ga kiring
2. greenmarket-backend proyektini oching
3. "Logs" bo'limiga o'ting
4. Real-time loglarni kuzating

### Flutter Debug Mode

Agar xatolik chiqsa, debug mode'da ishga tushiring:

```powershell
cd greenmarket_app
flutter run
```

Bu sizga batafsil xato xabarlarini ko'rsatadi.

## MyID Jamoasiga Murojaat

Agar 103 xatolik hali ham chiqsa, quyidagi ma'lumotlarni tayyorlang:

1. **Request/Response loglar:**
   - Access token request/response
   - Session yaratish request/response
   - SDK konfiguratsiyasi

2. **Xato detallari:**
   - Xato kodi: 103
   - Xato xabari: Session is expired
   - Environment: MyIdEnvironment.DEBUG
   - SDK versiyasi: 3.1.41

3. **Test ma'lumotlari:**
   - Pasport: AA1234567
   - Tug'ilgan sana: 1990-01-01
   - Qurilma: Samsung A515F, Android 13

## Qo'shimcha Ma'lumotlar

### Simple Authorization vs SDK Flow

**Simple Authorization (hozirgi):**
- Pasport ma'lumotlarini oldindan yuborish
- Backend orqali session yaratish
- SDK faqat yuz skanerlash uchun

**SDK Flow (eski):**
- SDK o'zi pasport ma'lumotlarini so'raydi
- SDK o'zi session yaratadi
- Murakkab va ko'p xatoliklar

### Xavfsizlik

- Barcha ma'lumotlar HTTPS orqali yuboriladi
- Pasport ma'lumotlari backend'da shifrlangan holda saqlanadi
- Access token 1 soat amal qiladi
- Session 1 soat amal qiladi

## Yordam

Agar qo'shimcha yordam kerak bo'lsa:
1. Loglarni to'liq ko'chirib yuboring
2. Qaysi bosqichda xatolik chiqganini ayting
3. Screenshot yuboring (agar mumkin bo'lsa)

---

**Sana:** 2025-01-19
**Versiya:** 1.0
**Mualliflar:** GreenMarket Development Team
