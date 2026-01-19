# MyID DEV Muhiti - 103 Xatolik

## Muammo

Biz DEV muhiti uchun credentials oldik va `MyIdEnvironment.DEBUG` ga o'zgartirdik, lekin hali ham **103 xatolik** (Session expired) chiqmoqda.

## Bizning Sozlamalar

### Credentials (DEV uchun tasdiqlangan)

```env
client_id: quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v
client_secret: JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP
client_hash_id: ac6d0f4a-5d5b-44e3-a865-9159a3146a8c
```

### SDK Konfiguratsiyasi

```dart
final config = MyIdConfig(
  sessionId: sessionId,
  clientHash: clientHash,
  clientHashId: clientHashId,
  environment: MyIdEnvironment.DEBUG,  // ✅ DEBUG ga o'zgartirdik
  entryType: MyIdEntryType.IDENTIFICATION,
  locale: MyIdLocale.UZBEK,
  residency: MyIdResidency.USER_DEFINED,
);
```

## Savollar

1. ✅ **DEV muhiti uchun alohida API endpoint bormi?**
   - Javob: Yo'q, bir xil endpoint ishlatiladi

2. ❓ **DEV credentials bilan session qanday yaratiladi?**
   - Biz quyidagi request yubormoqdamiz:

   ```bash
   POST https://api.myid.uz/api/v1/oauth2/session
   Headers:
     Authorization: Basic base64(client_id:client_secret)
   Body:
     {
       "grant_type": "one_authorization",
       "scope": "address,contacts,doc_data,common_data,doc_files"
     }
   ```

   - Bu to'g'rimi DEV uchun?
   - Qo'shimcha parametrlar kerakmi?

3. ❓ **DEV muhitida SDK qanday ishlashi kerak?**
   - `MyIdEnvironment.DEBUG` ishlatmoqdamiz
   - SessionId yaratish kerakmi yoki SDK o'zi yaratadimi?
   - Iltimos, DEV muhiti uchun to'liq misol bering

4. ❓ **103 xatolik nima uchun chiqmoqda?**
   - Session yaratilmoqdami?
   - Session muddati qancha?
   - DEV credentials to'g'ri faollashtirilganmi?

## Xatolik Detallari

- **Error Code**: 103
- **Error Message**: Session expired
- **Environment**: MyIdEnvironment.DEBUG
- **SDK Version**: 3.1.41

## Iltimos Yordam Bering

DEV muhitida qanday qilib to'g'ri ishlashini ko'rsating.
