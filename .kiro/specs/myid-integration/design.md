# MyID SDK Integratsiya - Dizayn Hujjati

## 1. Umumiy Ko'rinish

### 1.1 Maqsad
GreenMarket Flutter ilovasiga MyID SDK 3.1.41 orqali foydalanuvchi identifikatsiyasi va verifikatsiyasini integratsiya qilish. Backend-to-backend arxitektura orqali xavfsiz autentifikatsiya ta'minlash.

### 1.2 Arxitektura Diagrammasi

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  MyIdMainLoginScreen                                  │   │
│  │    ↓                                                  │   │
│  │  MyIdSdkLoginScreen                                   │   │
│  │    ↓ (HTTP Request)                                   │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│              Node.js Backend (Vercel)                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  POST /api/myid/create-session                        │   │
│  │    1. getBearerToken() - Token cache                  │   │
│  │    2. POST /api/v2/sdk/sessions                       │   │
│  │    3. Return session_id                               │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                  MyID API (api.devmyid.uz)                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  POST /api/v1/auth/clients/access-token              │   │
│  │  POST /api/v2/sdk/sessions                           │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                      MyID SDK                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  1. Pasport ma'lumotlarini kiritish                   │   │
│  │  2. Yuz identifikatsiyasi (Liveness)                 │   │
│  │  3. Natija qaytarish (MyIdResult)                    │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Komponentlar Dizayni

### 2.1 Flutter App Komponentlari

#### 2.1.1 MyIdMainLoginScreen
**Maqsad:** Kirish nuqtasi - foydalanuvchiga MyID orqali kirish imkoniyatini taqdim etish.

**UI Elementlari:**
- Logo (GreenMarket)
- "MyID orqali kirish" tugmasi
- Ma'lumot matni

**Funksiyalar:**
```dart
Future<void> _startLogin() async {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MyIdSdkLoginScreen()),
  );
}
```

#### 2.1.2 MyIdSdkLoginScreen
**Maqsad:** Session yaratish va MyID SDK'ni ishga tushirish.

**Holatlar:**
1. **Loading** - Session yaratilmoqda
2. **Ready** - Session tayyor, SDK'ni boshlash mumkin
3. **Error** - Xato yuz berdi

**Funksiyalar:**
```dart
// 1. Session yaratish
Future<void> _createSession() async {
  final result = await MyIdBackendService.createEmptySession();
  if (result['success'] == true) {
    setState(() {
      _sessionId = result['data']['session_id'];
    });
  }
}

// 2. MyID SDK'ni ishga tushirish
Future<void> _startMyIdSdk() async {
  final result = await MyIdClient.start(
    config: MyIdConfig(
      sessionId: _sessionId!,
      clientHash: RSA_PUBLIC_KEY,
      clientHashId: CLIENT_HASH_ID,
      environment: MyIdEnvironment.PRODUCTION,
      entryType: MyIdEntryType.IDENTIFICATION,
      locale: MyIdLocale.UZBEK,
    ),
  );
  await _handleMyIdResult(result);
}

// 3. Natijani qayta ishlash
Future<void> _handleMyIdResult(MyIdResult result) async {
  // User ma'lumotlarini saqlash
  final userData = {
    'pinfl': result.code,
    'full_name': result.profile?.fullName,
    'birth_date': result.profile?.birthDate,
    'passport': result.profile?.passport,
    'reuid': result.profile?.reuid,
    'verified': true,
    'timestamp': DateTime.now().toIso8601String(),
  };
  
  await prefs.setString('user_data', json.encode(userData));
  Navigator.pushReplacementNamed(context, '/home');
}
```

#### 2.1.3 MyIdBackendService
**Maqsad:** Backend API bilan aloqa.

**Metodlar:**
```dart
class MyIdBackendService {
  static const String baseUrl = 'https://greenmarket-backend-lilac.vercel.app';
  
  // Bo'sh session yaratish
  static Future<Map<String, dynamic>> createEmptySession() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/myid/create-session'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({}),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Session yaratishda xato: ${response.statusCode}');
    }
  }
}
```

