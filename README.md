# 🌱 GreenMarket - Ekologik Bozor Platformasi

**GreenMarket** - bu fermerlar va xaridorlarni to'g'ridan-to'g'ri bog'lovchi zamonaviy ekologik bozor platformasi. Biz organik va sog'lom mahsulotlarni uyingizga yetkazib beramiz, vositachilarni yo'qotib, adolatli narxlarni ta'minlaymiz.

## 🎯 Loyiha Haqida

GreenMarket - bu shunchaki onlayn do'kon emas, bu ekologik toza kelajak uchun harakat. Biz mahalliy fermerlarni qo'llab-quvvatlaymiz, sog'lom turmush tarzini targ'ib qilamiz va tabiatni asraymiz.

### ✨ Asosiy Xususiyatlar

- 🥬 **Organik Mahsulotlar** - To'g'ridan-to'g'ri fermerlardan yangi va sifatli mahsulotlar
- 🤖 **AI Bog'bon Maslahatchi** - Sun'iy intellekt yordamida o'simliklar parvarishi bo'yicha maslahatlar
- 📱 **Mobil Ilova** - Flutter asosida ishlab chiqilgan qulay mobil ilova
- 🚚 **Tezkor Yetkazib Berish** - Shahar bo'ylab tez va ishonchli yetkazib berish
- 💰 **Adolatli Narxlar** - Vositachilarsiz to'g'ridan-to'g'ri narxlar
- 🌍 **Ekologik Toza** - CO2 absorbsiyasi va ekologik sertifikatlar
- 🔒 **Xavfsizlik** - Zamonaviy xavfsizlik tizimlari va ma'lumotlar himoyasi
- 🆔 **MyID Integratsiyasi** - O'zbekiston Respublikasi pasport ma'lumotlari orqali xavfsiz autentifikatsiya
- 📊 **Statistika** - Buyurtmalar tarixi va shaxsiy statistika

### 🎨 Texnologiyalar

**Frontend:**

- HTML5, CSS3, JavaScript (ES6+)
- Responsive dizayn
- Progressive Web App (PWA)

**Mobile:**

- Flutter 3.x
- Dart
- Material Design
- MyID SDK 3.1.41 (Autentifikatsiya)

**Backend & Services:**

- Node.js 18+
- Express.js 4.x
- RESTful API
- MyID OAuth 2.0 API
- LocalStorage
- Cloud Storage

**DevOps:**

- Git & GitHub
- Vercel / GitHub Pages
- CI/CD

## 📁 Loyiha Tuzilmasi

```plaintext
eco-zamin/
├── 🌐 Web Platform
│   ├── index.html              # Bosh sahifa
│   ├── GreenMarket.html        # Mahsulotlar katalogi
│   ├── story.html              # Loyiha hikoyasi
│   ├── privacy-policy.html     # Maxfiylik siyosati
│   ├── style.css               # Asosiy stillar
│   ├── script.js               # JavaScript funksiyalar
│   └── lang/                   # Ko'p tillilik
│       ├── uz.json
│       ├── ru.json
│       └── en.json
│
├── 📱 Mobile App (Flutter)
│   └── greenmarket_app/
│       ├── lib/
│       │   ├── main.dart
│       │   ├── screens/        # Ekranlar
│       │   ├── services/       # Xizmatlar
│       │   ├── models/         # Ma'lumot modellari
│       │   └── data/           # Statik ma'lumotlar
│       ├── android/
│       ├── ios/
│       └── pubspec.yaml
│
├── 🔧 Backend & API
│   ├── greenmarket_api/        # API serverlari
│   ├── greenmarket_backend/    # Backend xizmatlari
│   │   ├── index.js            # Express server
│   │   ├── myid_sdk_flow.js    # MyID integratsiyasi
│   │   └── __tests__/          # Backend testlari
│   └── .env                    # Environment variables
│
├── 🧪 Tests
│   └── __tests__/              # Test fayllari
│
└── 📚 Documentation
    ├── README.md
    ├── PRIVACY_POLICY_SETUP.md
    └── VERSION_UPDATE_GUIDE.md
```

## 🚀 Boshlash

### Talablar

- Node.js 18 yoki undan yuqori
- Flutter 3.x
- Git
- MyID Client ID va Client Secret (production uchun)

### O'rnatish

```bash
# Repository'ni klonlash
git clone https://github.com/sardorbekuzb17-cpu/eco-zamin.git
cd eco-zamin

# Bog'liqliklarni o'rnatish
npm install

# Backend uchun environment variables sozlash
cd greenmarket_backend
cp .env.example .env
# .env faylida MYID_CLIENT_ID va MYID_CLIENT_SECRET ni to'ldiring
```

### Ishga Tushirish

**Backend server:**

```bash
cd greenmarket_backend

# Development rejimida
npm run dev

# Production rejimida
npm start
```

Server `http://localhost:3000` da ishga tushadi.

