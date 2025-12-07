# Design Document: Green Shop (Yasjil Dokon)

## Overview

GreenMarket platformasiga to'liq funksional e-commerce qobiliyatlarini qo'shish. Ushbu dizayn hozirgi statik katalogni interaktiv onlayn do'konga aylantiradi, bu yerda foydalanuvchilar mahsulotlarni savatga qo'shish, buyurtma berish, to'lov qilish va buyurtmalarni kuzatish imkoniyatiga ega bo'ladilar.

Dizayn client-side JavaScript yordamida amalga oshiriladi, localStorage dan ma'lumotlarni saqlash uchun foydalaniladi va hozirgi GreenMarket.html fayliga minimal o'zgarishlar kiritiladi.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    GreenMarket UI                        │
│  (Hozirgi HTML + Yangi Shop Components)                 │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│              Shop Module (JavaScript)                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │  Cart    │  │  Order   │  │  Search  │              │
│  │ Manager  │  │ Manager  │  │ Manager  │              │
│  └──────────┘  └──────────┘  └──────────┘              │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│              Storage Layer                               │
│         (localStorage + SessionStorage)                  │
└─────────────────────────────────────────────────────────┘
```

### Component Breakdown

1. **Cart Manager**: Savat operatsiyalarini boshqaradi (qo'shish, o'chirish, yangilash)
2. **Order Manager**: Buyurtmalarni yaratish va kuzatish
3. **Search Manager**: Mahsulotlarni qidirish va filtrlash
4. **Payment Handler**: To'lov jarayonini simulyatsiya qilish
5. **Storage Service**: localStorage bilan ishlash uchun abstraksiya

## Components and Interfaces

### 1. Cart Manager

**Mas'uliyat**: Savat holatini boshqarish va localStorage bilan sinxronlashtirish

```javascript
class CartManager {
  constructor()
  addItem(productId, quantity)
  removeItem(productId)
  updateQuantity(productId, quantity)
  getItems()
  getTotalPrice()
  clear()
  getItemCount()
}
```

**Key Methods**:
- `addItem`: Mahsulotni savatga qo'shadi yoki miqdorini oshiradi
- `removeItem`: Mahsulotni savatdan olib tashlaydi
- `updateQuantity`: Mahsulot miqdorini yangilaydi
- `getTotalPrice`: Savatdagi barcha mahsulotlarning umumiy narxini hisoblaydi

### 2. Order Manager

**Mas'uliyat**: Buyurtmalarni yaratish, saqlash va olish

```javascript
class OrderManager {
  constructor()
  createOrder(customerInfo, cartItems)
  getOrders()
  getOrderById(orderId)
  updateOrderStatus(orderId, status)
  generateOrderNumber()
}
```

**Key Methods**:
- `createOrder`: Yangi buyurtma yaratadi va localStorage ga saqlaydi
- `getOrders`: Barcha buyurtmalarni qaytaradi
- `generateOrderNumber`: Noyob buyurtma raqamini yaratadi

### 3. Search Manager

**Mas'uliyat**: Mahsulotlarni qidirish va filtrlash

```javascript
class SearchManager {
  constructor(products)
  search(query)
  filterByPrice(minPrice, maxPrice)
  filterByType(type)
  applyFilters(filters)
  clearFilters()
}
```

**Key Methods**:
- `search`: Mahsulot nomiga ko'ra qidiradi
- `filterByPrice`: Narx oralig'i bo'yicha filtrlaydi
- `filterByType`: Mahsulot turi bo'yicha filtrlaydi

### 4. UI Components

**Cart Modal**: Savat tarkibini ko'rsatuvchi modal oyna
**Checkout Form**: Buyurtma berish formasi
**Order History**: Buyurtmalar tarixi sahifasi
**Product Card**: Mahsulot kartochkasi (yangilangan)

## Data Models

### Product

```javascript
{
  id: string,           // Noyob identifikator
  name: string,         // Mahsulot nomi
  price: number,        // Narx (so'm)
  description: string,  // Tavsif
  icon: string,         // Unicode emoji
  type: string,         // Tur (daraxt, buta, meva)
  inStock: boolean,     // Omborda mavjudligi
  co2Absorption: number // Yillik CO₂ yutish (kg)
}
```

### CartItem

```javascript
{
  productId: string,    // Mahsulot ID
  quantity: number,     // Miqdor
  addedAt: timestamp    // Qo'shilgan vaqt
}
```

### Order

```javascript
{
  orderId: string,           // Noyob buyurtma raqami
  orderNumber: string,       // Foydalanuvchi ko'radigan raqam
  items: CartItem[],         // Buyurtma mahsulotlari
  customerInfo: {
    name: string,
    phone: string,
    address: string,
    email: string
  },
  totalPrice: number,        // Umumiy narx
  status: string,            // Holat (pending, confirmed, delivered)
  createdAt: timestamp,      // Yaratilgan vaqt
  qrCode: string,           // QR-kod (delivered holatida)
  certificate: string       // Sertifikat (delivered holatida)
}
```

### Filter

```javascript
{
  searchQuery: string,       // Qidiruv so'zi
  minPrice: number,          // Minimal narx
  maxPrice: number,          // Maksimal narx
  type: string              // Mahsulot turi
}
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Adding products increases cart count

