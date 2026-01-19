# Talablar Hujjati: MyID Integratsiyasi

## Kirish

MyID integratsiyasi GreenMarket platformasiga foydalanuvchilarning O'zbekiston Respublikasi pasport ma'lumotlari orqali xavfsiz autentifikatsiya qilish imkoniyatini beradi. Ushbu tizim MyID OAuth 2.0 protokoli va SDK yordamida yuz tanish texnologiyasi orqali foydalanuvchi identifikatsiyasini amalga oshiradi.

Tizim uch asosiy komponentdan iborat:
1. **Backend Server** - Access token boshqaruvi va sessiya yaratish
2. **Flutter Mobile App** - Foydalanuvchi interfeysi va MyID SDK integratsiyasi
3. **MyID Backend** - Tashqi autentifikatsiya xizmati

## Lug'at

- **MyID_System**: O'zbekiston Respublikasining milliy identifikatsiya tizimi
- **Backend_Server**: GreenMarket backend serveri (Node.js/Express)
- **Mobile_App**: GreenMarket Flutter mobil ilovasi
- **MyID_SDK**: MyID kutubxonasi (yuz tanish uchun)
- **Access_Token**: OAuth 2.0 autentifikatsiya tokeni (7 kun amal qiladi)
- **Session_ID**: Bir martalik sessiya identifikatori
- **PINFL**: Shaxsiy identifikatsiya raqami (14 raqam)
- **Pass_Data**: Pasport seriyasi va raqami (masalan: "AA1234567")
- **Yuz_Tanish**: Biometrik identifikatsiya jarayoni
- **Code**: MyID SDK tomonidan qaytariladigan natija kodi
- **User_Profile**: Foydalanuvchi shaxsiy ma'lumotlari (ism, familiya, tug'ilgan sana va h.k.)

## Talablar

### Talab 1: OAuth Autentifikatsiya

**Foydalanuvchi Hikoyasi:** Tizim administratori sifatida, men MyID bilan xavfsiz bog'lanish uchun OAuth autentifikatsiya mexanizmini sozlashni xohlayman, shunda foydalanuvchilar ma'lumotlari himoyalangan bo'ladi.

#### Qabul Mezonlari

1. WHEN Backend_Server MyID_System'dan access token so'raganda, THE Backend_Server SHALL client_id va client_secret yuborishi kerak
2. WHEN MyID_System access token so'rovini qabul qilganda, THE MyID_System SHALL 200 status kod bilan access_token, expires_in va token_type qaytarishi kerak
3. WHEN access token muvaffaqiyatli olinganda, THE Backend_Server SHALL tokenni xavfsiz saqlashi va 7 kun davomida qayta ishlatishi kerak
4. IF access token so'rovida xatolik yuz berganda, THEN THE Backend_Server SHALL xato ma'lumotlarini log qilishi va foydalanuvchiga tushunarli xabar ko'rsatishi kerak
5. WHEN access token muddati tugaganda, THE Backend_Server SHALL yangi token olish uchun avtomatik ravishda qayta so'rov yuborishi kerak

### Talab 2: Sessiya Boshqaruvi

**Foydalanuvchi Hikoyasi:** Foydalanuvchi sifatida, men MyID SDK orqali identifikatsiya qilishim uchun tizim sessiya yaratishi kerakligini xohlayman, shunda jarayon xavfsiz va tezkor bo'ladi.

#### Qabul Mezonlari

1. WHEN Mobile_App sessiya yaratishni so'raganda, THE Backend_Server SHALL avval access token mavjudligini tekshirishi kerak
2. WHEN sessiya yaratish so'rovi yuborilganda, THE Backend_Server SHALL MyID_System'ga POST so'rov yuborishi va session_id olishi kerak
3. WHERE foydalanuvchi pasport ma'lumotlarini kiritgan bo'lsa, THE Backend_Server SHALL pass_data va birth_date parametrlarini sessiya yaratishda yuborishi kerak
4. WHERE foydalanuvchi PINFL kiritgan bo'lsa, THE Backend_Server SHALL pinfl parametrini sessiya yaratishda yuborishi kerak
5. WHEN sessiya muvaffaqiyatli yaratilganda, THE Backend_Server SHALL session_id va expires_in ma'lumotlarini Mobile_App'ga qaytarishi kerak
6. IF sessiya yaratishda xatolik yuz berganda, THEN THE Backend_Server SHALL xato kodini va tafsilotlarini qaytarishi kerak
7. WHEN sessiya muddati tugaganda, THE Backend_Server SHALL eski sessiyani o'chirishi va yangi sessiya yaratishni taklif qilishi kerak

