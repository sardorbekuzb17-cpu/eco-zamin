# Requirements Document

## Introduction

GreenMarket platformasiga "Mavsumiy Eslatgich" bo'limini qo'shish loyihasi. Ushbu bo'lim foydalanuvchilarga yil davomida bog'bonchilik ishlari haqida ma'lumot beradi, har bir mavsumda qilish kerak bo'lgan ishlarni eslatadi va shaxsiy eslatma tizimini taqdim etadi. Bu foydalanuvchilarga o'z bog'lari va o'simliklariga to'g'ri vaqtda g'amxo'rlik qilishda yordam beradi.

## Glossary

- **GreenMarket**: Daraxt va o'simliklarni sotish uchun raqamli platforma
- **Foydalanuvchi**: Platformadan foydalanib bog'bonchilik maslahatlarini oluvchi shaxs
- **Mavsumiy Eslatgich**: Har bir mavsumda qilish kerak bo'lgan bog'bonchilik ishlarini ko'rsatuvchi tizim
- **Mavsum**: Yilning to'rt davri (Bahor, Yoz, Kuz, Qish)
- **Eslatma**: Foydalanuvchiga belgilangan vaqtda yuboriluvchi xabarnoma
- **Hozirgi oy maslahati**: Joriy oy uchun maxsus tavsiyalar va ishlar ro'yxati

## Requirements

### Requirement 1

**User Story:** Foydalanuvchi sifatida, men har bir mavsumda qilish kerak bo'lgan ishlarni ko'rishni xohlayman, shunda o'z bog'imga to'g'ri vaqtda g'amxo'rlik qilishim mumkin bo'ladi.

#### Acceptance Criteria

1. WHEN foydalanuvchi "Mavsumiy Eslatgich" bo'limiga kirsa THEN tizim to'rtta mavsumiy kartani ko'rsatadi
2. WHEN har bir mavsumiy karta ko'rsatilsa THEN tizim mavsum nomi, emoji belgisi, oylar oralig'i va asosiy ishlar ro'yxatini ko'rsatadi
3. WHEN Bahor kartasi ko'rsatilsa THEN tizim kesish, ekish, o'g'it berish va ko'chatlarni ko'chirish ishlarini ko'rsatadi
4. WHEN Yoz kartasi ko'rsatilsa THEN tizim sug'orish, tozalash, meva yig'ish va zararkunandalardan himoya ishlarini ko'rsatadi
5. WHEN Kuz kartasi ko'rsatilsa THEN tizim qishga tayyorlash, barglarni yig'ish, daraxt ekish va tuproqni haydash ishlarini ko'rsatadi
6. WHEN Qish kartasi ko'rsatilsa THEN tizim o'simliklarni himoya qilish, qor to'plash, uy o'simliklariga g'amxo'rlik va keyingi yil uchun reja tuzish ishlarini ko'rsatadi

### Requirement 2

**User Story:** Foydalanuvchi sifatida, men hozirgi oy uchun maxsus maslahatlarni ko'rishni xohlayman, shunda aynan hozir qilish kerak bo'lgan ishlarni bilishim mumkin bo'ladi.

#### Acceptance Criteria

1. WHEN foydalanuvchi bo'limga kirsa THEN tizim joriy oy nomini va yilini ko'rsatadi
2. WHEN hozirgi oy maslahati ko'rsatilsa THEN tizim "Asosiy ishlar" va "Ehtiyot choralar" bo'limlarini ko'rsatadi
3. WHEN "Asosiy ishlar" bo'limi ko'rsatilsa THEN tizim kamida 3 ta muhim ishni ro'yxat shaklida ko'rsatadi
4. WHEN "Ehtiyot choralar" bo'limi ko'rsatilsa THEN tizim kamida 3 ta ehtiyot chorasini ro'yxat shaklida ko'rsatadi
5. WHEN oy o'zgarganda THEN tizim yangi oyga mos maslahatlarni avtomatik yangilaydi

### Requirement 3

**User Story:** Foydalanuvchi sifatida, men muhim bog'bonchilik ishlari uchun eslatma o'rnatishni xohlayman, shunda kerakli ishlarni o'z vaqtida bajarishni unutmasligim mumkin bo'ladi.

#### Acceptance Criteria

1. WHEN foydalanuvchi eslatma tizimi bo'limini ko'rsa THEN tizim uchta asosiy eslatma turini ko'rsatadi
2. WHEN sug'orish eslatmasi ko'rsatilsa THEN tizim "Har 2-3 kunda eslatma" tavsifini va "O'rnatish" tugmasini ko'rsatadi
3. WHEN o'g'it berish eslatmasi ko'rsatilsa THEN tizim "Oyiga 1 marta eslatma" tavsifini va "O'rnatish" tugmasini ko'rsatadi
4. WHEN kesish eslatmasi ko'rsatilsa THEN tizim "Mavsumiy eslatma" tavsifini va "O'rnatish" tugmasini ko'rsatadi
5. WHEN foydalanuvchi "O'rnatish" tugmasini bosadi THEN tizim eslatma sozlash oynasini ochadi

### Requirement 4

**User Story:** Foydalanuvchi sifatida, men eslatmalarni sozlashni va boshqarishni xohlayman, shunda o'z ehtiyojlarimga mos eslatmalar olishim mumkin bo'ladi.