*For any* product and cart state, adding a product to the cart should increase the cart item count and the product should appear in the cart items list.

**Validates: Requirements 1.1**

### Property 2: Adding same product increases quantity

*For any* product, adding it to the cart multiple times should increase its quantity in the cart rather than creating duplicate entries.

**Validates: Requirements 1.2**

### Property 3: Cart displays all added items

*For any* cart state with items, opening the cart modal should display all items that exist in the cart state.

**Validates: Requirements 1.3**

### Property 4: Quantity changes update total price correctly

*For any* cart item, changing its quantity should result in the total price being recalculated as the sum of (quantity × price) for all items in the cart.

**Validates: Requirements 1.5, 2.1**

### Property 5: Removing items from cart

*For any* product in the cart, removing it should result in the product no longer appearing in the cart items list and the cart count decreasing.

**Validates: Requirements 2.3**

### Property 6: Cart persistence round-trip

*For any* cart state, saving to localStorage and then loading from localStorage should result in an equivalent cart state with the same items, quantities, and total price.

**Validates: Requirements 2.4, 2.5**

### Property 7: Form validation rejects invalid inputs

*For any* form field with validation rules, submitting invalid data (empty fields, invalid phone numbers, invalid email) should result in an error message and prevent form submission.

**Validates: Requirements 3.2, 3.3, 3.4, 4.3**

### Property 8: Valid form submission proceeds to next step

*For any* checkout form with all valid data, submitting the form should proceed to the payment page without errors.

**Validates: Requirements 3.5**

### Property 9: Successful payment creates order

*For any* valid payment, completing the payment should create an order with a unique order number, save it to storage, and display a confirmation page.

**Validates: Requirements 4.4**

### Property 10: Order history displays all orders

*For any* set of created orders, the order history page should display all orders that exist in storage.

**Validates: Requirements 5.1**

### Property 11: Order details contain complete information

*For any* order, viewing its details should display all required information including product list, total price, delivery address, and customer information.

**Validates: Requirements 5.3, 5.4**

### Property 12: Delivered orders have QR code and certificate

*For any* order with status "delivered", the order details should include a QR code and digital certificate.

**Validates: Requirements 5.5**

### Property 13: Search returns matching products

*For any* search query, all returned products should have names that contain the search query (case-insensitive).

**Validates: Requirements 6.1**

### Property 14: Price filter returns products in range

*For any* price range filter (minPrice, maxPrice), all returned products should have prices within that range (inclusive).

**Validates: Requirements 6.3**

### Property 15: Type filter returns matching products

*For any* product type filter, all returned products should have a type that matches the selected filter.

**Validates: Requirements 6.4**

### Property 16: Clearing filters returns all products

*For any* filtered product list, clearing all filters should return the complete original product list.

**Validates: Requirements 6.5**

### Property 17: Product CRUD operations persist

*For any* product, adding it to the catalog should make it appear in the product list, updating it should reflect changes immediately, and deleting it should remove it from the list.

