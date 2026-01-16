# GreenMarket Versiya Yangilash Qo'llanmasi

## Qisqa yo'l (Avtomatik)

Faqat 2 ta qadam:

### 1. Versiyani ko'tarish

`pubspec.yaml` faylida versiyani yangilang:

```yaml
version: 1.0.1+2  # 1.0.0+1 dan 1.0.1+2 ga
```

Format: `MAJOR.MINOR.PATCH+BUILD_NUMBER`

- `1.0.1` - versiya raqami (foydalanuvchilarga ko'rinadi)
- `2` - build raqami (har safar +1 qiling)

### 2. Scriptni ishga tushirish

PowerShell da:

```powershell
cd greenmarket_app
.\update_version.ps1
```

Bu script avtomatik ravishda:

- ✅ `version.js` API faylini yangilaydi
- ✅ Version API ni Vercel ga deploy qiladi
- ✅ AAB faylini build qiladi
- ✅ Hamma tayyor!

## Qo'lda yangilash (agar kerak bo'lsa)

### 1. pubspec.yaml ni tahrirlash

`pubspec.yaml` da versiyani yangilang

### 2. Version API ni yangilash

```powershell
cd greenmarket_app/scripts
dart run sync_version.dart
```

### 3. API ni deploy qilish

```powershell
cd greenmarket_api
vercel --prod
```

### 4. AAB build qilish

```powershell
cd greenmarket_app
flutter build appbundle --release
```

## Versiya strategiyasi

- **Kichik o'zgarishlar** (bug fix): `1.0.0+1` → `1.0.1+2`
- **Yangi funksiyalar**: `1.0.0+1` → `1.1.0+2`
- **Katta o'zgarishlar**: `1.0.0+1` → `2.0.0+2`

## Majburiy yangilanishni boshqarish

`greenmarket_api/api/version.js` da:

```javascript
isForceUpdate: true,  // Majburiy yangilanish
isForceUpdate: false, // Ixtiyoriy yangilanish
```

## Fayllar

- `pubspec.yaml` - Asosiy versiya manbai
- `scripts/sync_version.dart` - Versiyani sinxronlashtirish
- `update_version.ps1` - Avtomatik yangilash scripti
- `greenmarket_api/api/version.js` - Version API