### Talab 3: MyID SDK Integratsiyasi

**Foydalanuvchi Hikoyasi:** Foydalanuvchi sifatida, men mobil ilovada MyID SDK orqali yuzimni tanish jarayonini o'tishni xohlayman, shunda tizimga xavfsiz kirishim mumkin bo'ladi.

#### Qabul Mezonlari

1. WHEN Mobile_App session_id olganda, THE Mobile_App SHALL MyID_SDK'ni session_id bilan ishga tushirishi kerak
2. WHEN MyID_SDK ishga tushganda, THE MyID_SDK SHALL kamera ruxsatini so'rashi va foydalanuvchiga yuz tanish ekranini ko'rsatishi kerak
3. WHILE yuz tanish jarayoni davom etayotganda, THE Mobile_App SHALL foydalanuvchiga jarayon holatini ko'rsatishi kerak (loading indikator)
4. WHEN yuz tanish muvaffaqiyatli yakunlanganda, THE MyID_SDK SHALL result, image va code qaytarishi kerak
5. IF yuz tanish muvaffaqiyatsiz bo'lsa, THEN THE MyID_SDK SHALL xato kodini qaytarishi va Mobile_App foydalanuvchiga qayta urinish imkoniyatini berishi kerak
6. WHEN code "0" bo'lganda, THE Mobile_App SHALL jarayonni muvaffaqiyatli deb hisoblashi va keyingi bosqichga o'tishi kerak
7. WHEN code "1" bo'lganda, THE Mobile_App SHALL "Bekor qilindi" xabarini ko'rsatishi va foydalanuvchiga qayta urinish tugmasini taqdim etishi kerak
8. WHEN code "2" yoki "3" bo'lganda, THE Mobile_App SHALL xato xabarini ko'rsatishi va texnik yordam uchun yo'riqnoma berishi kerak

### Talab 4: Foydalanuvchi Ma'lumotlarini Olish

**Foydalanuvchi Hikoyasi:** Foydalanuvchi sifatida, men MyID orqali identifikatsiya qilganimdan keyin tizim mening shaxsiy ma'lumotlarimni avtomatik olishini xohlayman, shunda qo'lda kiritishim shart bo'lmaydi.

#### Qabul Mezonlari

1. WHEN Mobile_App MyID_SDK'dan code olganda, THE Mobile_App SHALL code'ni Backend_Server'ga yuborishi kerak
2. WHEN Backend_Server code qabul qilganda, THE Backend_Server SHALL MyID_System'dan foydalanuvchi ma'lumotlarini so'rashi kerak
3. WHEN MyID_System foydalanuvchi ma'lumotlarini qaytarganda, THE Backend_Server SHALL profile, result va comparison_value ma'lumotlarini olishi kerak
4. WHEN foydalanuvchi ma'lumotlari olinganda, THE Backend_Server SHALL ma'lumotlarni ma'lumotlar bazasiga saqlashi kerak
5. WHEN ma'lumotlar saqlanganda, THE Backend_Server SHALL foydalanuvchiga User_Profile ma'lumotlarini qaytarishi kerak
6. IF ma'lumotlarni olishda xatolik yuz berganda, THEN THE Backend_Server SHALL xato xabarini qaytarishi va foydalanuvchiga qayta urinish imkoniyatini berishi kerak

### Talab 5: Xavfsizlik va Ma'lumotlar Himoyasi

**Foydalanuvchi Hikoyasi:** Tizim administratori sifatida, men foydalanuvchilar shaxsiy ma'lumotlari xavfsiz saqlanishini va uzatilishini ta'minlashni xohlayman, shunda GDPR va O'zbekiston qonunlariga rioya qilinadi.