### 2.2 Backend Komponentlari

#### 2.2.1 Token Management
**Maqsad:** Bearer token'ni cache qilish va qayta ishlatish.

```javascript
let bearerToken = null;
let tokenExpiry = null;

async function getBearerToken() {
  // Token hali amal qilayaptimi?
  if (bearerToken && tokenExpiry && Date.now() < tokenExpiry) {
    return bearerToken;
  }
  
  // Yangi token olish
  const response = await axios.post(
    `${MYID_HOST}/api/v1/auth/clients/access-token`,
    { client_id: CLIENT_ID, client_secret: CLIENT_SECRET }
  );
  
  bearerToken = response.data.access_token;
  tokenExpiry = Date.now() + (response.data.expires_in * 1000);
  
  return bearerToken;
}
```

#### 2.2.2 Session Creation
**Maqsad:** MyID API'dan session_id olish.

```javascript
app.post('/api/myid/create-session', async (req, res) => {
  try {
    const token = await getBearerToken();
    
    const response = await axios.post(
      `${MYID_HOST}/api/v2/sdk/sessions`,
      {}, // Bo'sh obyekt - SDK'da pasport kiritiladi
      {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
      }
    );
    
    res.json({
      success: true,
      data: {
        session_id: response.data.session_id,
        expires_in: response.data.expires_in || 600, // 10 daqiqa
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});
```

---

## 3. Ma'lumotlar Modellari

### 3.1 MyIdUser Model
```dart
class MyIdUser {
  final String pinfl;
  final String fullName;
  final String firstName;
  final String lastName;
  final String middleName;
  final String birthDate;
  final String passportSeries;
  final String passportNumber;
  final String? reuid;
  final bool verified;
  final DateTime timestamp;
  
  MyIdUser({
    required this.pinfl,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.birthDate,
    required this.passportSeries,
    required this.passportNumber,
    this.reuid,
    required this.verified,
    required this.timestamp,
  });
  
  factory MyIdUser.fromJson(Map<String, dynamic> json) {
    return MyIdUser(
      pinfl: json['pinfl'],
      fullName: json['full_name'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      middleName: json['middle_name'],
      birthDate: json['birth_date'],
      passportSeries: json['passport_series'],
      passportNumber: json['passport_number'],
      reuid: json['reuid'],
      verified: json['verified'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'pinfl': pinfl,
      'full_name': fullName,
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'birth_date': birthDate,
      'passport_series': passportSeries,
      'passport_number': passportNumber,
      'reuid': reuid,
      'verified': verified,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
```

---

## 4. Xavfsizlik Dizayni

### 4.1 Root/Jailbreak Detection
**⚠️ Muhim:** MyID SDK root va jailbreak tekshiruvlarini o'zi qilmaydi. Biz parent app'da qilishimiz kerak.

**Kutubxona:** `flutter_jailbreak_detection`

**Implementatsiya:**
```dart
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

class SecurityService {
  static Future<bool> isDeviceSecure() async {
    try {
      final jailbroken = await FlutterJailbreakDetection.jailbroken;
      final developerMode = await FlutterJailbreakDetection.developerMode;
      
      return !jailbroken && !developerMode;
    } catch (e) {
      // Xato bo'lsa, xavfsiz deb hisoblaymiz
      return true;
    }
  }
  
  static Future<void> checkSecurityBeforeMyId(BuildContext context) async {
    final isSecure = await isDeviceSecure();
    
    if (!isSecure) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Xavfsizlik Ogohlantirishi'),
          content: Text(
            'Qurilmangiz root/jailbreak qilingan. '
            'MyID xavfsizlik sabablariga ko\'ra ishlamaydi.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      throw Exception('Device is not secure');
    }
  }
}
```

### 4.2 Emulator Detection
**Kutubxona:** `safe_device`

