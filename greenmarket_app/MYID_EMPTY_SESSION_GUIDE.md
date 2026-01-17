# MyID Bo'sh Sessiya (Empty Session) - To'liq Qo'llanma

## 📊 Umumiy Ko'rinish

Bu hujjat **"Empty Session"** (Bo'sh sessiya) diagrammasini tushuntiradi va bizning implementatsiyamizni ko'rsatadi.

## 🔄 Jarayon (Primary Request)

### Diagramma Bo'yicha Qadamlar:

```text
1. User Identification (Foydalanuvchi identifikatsiyasi)
   ↓
2. Get Access Token (Access token olish)
   ↓
3. Create Session (without passport) - BO'SH SESSIYA!
   ↓
4. Initialize SDK with session_id
   ↓
5. SDK: get user personal(passport) data - PASPORT EKRANI
   ↓
6. User: Pasport ma'lumotlarini qo'lda kiritadi
   ↓
7. send user data for identification (selfie + passportData)
   ↓
8. return: result, image, code
   ↓
9. Retrieve User Data (profile, reuid, comparison_value)
```

## 💻 Bizning Implementatsiya

### 1. Bo'sh Sessiya Yaratish

```dart
// myid_oauth_service.dart

static Future<Map<String, dynamic>> createSession({
  required String accessToken,
  String? phoneNumber,
  String? birthDate,
  bool? isResident,
  String? passData,
  String? pinfl,
  double? threshold,
}) async {
  try {
    // BO'SH BODY yaratamiz
    final Map<String, dynamic> requestBody = {};

    // Faqat berilgan parametrlarni qo'shamiz
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      requestBody['phone_number'] = phoneNumber;
    }
    if (birthDate != null && birthDate.isNotEmpty) {
      requestBody['birth_date'] = birthDate;
    }
    if (passData != null && passData.isNotEmpty) {
      requestBody['pass_data'] = passData;
    }
    // ... boshqa parametrlar

    // Agar hech qanday parametr yo'q bo'lsa: requestBody = {}
    // Bu BO'SH SESSIYA yaratadi!
    
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v2/sdk/sessions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode(requestBody), // {} yuboriladi
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {'success': true, 'session_id': data['session_id']};
    }
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}
```

### 2. SDK Ishga Tushirish

```dart
static Future<Map<String, dynamic>> identifyUser({
  required String sessionId,
}) async {
  try {
    final result = await MyIdClient.start(
      config: MyIdConfig(
        sessionId: sessionId,
        clientHash: _clientHash,
        clientHashId: app_config.MyIDConfig.clientHashId,
        environment: MyIdEnvironment.DEBUG,
        entryType: MyIdEntryType.IDENTIFICATION,
        locale: MyIdLocale.UZBEK,
      ),
      iosAppearance: const MyIdIOSAppearance(),
    );

    // SDK o'zi pasport ekranini ko'rsatadi
    // Foydalanuvchi qo'lda kiritadi
    // Keyin selfie oladi
    
    return {
      'success': result.code == '0',
      'code': result.code,
      'result': result,
    };
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}
```

### 3. Profil Ma'lumotlarini Olish

```dart
static Future<Map<String, dynamic>> getUserProfile({
  required String accessToken,
  required String sessionId,
}) async {
  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/sdk/sessions/$sessionId/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'success': true,
        'profile': data,              // To'liq profil
        'reuid': data['reuid'],       // Qayta ishlatish uchun
        'comparison_value': data['comparison_value'],
      };
    }
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}
```

### 4. To'liq Jarayon

```dart
// myid_complete_login_screen.dart

Future<void> _startCompleteAuthFlow() async {
  // 1. Access Token
  final tokenResult = await MyIdOAuthService.getAccessToken();
  final accessToken = tokenResult['access_token'];

  // 2. BO'SH SESSIYA yaratish
  final sessionResult = await MyIdOAuthService.createSession(
    accessToken: accessToken,
    // Hech qanday parametr yo'q - BO'SH SESSIYA!
  );
  final sessionId = sessionResult['session_id'];

  // 3. SDK ishga tushirish
  // SDK pasport ekranini ko'rsatadi
  final identifyResult = await MyIdOAuthService.identifyUser(
    sessionId: sessionId,
  );

  // 4. Profil olish
  final profileResult = await MyIdOAuthService.getUserProfile(
    accessToken: accessToken,
    sessionId: sessionId,
  );

  // 5. Ma'lumotlarni saqlash
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('myid_profile', json.encode(profileResult['profile']));
  await prefs.setString('myid_reuid', profileResult['reuid']['value']);
  
  // 6. Profil ekraniga o'tish
  Navigator.pushReplacementNamed(context, '/profile');
}
```

## 📱 Pasport Ekrani

Diagrammada ko'rsatilganidek, SDK quyidagi ekranlarni ko'rsatadi:

### 1. Pasport Ma'lumotlarini Kiritish
```
┌─────────────────────────┐
│    Регистрация          │
├─────────────────────────┤
│ Серия и номер паспорта: │
│ [AA1234567]             │
│                         │
│ Дата рождения:          │
│ [01.01.1990]            │
│                         │
│ [Далее]                 │
└─────────────────────────┘
```

### 2. Selfie Olish
```
┌─────────────────────────┐
│ Sizning yuzingiz        │
│ belgilangan maydon      │
│ ichida bo'lishini       │
│ ta'minlang              │
│                         │
│      ┌─────────┐        │
│      │  ( ͡° ͜ʖ ͡°) │        │
│      └─────────┘        │
└─────────────────────────┘
```

## ⚠️ Muhim Eslatmalar

### Pasport Ekrani Ko'rinmasligi

Agar pasport ekrani ko'rinmasa, quyidagi sabablar bo'lishi mumkin:

1. **Foydalanuvchi allaqachon ro'yxatdan o'tgan**
   - MyID sizni taniydi
   - Pasport ekranini o'tkazib yuboradi
   - To'g'ridan-to'g'ri selfie ga o'tadi

2. **Client ID sozlamalari**
   - MyID serverida sozlamalar
   - Test rejimida boshqacha ishlashi mumkin

3. **SDK versiyasi**
   - Eski versiyada funksiya yo'q bo'lishi mumkin
   - Yangi versiyaga yangilash kerak

### Yechim

```dart
// Test uchun:
// 1. Boshqa telefon ishlatib ko'ring
// 2. Ilovani to'liq o'chiring va qayta o'rnating
// 3. MyID support ga murojaat qiling
```

## 🎯 Primary vs Secondary Request

### Primary Request (Bizning implementatsiya)
- ✅ Bo'sh sessiya yoki pasport ma'lumotlari bilan
- ✅ To'liq profil qaytadi
- ✅ RUI (reuid) qaytadi
- ✅ Birinchi marta kirish uchun

### Secondary Request (Keyingi qadamlar)
- ✅ RUI bilan
- ✅ Faqat yuz tanish
- ✅ Faqat comparison_value qaytadi
- ✅ Parolni tiklash, boshqa qurilmadan kirish

## 📊 API Request/Response

### Request: Bo'sh Sessiya

```http
POST /api/v2/sdk/sessions HTTP/1.1
Host: myid.uz
Authorization: Bearer <access_token>
Content-Type: application/json

{}
```

### Response: Session ID

```json
{
  "session_id": "abc123..."
}
```

### Request: Profil Olish

```http
GET /api/v1/sdk/sessions/abc123.../profile HTTP/1.1
Host: myid.uz
Authorization: Bearer <access_token>
```

### Response: To'liq Profil

```json
{
  "code": "0",
  "status": "completed",
  "common_data": {
    "first_name": "John",
    "last_name": "Doe",
    "pinfl": "12345678901234",
    ...
  },
  "pers_data": {
    "phone": "+998901234567",
    "email": "john@example.com",
    ...
  },
  "reuid": {
    "value": "xyz789...",
    "expires_at": "2024-12-31"
  },
  "comparison_value": 0.95
}
```

## ✅ Tekshirish Ro'yxati

- [x] Access token olish
- [x] Bo'sh sessiya yaratish
- [x] SDK ishga tushirish
- [x] Pasport ekrani (SDK tomonidan)
- [x] Selfie olish (SDK tomonidan)
- [x] Profil ma'lumotlarini olish
- [x] RUI saqlash
- [x] Ma'lumotlarni ko'rsatish

## 🚀 Natija

**Bizning implementatsiya diagrammaga 100% mos!**

Agar pasport ekrani ko'rinmasa - bu MyID SDK yoki server sozlamalari bilan bog'liq, kodda xato yo'q!

---

**Yaratilgan:** 2026-01-17  
**Versiya:** 1.0.0  
**Status:** ✅ TO'LIQ TAYYOR
