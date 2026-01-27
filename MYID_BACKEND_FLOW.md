# MyID Backend-First Integratsiya

## O'zgarishlar
Foydalanuvchi talabiga binoan, barcha MyID operatsiyalari endi **Backend** orqali amalga oshiriladi. 
Flutter ilovasi to'g'ridan-to'g'ri `myid.uz` ga murojaat qilmaydi, balki o'zimizning backend proxy endpointlarimizdan foydalanadi.

### Yangi Oqim (Flow)

1. **Sessiya Yaratish**
   - **Frontend**: `POST https://greenmarket-backend-lilac.vercel.app/api/myid/create-session`
   - **Backend**: O'zi access token oladi va sessiya yaratib `session_id` qaytaradi.

2. **Identifikatsiya**
   - **Frontend**: MyID SDK ni `session_id` bilan ishga tushiradi.
   - **User**: Yuzini va pasportini ko'rsatadi.
   - **SDK**: `code` qaytaradi.

3. **Profilni Olish**
   - **Frontend**: `POST https://greenmarket-backend-lilac.vercel.app/api/myid/get-user-info`
   - **Body**: `{ "session_id": "...", "code": "..." }`
   - **Backend**: MyID dan profil ma'lumotlarini oladi va frontendga qaytaradi.

### Afzalliklari
- ✅ **Xavfsizlik**: Client Secret ilovada saqlanmaydi.
- ✅ **Barqarorlik**: CORS xatoliklari bo'lmaydi.
- ✅ **Timeout**: 30 soniyalik timeout qo'shildi (`http` client da).
- ✅ **Oddiylik**: Logic backend da boshqariladi.

## Fayllardagi O'zgarishlar
- `lib/services/myid_oauth_service.dart`: To'liq qayta yozildi, faqat backend endpointlarga murojaat qiladi.

## Keyingi Qadam
- `flutter build apk`
- Telefonga o'rnatish