**Implementatsiya:**
```dart
import 'package:safe_device/safe_device.dart';

class SecurityService {
  static Future<bool> isRealDevice() async {
    try {
      final isRealDevice = await SafeDevice.isRealDevice;
      return isRealDevice;
    } catch (e) {
      return true;
    }
  }
  
  static Future<void> checkEmulatorBeforeMyId(BuildContext context) async {
    final isReal = await isRealDevice();
    
    if (!isReal) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Emulator Aniqlandi'),
          content: Text(
            'MyID emulator\'da ishlamaydi. '
            'Iltimos, haqiqiy qurilmada sinab ko\'ring.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      throw Exception('Running on emulator');
    }
  }
}
```

### 4.3 Xavfsiz Ma'lumotlar Saqlash
**Kutubxona:** `flutter_secure_storage`

**Implementatsiya:**
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  
  static Future<void> saveUserData(MyIdUser user) async {
    await _storage.write(
      key: 'myid_user',
      value: json.encode(user.toJson()),
    );
  }
  
  static Future<MyIdUser?> getUserData() async {
    final data = await _storage.read(key: 'myid_user');
    if (data != null) {
      return MyIdUser.fromJson(json.decode(data));
    }
    return null;
  }
  
  static Future<void> clearUserData() async {
    await _storage.delete(key: 'myid_user');
  }
}
```

---

## 5. Xato Qayta Ishlash

### 5.1 MyID SDK Xato Kodlari

| Kod | Xato | Harakatlar |
|-----|------|-----------|
| 101 | Foydalanuvchi bekor qildi | Kirish ekraniga qaytish |
| 102 | Kamera ruxsati yo'q | Ruxsat so'rash dialog |
| 103 | Server/SDK xatosi | Qayta urinish taklifi |
| 122 | Foydalanuvchi bloklangan | Support bilan bog'lanish |

**Implementatsiya:**
```dart
Future<void> _handleMyIdResult(MyIdResult result) async {
  if (result.code == null) {
    // Xato yuz berdi
    final errorCode = result.errorCode ?? 0;
    
    switch (errorCode) {
      case 101:
        _showError('Siz jarayonni bekor qildingiz');
        break;
      case 102:
        _showError('Kamera ruxsati kerak. Sozlamalarga o\'ting.');
        break;
      case 103:
        _showError('Server xatosi. Qayta urinib ko\'ring.');
        break;
      case 122:
        _showError('Sizning hisobingiz bloklangan. Support: 712022202');
        break;
      default:
        _showError('Noma\'lum xato: $errorCode');
    }
    return;
  }
  
  // Muvaffaqiyatli natija
  await _saveUserData(result);
  Navigator.pushReplacementNamed(context, '/home');
}
```

### 5.2 Backend Xatolari

```dart
Future<Map<String, dynamic>> createEmptySession() async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/myid/create-session'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({}),
    ).timeout(Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Backend endpoint topilmadi');
    } else if (response.statusCode >= 500) {
      throw Exception('Server xatosi. Keyinroq urinib ko\'ring.');
    } else {
      throw Exception('Xato: ${response.statusCode}');
    }
  } on TimeoutException {
    throw Exception('Tarmoq sekin. Qayta urinib ko\'ring.');
  } catch (e) {
    throw Exception('Xatolik: ${e.toString()}');
  }
}
```

---

## 6. Testlash Strategiyasi

### 6.1 Unit Testlar

**MyIdBackendService Test:**
```dart
test('createEmptySession returns session_id', () async {
  final result = await MyIdBackendService.createEmptySession();
  
  expect(result['success'], true);
  expect(result['data']['session_id'], isNotNull);
  expect(result['data']['session_id'], isA<String>());
});
```

**SecurityService Test:**
```dart
test('isDeviceSecure returns boolean', () async {
  final isSecure = await SecurityService.isDeviceSecure();
  expect(isSecure, isA<bool>());
});
```

### 6.2 Integration Testlar

**To'liq Flow Test:**
1. MyIdMainLoginScreen ochiladi
2. "MyID orqali kirish" tugmasi bosiladi
3. MyIdSdkLoginScreen ochiladi
4. Session yaratiladi
5. MyID SDK ishga tushadi
6. Foydalanuvchi pasport kiritadi
7. Yuz identifikatsiyasi o'tkaziladi
8. Ma'lumotlar saqlanadi
9. Home sahifasiga o'tiladi

### 6.3 Manual Testlar

**Haqiqiy Qurilmada:**
- [ ] Android qurilmada test qilish
- [ ] iOS qurilmada test qilish
- [ ] Turli pasport ma'lumotlari bilan test
- [ ] Xato holatlarini test qilish
- [ ] Session timeout'ni test qilish

---

## 7. Performance Optimizatsiyalari

### 7.1 Token Caching
Backend'da Bearer token cache qilinadi - har safar yangi token olish shart emas.

### 7.2 Session Reuse
Session 10 daqiqa amal qiladi - bu vaqt ichida qayta ishlatish mumkin.

### 7.3 REUID Flow (Kelajakda)
Birinchi muvaffaqiyatli login'dan keyin REUID saqlanadi. Keyingi kirishlarda faqat yuz identifikatsiyasi o'tkaziladi - pasport kiritish shart emas.

---

## 8. Deployment

### 8.1 Backend (Vercel)
```bash
# Backend deploy
cd greenmarket_backend
vercel --prod
```

**Environment Variables:**
- `CLIENT_ID` - MyID client ID
- `CLIENT_SECRET` - MyID client secret
- `MYID_HOST` - MyID API URL

### 8.2 Flutter App
```bash
# Android APK
cd greenmarket_app
flutter build apk --release

