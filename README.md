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

**Backend & Services:**

- RESTful API
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
│   └── greenmarket_backend/    # Backend xizmatlari
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

### O'rnatish

```bash
# Repository'ni klonlash
git clone https://github.com/sardorbekuzb17-cpu/eco-zamin.git
cd eco-zamin

# Bog'liqliklarni o'rnatish
npm install
```

### Ishga Tushirish

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
# Barcha testlarni ishga tushirish
npm test

# Watch rejimida testlar
npm run test:watch

# Coverage bilan testlar
npm run test:coverage
```

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

Xavfsizlik va autentifikatsiya xizmatlarini ta'minlaydi

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
- ✅ Push bildirishnomalar
- ✅ Offline rejim
- ✅ Buyurtmalar tarixi
- ✅ QR kod skanerlash
- ✅ Xarita integratsiyasi
- ✅ To'lov tizimlari

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