#### Acceptance Criteria

1. WHEN foydalanuvchi eslatma sozlash oynasini ochsa THEN tizim eslatma turi, vaqt va takrorlanish sozlamalarini ko'rsatadi
2. WHEN foydalanuvchi eslatma vaqtini tanlasa THEN tizim 24 soatlik format yoki 12 soatlik formatda vaqt tanlash imkoniyatini beradi
3. WHEN foydalanuvchi eslatmani saqlasa THEN tizim eslatmani localStorage ga saqlaydi
4. WHEN foydalanuvchi aktiv eslatmalarni ko'rsa THEN tizim barcha o'rnatilgan eslatmalarni ro'yxat shaklida ko'rsatadi
5. WHEN foydalanuvchi eslatmani o'chirsa THEN tizim eslatmani localStorage dan olib tashlaydi va ro'yxatdan o'chiradi

### Requirement 5

**User Story:** Foydalanuvchi sifatida, men eslatmalarni o'z vaqtida olishni xohlayman, shunda muhim ishlarni bajarishni unutmasligim mumkin bo'ladi.

#### Acceptance Criteria

1. WHEN belgilangan vaqt kelganda THEN tizim brauzer xabarnomasi orqali eslatma yuboradi
2. WHEN foydalanuvchi xabarnomaga ruxsat bermagan bo'lsa THEN tizim sahifa ichida modal oyna orqali eslatma ko'rsatadi
3. WHEN eslatma ko'rsatilsa THEN tizim eslatma turi, qilish kerak bo'lgan ish va keyingi eslatma vaqtini ko'rsatadi
4. WHEN foydalanuvchi eslatmani ko'rsa THEN tizim "Bajarildi" va "Keyinroq eslatish" tugmalarini ko'rsatadi
5. WHEN foydalanuvchi "Keyinroq eslatish" tugmasini bosadi THEN tizim 1 soatdan keyin qayta eslatadi

### Requirement 6

**User Story:** Foydalanuvchi sifatida, men mobil qurilmada mavsumiy maslahatlarni ko'rishni xohlayman, shunda istalgan joydan bog'bonchilik ma'lumotlariga kirishim mumkin bo'ladi.

#### Acceptance Criteria

1. WHEN foydalanuvchi mobil qurilmada bo'limni ochsa THEN tizim responsiv interfeys ko'rsatadi
2. WHEN mavsumiy kartalar mobil qurilmada ko'rsatilsa THEN tizim kartalarni vertikal tartibda joylashtiradi
3. WHEN hozirgi oy maslahati mobil qurilmada ko'rsatilsa THEN tizim "Asosiy ishlar" va "Ehtiyot choralar" bo'limlarini vertikal tartibda ko'rsatadi
4. WHEN eslatma tizimi mobil qurilmada ko'rsatilsa THEN tizim eslatma kartalarini vertikal tartibda joylashtiradi
5. WHEN sahifa mobil qurilmada yuklansa THEN tizim 3 soniyadan kam vaqtda yuklashni ta'minlaydi

### Requirement 7

**User Story:** Foydalanuvchi sifatida, men mavsumiy maslahatlarning to'g'riligiga ishonishni xohlayman, shunda o'simliklarimga zarar yetkazmasligim mumkin bo'ladi.

#### Acceptance Criteria

1. WHEN tizim mavsumiy maslahatlarni ko'rsatsa THEN tizim O'zbekiston iqlim sharoitlariga mos maslahatlarni ko'rsatadi
2. WHEN bahor maslahatlari ko'rsatilsa THEN tizim Mart-May oylariga mos ishlarni ko'rsatadi
3. WHEN yoz maslahatlari ko'rsatilsa THEN tizim Iyun-Avgust oylariga mos ishlarni ko'rsatadi
4. WHEN kuz maslahatlari ko'rsatilsa THEN tizim Sentyabr-Noyabr oylariga mos ishlarni ko'rsatadi
5. WHEN qish maslahatlari ko'rsatilsa THEN tizim Dekabr-Fevral oylariga mos ishlarni ko'rsatadi

### Requirement 8

**User Story:** Foydalanuvchi sifatida, men eslatmalar tarixini ko'rishni xohlayman, shunda qaysi ishlarni bajarganim va qaysilarini bajarmaganim haqida ma'lumotga ega bo'lishim mumkin bo'ladi.

#### Acceptance Criteria

1. WHEN foydalanuvchi eslatmalar tarixini ochsa THEN tizim oxirgi 30 kunlik eslatmalar ro'yxatini ko'rsatadi
2. WHEN eslatma bajarilgan deb belgilansa THEN tizim eslatmani yashil rangda va "✓" belgisi bilan ko'rsatadi
3. WHEN eslatma o'tkazib yuborilgan bo'lsa THEN tizim eslatmani qizil rangda va "✗" belgisi bilan ko'rsatadi
4. WHEN foydalanuvchi tarix ro'yxatini filtrlasa THEN tizim faqat tanlangan eslatma turini ko'rsatadi
5. WHEN foydalanuvchi tarixni tozalasa THEN tizim tasdiqlash so'rovini ko'rsatadi va tasdiqlangandan keyin tarixni o'chiradi
