# MyID OAuth - Sequence Diagram (Ketma-ketlik diagrammasi)

## 📊 Umumiy ko'rinish

Bu hujjat rasmda ko'rsatilgan **Birinchi so'rov diagrammasi**ni tushuntiradi.

## 🔄 Jarayon ishtirokchilari

1. **Client Backend** - Sizning backend serveringiz
2. **Mobile APP** - Flutter ilovangiz
3. **MyIDSDK** - MyID SDK kutubxonasi
4. **MyID Backend** - MyID serveri

## 📋 To'liq jarayon (Primary Request)

### 1. Foydalanuvchi identifikatsiyasi

```text
User Identification
    ↓
Mobile APP → MyIDSDK: return access_token
    ↓
MyIDSDK → Mobile APP: 1. Create Session (with passport)
    ↓
Mobile APP → MyID Backend: return session_id
```

**Tushuntirish:**

- Foydalanuvchi ilovada identifikatsiya qilishni boshlaydi
- Mobile APP access token oladi
- Session yaratiladi (pasport ma'lumotlari bilan)
- MyID Backend session_id qaytaradi

### 2. SDK ishga tushirish

```text
Mobile APP → MyIDSDK: Initialize SDK with session_id
    ↓
MyIDSDK: Identification of user
    ↓
MyIDSDK → Mobile APP: return:
    - result
    - image
    - code
```

**Tushuntirish:**

- SDK session_id bilan ishga tushiriladi
- Foydalanuvchi yuzini tanish jarayoni boshlanadi
- Natija qaytariladi:
  - `result` - Natija (muvaffaqiyatli/xato)
  - `image` - Yuz surati
  - `code` - Natija kodi

### 3. Backend'ga ma'lumot yuborish

```text
Mobile APP → Client Backend: send image to db
    ↓
Client Backend: save image to db
```

**Tushuntirish:**

- Yuz surati backend'ga yuboriladi
- Backend ma'lumotlar bazasiga saqlaydi

### 4. Foydalanuvchi ma'lumotlarini olish

```text
Mobile APP → MyID Backend: 2. Retrieve User Data
    ↓
MyID Backend → Mobile APP: response:
    - profile
    - result
    - comparison_value
```

**Tushuntirish:**

- Foydalanuvchi ma'lumotlari so'raladi
- MyID Backend javob qaytaradi:
  - `profile` - Foydalanuvchi profili
  - `result` - Natija
  - `comparison_value` - Taqqoslash qiymati

## 🎯 Bizning implementatsiyamiz

### 1. Access Token olish

```dart
final tokenResult = await MyIdBackendService.getAccessToken(
  clientId: MyIDConfig.clientId,
  clientSecret: MyIDConfig.clientSecret,
);
```

### 2. Sessiya yaratish

```dart
final sessionResult = await MyIdBackendService.createSession(
  accessToken: tokenResult['access_token'],
  passData: 'AA1234567',  // Pasport ma'lumotlari
  birthDate: '1990-01-01',
);
```

### 3. SDK ishga tushirish

```dart
final result = await MyIdClient.start(
  config: MyIdConfig(
    sessionId: sessionResult['session_id'],
    clientHash: clientHash,
    clientHashId: clientHashId,
    environment: MyIdEnvironment.DEBUG,
    entryType: MyIdEntryType.IDENTIFICATION,
    locale: MyIdLocale.UZBEK,
  ),
);
```

### 4. Natijani qayta ishlash

```dart
if (result.code == '0') {
  // Muvaffaqiyatli
  final userData = {
    'myid_code': result.code,
    'session_id': sessionId,
    'timestamp': DateTime.now().toIso8601String(),
    'verified': true,
  };
  
  // Ma'lumotlarni saqlash
  await prefs.setString('user_data', json.encode(userData));
  
  // Home sahifasiga o'tish
  Navigator.pushReplacementNamed(context, '/home');
}
```

## 📊 Diagramma tushuntirish

### Primary Request (Asosiy so'rov)

```text
┌─────────────┐   ┌────────────┐   ┌──────────┐   ┌──────────────┐
│   Client    │   │  Mobile    │   │  MyID    │   │    MyID      │
│   Backend   │   │    APP     │   │   SDK    │   │   Backend    │
└──────┬──────┘   └─────┬──────┘   └────┬─────┘   └──────┬───────┘
       │                │               │                 │
       │  1. Get Access Token           │                 │
       │◄───────────────┤               │                 │
       │                │               │                 │
       │  2. Create Session             │                 │
       │                ├──────────────────────────────►  │
       │                │               │                 │
       │  3. Return session_id          │                 │
       │                │◄──────────────────────────────  │
       │                │               │                 │
       │  4. Initialize SDK             │                 │
       │                ├──────────────►│                 │
       │                │               │                 │
       │  5. Identification             │                 │
       │                │               │                 │
       │  6. Return result              │                 │
       │                │◄──────────────┤                 │
       │                │               │                 │
       │  7. Save image │               │                 │
       │◄───────────────┤               │                 │
       │                │               │                 │
       │  8. Get User Data              │                 │
       │                ├──────────────────────────────►  │
       │                │               │                 │
       │  9. Return profile             │                 │
       │                │◄──────────────────────────────  │
       │                │               │                 │
```

## 🔐 Xavfsizlik

### Access Token

- ✅ Backend'da saqlanadi
- ✅ HTTPS orqali uzatiladi
- ✅ 7 kun amal qiladi
- ⚠️ Frontend'da saqlamang

### Session ID

- ✅ Bir martalik ishlatiladi
- ✅ SDK'da xavfsiz saqlanadi
- ✅ Muddati cheklangan

### Foydalanuvchi ma'lumotlari

- ✅ Shifrlangan holda uzatiladi
- ✅ Backend'da xavfsiz saqlanadi
- ✅ GDPR talablariga mos

## 📱 Foydalanuvchi tajribasi

### 1. Boshlash

```text
Foydalanuvchi → "MyID orqali kirish" tugmasi
```

### 2. Jarayon

```text
Loading... → "Access token olinmoqda..."
Loading... → "Sessiya yaratilmoqda..."
Loading... → "MyID SDK ishga tushirilmoqda..."
```

### 3. Yuz tanish

```text
📸 Kamerani yoqish
👤 Yuzni ko'rsatish
✅ Tasdiqlash
```

### 4. Yakunlash

```text
✅ Muvaffaqiyatli kirish
→ Home sahifasiga o'tish
```

## 🧪 Test qilish

### 1. Access Token testi

```dart
final result = await MyIdBackendService.getAccessToken(
  clientId: 'test_client_id',
  clientSecret: 'test_client_secret',
);

expect(result['success'], true);
expect(result['access_token'], isNotNull);
```

### 2. Sessiya yaratish testi

```dart
final result = await MyIdBackendService.createSession(
  accessToken: 'test_token',
  passData: 'AA1234567',
);

expect(result['success'], true);
expect(result['session_id'], isNotNull);
```

### 3. To'liq jarayon testi

```dart
final result = await MyIdBackendService.createSessionWithToken(
  clientId: MyIDConfig.clientId,
  clientSecret: MyIDConfig.clientSecret,
  passData: 'AA1234567',
);

expect(result['success'], true);
expect(result['session_id'], isNotNull);
expect(result['access_token'], isNotNull);
```

## 📊 Xato kodlari

| Kod | Ma'nosi           | Harakat                    |
| --- | ----------------- | -------------------------- |
| `0` | Muvaffaqiyatli    | Davom etish                |
| `1` | Bekor qilindi     | Qayta urinish              |
| `2` | Xato              | Xato xabarini ko'rsatish   |
| `3` | Timeout           | Qayta urinish              |

## 🔄 Qayta urinish strategiyasi

```dart
int maxRetries = 3;
int currentRetry = 0;

while (currentRetry < maxRetries) {
  try {
    final result = await createSession();
    if (result['success']) break;
  } catch (e) {
    currentRetry++;
    if (currentRetry >= maxRetries) {
      // Xato xabarini ko'rsatish
      showError('Qayta urinib ko\'ring');
    }
  }
}
```

## ✅ Yakuniy tekshirish ro'yxati

- [ ] Access token olinadi
- [ ] Sessiya yaratiladi
- [ ] SDK ishga tushadi
- [ ] Yuz tanish ishlaydi
- [ ] Natija qayta ishlanadi
- [ ] Ma'lumotlar saqlanadi
- [ ] Foydalanuvchi kiradi

## 📚 Qo'shimcha resurslar

- [MyID SDK Dokumentatsiyasi](https://docs.myid.uz/)
- [OAuth 2.0 Spetsifikatsiyasi](https://oauth.net/2/)
- [Flutter MyID Plugin](https://pub.dev/packages/myid)

---

**Yaratilgan:** 2025-01-17
**Versiya:** 1.0.0
**Holat:** ✅ To'liq
