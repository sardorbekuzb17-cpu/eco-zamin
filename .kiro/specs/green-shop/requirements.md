# Requirements Document

## Introduction

GreenMarket platformasiga to'liq funksional onlayn do'kon (yasjil dokon) qo'shish loyihasi. Ushbu loyiha foydalanuvchilarga daraxt va o'simliklarni savatga qo'shish, buyurtma berish, to'lov qilish va buyurtmalarni kuzatish imkoniyatini beradi. Hozirda platforma faqat mahsulotlar katalogini ko'rsatadi, lekin haqiqiy xarid funksiyasi yo'q.

## Glossary

- **GreenMarket**: Daraxt va o'simliklarni sotish uchun raqamli platforma
- **Foydalanuvchi**: Platformadan foydalanib daraxt yoki o'simlik xarid qiluvchi shaxs
- **Savat**: Foydalanuvchi xarid qilmoqchi bo'lgan mahsulotlar ro'yxati
- **Buyurtma**: Foydalanuvchi tomonidan tasdiqlangan va to'langan mahsulotlar to'plami
- **Mahsulot**: Sotuvga qo'yilgan daraxt yoki o'simlik
- **To'lov tizimi**: Onlayn to'lovlarni qayta ishlash xizmati
- **QR-kod**: Har bir daraxtga biriktirilgan noyob identifikator

## Requirements

### Requirement 1

**User Story:** Foydalanuvchi sifatida, men mahsulotlarni savatga qo'shishni xohlayman, shunda keyinroq ularni xarid qilishim mumkin bo'ladi.

#### Acceptance Criteria

1. WHEN foydalanuvchi mahsulot kartochkasida "Savatga qo'shish" tugmasini bosadi THEN tizim mahsulotni savatga qo'shadi va savat sonini yangilaydi
2. WHEN foydalanuvchi bir xil mahsulotni ikkinchi marta savatga qo'shadi THEN tizim mahsulot miqdorini oshiradi
3. WHEN foydalanuvchi savat ikonkasini bosadi THEN tizim savat tarkibini ko'rsatadi
4. WHEN savat bo'sh bo'lsa THEN tizim "Savat bo'sh" xabarini ko'rsatadi
5. WHEN foydalanuvchi savatdagi mahsulot miqdorini o'zgartiradi THEN tizim umumiy narxni qayta hisoblaydi

### Requirement 2

**User Story:** Foydalanuvchi sifatida, men savatdagi mahsulotlarni boshqarishni xohlayman, shunda kerakli mahsulotlarni o'chirishim yoki miqdorini o'zgartirishim mumkin bo'ladi.

#### Acceptance Criteria

1. WHEN foydalanuvchi savatdagi mahsulot miqdorini kamaytiradi THEN tizim yangi miqdorni saqlaydi va umumiy narxni yangilaydi
2. WHEN mahsulot miqdori 0 ga teng bo'lsa THEN tizim mahsulotni savatdan olib tashlaydi
3. WHEN foydalanuvchi "O'chirish" tugmasini bosadi THEN tizim mahsulotni savatdan darhol olib tashlaydi
4. WHEN savat yangilanganda THEN tizim o'zgarishlarni localStorage ga saqlaydi
5. WHEN foydalanuvchi sahifani yangilasa THEN tizim savatni localStorage dan tiklaydi

### Requirement 3

**User Story:** Foydalanuvchi sifatida, men buyurtma berishni xohlayman, shunda tanlagan mahsulotlarimni xarid qilishim mumkin bo'ladi.

#### Acceptance Criteria

1. WHEN foydalanuvchi "Buyurtma berish" tugmasini bosadi THEN tizim buyurtma formasini ko'rsatadi
2. WHEN foydalanuvchi forma maydonlarini to'ldiradi THEN tizim har bir maydonni validatsiya qiladi
3. WHEN forma maydonlari bo'sh bo'lsa THEN tizim xato xabarini ko'rsatadi va buyurtmani qabul qilmaydi
4. WHEN foydalanuvchi noto'g'ri telefon raqami kiritsa THEN tizim xato xabarini ko'rsatadi
5. WHEN barcha maydonlar to'g'ri to'ldirilsa THEN tizim to'lov sahifasiga o'tkazadi

### Requirement 4

**User Story:** Foydalanuvchi sifatida, men xavfsiz to'lov qilishni xohlayman, shunda xaridimni yakunlashim mumkin bo'ladi.

#### Acceptance Criteria