#### Qabul Mezonlari

1. THE Backend_Server SHALL barcha MyID API so'rovlarini HTTPS protokoli orqali yuborishi kerak
2. THE Backend_Server SHALL access_token'ni environment variables yoki xavfsiz konfiguratsiya faylida saqlashi kerak
3. THE Backend_Server SHALL client_secret'ni hech qachon frontend'ga yubormasligi kerak
4. WHEN foydalanuvchi ma'lumotlari ma'lumotlar bazasiga saqlanayotganda, THE Backend_Server SHALL maxfiy ma'lumotlarni (pasport raqami, PINFL) shifrlashi kerak
5. WHEN yuz surati saqlanayotganda, THE Backend_Server SHALL rasmni xavfsiz storage'da saqlashi va faqat autentifikatsiya qilingan foydalanuvchilarga kirish berishi kerak
6. THE Backend_Server SHALL barcha MyID API so'rovlari va javoblarini log qilishi kerak (maxfiy ma'lumotlarni log'dan chiqarib)
7. WHEN foydalanuvchi tizimdan chiqsa, THE Mobile_App SHALL barcha sessiya ma'lumotlarini (session_id, access_token) o'chirishi kerak
8. THE Backend_Server SHALL har bir API so'rovida rate limiting qo'llashi kerak (1 daqiqada maksimal 10 so'rov)

### Talab 6: Xato Boshqaruvi va Qayta Urinish

**Foydalanuvchi Hikoyasi:** Foydalanuvchi sifatida, men tarmoq xatoliklari yoki vaqtinchalik muammolar yuz berganda tizim menga tushunarli xabar ko'rsatishini va qayta urinish imkoniyatini berishini xohlayman.

#### Qabul Mezonlari

1. WHEN tarmoq xatoligi yuz berganda, THE Mobile_App SHALL foydalanuvchiga "Tarmoq bilan bog'lanishda xatolik" xabarini ko'rsatishi kerak
2. WHEN MyID_System timeout qaytarganda, THE Backend_Server SHALL maksimal 3 marta qayta urinishi kerak
3. WHILE qayta urinish davom etayotganda, THE Mobile_App SHALL foydalanuvchiga kutish holatini ko'rsatishi kerak
4. IF 3 marta qayta urinish muvaffaqiyatsiz bo'lsa, THEN THE Mobile_App SHALL foydalanuvchiga "Keyinroq qayta urinib ko'ring" xabarini ko'rsatishi kerak
5. WHEN MyID_System 4xx xato kodi qaytarganda, THE Backend_Server SHALL xato tafsilotlarini log qilishi va foydalanuvchiga tushunarli xabar ko'rsatishi kerak
6. WHEN MyID_System 5xx xato kodi qaytarganda, THE Backend_Server SHALL xatoni log qilishi va foydalanuvchiga "Tizimda vaqtinchalik muammo" xabarini ko'rsatishi kerak

### Talab 7: Ko'p Tillilik

**Foydalanuvchi Hikoyasi:** Foydalanuvchi sifatida, men o'z tilimda (o'zbek, rus yoki ingliz) tizim xabarlarini ko'rishni xohlayman, shunda jarayonni yaxshiroq tushunaman.

#### Qabul Mezonlari

1. THE Mobile_App SHALL o'zbek, rus va ingliz tillarini qo'llab-quvvatlashi kerak
2. WHEN foydalanuvchi til tanlasa, THE Mobile_App SHALL barcha interfeys elementlarini tanlangan tilda ko'rsatishi kerak
3. WHEN MyID_SDK ishga tushganda, THE Mobile_App SHALL foydalanuvchi tanlagan tilni SDK'ga uzatishi kerak (MyIdLocale)
4. WHEN xato xabarlari ko'rsatilganda, THE Mobile_App SHALL xabarlarni foydalanuvchi tilida ko'rsatishi kerak
5. THE Mobile_App SHALL tanlangan tilni local storage'da saqlashi va keyingi kirishda avtomatik qo'llashi kerak

### Talab 8: Foydalanuvchi Interfeysi va Tajriba

