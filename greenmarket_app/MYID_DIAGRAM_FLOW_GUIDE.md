# MyID Chizma bo'yicha Integratsiya - To'liq Qo'llanma

## 📋 Nima qilindi?

Sizning chizmangizga muvofiq to'liq MyID integratsiyasi amalga oshirildi:

### 1. Yangi Screenlar

#### a) `MyIdDiagramFlowScreen` (Chizma bo'yicha)

- **Fayl**: `lib/screens/myid_diagram_flow_screen.dart`
- **Route**: `/diagram-flow`
- **Vazifasi**: Chizmaga muvofiq to'liq jarayonni amalga oshiradi

**Jarayon qadamlari:**

1. ✅ Backend → access_token oladi
2. ✅ Backend → bo'sh sessiya yaratadi (without passport)
3. ✅ Mobile → session_id oladi
4. ✅ Mobile → SDK'ni ishga tushiradi
5. ✅ SDK → pasport ma'lumotlarini so'raydi
6. ✅ SDK → selfie va pasport yuboradi
7. ✅ MyID → natijani qaytaradi
8. ✅ Mobile → ma'lumotlarni saqlaydi

#### b) `MyIdSimpleTestScreen` (SDK Test)

- **Fayl**: `lib/screens/myid_simple_test_screen.dart`
- **Route**: `/simple-test`
- **Vazifasi**: SDK'ni to'g'ridan-to'g'ri test qilish (backend'siz)

### 2. Home Screen Yangilandi

`lib/screens/home_screen.dart` ga 2 ta yangi karta qo'shildi:

1. **SDK Test** (🧪 Binafsha rang)
   - SDK'ni backend'siz test qilish
   - Agar bu ishlasa, muammo backend'da

2. **Chizma bo'yicha** (🌳 Yashil rang)
   - To'liq jarayonni chizmaga muvofiq amalga oshirish
   - Bu asosiy integratsiya usuli

### 3. Routes Yangilandi

`lib/main.dart` ga yangi route'lar qo'shildi:

```dart
'/simple-test': (context) => const MyIdSimpleTestScreen(),
'/diagram-flow': (context) => const MyIdDiagramFlowScreen(),
```

## 🚀 Qanday Test Qilish?

### 1. Ilovani Build Qilish

```powershell
cd greenmarket_app
flutter build apk --release
```

### 2. Telefoniga O'rnatish

```powershell
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### 3. Test Qilish Tartibi

#### A) SDK Test (Backend'siz)

1. Ilovani oching
2. "SDK Test" kartasini bosing
3. "SDK'ni test qilish" tugmasini bosing
4. SDK ochilishi kerak va pasport ekranini ko'rsatishi kerak

**Kutilayotgan natija:**

- ✅ SDK ochiladi
- ✅ Pasport ekrani ko'rsatiladi
- ✅ Pasport ma'lumotlarini kiritish mumkin
- ✅ Selfie olish mumkin
- ✅ Natija qaytadi

**Agar ishlamasa:**

- ❌ Credentials noto'g'ri
- ❌ MyID support bilan bog'lanish kerak

#### B) Chizma bo'yicha (To'liq jarayon)

1. Ilovani oching
2. "Chizma bo'yicha" kartasini bosing
3. "Boshlash" tugmasini bosing
4. Jarayon qadamlari ko'rsatiladi

**Kutilayotgan qadamlar:**

```text
✅ Backend'dan sessiya olinmoqda...
✅ MyID SDK ishga tushirilmoqda...
✅ Foydalanuvchi saqlanmoqda...
✅ Ma'lumotlar saqlandi
✅ Muvaffaqiyatli autentifikatsiya!
```

**Agar xatolik bo'lsa:**

- Xato xabari ko'rsatiladi
- Qadamlar ro'yxatida qaysi qadamda xatolik bo'lganini ko'rish mumkin

## 🔍 Muammolarni Aniqlash

### 1. SDK Xatosi (103 Bad Request)

**Sabab:** Backend'dan kelgan sessiya noto'g'ri

**Yechim:**

1. Backend'ni tekshiring: <https://greenmarket-backend-lilac.vercel.app/health>
2. Backend log'larini ko'ring
3. MyID credentials'ni tekshiring

### 2. SDK Ochilmaydi

**Sabab:** Credentials noto'g'ri yoki SDK'da muammo

**Yechim:**

1. "SDK Test" ni sinab ko'ring
2. Agar SDK Test ishlasa, muammo backend'da
3. Agar SDK Test ishlamasa, credentials noto'g'ri

### 3. Pasport Ekrani Ko'rsatilmaydi

**Sabab:** `residency` parametri noto'g'ri

**Yechim:**

```dart
residency: MyIdResidency.USER_DEFINED, // Bu pasport ekranini ko'rsatadi
```

## 📊 Backend API Endpoints

### 1. Bo'sh Sessiya Yaratish

```text
POST https://greenmarket-backend-lilac.vercel.app/api/myid/create-session
```

**Response:**

```json
{
  "success": true,
  "data": {
    "session_id": "xxx-xxx-xxx",
    "expires_in": 3600
  }
}
```

### 2. Foydalanuvchini Saqlash

```text
POST https://greenmarket-backend-lilac.vercel.app/api/users/register
Body: {
  "session_id": "xxx-xxx-xxx"
}
```

### 3. Foydalanuvchilar Ro'yxati

```text
GET https://greenmarket-backend-lilac.vercel.app/api/users
```

## 🎯 Keyingi Qadamlar

### 1. Agar SDK Test Ishlasa

✅ SDK to'g'ri sozlangan
✅ Credentials to'g'ri
➡️ Backend'ni tuzatish kerak

**Backend'da tekshirish kerak:**

- Access token to'g'ri olinmoqdami?
- Sessiya to'g'ri yaratilmoqdami?
- Session ID to'g'ri formatdami?

### 2. Agar SDK Test Ishlamasa

❌ Credentials noto'g'ri
❌ MyID support bilan bog'lanish kerak

**MyID Support:**

- Telegram: @myid_support
- Email: <support@myid.uz>
- Telefon: +998 71 202 22 02

**So'rash kerak:**

1. Test muhiti uchun to'g'ri credentials
2. `clientHash` va `clientHashId` to'g'rimi?
3. SDK versiyasi to'g'rimi? (3.1.41)

### 3. Agar Chizma bo'yicha Ishlasa

✅ To'liq integratsiya muvaffaqiyatli!
✅ Production'ga o'tish mumkin

**Production'ga o'tish:**

1. `MyIdEnvironment.DEBUG` → `MyIdEnvironment.PRODUCTION`
2. `https://api.devmyid.uz` → `https://api.myid.uz`
3. Production credentials olish