**Validates: Requirements 7.1, 7.2, 7.3**

### Property 18: Out-of-stock products cannot be purchased

*For any* product with inStock = false, attempting to add it to the cart should be prevented and show an appropriate message.

**Validates: Requirements 7.4**

### Property 19: Product images persist and display

*For any* product with an uploaded image, the image should be saved and displayed on the product card.

**Validates: Requirements 7.5**

### Property 20: Mobile payment methods available

*For any* payment page on mobile, the available payment methods should include mobile-specific options.

**Validates: Requirements 8.4**

## Error Handling

### Cart Errors

1. **Invalid Product ID**: Agar mavjud bo'lmagan mahsulot ID bilan savat operatsiyasi bajarilsa, xato qaytariladi va savat holati o'zgarmaydi
2. **Invalid Quantity**: Manfiy yoki nol miqdor bilan yangilash urinishi xato qaytaradi
3. **Storage Quota Exceeded**: localStorage to'lgan bo'lsa, foydalanuvchiga xabar ko'rsatiladi va eski ma'lumotlarni tozalash taklif qilinadi

### Order Errors

1. **Validation Errors**: Forma validatsiyasi muvaffaqiyatsiz bo'lsa, aniq xato xabarlari ko'rsatiladi
2. **Payment Failure**: To'lov muvaffaqiyatsiz bo'lsa, xato sababi ko'rsatiladi va qayta urinish imkoniyati beriladi
3. **Order Not Found**: Mavjud bo'lmagan buyurtma ID bilan so'rov yuborilsa, 404 xato qaytariladi

### Search Errors

1. **Empty Results**: Qidiruv natijalari topilmasa, "Natija topilmadi" xabari ko'rsatiladi
2. **Invalid Filter Values**: Noto'g'ri filtr qiymatlari (masalan, minPrice > maxPrice) xato qaytaradi

### Admin Errors

1. **Duplicate Product ID**: Mavjud ID bilan yangi mahsulot qo'shish urinishi xato qaytaradi
2. **Invalid Product Data**: Majburiy maydonlar bo'sh bo'lsa, validatsiya xatosi qaytariladi
3. **Image Upload Failure**: Rasm yuklash muvaffaqiyatsiz bo'lsa, xato xabari ko'rsatiladi

## Testing Strategy

### Unit Testing

Biz Jest test framework dan foydalanamiz. Unit testlar quyidagi komponentlarni qamrab oladi:

**Cart Manager Tests**:
- Mahsulot qo'shish funksiyasi
- Mahsulot o'chirish funksiyasi
- Miqdorni yangilash funksiyasi
- Umumiy narxni hisoblash funksiyasi
- Edge cases: bo'sh savat, noto'g'ri ID, manfiy miqdor

**Order Manager Tests**:
- Buyurtma yaratish funksiyasi
- Buyurtma raqami generatsiyasi (noyoblik)
- Buyurtma holatini yangilash
- Edge cases: bo'sh savat bilan buyurtma, noto'g'ri buyurtma ID

