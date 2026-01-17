# MyID OAuth - To'liq Qo'llanma

## 📚 Umumiy ma'lumot

Bu qo'llanma MyID OAuth API integratsiyasining to'liq jarayonini tushuntiradi. Barcha rasmlar va dokumentatsiyaga asoslanib yaratilgan.

## 🎯 Maqsad

MyID OAuth API orqali foydalanuvchilarni autentifikatsiya qilish va yuz tanish (Face Recognition) orqali tasdiqlash.

## 📋 Jarayon qadamlari

```text
1. Access Token olish
   ↓
2. Sessiya yaratish
   ↓
3. MyID SDK ishga tushirish
   ↓
4. Yuz tanish (Face Recognition)
   ↓
5. Foydalanuvchi ma'lumotlarini olish
   ↓
6. Muvaffaqiyatli kirish
```

## 🔧 Amalga oshirilgan funksiyalar

### 1. Access Token olish

**API:** `POST https://myid.uz/api/v1/auth/clients/access-token`

**Parametrlar:**
- `client_id` - Mijoz identifikatori (200 belgi)
- `client_secret` - Mijoz sirli kodi (200 belgi)

**Javob:**
```json
{
  "access_token": "eyJhb5ci...",
  "expires_in": 604800,
  "token_type": "Bearer"
}
```

**Kod:**
```dart
final result = await MyIdBackendService.getAccessToken(
  clientId: MyIDConfig.clientId,
  clientSecret: MyIDConfig.clientSecret,
);
```

### 2. Sessiya yaratish

**API:** `POST https://myid.uz/api/v2/sdk/sessions`

**Avtorizatsiya:** `Bearer {access_token}`

**Parametrlar:**

| Parametr | Turi | Majburiy | Tavsif |
|----------|------|----------|--------|
| `phone_number` | satr (12-13) | Yo'q | Telefon raqami |
| `birth_date` | satr (YYYY-MM-DD) | Yo'q | Tug'ilgan sana |
| `is_resident` | bool | Yo'q | Rezidentmi (standart: true) |
| `pinfl` | satr (14) | Yo'q | PINFL |
| `pass_data` | satr | Yo'q | Pasport seriyasi va raqami |
| `threshold` | suzuvchi | Yo'q | 0.5 dan 0.99 gacha |

**Javob:**
```json
{
  "session_id": "abc123..."
}
```

**Kod:**
```dart
final result = await MyIdBackendService.createSession(
  accessToken: accessToken,
  phoneNumber: '998901234567',
  birthDate: '1990-01-01',
  isResident: true,
  passData: 'AA1234567',
  threshold: 0.75,
);
```

### 3. MyID SDK ishga tushirish

**Kod:**
```dart
final result = await MyIdClient.start(
  config: MyIdConfig(
    sessionId: sessionId,
    clientHash: clientHash,
    clientHashId: clientHashId,
    environment: MyIdEnvironment.DEBUG,
    entryType: MyIdEntryType.IDENTIFICATION,
    locale: MyIdLocale.UZBEK,
  ),
  iosAppearance: const MyIdIOSAppearance(),
);
```

## 🚀 To'liq avtomatik jarayon

**Funksiya:** `createSessionWithToken()`

Bu funksiya barcha qadamlarni avtomatik bajaradi:

```dart
final result = await MyIdBackendService.createSessionWithToken(
  clientId: MyIDConfig.clientId,
  clientSecret: MyIDConfig.clientSecret,
  phoneNumber: '998901234567',
  birthDate: '1990-01-01',
  passData: 'AA1234567',
);

if (result['success'] == true) {
  final sessionId = result['session_id'];
  // MyID SDK'ni ishga tushiring
}
```

## 📱 Yaratilgan ekranlar

### 1. MyIdOAuthFullLoginScreen

**Maqsad:** To'liq avtomatik login jarayoni

**Xususiyatlari:**
- ✅ Access token avtomatik olinadi
- ✅ Sessiya avtomatik yaratiladi
- ✅ MyID SDK avtomatik ishga tushadi
- ✅ Real-time status ko'rsatish
- ✅ Foydalanuvchi faqat yuzini ko'rsatadi

**Ishlatish:**
```dart
Navigator.pushNamed(context, '/oauth-login');
```

### 2. MyIdOAuthTestScreen

**Maqsad:** Dasturchilar uchun test rejimi

**Xususiyatlari:**
- 🧪 Qo'lda token olish
- 🧪 Qo'lda sessiya yaratish
- 📋 Token va Session ID ko'rish
- 📝 Nusxalash imkoniyati

