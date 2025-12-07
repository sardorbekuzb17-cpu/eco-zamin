# GreenMarket Library

Tez va optimallashtirilgan JavaScript kutubxonasi e-commerce loyihalar uchun.

## O'rnatish

### NPM orqali (kelajakda)

```bash
npm install greenmarket-lib
```

### CDN orqali

```html
<script src="https://cdn.example.com/greenmarket-lib.min.js"></script>
```

### Lokal fayldan

```html
<script type="module" src="./src/GreenMarketLib.js"></script>
```

## Ishlatish

### Asosiy ishlatish

```javascript
// Kutubxonani import qilish
import GreenMarket from './src/GreenMarketLib.js';

// Initsializatsiya
const shop = new GreenMarket({
    storagePrefix: 'myshop',
    language: 'uz',
    enableCache: true,
    enableLazyLoad: true
});

// Mahsulotlarni olish
const products = shop.products.getAllProducts();

// Qidirish (debounce bilan)
shop.searchProducts('olma', (results) => {
    console.log('Topilgan mahsulotlar:', results);
});

// Savatga qo'shish
await shop.addToCart('product-id', 2);

// Buyurtma berish
const order = await shop.createOrder(
    { name: 'Ali', phone: '+998200000000', address: 'Toshkent', email: 'ali@example.com' },
    'card',
    { cardNumber: '1234567890123456', cardHolder: 'Ali Valiyev', expiryDate: '12/25', cvv: '123' }
);
```

### Lazy Loading

```javascript
// Rasmlarni lazy load qilish
// HTML da:
<img data-src="image.jpg" alt="Rasm" class="lazy">

// JavaScript da:
shop.lazyLoader.observeImages();
```

### Event Delegation

```javascript
// Event delegation orqali click event
shop.on(document.body, 'click', '.add-to-cart-btn', function(event) {
    const productId = this.dataset.productId;
    shop.addToCart(productId, 1);
});
```

### Virtual Scrolling

```javascript
// Katta ro'yxatlar uchun
const scroller = shop.createVirtualScroller(
    document.getElementById('product-list'),
    {
        itemHeight: 100,
        bufferSize: 5,
        renderItem: (product) => {
            const div = document.createElement('div');
            div.innerHTML = `<h3>${product.name}</h3><p>${product.price}</p>`;
            return div;
        }
    }
);

scroller.setItems(products);
```

### Tilni o'zgartirish

```javascript
// Tilni o'zgartirish
shop.changeLanguage('en'); // 'uz', 'ru', 'en'

// Tarjima olish
const translation = shop.i18n.t('header.home');
```

## API Reference

### GreenMarket Class

#### Constructor

```javascript
new GreenMarket(config)
```

**Config parametrlari:**

- `storagePrefix` (string): LocalStorage uchun prefix. Default: 'greenmarket'
- `language` (string): Boshlang'ich til. Default: 'uz'
- `enableCache` (boolean): Keshni yoqish. Default: true
- `enableLazyLoad` (boolean): Lazy loading ni yoqish. Default: true

#### Methods

##### `searchProducts(query, callback, delay)`

Mahsulotlarni qidirish (debounce bilan)

##### `applyFilters(filters, callback, delay)`

Filtrlarni qo'llash (debounce bilan)

##### `addToCart(productId, quantity)`

Savatga mahsulot qo'shish

##### `createOrder(customerInfo, paymentMethod, paymentDetails)`

Buyurtma yaratish

##### `changeLanguage(lang)`

Tilni o'zgartirish

##### `on(container, eventType, selector, handler)`

Event delegation orqali event qo'shish

##### `createVirtualScroller(container, options)`

Virtual scroller yaratish

##### `getStats()`

Statistika olish

##### `destroy()`

Kutubxonani tozalash

## Performance Optimizations

### 1. Lazy Loading

- Rasmlar faqat ko'rinishga kelganda yuklanadi
- 50px oldindan yuklash (rootMargin)

### 2. Debouncing

- Qidiruv: 300ms
- Filtr: 200ms

### 3. Caching

- Mahsulotlar keshi: 5 daqiqa
- SessionStorage orqali tez kirish

### 4. Event Delegation

- Bitta listener ko'p elementlar uchun
- Memory leak oldini olish

### 5. Virtual Scrolling

- Faqat ko'rinadigan elementlar render qilinadi
- Katta ro'yxatlar uchun ideal

## Browser Support

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Misollar

### To'liq misol

```javascript
import GreenMarket from './src/GreenMarketLib.js';

// Initsializatsiya
const shop = new GreenMarket({
    language: 'uz',
    enableCache: true
});

// Mahsulotlarni ko'rsatish
function renderProducts(products) {
    const container = document.getElementById('products');
    container.innerHTML = products.map(p => `
        <div class="product" data-product-id="${p.id}">
            <img data-src="${p.image}" alt="${p.name}" class="lazy">
            <h3>${p.name}</h3>
            <p>${p.price} so'm</p>
            <button class="add-to-cart-btn">Savatga</button>
        </div>
    `).join('');
    
    // Lazy loading
    shop.lazyLoader.observeImages();
}

// Qidiruv
const searchInput = document.getElementById('search');
searchInput.addEventListener('input', (e) => {
    shop.searchProducts(e.target.value, renderProducts);
});

// Savatga qo'shish
shop.on(document.body, 'click', '.add-to-cart-btn', async function() {
    const productId = this.closest('.product').dataset.productId;
    await shop.addToCart(productId, 1);
});

// Dastlabki render
renderProducts(shop.products.getAllProducts());
```

## Litsenziya

MIT

## Muallif

GreenMarket Team