## 📱 Foydalanuvchi Tajribasi

### 1. Boshlash

```text
Foydalanuvchi → "Chizma bo'yicha" kartasini bosadi
```

### 2. Jarayon

```text
Loading... → "Backend'dan sessiya olinmoqda..."
Loading... → "MyID SDK ishga tushirilmoqda..."
SDK ochiladi → Pasport ekrani
Foydalanuvchi → Pasport ma'lumotlarini kiritadi
SDK → Selfie oladi
Loading... → "Foydalanuvchi saqlanmoqda..."
```

### 3. Yakunlash

```text
✅ Muvaffaqiyatli autentifikatsiya!
→ Home sahifasiga o'tish
```

## � Xavfsizlik

### Access Token

- ✅ Backend'da saqlanadi
- ✅ HTTPS orqali uzatiladi
- ✅ 7 kun amal qiladi
- ⚠️ Frontend'da saqlamang

### Session ID

- ✅ Bir martalik ishlatiladi
- ✅ SDK'da xavfsiz saqlanadi
- ✅ Muddati cheklangan

### Foydalanuvchi Ma'lumotlari

- ✅ Shifrlangan holda uzatiladi
- ✅ Backend'da xavfsiz saqlanadi
- ✅ GDPR talablariga mos

## 📚 Qo'shimcha Ma'lumotlar

### Fayllar Ro'yxati

1. **Screenlar:**
   - `lib/screens/myid_diagram_flow_screen.dart` - Chizma bo'yicha
   - `lib/screens/myid_simple_test_screen.dart` - SDK test
   - `lib/screens/home_screen.dart` - Yangilangan

2. **Servislar:**
   - `lib/services/myid_backend_client.dart` - Backend client
   - `lib/config/myid_config.dart` - Credentials

3. **Backend:**
   - `greenmarket_backend/index.js` - Express server

### Muhim Parametrlar

```dart
// SDK sozlamalari
environment: MyIdEnvironment.DEBUG,  // Test muhiti
entryType: MyIdEntryType.IDENTIFICATION,  // Identifikatsiya
locale: MyIdLocale.UZBEK,  // O'zbek tili
residency: MyIdResidency.USER_DEFINED,  // Pasport ekranini ko'rsatish
```

### Xato Kodlari

| Kod | Ma'nosi | Harakat |
| --- | --- | --- |
| `0` | Muvaffaqiyatli | Davom etish |
| `1` | Bekor qilindi | Qayta urinish |
| `103` | Bad Request | Backend'ni tekshirish |
| `122` | User banned | Support bilan bog'lanish |

## ✅ Tekshirish Ro'yxati

- [ ] SDK Test ishlaydi
- [ ] Pasport ekrani ko'rsatiladi
- [ ] Selfie olish ishlaydi
- [ ] Backend sessiya yaratadi
- [ ] Foydalanuvchi saqlanadi
- [ ] Home sahifasiga o'tadi
- [ ] Ma'lumotlar to'g'ri ko'rsatiladi

## 🎉 Yakuniy Natija

Agar barcha qadamlar muvaffaqiyatli bo'lsa:

1. ✅ SDK to'g'ri ishlaydi
2. ✅ Backend to'g'ri ishlaydi
3. ✅ Chizma bo'yicha integratsiya to'liq
4. ✅ Production'ga o'tish mumkin

---

**Yaratilgan:** 2025-01-18
**Versiya:** 1.0.0
**Holat:** ✅ Tayyor test qilish uchun