**Web versiyasi:**

```bash
# Development server
npm start

# Yoki oddiy HTTP server
npx http-server
```

Brauzerda oching: `http://localhost:8080`

**Mobil ilova (Flutter):**

```bash
cd greenmarket_app

# Bog'liqliklarni o'rnatish
flutter pub get

# Ishga tushirish
flutter run

# Android uchun build
flutter build apk

# iOS uchun build
flutter build ios
```

## 🧪 Testlar

```bash
# Backend testlari
cd greenmarket_backend

# Barcha testlarni ishga tushirish
npm test

# Watch rejimida testlar
npm run test:watch

# Coverage bilan testlar
npm run test:coverage

# Property-based testlar
npm run test:property

# Flutter testlari
cd greenmarket_app

# Widget testlarni ishga tushirish
flutter test

# Coverage bilan testlar
flutter test --coverage
```

## 🆔 MyID Integratsiyasi

GreenMarket platformasi O'zbekiston Respublikasining milliy identifikatsiya tizimi **MyID** bilan integratsiya qilingan. Bu foydalanuvchilarga pasport ma'lumotlari va yuz tanish texnologiyasi orqali xavfsiz autentifikatsiya qilish imkoniyatini beradi.

### MyID Xususiyatlari

- 🔐 **OAuth 2.0 Autentifikatsiya** - Xavfsiz token-based autentifikatsiya
- 👤 **Yuz Tanish** - MyID SDK orqali biometrik identifikatsiya
- 📱 **Mobil SDK** - Flutter ilovada to'liq integratsiya
- 🔒 **Ma'lumotlar Xavfsizligi** - HTTPS va AES-256 shifrlash
- 🌐 **Ko'p Tillilik** - O'zbek, Rus va Ingliz tillarida

### MyID Autentifikatsiya Oqimi

1. **Sessiya Yaratish** - Backend MyID API'dan sessiya yaratadi
2. **SDK Ishga Tushirish** - Mobil ilovada MyID SDK ishga tushadi
3. **Yuz Tanish** - Foydalanuvchi yuzini kameraga ko'rsatadi
4. **Identifikatsiya** - MyID tizimi foydalanuvchini tasdiqlaydi
5. **Ma'lumotlar Olish** - Backend foydalanuvchi ma'lumotlarini oladi
6. **Kirish** - Foydalanuvchi tizimga kiritiladi

### MyID API Endpointlari

**Backend API:**

```bash
# Sessiya yaratish
POST /api/myid/create-session
Response: { session_id, expires_in }

# Foydalanuvchi ma'lumotlarini olish
POST /api/myid/sdk/get-user-data
Body: { code }
Response: { profile, comparison_value }

# Access token olish (test uchun)
POST /api/myid/get-access-token
Response: { access_token, expires_in }

# Foydalanuvchilar ro'yxati
GET /api/users?page=1&limit=10&status=active
Response: { users, pagination, stats }
```

### MyID Konfiguratsiyasi

**Backend (.env):**

```env
MYID_CLIENT_ID=your_client_id
MYID_CLIENT_SECRET=your_client_secret
MYID_BASE_URL=https://api.myid.uz
```

**Flutter (MyID SDK):**

```dart
final config = MyIdConfig(
  sessionId: sessionId,
  clientHash: 'your_client_hash',
  clientHashId: 'your_client_hash_id',
  environment: MyIdEnvironment.PRODUCTION,
  entryType: MyIdEntryType.IDENTIFICATION,
  locale: MyIdLocale.UZBEK,
);

final result = await MyIdClient.start(config: config);
```

### MyID Xavfsizlik

