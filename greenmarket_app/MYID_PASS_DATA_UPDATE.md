# MyID pass_data Parametri - Yangilanish

## Nima qo'shildi?

Rasmda ko'rsatilgan **pass_data** parametri qo'shildi. Bu parametr pasport seriyasi va raqamini yuborish uchun ishlatiladi.

## Yangilangan funksiyalar

### 1. `createSession()` funksiyasi

Yangi parametr qo'shildi:
```dart
String? passData,  // Pasport seriyasi va raqami
```

### 2. `createSessionWithToken()` funksiyasi

Yangi parametr qo'shildi:
```dart
String? passData,  // Pasport seriyasi va raqami
```

## Parametrlar ro'yxati (rasmdan)

| Maydon | Turi | Majburiy | Tavsif |
|--------|------|----------|--------|
| `phone_number` | satr (12-13) | Yo'q | Telefon raqami |
| `birth_date` | satr (YYYY-MM-DD) | Yo'q | Tug'ilgan sana |
| `is_resident` | bool | Yo'q | Rezidentmi (standart: true) |
| `pass_data` | satr | Yo'q | **Pasport seriyasi va raqami** |
| `threshold` | suzuvchi | Yo'q | 0.5 dan 0.99 gacha |

## Muhim eslatma

📌 **Agar sessiya pasport ma'lumotlari (pass_data yoki pinfl) bilan yaratilsa, SDK birinchi sahifani o'tkazib yuboradi va to'g'ridan-to'g'ri yuzni suratga olishga o'tadi.**

Bu degani:
- ✅ Pasport ma'lumotlari berilsa → Faqat yuz tanish
- ❌ Pasport ma'lumotlari berilmasa → Pasport kiritish + Yuz tanish

## Ishlatish misoli

### A. Pasport ma'lumotlari bilan

```dart
final result = await MyIdBackendService.createSessionWithToken(
  clientId: MyIDConfig.clientId,
  clientSecret: MyIDConfig.clientSecret,
  passData: 'AA1234567',  // Pasport seriyasi va raqami
  birthDate: '1990-01-01',
  phoneNumber: '998901234567',
);
```

### B. PINFL bilan

```dart
final result = await MyIdBackendService.createSessionWithToken(
  clientId: MyIDConfig.clientId,
  clientSecret: MyIDConfig.clientSecret,
  pinfl: '12345678901234',  // PINFL
  birthDate: '1990-01-01',
);
```

### C. Pasport ma'lumotlarisiz (SDK'da kiritiladi)

```dart
final result = await MyIdBackendService.createSessionWithToken(
  clientId: MyIDConfig.clientId,
  clientSecret: MyIDConfig.clientSecret,
  // pass_data va pinfl berilmagan
  // Foydalanuvchi SDK'da pasport ma'lumotlarini kiritadi
);
```

## So'rov misoli (JSON)

```json
{
  "phone_number": "string(min_len=12, max_len=13) | null",
  "birth_date": "string(dt) | null",
  "is_resident": "bool | null",
  "pass_data": "string | null",
  "threshold": "float | null"
}
```

## Test qilish

1. OAuth Test sahifasiga o'ting
2. Access token oling
3. Sessiya yaratishda pass_data parametrini qo'shing
4. MyID SDK avtomatik yuz tanishga o'tadi

## Xulosa

✅ `pass_data` parametri qo'shildi
✅ Pasport ma'lumotlari bilan sessiya yaratish mumkin
✅ SDK birinchi sahifani o'tkazib yuboradi
✅ Foydalanuvchi tajribasi yaxshilandi
