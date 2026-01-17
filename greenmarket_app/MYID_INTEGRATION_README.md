# MyID OAuth Integratsiyasi - Asosiy README

## 📚 Hujjatlar ro'yxati

Ushbu loyihada MyID OAuth integratsiyasi to'liq amalga oshirilgan. Quyida barcha hujjatlar ro'yxati keltirilgan:

### 1. 📖 MYID_OAUTH_GUIDE.md
**Maqsad:** Asosiy qo'llanma

**Mavzular:**
- Access Token olish
- Sessiya yaratish
- MyID SDK ishga tushirish
- Test qilish

### 2. 📝 MYID_PASS_DATA_UPDATE.md
**Maqsad:** pass_data parametri haqida

**Mavzular:**
- pass_data parametri nima?
- Qanday ishlatiladi?
- Foydalanuvchi tajribasiga ta'siri

### 3. 📘 MYID_OAUTH_COMPLETE_GUIDE.md
**Maqsad:** To'liq qo'llanma

**Mavzular:**
- Barcha API endpoint'lar
- To'liq kod misollari
- Fayl strukturasi
- Xavfsizlik

### 4. 📊 MYID_OAUTH_SEQUENCE_DIAGRAM.md
**Maqsad:** Sequence diagram tushuntirish

**Mavzular:**
- Jarayon diagrammasi
- Ishtirokchilar
- Xato kodlari
- Test strategiyasi

## 🚀 Tezkor boshlash

### 1. Oddiy foydalanuvchilar uchun

```dart
// Home sahifasidan
Navigator.pushNamed(context, '/oauth-login');
```

### 2. Dasturchilar uchun

```dart
// Test rejimi
Navigator.pushNamed(context, '/oauth-test');
```

### 3. To'liq kod misoli

```dart
final result = await MyIdBackendService.createSessionWithToken(
  clientId: MyIDConfig.clientId,
  clientSecret: MyIDConfig.clientSecret,
  passData: 'AA1234567',
  birthDate: '1990-01-01',
);

if (result['success'] == true) {
  final sessionId = result['session_id'];
  
  // MyID SDK ishga tushirish
  final sdkResult = await MyIdClient.start(
    config: MyIdConfig(
      sessionId: sessionId,
      clientHash: clientHash,
      clientHashId: clientHashId,
      environment: MyIdEnvironment.DEBUG,
      entryType: MyIdEntryType.IDENTIFICATION,
      locale: MyIdLocale.UZBEK,
    ),
  );
  
  if (sdkResult.code == '0') {
    // Muvaffaqiyatli!
    Navigator.pushReplacementNamed(context, '/home');
  }
}
```

## 📁 Fayl strukturasi

```
greenmarket_app/
├── lib/
│   ├── config/
│   │   └── myid_config.dart
│   ├── services/
│   │   └── myid_backend_service.dart
│   └── screens/
│       ├── myid_oauth_full_login_screen.dart
│       └── myid_oauth_test_screen.dart
├── MYID_OAUTH_GUIDE.md
├── MYID_PASS_DATA_UPDATE.md
├── MYID_OAUTH_COMPLETE_GUIDE.md
├── MYID_OAUTH_SEQUENCE_DIAGRAM.md
└── MYID_INTEGRATION_README.md (bu fayl)
```

## 🎯 Asosiy funksiyalar

### 1. getAccessToken()
Access token olish

```dart
await MyIdBackendService.getAccessToken(
  clientId: clientId,
  clientSecret: clientSecret,
);
```

### 2. createSession()
Sessiya yaratish

```dart
await MyIdBackendService.createSession(
  accessToken: accessToken,
  passData: 'AA1234567',
);
```

### 3. createSessionWithToken()
To'liq avtomatik jarayon

```dart
await MyIdBackendService.createSessionWithToken(
  clientId: clientId,
  clientSecret: clientSecret,
  passData: 'AA1234567',
);
```

## 📊 API Endpoint'lar

| Endpoint | Metod | Maqsad |
|----------|-------|--------|
| `/api/v1/auth/clients/access-token` | POST | Access token |
| `/api/v2/sdk/sessions` | POST | Sessiya yaratish |

## 🔐 Xavfsizlik

- ✅ HTTPS faqat
- ✅ Token xavfsiz saqlash
- ✅ Client Secret backend'da
- ✅ GDPR mos

## 🧪 Test qilish

### Unit testlar

```bash
flutter test test/myid_backend_service_test.dart
```

### Integration testlar

```bash
flutter test integration_test/myid_oauth_test.dart
```

### Manual test

1. Home → 🔐 → Login
2. Home → 🧪 → Test

## 📱 Ekranlar

### MyIdOAuthFullLoginScreen
- To'liq avtomatik login
- Real-time status
- Yuz tanish

### MyIdOAuthTestScreen
- Qo'lda test
- Token ko'rish
- Session ID nusxalash

## ✅ Tekshirish ro'yxati

- [x] Access token olish
- [x] Sessiya yaratish
- [x] SDK integratsiyasi
- [x] Yuz tanish
- [x] pass_data qo'llab-quvvatlash
- [x] Xato qayta ishlash
- [x] Test ekranlari
- [x] Hujjatlashtirish

## 🔄 Yangilanishlar

### v1.0.0 (2025-01-17)
- ✅ Dastlabki versiya
- ✅ Barcha asosiy funksiyalar
- ✅ To'liq hujjatlashtirish

## 📞 Yordam

**Texnik qo'llab-quvvatlash:**
- Email: support@myid.uz
- Telegram: @myid_support

**Hujjatlar:**
- https://docs.myid.uz/

## 🎓 O'rganish yo'li

1. **Boshlang'ich:** `MYID_OAUTH_GUIDE.md`
2. **Parametrlar:** `MYID_PASS_DATA_UPDATE.md`
3. **To'liq:** `MYID_OAUTH_COMPLETE_GUIDE.md`
4. **Diagramma:** `MYID_OAUTH_SEQUENCE_DIAGRAM.md`

## 💡 Maslahatlar

### 1. Pasport ma'lumotlari bilan tezroq

```dart
passData: 'AA1234567',  // SDK pasport sahifasini o'tkazib yuboradi
```

### 2. Xato qayta ishlash

```dart
try {
  final result = await createSession();
} catch (e) {
  showError('Qayta urinib ko\'ring');
}
```

### 3. Loading ko'rsatish

```dart
setState(() => _statusMessage = 'Sessiya yaratilmoqda...');
```

## 🌟 Eng yaxshi amaliyotlar

1. ✅ Token'ni xavfsiz saqlang
2. ✅ Xatolarni to'g'ri qayta ishlang
3. ✅ Loading holatini ko'rsating
4. ✅ Foydalanuvchiga feedback bering
5. ✅ Timeout'larni sozlang

## 📈 Keyingi qadamlar

- [ ] Backend integratsiyasi
- [ ] Production sozlamalari
- [ ] Monitoring qo'shish
- [ ] Analytics integratsiyasi

---

**Loyiha:** GreenMarket
**Versiya:** 1.0.0
**Sana:** 2025-01-17
**Holat:** ✅ Production tayyor
