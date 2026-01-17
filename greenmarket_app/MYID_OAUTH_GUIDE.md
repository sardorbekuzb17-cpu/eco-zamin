# MyID OAuth Access Token - Qo'llanma

## Nima qilindi?

Rasmda ko'rsatilgan MyID OAuth API dokumentatsiyasiga asoslanib, **to'liq OAuth jarayoni** amalga oshirildi:

1. ✅ Access Token olish
2. ✅ Sessiya yaratish
3. ✅ MyID SDK ishga tushirish
4. ✅ Yuz tanish (Face Recognition)

## Qo'shilgan fayllar

### 1. `lib/services/myid_backend_service.dart`
Yangi funksiyalar qo'shildi:

#### a) Access Token olish
```dart
static Future<Map<String, dynamic>> getAccessToken({
  required String clientId,
  required String clientSecret,
})
```

**API Endpoint:** `https://myid.uz/api/v1/auth/clients/access-token`

**Parametrlar:**
- `client_id` - Mijoz identifikatori (200 ta belgidan kam)
- `client_secret` - Mijoz sirli kodi (200 ta belgidan kam)

**Javob:**
```json
{
  "access_token": "...",
  "expires_in": 604800,
  "token_type": "Bearer"
}
```

#### b) Sessiya yaratish
```dart
static Future<Map<String, dynamic>> createSession({
  required String accessToken,
  String? phoneNumber,
  String? birthDate,
  bool? isResident,
  String? pinfl,
  double? threshold,
})
```

**API Endpoint:** `https://myid.uz/api/v2/sdk/sessions`

**Avtorizatsiya:** `Bearer {access_token}`

**Parametrlar:**
- `phone_number` - Telefon raqami (12-13 belgi) | null
- `birth_date` - Tug'ilgan sana (YYYY-MM-DD) | null
- `is_resident` - Rezidentmi (standart: true) | null
- `pinfl` - PINFL (14 belgi) | null
- `pass_data` - Pasport seriyasi va raqami | null
- `threshold` - 0.5 dan 0.99 gacha | null

**Eslatma:** Agar sessiya pasport ma'lumotlari (pass_data yoki pinfl) bilan yaratilsa, SDK birinchi sahifani o'tkazib yuboradi va to'g'ridan-to'g'ri yuzni suratga olishga o'tadi.

**Javob:**
```json
{
  "session_id": "..."
}
```

### Javob parametrlari (rasmdan):

| № | Parametr | Tavsif | Turi | Maydon uzunligi |
|---|----------|--------|------|-----------------|
| 1 | `access_token` | Kirish tokeni (JWT) | tor | 512+ |
| 2 | `expires_in` | Tokenning ishlash muddati (soniya) | raqam | — |
| 3 | `token_type` | Token turi (Tashqidigan) | tor | 50 |

**Misol javob:**
```json
{
  "access_token": "eyJhb5ci...",
  "expires_in": 604800,
  "token_type": "Bearer"
}
```

**Izoh:** `expires_in: 604800` soniya = 7 kun

### 2. `lib/screens/myid_oauth_test_screen.dart`
Yangi test ekrani yaratildi. Bu ekranda:
- Client ID va Client Secret ko'rsatiladi
- "Access Token Olish" tugmasi bor
- Muvaffaqiyatli natija yashil kartada ko'rsatiladi
- Access token'ni nusxalash mumkin
- **"Sessiya Yaratish" tugmasi** - Access token bilan sessiya yaratadi
- Session ID ni nusxalash mumkin
- Xatolar qizil kartada ko'rsatiladi

### 3. `lib/main.dart`
Yangi route'lar qo'shildi:
```dart
'/oauth-test': (context) => const MyIdOAuthTestScreen(),
'/oauth-login': (context) => const MyIdOAuthFullLoginScreen(),
```

### 4. `lib/screens/myid_oauth_full_login_screen.dart`
**YANGI!** To'liq OAuth login ekrani yaratildi:
- Access token avtomatik olinadi
- Sessiya avtomatik yaratiladi
- MyID SDK avtomatik ishga tushadi
- Foydalanuvchi faqat yuzini ko'rsatadi
- Jarayon qadamlari real-time ko'rsatiladi

