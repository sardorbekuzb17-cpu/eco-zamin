# MyID SDK Integratsiya Xatoligi - Texnik Hisobot

## Muammo Tavsifi

MyID SDK Flutter ilovasida ishlatilmoqda. SDK ishga tushganda quyidagi xatolik yuz bermoqda:

```
PlatformException(103, Session is expired, null, null)
```

**Xato kodi:** 103  
**Xato xabari:** Session is expired  
**Platforma:** Android (Samsung A515F, Android 13)  
**SDK versiyasi:** MyID Flutter SDK 3.1.41

---

## Credentials Ma'lumotlari

```
client_id: quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v
client_secret: JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP
client_hash_id: ac6d0f4a-5d5b-44e3-a865-9159a3146a8c
```

---

## 1. Access Token Olish (Muvaffaqiyatsiz)

### REQUEST:
```http
POST https://api.myid.uz/api/v1/auth/clients/access-token
Content-Type: application/json

{
  "client_id": "quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v",
  "client_secret": "JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP"
}
```

### RESPONSE:
```http
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "detail": "Incorrect client_id or client_secret"
}
```

**Natija:** ❌ Access token olinmadi - credentials noto'g'ri yoki muddati tugagan

---

## 2. Session Yaratish (Muvaffaqiyatsiz)

### REQUEST:
```http
POST https://api.myid.uz/api/v2/sdk/sessions
Content-Type: application/json
Authorization: Bearer [TOKEN_OLINMADI]

{}
```

### RESPONSE:
```
Request yuborilmadi - access token olish muvaffaqiyatsiz bo'lgani uchun
```

**Natija:** ❌ Session yaratilmadi

---

## 3. MyID SDK Ishga Tushirish (Muvaffaqiyatsiz)

### Flutter SDK Konfiguratsiyasi:
```dart
final result = await MyIdClient.start(
  config: MyIdConfig(
    sessionId: "UUID_GENERATED", // UUID bilan yaratilgan
    clientHash: '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5wQYaS8i1b0Rj5wuJLhI
yDuTW/WoWB/kRbJCBHFLyFTxETADNa/CU+xw0moN9X10+MVD5kRMinMRQpGUVCrU
XjUAEjwbdaCSLR6suRYI1EfDMQ5XFdJsfkAlNzZyyfBlif4OA4qxaMtdyvJCa/8n
wHn2KC89BNhqBQMre7iLaW8Z9bArSulSxBJzbzPjd7Jkg4ccQ47bVyjEKBcu/1KX
Ud/audUr1WsUpBf9yvgSTDRG2cuVXpMGEBJAqrsCS3RtIt7pEnGtr5FsB+UmBec9
Ei97fK2LcVfWpc/m7WjWMz3mku/pmhSjC6Vl6dlOrP1dv/fJkhfh3axzXtZoxgV1
QwIDAQAB
-----END PUBLIC KEY-----''',
    clientHashId: 'ac6d0f4a-5d5b-44e3-a865-9159a3146a8c',
    environment: MyIdEnvironment.PRODUCTION,
    entryType: MyIdEntryType.IDENTIFICATION,
    residency: MyIdResidency.USER_DEFINED,
    locale: MyIdLocale.UZBEK,
  ),
  iosAppearance: const MyIdIOSAppearance(),
);
```

### SDK Xatosi:
```
PlatformException(103, Session is expired, null, null)
```

**Natija:** ❌ SDK ishlamadi - session noto'g'ri yoki muddati tugagan

---

## Muammo Tahlili

### 1. **Access Token Muammosi**
- `client_id` va `client_secret` MyID API tomonidan qabul qilinmayapti
- Xato: `"Incorrect client_id or client_secret"`
- Bu credentials noto'g'ri yoki muddati tugaganligini ko'rsatadi

### 2. **Session ID Muammosi**
- UUID bilan yaratilgan session ID MyID SDK tomonidan qabul qilinmayapti
- Xato kodi 103: "Session is expired"
- MyID dokumentatsiyasiga ko'ra, session ID faqat MyID API orqali yaratilishi kerak

### 3. **To'g'ri Oqim**
MyID dokumentatsiyasiga ko'ra to'g'ri oqim:

```
1. Access Token olish
   POST /api/v1/auth/clients/access-token
   → access_token

2. Session yaratish
   POST /api/v2/sdk/sessions
   Authorization: Bearer {access_token}
   → session_id

3. SDK ishga tushirish
   MyIdClient.start(sessionId: session_id)
   → PINFL
```

Bizning holatda 1-qadam muvaffaqiyatsiz bo'lgani uchun keyingi qadamlar ishlamayapti.

---

## So'rov

MyID xodimlariga quyidagi savollar:

1. **Credentials tekshirish:**
   - `client_id: quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v` - bu to'g'rimi?
   - `client_secret` muddati tugaganmi?
   - Credentials qaysi muhit uchun (PRODUCTION/DEBUG)?

2. **API endpoint tekshirish:**
   - `https://api.myid.uz/api/v1/auth/clients/access-token` - bu to'g'ri endpoint'mi?
   - Boshqa endpoint ishlatish kerakmi?

3. **Session yaratish:**
   - Session yaratish uchun qo'shimcha parametrlar kerakmi?
   - UUID bilan session yaratish mumkinmi yoki faqat API orqali yaratilishi kerakmi?

---

## Qo'shimcha Ma'lumotlar

**Ilova:** GreenMarket (Flutter)  
**Backend:** Node.js (Vercel)  
**MyID SDK:** Flutter plugin v3.1.41  
**Test muhiti:** Android (Samsung A515F, Android 13)  
**Maqsad:** Foydalanuvchilarni MyID orqali identifikatsiya qilish

---

## Kutilayotgan Yechim

Iltimos, quyidagilarni taqdim eting:

1. ✅ To'g'ri `client_id` va `client_secret`
2. ✅ To'g'ri API endpoint'lar
3. ✅ Session yaratish uchun to'liq request/response namunasi
4. ✅ SDK ishga tushirish uchun to'liq kod namunasi (Flutter)

---

**Sana:** 2025-01-19  
**Murojaat qiluvchi:** GreenMarket Development Team  
**Aloqa:** [sizning email/telefon]