**Search Manager Tests**:
- Qidiruv funksiyasi (turli so'zlar bilan)
- Narx filtri (turli oraliqlar bilan)
- Tur filtri (turli turlar bilan)
- Filtrlarni tozalash
- Edge cases: bo'sh qidiruv, natija topilmagan holat

**Storage Service Tests**:
- Ma'lumotlarni saqlash va olish
- Serialization/deserialization
- Edge cases: localStorage to'lgan holat, noto'g'ri JSON

### Property-Based Testing

Biz **fast-check** kutubxonasidan foydalanamiz. Har bir property-based test kamida **100 iteratsiya** bilan ishga tushiriladi.

**Property Test Requirements**:
- Har bir property-based test dizayn hujjatidagi aniq propertyga havola qilishi kerak
- Tag formati: `**Feature: green-shop, Property {number}: {property_text}**`
- Har bir correctness property BITTA property-based test bilan amalga oshirilishi kerak

**Property Tests**:

1. **Cart Operations Properties**:
   - Property 1: Adding products increases cart count
   - Property 2: Adding same product increases quantity
   - Property 4: Quantity changes update total price correctly
   - Property 5: Removing items from cart
   - Property 6: Cart persistence round-trip

2. **Order Properties**:
   - Property 9: Successful payment creates order
   - Property 10: Order history displays all orders
   - Property 11: Order details contain complete information
   - Property 12: Delivered orders have QR code and certificate

3. **Search and Filter Properties**:
   - Property 13: Search returns matching products
   - Property 14: Price filter returns products in range
   - Property 15: Type filter returns matching products
   - Property 16: Clearing filters returns all products

4. **Validation Properties**:
   - Property 7: Form validation rejects invalid inputs
   - Property 8: Valid form submission proceeds to next step

5. **Admin Properties**:
   - Property 17: Product CRUD operations persist
   - Property 18: Out-of-stock products cannot be purchased
   - Property 19: Product images persist and display

**Generator Strategy**:
- Product generator: tasodifiy ID, nom, narx, tur yaratadi
- Cart state generator: tasodifiy mahsulotlar va miqdorlar bilan savat yaratadi
- Customer info generator: to'g'ri va noto'g'ri ma'lumotlar yaratadi
- Order generator: tasodifiy buyurtmalar yaratadi

### Integration Testing

Integration testlar quyidagi oqimlarni tekshiradi:

1. **Complete Purchase Flow**: Mahsulot tanlash → Savatga qo'shish → Buyurtma berish → To'lov → Tasdiqlash
2. **Search and Purchase Flow**: Qidiruv → Filtrlash → Mahsulot tanlash → Xarid qilish
3. **Order History Flow**: Buyurtma yaratish → Buyurtmalar sahifasini ochish → Tafsilotlarni ko'rish
4. **Admin Flow**: Mahsulot qo'shish → Tahrirlash → O'chirish

### End-to-End Testing

E2E testlar uchun Playwright dan foydalanamiz:

1. Foydalanuvchi butun xarid jarayonini yakunlaydi
2. Mobil qurilmada responsiv interfeys ishlaydi
3. Sahifa yangilanganidan keyin savat saqlanadi
4. Buyurtmalar tarixi to'g'ri ko'rsatiladi

## Implementation Notes

### localStorage Structure

```javascript
{
  "greenmarket_cart": {
    "items": [...],
    "lastUpdated": timestamp
  },
  "greenmarket_orders": [...],
  "greenmarket_products": [...],
  "greenmarket_user": {...}
}
```

### Performance Considerations

1. **Debouncing**: Qidiruv maydoniga kiritish 300ms debounce bilan amalga oshiriladi
2. **Lazy Loading**: Mahsulot rasmlari lazy loading bilan yuklanadi
3. **Caching**: Mahsulotlar ro'yxati sessionStorage da keshlanadi
4. **Pagination**: Agar mahsulotlar soni 50 dan oshsa, pagination qo'llaniladi

### Security Considerations

1. **Input Sanitization**: Barcha foydalanuvchi kiritmalari sanitize qilinadi
2. **XSS Prevention**: innerHTML o'rniga textContent ishlatiladi
3. **Data Validation**: Client-side va server-side (kelajakda) validatsiya
4. **Payment Security**: To'lov ma'lumotlari localStorage da saqlanmaydi

### Accessibility

1. **Keyboard Navigation**: Barcha interaktiv elementlar klaviatura bilan boshqariladi
2. **ARIA Labels**: Screen reader lar uchun tegishli ARIA atributlari qo'shiladi
3. **Focus Management**: Modal oynalar ochilganda fokus to'g'ri boshqariladi
4. **Color Contrast**: WCAG AA standartlariga muvofiq rang kontrastlari

### Future Enhancements

1. **Backend Integration**: Hozirda client-side only, kelajakda backend API qo'shiladi
2. **Real Payment Gateway**: Haqiqiy to'lov tizimi integratsiyasi
3. **User Authentication**: Foydalanuvchi autentifikatsiyasi va profil boshqaruvi
4. **Push Notifications**: Buyurtma holati o'zgarganda bildirishnomalar
5. **Analytics**: Foydalanuvchi xatti-harakatlari va konversiya tahlili