**Ishlatish:**
```dart
Navigator.pushNamed(context, '/oauth-test');
```

## 📌 Muhim eslatmalar

### 1. Pasport ma'lumotlari

Agar sessiya pasport ma'lumotlari bilan yaratilsa:
- ✅ SDK birinchi sahifani o'tkazib yuboradi
- ✅ To'g'ridan-to'g'ri yuz tanishga o'tadi
- ✅ Foydalanuvchi tajribasi tezlashadi

**Misol:**
```dart
// Pasport ma'lumotlari bilan
passData: 'AA1234567',  // SDK pasport sahifasini o'tkazib yuboradi

// yoki

pinfl: '12345678901234',  // SDK pasport sahifasini o'tkazib yuboradi
```

### 2. Token muddati

- Access token muddati: **604800 soniya (7 kun)**
- Token muddati tugaganda yangilab turing

### 3. Xavfsizlik

⚠️ **Muhim:**
- Client Secret ni frontend kodida saqlamang
- Production'da backend orqali token oling
- Token'ni xavfsiz joyda saqlang (secure storage)

## 🎨 Foydalanuvchi tajribasi

### A. Pasport ma'lumotlari bilan

```text
1. "MyID OAuth orqali kirish" tugmasini bosish
   ↓
2. Jarayon avtomatik boshlanadi
   ↓
3. Yuzni ko'rsatish
   ↓
4. Muvaffaqiyatli kirish
```

### B. Pasport ma'lumotlarisiz

```text
1. "MyID OAuth orqali kirish" tugmasini bosish
   ↓
2. Jarayon avtomatik boshlanadi
   ↓
3. Pasport ma'lumotlarini kiritish (SDK'da)
   ↓
4. Yuzni ko'rsatish
   ↓
5. Muvaffaqiyatli kirish
```

## 📊 API Endpoint'lar

| № | Endpoint | Metod | Maqsad |
|---|----------|-------|--------|
| 1 | `/api/v1/auth/clients/access-token` | POST | Access token olish |
| 2 | `/api/v2/sdk/sessions` | POST | Sessiya yaratish |

## 🧪 Test qilish

### Oddiy foydalanuvchilar uchun:

1. Ilovani ishga tushiring: `flutter run`
2. Home sahifasiga kiring
3. 🔐 (login) belgisiga bosing
4. "MyID OAuth orqali kirish" tugmasini bosing
5. Yuzingizni ko'rsating
6. Tayyor!

### Dasturchilar uchun:

1. Ilovani ishga tushiring: `flutter run`
2. Home sahifasiga kiring
3. 🧪 (test) belgisiga bosing
4. "Access Token Olish" tugmasini bosing
5. "Sessiya Yaratish" tugmasini bosing
6. Session ID ni nusxalang

## 📁 Fayl strukturasi

```
greenmarket_app/
├── lib/
│   ├── config/
│   │   └── myid_config.dart          # MyID konfiguratsiyasi
│   ├── services/
│   │   └── myid_backend_service.dart # OAuth API funksiyalari
│   └── screens/
│       ├── myid_oauth_full_login_screen.dart  # To'liq login
│       └── myid_oauth_test_screen.dart        # Test rejimi
├── MYID_OAUTH_GUIDE.md               # Asosiy qo'llanma
├── MYID_PASS_DATA_UPDATE.md          # pass_data yangilanishi
└── MYID_OAUTH_COMPLETE_GUIDE.md      # To'liq qo'llanma (bu fayl)
```

## ✅ Yakuniy natija

- ✅ Access token olish funksiyasi
- ✅ Sessiya yaratish funksiyasi
- ✅ To'liq avtomatik login ekrani
- ✅ Test rejimi ekrani
- ✅ MyID SDK integratsiyasi
- ✅ Yuz tanish (Face Recognition)
- ✅ Pasport ma'lumotlari qo'llab-quvvatlash
- ✅ Real-time status ko'rsatish

## 🔗 Foydali havolalar

- MyID SDK Dokumentatsiyasi: https://docs.myid.uz/
- MyID API Dokumentatsiyasi: https://docs.myid.uz/api/
- Flutter MyID Plugin: https://pub.dev/packages/myid

## 📞 Yordam

Agar savollar bo'lsa:
- MyID qo'llab-quvvatlash: support@myid.uz
- Telegram: @myid_support

---

**Yaratilgan sana:** 2025-01-17
**Versiya:** 1.0.0
**Holat:** ✅ Tayyor