- ✅ Barcha so'rovlar HTTPS orqali
- ✅ Access token 7 kun amal qiladi
- ✅ Session ID bir martalik va 1 soat amal qiladi
- ✅ Maxfiy ma'lumotlar shifrlangan
- ✅ Rate limiting (1 daqiqada 10 so'rov)
- ✅ Client secret hech qachon frontend'ga yuborilmaydi

### MyID Test Rejimi

Development muhitida MyID test rejimini ishlatish mumkin:

```dart
environment: MyIdEnvironment.DEBUG  // Test rejimi
```

**Eslatma:** Production'da faqat `MyIdEnvironment.PRODUCTION` ishlatiladi.

### MyID Xato Kodlari

| Kod | Ma'nosi | Harakat |
|-----|---------|---------|
| `0` | Muvaffaqiyatli | Davom etish |
| `1` | Bekor qilindi | Qayta urinish taklifi |
| `2` | Xato | Xato xabarini ko'rsatish |
| `3` | Timeout | Qayta urinish |

### MyID Hujjatlar

To'liq hujjatlar uchun qarang:
- [MyID Rasmiy Hujjatlari](https://docs.myid.uz)
- [MyID SDK GitHub](https://github.com/MyIDUz/myid-flutter-sdk)
- [GreenMarket MyID Spec](.kiro/specs/myid-integration-v2/)

## 📊 Ma'lumot Modellari

### Product (Mahsulot)

- `id`: string - Noyob identifikator
- `name`: string - Mahsulot nomi
- `price`: number - Narxi (so'm)
- `description`: string - Tavsif
- `icon`: string - Emoji belgisi
- `type`: string - Turi (meva, sabzavot, va h.k.)
- `inStock`: boolean - Mavjudligi
- `co2Absorption`: number - CO2 absorbsiyasi

### CartItem (Savatdagi Mahsulot)

- `productId`: string - Mahsulot ID
- `quantity`: number - Miqdori
- `addedAt`: timestamp - Qo'shilgan vaqt

### Order (Buyurtma)

- `orderId`: string - Buyurtma ID
- `orderNumber`: string - Buyurtma raqami
- `items`: CartItem[] - Mahsulotlar ro'yxati
- `customerInfo`: object - Mijoz ma'lumotlari
- `totalPrice`: number - Umumiy narx
- `status`: string - Holati
- `createdAt`: timestamp - Yaratilgan vaqt
- `qrCode`: string - QR kod (yetkazilgan buyurtmalar uchun)
- `certificate`: string - Sertifikat

### Filter (Filtr)

- `searchQuery`: string - Qidiruv so'rovi
- `minPrice`: number - Minimal narx
- `maxPrice`: number - Maksimal narx
- `type`: string - Mahsulot turi

## 🛠️ Xizmatlar (Services)

### CartManager

Savat operatsiyalarini boshqaradi (qo'shish, o'chirish, yangilash)

### OrderManager

Buyurtmalarni yaratish va olishni boshqaradi

### SearchManager

Mahsulotlarni qidirish va filtrlashni boshqaradi

### StorageService

LocalStorage operatsiyalarini xatoliklarni boshqarish bilan amalga oshiradi

### SecurityService

Xavfsizlik va autentifikatsiya xizmatlarini ta'minlaydi, MyID integratsiyasini boshqaradi

### MyIdBackendService

MyID backend API bilan aloqani boshqaradi (sessiya yaratish, foydalanuvchi ma'lumotlarini olish)

### ApiService

Backend API bilan aloqani boshqaradi

### VersionService

Ilova versiyalarini kuzatish va yangilash

## 🌟 Asosiy Funksiyalar

### Web Platform

- ✅ Mahsulotlar katalogi
- ✅ Qidiruv va filtrlash
- ✅ Savat tizimi
- ✅ Buyurtma berish
- ✅ Ko'p tillilik (O'zbek, Rus, Ingliz)
- ✅ Responsive dizayn
- ✅ Dark mode

### Mobil Ilova

- ✅ AI bog'bon maslahatchi
- ✅ MyID autentifikatsiya (pasport va yuz tanish)
- ✅ Push bildirishnomalar
- ✅ Offline rejim
- ✅ Buyurtmalar tarixi
- ✅ QR kod skanerlash
- ✅ Xarita integratsiyasi
- ✅ To'lov tizimlari
- ✅ Ko'p tillilik (O'zbek, Rus, Ingliz)

## 📈 Statistika

- 👥 **10,000+** Faol foydalanuvchilar
- 🌾 **500+** Ro'yxatdan o'tgan fermerlar
- 📦 **50,000+** Yetkazilgan buyurtmalar
- ⭐ **4.8/5** O'rtacha reyting
- 🌍 **15+** Shaharlar

## 🤝 Hissa Qo'shish

Loyihaga hissa qo'shishni xohlaysizmi? Biz har doim yangi g'oyalar va yaxshilanishlarga ochiqmiz!

1. Repository'ni fork qiling
2. Yangi branch yarating (`git checkout -b feature/AjoyibXususiyat`)
3. O'zgarishlaringizni commit qiling (`git commit -m 'Ajoyib xususiyat qo'shildi'`)
4. Branch'ni push qiling (`git push origin feature/AjoyibXususiyat`)
5. Pull Request oching

## 📝 Litsenziya

Bu loyiha MIT litsenziyasi ostida tarqatiladi.

## 📞 Aloqa

- 🌐 Website: [eco-zamin.vercel.app](https://eco-zamin.vercel.app)
- 📧 Email: [support@greenmarket.uz](mailto:support@greenmarket.uz)
- 📱 Telegram: [@greenmarket_uz](https://t.me/greenmarket_uz)
- 🐙 GitHub: [@sardorbekuzb17-cpu](https://github.com/sardorbekuzb17-cpu)

## 🙏 Minnatdorchilik

Ushbu loyihani amalga oshirishda yordam bergan barcha fermerlar, dasturchilar va foydalanuvchilarga katta rahmat!

---

🌱 Birgalikda yashilroq kelajak quramiz! 🌱

Made with 💚 in Uzbekistan
