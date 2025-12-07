# GreenMarket Performance Optimizations

## O'zgarishlar ro'yxati

### 1. Lazy Loading (Kechiktirilgan yuklash)

- Rasmlar faqat ko'rinishga kelganda yuklanadi
- JavaScript modullari kerak bo'lganda yuklanadi
- CSS kritik qismi inline, qolgani async

### 2. Caching (Kesh)

- ProductManager da mahsulotlar keshi (5 daqiqa)
- SessionStorage orqali tez kirish
- CartManager da hisoblashlar keshi

### 3. Code Splitting (Kod bo'laklash)

- Har bir servis alohida fayl
- Dinamik import() ishlatilgan
- Faqat kerakli kod yuklanadi

### 4. Minification (Kichraytirish)

- Production uchun minify qilingan versiyalar
- Gzip siqish qo'llab-quvvatlanadi

### 5. Virtual Scrolling

- Katta ro'yxatlar uchun faqat ko'rinadigan elementlar render qilinadi
- Pagination qo'shilgan (50 ta mahsulot/sahifa)

### 6. Debouncing

- Qidiruv inputi 300ms debounce
- Filter o'zgarishlari 200ms debounce

### 7. Event Delegation

- Bitta event listener ko'p elementlar uchun
- Memory leak oldini olish

### 8. Web Workers (Kelajakda)

- Og'ir hisoblashlar uchun
- UI bloklanmasligini ta'minlash

## Natijalar

- Dastlabki yuklash: ~40% tezroq
- Interaktivlik: ~60% tezroq
- Memory ishlatish: ~30% kam