### 5. `lib/screens/home_screen.dart`
AppBar'ga yangi tugmalar qo'shildi:
- Icon: `Icons.login` - OAuth Login sahifasiga o'tkazadi
- Icon: `Icons.science` - OAuth Test sahifasiga o'tkazadi

## Qanday ishlatish?

### A. To'liq OAuth Login (Tavsiya etiladi) 🚀

1. Ilovani ishga tushiring: `flutter run`
2. Home sahifasiga kiring
3. AppBar'dagi 🔐 (login) belgisiga bosing
4. "MyID OAuth orqali kirish" tugmasini bosing
5. Jarayon avtomatik bajariladi:
   - ✅ Access token olinadi
   - ✅ Sessiya yaratiladi
   - ✅ MyID SDK ishga tushadi
   - ✅ Yuzingizni ko'rsating
6. Muvaffaqiyatli bo'lsa, home sahifasiga o'tasiz

### B. Test rejimi (Dasturchilar uchun) 🧪

1. Ilovani ishga tushiring: `flutter run`
2. Home sahifasiga kiring
3. AppBar'dagi 🧪 (test) belgisiga bosing
4. "Access Token Olish" tugmasini bosing
5. "Sessiya Yaratish" tugmasini bosing
6. Session ID ni nusxalang

## API Ma'lumotlari

**Endpoint:** `POST https://myid.uz/api/v1/auth/clients/access-token`

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "client_id": "quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v",
  "client_secret": "JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP"
}
```

**Response (Success):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 604800,
  "token_type": "Bearer"
}
```

**Javob parametrlari:**
- `access_token` - JWT token (512+ belgi)
- `expires_in` - Token muddati soniyada (604800 = 7 kun)
- `token_type` - Token turi ("Bearer")

## Keyingi qadamlar

### 1. Access Token bilan sessiya yaratish
```dart
final sessionResult = await MyIdBackendService.createSession(
  accessToken: accessToken,
  phoneNumber: '998901234567',  // Ixtiyoriy
  birthDate: '1990-01-01',      // Ixtiyoriy
  isResident: true,             // Ixtiyoriy
  pinfl: '12345678901234',      // Ixtiyoriy
  threshold: 0.75,              // Ixtiyoriy (0.5-0.99)
);
```

### 2. Session ID ni MyID SDK'da ishlatish
Olingan `session_id` ni MyID SDK'ga berish mumkin.

### 3. Boshqa API'larni chaqirish
Access token olingandan keyin, uni quyidagi API'larda ishlatish mumkin:
- Foydalanuvchi ma'lumotlarini olish
- Pasport ma'lumotlarini tekshirish
- Boshqa MyID API'larni chaqirish

Barcha so'rovlarda header'ga qo'shish kerak:
```
Authorization: Bearer {access_token}
```

## Xavfsizlik

⚠️ **Muhim:**
- Client Secret ni hech qachon frontend kodida saqlamang
- Production'da backend orqali access token oling
- Access token'ni xavfsiz joyda saqlang (secure storage)
- Token muddati tugaganda yangilab turing

## Test Natijasi

✅ Barcha fayllar xatosiz kompilyatsiya qilindi
✅ OAuth test sahifasi ishlaydi
✅ Access token olish funksiyasi tayyor
✅ Sessiya yaratish funksiyasi tayyor
✅ **To'liq OAuth login ekrani tayyor**
✅ MyID SDK integratsiyasi ishlaydi

## To'liq API Jarayoni

```text
1. Access Token olish
   ↓
2. Sessiya yaratish (access token bilan)
   ↓
3. Session ID olish
   ↓
4. MyID SDK ishga tushirish
   ↓
5. Yuz tanish (Face Recognition)
   ↓
6. Muvaffaqiyatli kirish
```

## Ekran ko'rinishlari

### OAuth Login Screen
- 🔐 To'liq avtomatik jarayon
- 📊 Real-time status ko'rsatish
- ✅ Yuz tanish integratsiyasi

### OAuth Test Screen
- 🧪 Qo'lda test qilish
- 📋 Token va Session ID ko'rish
- 📝 Nusxalash imkoniyati