# iOS IPA
flutter build ios --release
```

**Kerakli Konfiguratsiyalar:**
- Android: `minSdkVersion 21`
- iOS: `platform :ios, '13.0'`
- Kamera ruxsati: `Info.plist` va `AndroidManifest.xml`

---

## 9. Monitoring va Logging

### 9.1 Backend Logs
```javascript
console.log('📤 Session yaratish so\'rovi');
console.log('✅ Session yaratildi:', session_id);
console.log('❌ Xato:', error.message);
```

### 9.2 Flutter Logs
```dart
print('🔄 Session yaratilmoqda...');
print('✅ Session tayyor: $_sessionId');
print('🚀 MyID SDK ishga tushmoqda...');
print('✅ Muvaffaqiyatli: ${result.code}');
print('❌ Xato: ${result.errorCode}');
```

---

## 10. Kelajak Yaxshilanishlar

### 10.1 REUID Flow
- [ ] REUID'ni saqlash
- [ ] REUID bilan session yaratish
- [ ] Tezkor kirish (faqat liveness)

### 10.2 Biometrik Autentifikatsiya
- [ ] Fingerprint qo'shish
- [ ] Face ID qo'shish
- [ ] MyID + Biometrik kombinatsiya

### 10.3 Offline Support
- [ ] Ma'lumotlarni lokal saqlash
- [ ] Offline rejimda ishlash
- [ ] Sync qilish

---

## 11. Xavfsizlik Checklist

- [x] Backend-to-backend arxitektura
- [x] HTTPS faqat
- [x] Bearer token caching
- [ ] Root/Jailbreak detection
- [ ] Emulator detection
- [ ] Secure storage
- [x] Session timeout (10 daqiqa)
- [ ] REUID expiry tracking
- [ ] SSL pinning (kelajakda)

---

## 12. Havola va Resurslar

- **MyID SDK:** `../myid-3.1.41`
- **MyID Docs:** https://docs.myid.uz
- **Backend:** https://greenmarket-backend-lilac.vercel.app
- **Support:** @myid_support (Telegram)
- **Test Environment:** https://api.devmyid.uz
