# Implementatsiya Rejasi: MyID Integratsiyasi

## Umumiy Ko'rinish

Ushbu implementatsiya rejasi MyID integratsiyasini GreenMarket platformasiga qo'shish uchun ketma-ket vazifalarni belgilaydi. Har bir vazifa oldingi vazifalar asosida quriladi va kod yozish, o'zgartirish yoki test qilish bilan bog'liq.

## Bajarilgan Vazifalar

- [x] 1. Backend asosiy tuzilmasini sozlash
  - MyID SDK flow moduli yaratildi (`myid_sdk_flow.js`)
  - Express API endpointlari sozlandi (`index.js`)
  - Environment variables konfiguratsiyasi sozlandi
  - _Requirements: 1.1, 5.2_

- [x] 1.1. Backend asosiy tuzilmasi uchun unit testlar yozish
  - Express server ishga tushishi testi yozildi
  - Environment variables yuklash testi yozildi
  - _Requirements: 10.1_

- [x] 1.2. MyID OAuth token boshqaruvini amalga oshirish
  - getAccessToken funksiyasi yozildi
  - Token olish va qaytarish mexanizmi ishlayapti
  - _Requirements: 1.1, 1.2_

- [x] 1.3. Sessiya boshqaruvini amalga oshirish
  - createSession funksiyasi yozildi (bo'sh va pasport bilan)
  - Session ID qaytarish mexanizmi ishlayapti
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 1.4. Foydalanuvchi ma'lumotlarini olish
  - retrieveUserData funksiyasi yozildi
  - Ma'lumotlarni saqlash mexanizmi ishlayapti
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 1.5. Express API endpointlarini yaratish
  - POST /api/myid/create-session endpoint yaratildi
  - POST /api/myid/sdk/get-user-data endpoint yaratildi
  - GET /api/users endpoint yaratildi
  - _Requirements: 9.1, 9.2, 9.5, 9.6, 9.7_

- [x] 1.6. Flutter MyID Backend Service yaratish
  - MyIdBackendService klassi yaratildi
  - Barcha metodlar amalga oshirildi
  - _Requirements: 2.1, 2.2, 4.1_

- [x] 1.7. MyID login ekranlarini yaratish
  - MyIdMainLoginScreen yaratildi
  - MyIdLoginScreenV2 yaratildi
  - _Requirements: 8.1, 8.2_

- [x] 1.8. MyID SDK integratsiyasini qo'shish
  - SDK konfiguratsiyasi sozlandi
  - SDK ishga tushirish funksiyasi yozildi
  - _Requirements: 3.1, 3.4_

## Qolgan Vazifalar

### Backend Yaxshilashlar

- [ ] 2. Token saqlash va qayta ishlatish mexanizmini qo'shish
  - [x] 2.1. Token cache mexanizmini yaratish
    - Token'ni xotirada saqlash (in-memory cache yoki Redis)
    - Token muddatini tekshirish
    - Muddati tugagan tokenni avtomatik yangilash
    - _Requirements: 1.3, 1.5_
  
  - [x] 2.2. Token saqlash uchun unit testlar yozish

    - Token saqlash va olish testini yozish
    - Token muddati tugashi testini yozish
    - Avtomatik yangilanish testini yozish
    - _Requirements: 1.3, 1.5_
  
  - [x] 2.3. OAuth token uchun property test yozish




    - **Property 1: OAuth Token Olish va Saqlash**
    - **Validates: Requirements 1.1, 1.2, 1.3, 1.5**

- [ ] 3. Xato boshqaruvini qo'shish
  - [x] 3.1. Xato handler middleware yaratish
    - Barcha xatolarni ushlash
    - Xato tafsilotlarini log qilish
    - Tushunarli xato xabarlarini qaytarish
    - To'g'ri HTTP status kodlarini ishlatish (400, 401, 500)
    - _Requirements: 1.4, 2.6, 6.5, 6.6_
  
  - [x] 3.2. Qayta urinish mexanizmini qo'shish
    - Eksponensial backoff algoritmi
    - Maksimal 3 marta qayta urinish
    - Timeout xatolarini boshqarish
    - _Requirements: 6.2_
  
  - [ ]* 3.3. Xato boshqaruvi uchun property testlar yozish
    - **Property 4: Xato Holatlarini Boshqarish**
    - **Validates: Requirements 1.4, 2.6, 6.1, 6.5, 6.6**
    - **Property 9: Qayta Urinish Mexanizmi**
    - **Validates: Requirements 6.2**

- [ ] 4. Xavfsizlik funksiyalarini qo'shish
  - [x] 4.1. HTTPS protokolini majburiy qilish
    - Barcha MyID API so'rovlari HTTPS orqali (allaqachon amalga oshirilgan, tekshirish kerak)
    - URL validatsiyasi (https:// bilan boshlanishi kerak)
    - _Requirements: 5.1_
  
  - [x] 4.2. Maxfiy ma'lumotlarni himoya qilish
    - client_secret'ni API javoblarida yo'q qilish (tekshirish kerak)
    - Pasport va PINFL'ni shifrlash (AES-256)
    - Ma'lumotlar bazasida shifrlangan formatda saqlash
    - _Requirements: 5.3, 5.4_
  
  - [x] 4.3. Rate limiting qo'shish
    - express-rate-limit middleware qo'shish
    - 1 daqiqada maksimal 10 so'rov
    - 429 status kodi qaytarish
    - _Requirements: 5.8_
  
  - [ ]* 4.4. Xavfsizlik uchun property testlar yozish
    - **Property 6: HTTPS Protokoli**
    - **Validates: Requirements 5.1**
    - **Property 7: Maxfiy Ma'lumotlarni Himoya Qilish**
    - **Validates: Requirements 5.3, 5.4**
    - **Property 8: Rate Limiting**
    - **Validates: Requirements 5.8**

- [ ] 5. Backend property testlarini yozish
  - [ ]* 5.1. Sessiya yaratish uchun property testlar yozish
    - **Property 2: Sessiya Yaratish Parametrlari**
    - **Validates: Requirements 2.3, 2.4**
    - **Property 3: Sessiya Yaratish Javob Formati**
    - **Validates: Requirements 2.2, 2.5**
    - **Property 21: Bo'sh Sessiya Yaratish**
    - **Validates: Requirements 2.1, 2.2**
  
  - [ ]* 5.2. Foydalanuvchi ma'lumotlari uchun property test yozish
    - **Property 5: Foydalanuvchi Ma'lumotlarini Saqlash**
    - **Validates: Requirements 4.4, 4.5**
  
  - [ ]* 5.3. API endpointlar uchun property testlar yozish
    - **Property 10: API Endpoint Javob Formati**
    - **Validates: Requirements 9.7, 9.8**

- [x] 6. Checkpoint - Backend xavfsizlik va testlarni tekshirish
  - Barcha testlar o'tishini ta'minlash, savol tug'ilsa foydalanuvchidan so'rash.

### Frontend Yaxshilashlar

- [ ] 7. MyID SDK Flow ekranini yaratish
  - [x] 7.1. MyIdSdkFlowScreen yaratish
    - Sessiya yaratish bosqichini qo'shish
    - SDK ishga tushirish bosqichini qo'shish
    - Loading indikatorlarini qo'shish
    - Jarayon bosqichlarini ko'rsatish (1/4, 2/4, 3/4, 4/4)
    - _Requirements: 8.2, 8.3_
  
  - [x] 7.2. SDK natijalarini qayta ishlash
    - code="0": Muvaffaqiyatli, keyingi bosqichga o'tish
    - code="1": Bekor qilindi, qayta urinish taklifi
    - code="2" yoki "3": Xato, xato xabarini ko'rsatish
    - _Requirements: 3.6, 3.7, 3.8_
  
  - [ ]* 7.3. SDK integratsiyasi uchun property test yozish
    - **Property 11: SDK Ishga Tushirish**
    - **Validates: Requirements 3.1**
    - **Property 12: SDK Natijalarini Qayta Ishlash**
    - **Validates: Requirements 3.6, 3.7, 3.8**

- [ ] 8. MyID profil ekranini yaratish
  - [x] 8.1. MyIdProfileScreen yaratish
    - Foydalanuvchi ma'lumotlarini ko'rsatish
    - Chiqish tugmasini qo'shish
    - Sozlamalar bo'limini qo'shish
    - _Requirements: 4.5_
  
  - [ ]* 8.2. Profil ekrani uchun widget test yozish
    - MyIdProfileScreen widget testini yozish
    - _Requirements: 10.3_

- [ ] 9. Loading va xato holatlarini qo'shish
  - [x] 9.1. Loading indikatorlarini qo'shish
    - CircularProgressIndicator widget'ini qo'shish
    - Holat xabarlarini ko'rsatish ("Access token olinmoqda...", "Sessiya yaratilmoqda...")
    - Jarayon bosqichlarini yangilash
    - _Requirements: 3.3, 8.3_
  
  - [x] 9.2. Xato xabarlarini qo'shish
    - Xato dialog'ini yaratish
    - "Qayta urinish" tugmasini qo'shish
    - Xato xabarlarini ko'p tilda ko'rsatish
    - _Requirements: 3.5, 8.6_
  
  - [ ]* 9.3. Loading va xato holatlari uchun property testlar yozish
    - **Property 13: Loading Holatini Ko'rsatish**
    - **Validates: Requirements 3.3, 8.3**
    - **Property 14: Xato Xabarlarini Ko'rsatish**
    - **Validates: Requirements 3.5, 8.6**

- [ ] 10. Ko'p tillilikni qo'llab-quvvatlash
  - [x] 10.1. Tarjima fayllarini yaratish
    - uz.json, ru.json, en.json fayllarini yaratish
    - Barcha interfeys matnlarini tarjima qilish
    - Xato xabarlarini tarjima qilish
    - _Requirements: 7.1_
  
  - [x] 10.2. Til tanlash funksiyasini qo'shish
    - Til tanlash dialog'ini yaratish
    - Tanlangan tilni local storage'da saqlash
    - Ilovani qayta ochganda tilni yuklash
    - _Requirements: 7.2, 7.5_
  
  - [x] 10.3. SDK'ga til uzatish
    - MyIdLocale.UZBEK, RUSSIAN, ENGLISH qo'llab-quvvatlash
    - Foydalanuvchi tanlagan tilni SDK'ga uzatish
    - _Requirements: 7.3_
  
  - [ ]* 10.4. Ko'p tillilik uchun property test yozish
    - **Property 15: Ko'p Tillilik Qo'llab-quvvatlash**
    - **Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5**

- [ ] 11. Local storage boshqaruvini qo'shish
  - [x] 11.1. Foydalanuvchi ma'lumotlarini saqlash
    - SharedPreferences'dan foydalanish (allaqachon qisman amalga oshirilgan)
    - user_data kaliti bilan saqlash
    - JSON formatida saqlash
    - _Requirements: 4.5_
  
  - [x] 11.2. Logout funksiyasini qo'shish
    - Barcha sessiya ma'lumotlarini o'chirish
    - session_id, access_token, user_data o'chirish
    - Login ekraniga qaytarish
    - _Requirements: 5.7_
  
  - [ ]* 11.3. Local storage uchun property test yozish
    - **Property 16: Sessiya Ma'lumotlarini Tozalash**
    - **Validates: Requirements 5.7**

- [ ] 12. Accessibility qo'llab-quvvatlashni qo'shish
  - [x] 12.1. Semantics widget'larini qo'shish
    - Barcha tugmalar uchun semantics qo'shish
    - Barcha matnlar uchun semantics qo'shish
    - Barcha rasmlar uchun semantics qo'shish
    - _Requirements: 8.7_
  
  - [ ]* 12.2. Accessibility uchun property test yozish
    - **Property 17: Accessibility Qo'llab-quvvatlash**
    - **Validates: Requirements 8.7**

- [ ] 13. Frontend widget testlarini yozish
  - [ ]* 13.1. Login ekranlari uchun widget testlar yozish
    - MyIdMainLoginScreen widget testini yozish
    - MyIdSdkFlowScreen widget testini yozish
    - _Requirements: 10.3_

- [x] 14. Checkpoint - Frontend funksiyalar testlarini tekshirish
  - Barcha testlar o'tishini ta'minlash, savol tug'ilsa foydalanuvchidan so'rash.

### Integratsiya va Edge Case Testlar

- [ ] 15. To'liq integratsiya testlarini yozish
  - [ ]* 15.1. Backend integratsiya testlarini yozish
    - To'liq autentifikatsiya oqimi testini yozish
    - MyID API bilan integratsiya testini yozish (staging muhitida)
    - Ma'lumotlar bazasi integratsiyasini test qilish
    - _Requirements: 10.2_
  
  - [ ]* 15.2. Frontend integratsiya testlarini yozish
    - Backend bilan integratsiya testini yozish
    - SDK bilan integratsiya testini yozish (mock SDK)
    - To'liq oqim testini yozish (login dan home gacha)
    - _Requirements: 10.3_
  
  - [ ]* 15.3. To'liq oqim uchun property testlar yozish
    - **Property 19: To'liq Autentifikatsiya Oqimi**
    - **Validates: Requirements 1.1, 2.2, 3.1, 3.4, 4.1, 4.2, 4.4**
    - **Property 20: Xavfsiz Ma'lumot Uzatish**
    - **Validates: Requirements 5.1, 5.3, 5.4**

- [ ] 16. Edge case testlarini yozish
  - [ ]* 16.1. Muddati tugagan sessiya testini yozish
    - **Property 22: Muddati Tugagan Sessiya**
    - **Validates: Requirements 2.7**
  
  - [ ]* 16.2. Maksimal qayta urinishlar testini yozish
    - **Property 23: Maksimal Qayta Urinishlar**
    - **Validates: Requirements 6.4**

- [ ] 17. Xavfsizlik testlarini yozish
  - [ ]* 17.1. SQL injection testini yozish
    - Zararli kiritma bilan test qilish
    - Ma'lumotlar bazasi buzilmasligini tekshirish
    - _Requirements: 5.4_
  
  - [ ]* 17.2. XSS hujumi testini yozish
    - Zararli script bilan test qilish
    - Script bajarilmasligini tekshirish
    - _Requirements: 5.4_
  
  - [ ]* 17.3. Rate limiting testini yozish
    - 11 ta so'rov yuborish
    - 11-chi so'rov rad etilishini tekshirish
    - _Requirements: 5.8_

- [ ] 18. Final checkpoint - Barcha testlarni tekshirish
  - Barcha unit testlar o'tishini ta'minlash
  - Barcha property testlar o'tishini ta'minlash (100+ iteratsiya)
  - Barcha integratsiya testlari o'tishini ta'minlash
  - Test coverage 80% dan yuqori ekanligini tekshirish
  - Savol tug'ilsa foydalanuvchidan so'rash

### Dokumentatsiya va Kod Tozalash

- [ ] 19. Dokumentatsiya va kod tozalash
  - [x] 19.1. API dokumentatsiyasini yozish
    - Har bir endpoint uchun dokumentatsiya
    - Request/Response misollari
    - Xato kodlari ro'yxati
    - _Requirements: 9.1-9.8_
  
  - [x] 19.2. Kod izohlarini qo'shish
    - Har bir funksiya uchun JSDoc/DartDoc
    - Murakkab logika uchun izohlar
    - TODO va FIXME izohlarini olib tashlash
    - _Requirements: 10.6_
  
  - [-] 19.3. README faylini yangilash
    - Loyiha tavsifi
    - O'rnatish yo'riqnomasi
    - Foydalanish misollari
    - Test ishga tushirish yo'riqnomasi
    - _Requirements: 10.1-10.7_

## Eslatmalar

- `*` belgisi bilan belgilangan vazifalar ixtiyoriy (test vazifalar)
- Har bir vazifa aniq requirements'ga havola qiladi
- Checkpoint vazifalar jarayonni tekshirish uchun
- Property testlar dizayn hujjatidagi propertylar bilan bog'langan
- Barcha property testlar kamida 100 iteratsiya bilan ishga tushirilishi kerak
- Backend asosiy funksiyalar allaqachon amalga oshirilgan, endi xavfsizlik va testlarga e'tibor berish kerak
- Frontend asosiy funksiyalar qisman amalga oshirilgan, to'liq SDK flow va ko'p tillilik qo'shish kerak
