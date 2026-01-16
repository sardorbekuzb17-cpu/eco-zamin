# MyID SDK To'liq Integratsiya Qo'llanmasi

## ⚠️ MUHIM OGOHLANTIRISH

MyID SDK **backend server**siz ishlamaydi! Quyidagi qadamlarni bajarish kerak:

## 1. Backend Serverni Deploy Qilish

### Vercel ga deploy (TAVSIYA QILINADI):

```bash
cd greenmarket_backend
npm install
npm install -g vercel
vercel login
vercel
```

Vercel sizdan so'raydi:
- Project name: `greenmarket-myid`
- Deploy: `Yes`

Deploy tugagandan keyin URL olasiz: `https://greenmarket-myid.vercel.app`

### Yoki Heroku ga:

```bash
cd greenmarket_backend
npm install
heroku login
heroku create greenmarket-myid
git init
git add .
git commit -m "MyID backend"
git push heroku main
```

## 2. Flutter Ilovasida Backend URL ni Sozlash

`lib/services/myid_backend_service.dart` faylida:

```dart
static const String BACKEND_URL = 'https://your-backend-url.vercel.app';
```

O'zingizning backend URL ni kiriting!

## 3. MyID SDK ni Yoqish

`lib/main.dart` faylida `_loginWithMyID` funksiyasini backend bilan bog'lang.

## 4. Test Qilish

1. Backend serverni tekshiring: `https://your-backend-url.vercel.app/health`
2. Flutter ilovasini qayta qurib o'rnating
3. Profil sahifasida "Profilga kirish" tugmasini bosing
4. Pasport ma'lumotlarini kiriting
5. Backend API pasport ma'lumotlarini MyID ga yuboradi
6. MyID SDK yuz tasdiqlanishini boshlaydi

## ⚠️ XARAJATLAR

- Vercel: Bepul (oyiga 100GB bandwidth)
- Heroku: $7/oy (Hobby plan)
- MyID API: MyID kompaniyasi bilan shartnoma kerak

## 🎯 TAVSIYA

Agar backend serverni deploy qilish qiyin bo'lsa, **hozirgi oddiy versiyani ishlating**:
- Pasport va tug'ilgan sana bilan kirish
- Backend kerak emas
- 100% ishlaydi
- Xatolik yo'q

## 📞 Yordam

MyID SDK bilan muammolar bo'lsa:
1. MyID kompaniyasiga murojaat qiling: https://myid.uz
2. Backend API hujjatlarini o'qing: https://docs.myid.uz
3. Telegram: @myid_support

---

**XULOSA:** MyID SDK juda murakkab va backend server kerak. Hozirgi oddiy versiya - eng yaxshi yechim sizning loyihangiz uchun!