1. WHEN foydalanuvchi to'lov sahifasiga kirsa THEN tizim buyurtma xulosasini ko'rsatadi
2. WHEN foydalanuvchi to'lov usulini tanlasa THEN tizim tanlangan usulga mos forma ko'rsatadi
3. WHEN foydalanuvchi to'lov ma'lumotlarini kiritadi THEN tizim ma'lumotlarni validatsiya qiladi
4. WHEN to'lov muvaffaqiyatli amalga oshsa THEN tizim tasdiqlash sahifasini ko'rsatadi va buyurtma raqamini beradi
5. WHEN to'lov muvaffaqiyatsiz bo'lsa THEN tizim xato xabarini ko'rsatadi va qayta urinish imkoniyatini beradi

### Requirement 5

**User Story:** Foydalanuvchi sifatida, men buyurtmalarimni ko'rishni xohlayman, shunda ularning holatini kuzatishim mumkin bo'ladi.

#### Acceptance Criteria

1. WHEN foydalanuvchi "Mening buyurtmalarim" sahifasiga kirsa THEN tizim barcha buyurtmalarni ko'rsatadi
2. WHEN buyurtma ro'yxati bo'sh bo'lsa THEN tizim "Buyurtmalar yo'q" xabarini ko'rsatadi
3. WHEN foydalanuvchi buyurtmani bosadi THEN tizim buyurtma tafsilotlarini ko'rsatadi
4. WHEN buyurtma tafsilotlari ko'rsatilsa THEN tizim mahsulotlar ro'yxati, umumiy narx va yetkazib berish manzilini ko'rsatadi
5. WHEN buyurtma yetkazib berilsa THEN tizim QR-kod va raqamli sertifikatni ko'rsatadi

### Requirement 6

**User Story:** Foydalanuvchi sifatida, men mahsulotlarni qidirishni va filtrlashni xohlayman, shunda kerakli mahsulotni tezda topishim mumkin bo'ladi.

#### Acceptance Criteria

1. WHEN foydalanuvchi qidiruv maydoniga matn kiritadi THEN tizim mahsulot nomiga mos natijalarni ko'rsatadi
2. WHEN qidiruv natijalari topilmasa THEN tizim "Natija topilmadi" xabarini ko'rsatadi
3. WHEN foydalanuvchi narx filtri qo'llasa THEN tizim belgilangan narx oralig'idagi mahsulotlarni ko'rsatadi
4. WHEN foydalanuvchi mahsulot turi filtri qo'llasa THEN tizim faqat tanlangan turdagi mahsulotlarni ko'rsatadi
5. WHEN foydalanuvchi barcha filtrlarni tozalasa THEN tizim barcha mahsulotlarni ko'rsatadi

### Requirement 7

**User Story:** Administrator sifatida, men mahsulotlarni boshqarishni xohlayman, shunda katalogni yangilashim mumkin bo'ladi.

#### Acceptance Criteria

1. WHEN administrator yangi mahsulot qo'shadi THEN tizim mahsulotni katalogga qo'shadi va barcha foydalanuvchilarga ko'rsatadi
2. WHEN administrator mahsulot ma'lumotlarini tahrirlasa THEN tizim o'zgarishlarni saqlaydi va darhol ko'rsatadi
3. WHEN administrator mahsulotni o'chirsa THEN tizim mahsulotni katalogdan olib tashlaydi
4. WHEN mahsulot omborda tugasa THEN tizim mahsulotni "Tugagan" deb belgilaydi va xarid qilish imkoniyatini o'chiradi
5. WHEN administrator mahsulot rasmini yuklasa THEN tizim rasmni saqlaydi va mahsulot kartochkasida ko'rsatadi

### Requirement 8

**User Story:** Foydalanuvchi sifatida, men mobil qurilmada qulay xarid qilishni xohlayman, shunda istalgan joydan buyurtma berishim mumkin bo'ladi.

#### Acceptance Criteria

1. WHEN foydalanuvchi mobil qurilmada saytni ochsa THEN tizim responsiv interfeys ko'rsatadi
2. WHEN foydalanuvchi mobil qurilmada savatni ochsa THEN tizim to'liq ekran modal oynasini ko'rsatadi
3. WHEN foydalanuvchi mobil qurilmada forma to'ldirsa THEN tizim klaviatura bilan qulay ishlashni ta'minlaydi
4. WHEN foydalanuvchi mobil qurilmada to'lov qilsa THEN tizim mobil to'lov usullarini qo'llab-quvvatlaydi
5. WHEN sahifa mobil qurilmada yuklansa THEN tizim 3 soniyadan kam vaqtda yuklashni ta'minlaydi