**Foydalanuvchi Hikoyasi:** Foydalanuvchi sifatida, men MyID orqali kirish jarayonini oddiy va intuitiv bo'lishini xohlayman, shunda qiyinchiliksiz tizimga kirishim mumkin bo'ladi.

#### Qabul Mezonlari

1. WHEN foydalanuvchi login ekraniga kirganda, THE Mobile_App SHALL "MyID orqali kirish" tugmasini ko'rsatishi kerak
2. WHEN foydalanuvchi "MyID orqali kirish" tugmasini bosganda, THE Mobile_App SHALL jarayon bosqichlarini ko'rsatishi kerak (1/4, 2/4, 3/4, 4/4)
3. WHILE jarayon davom etayotganda, THE Mobile_App SHALL har bir bosqich uchun loading indikator va holat xabarini ko'rsatishi kerak
4. WHEN yuz tanish bosqichiga yetganda, THE Mobile_App SHALL foydalanuvchiga yo'riqnoma ko'rsatishi kerak ("Yuzingizni kameraga ko'rsating")
5. WHEN jarayon muvaffaqiyatli yakunlanganda, THE Mobile_App SHALL muvaffaqiyat xabarini ko'rsatishi va 2 soniyadan keyin home ekraniga o'tishi kerak
6. IF jarayonda xatolik yuz berganda, THEN THE Mobile_App SHALL xato xabarini va "Qayta urinish" tugmasini ko'rsatishi kerak
7. THE Mobile_App SHALL barcha tugmalar va matnlar uchun accessibility qo'llab-quvvatlashi kerak (screen reader uchun)

### Talab 9: Backend API Endpointlari

**Foydalanuvchi Hikoyasi:** Backend dasturchi sifatida, men MyID integratsiyasi uchun aniq va hujjatlashtirilgan API endpointlariga ega bo'lishni xohlayman, shunda frontend bilan integratsiya oson bo'ladi.

#### Qabul Mezonlari

1. THE Backend_Server SHALL POST /api/myid/create-session endpointini taqdim etishi kerak
2. WHEN /api/myid/create-session chaqirilganda, THE Backend_Server SHALL session_id va expires_in qaytarishi kerak
3. THE Backend_Server SHALL POST /api/myid/verify-passport endpointini taqdim etishi kerak
4. WHEN /api/myid/verify-passport chaqirilganda, THE Backend_Server SHALL pasport ma'lumotlarini tekshirishi va natijani qaytarishi kerak
5. THE Backend_Server SHALL GET /api/myid/user-data endpointini taqdim etishi kerak
6. WHEN /api/myid/user-data chaqirilganda, THE Backend_Server SHALL code parametrini qabul qilishi va foydalanuvchi ma'lumotlarini qaytarishi kerak
7. THE Backend_Server SHALL barcha endpointlar uchun JSON formatida javob qaytarishi kerak
8. THE Backend_Server SHALL har bir endpoint uchun xato holatlarini to'g'ri boshqarishi va mos status kodlarini qaytarishi kerak (400, 401, 500)

### Talab 10: Test va Sifat Nazorati

**Foydalanuvchi Hikoyasi:** QA muhandis sifatida, men MyID integratsiyasining barcha funksiyalari to'g'ri ishlashini tekshirish uchun avtomatlashtirilgan testlarga ega bo'lishni xohlayman.

#### Qabul Mezonlari

1. THE Backend_Server SHALL har bir API endpoint uchun unit testlarga ega bo'lishi kerak
2. THE Backend_Server SHALL MyID API bilan integratsiya testlariga ega bo'lishi kerak
3. THE Mobile_App SHALL MyID SDK integratsiyasi uchun widget testlariga ega bo'lishi kerak
4. THE Mobile_App SHALL xato holatlarini simulyatsiya qilish uchun mock testlariga ega bo'lishi kerak
5. WHEN testlar ishga tushirilganda, THE Backend_Server SHALL barcha testlarning kamida 80% o'tishi kerak
6. THE Backend_Server SHALL har bir test uchun aniq assertion va kutilgan natijaga ega bo'lishi kerak
7. THE Mobile_App SHALL UI testlari uchun screenshot testlariga ega bo'lishi kerak

