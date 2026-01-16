# Maxfiylik Siyosatini Joylashtirish

## Variant 1: GitHub Pages (Tavsiya etiladi - Bepul)

1. GitHub da yangi repository yarating: `greenmarket-privacy`
2. `privacy-policy.html` faylini repository ga yuklang
3. Repository Settings > Pages ga o'ting
4. Source: `main` branch ni tanlang
5. Save bosing
6. URL: `https://[username].github.io/greenmarket-privacy/privacy-policy.html`

## Variant 2: Vercel (Bepul va tez)

```bash
# Yangi papka yarating
mkdir greenmarket-privacy
cd greenmarket-privacy

# privacy-policy.html ni ko'chiring
copy ..\privacy-policy.html index.html

# Vercel ga deploy qiling
vercel --prod
```

URL: `https://greenmarket-privacy.vercel.app`

## Variant 3: Firebase Hosting (Bepul)

```bash
# Firebase CLI o'rnating
npm install -g firebase-tools

# Login qiling
firebase login

# Loyiha yarating
firebase init hosting

# Deploy qiling
firebase deploy --only hosting
```

## Google Play Console ga qo'shish

1. Google Play Console ga kiring
2. GreenMarket ilovangizni tanlang
3. "App content" > "Privacy policy" ga o'ting
4. Yuqoridagi URL lardan birini kiriting
5. Save qiling

## Muhim eslatmalar

- URL albatta HTTPS bo'lishi kerak
- Sahifa 24/7 ochiq bo'lishi kerak
- Email manzilni o'zingiznikiga o'zgartiring: `support@greenmarket.uz`
- Agar kompaniya manzili bo'lsa, to'liq manzilni kiriting

## Qo'shimcha ma'lumotlar

Maxfiylik siyosati quyidagilarni o'z ichiga oladi:
- ✅ O'zbek va Ingliz tillarida
- ✅ Google Play talablariga mos
- ✅ Bolalar maxfiyligi (13 yosh)
- ✅ AdMob reklama siyosati
- ✅ Ma'lumotlar xavfsizligi
- ✅ Foydalanuvchi huquqlari
- ✅ Aloqa ma'lumotlari
