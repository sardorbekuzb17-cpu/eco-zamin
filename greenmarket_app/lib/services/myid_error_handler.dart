/// MyID xato kodlarini qayta ishlash servisi
/// Rasmda ko'rsatilgan barcha xato kodlarini qamrab oladi
class MyIdErrorHandler {
  /// SDK xato kodlarini qayta ishlash
  /// Rasmda: "Коды ошибок SDK" - 0-36 gacha kodlar
  static String getErrorMessage(String code) {
    switch (code) {
      case '0':
        return 'Muvaffaqiyatli';
      case '1':
        return 'Pasport ma\'lumotlari noto\'g\'ri kiritilgan';
      case '2':
        return 'Pasport ma\'lumotlari noto\'g\'ri kiritilgan';
      case '3':
        return 'Yuzni tanib bo\'lmadi, aniqroq fotosurat kerak';
      case '4':
        return 'Yuzni tanib bo\'lmadi';
      case '5':
        return 'Tashqi server xatosi, qayta urinib ko\'ring';
      case '6':
        return 'Foydalanuvchi tomonidan bekor qilindi';
      case '7':
        return 'Resurs topilmadi';
      case '8':
        return 'Ichki xato yuz berdi';
      case '9':
        return 'Vazifa bajarilishida xato';
      case '10':
        return 'Vazifa yaratishda xato';
      case '11':
      case '13':
        return 'MyID serveri javob bermadi, qayta urinib ko\'ring';
      case '14':
        return 'Yuzni tanib bo\'lmadi, aniqroq fotosurat kerak';
      case '15':
      case '16':
        return 'MyID serveri javob bermadi, qayta urinib ko\'ring';
      case '17':
        return 'Yuzni tanib bo\'lmadi, aniqroq fotosurat kerak';
      case '18':
        return 'Server xatosi, qayta urinib ko\'ring';
      case '19':
        return 'Server xatosi, qayta urinib ko\'ring';
      case '20':
        return 'Fotosurat qayta ishlashda xato';
      case '21':
        return 'Foydalanuvchi topilmadi';
      case '22':
        return 'Noto\'g\'ri yosh';
      case '23':
        return 'Fotosurat sifati past, aniqroq fotosurat kerak';
      case '24':
        return 'Noto\'g\'ri maydon';
      case '25':
        return 'Server xatosi, fotosurat qayta ishlanmadi';
      case '26':
        return 'Yuz topilmadi yoki suv belgisi bor';
      case '27':
        return 'Sahifaga qaytish';
      case '28':
        return 'Fotosurat qayta ishlanmadi';
      case '29':
        return 'Sertifikat xatosi, qurilmani qayta ishga tushiring';
      case '30':
        return 'Noto\'g\'ri javob';
      case '31':
        return 'Markaziy maydon eng katta bo\'lishi kerak';
      case '32':
        return 'Pasport qayta ishlanmadi';
      case '33':
        return 'Ma\'lumot topilmadi';
      case '34':
        return 'Noto\'g\'ri jarayon';
      case '35':
        return 'MyID jadval xatosi';
      case '36':
        return 'Xato yuz berdi';
      case '101':
        return 'Kamera sozlamalariga kirish';
      case '102':
        return 'Kamera sozlamalariga kirish';
      case '103':
        return 'Server bilan aloqa xatosi';
      case '122':
        return 'Foydalanuvchi bloklangan';
      default:
        return 'Noma\'lum xato: $code';
    }
  }

  /// HTTP status kodlarini qayta ishlash
  static String getHttpErrorMessage(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return 'Muvaffaqiyatli';
    } else if (statusCode >= 400 && statusCode < 500) {
      return 'So\'rov xatosi. Iltimos, ma\'lumotlarni tekshiring.';
    } else if (statusCode >= 500) {
      return 'Server xatosi. Iltimos, keyinroq qayta urinib ko\'ring.';
    } else {
      return 'Noma\'lum xato: $statusCode';
    }
  }

  /// Hujjat turini aniqlash
  /// Rasmda: "Типы документов" - doc_type_id
  static String getDocumentTypeName(String? docTypeId) {
    if (docTypeId == null) return 'Noma\'lum';

    switch (docTypeId) {
      case '8':
        return 'O\'zbekiston Respublikasi fuqarosi ID kartasi';
      case '9':
        return 'O\'zbekiston Respublikasi fuqarosi pasporti';
      case '15':
        return 'Chet el fuqarosi pasporti';
      case '40':
        return 'Biometrik pasport (16 yoshgacha)';
      case '49':
        return 'Biometrik pasport (16 yoshdan katta)';
      case '50':
        return 'Biometrik pasport (Qoraqalpog\'iston)';
      case '55':
        return 'Biometrik pasport (16 yoshgacha, Qoraqalpog\'iston)';
      case '70':
        return 'O\'zbekiston fuqarosi pasporti';
      case '71':
        return 'Qoraqalpog\'iston fuqarosi pasporti';
      case '501':
        return 'O\'zbekiston Respublikasi ID kartasi';
      case '502':
        return 'Chet el fuqarosi ID kartasi';
      case '503':
        return 'Chet el fuqarosi pasporti';
      case '504':
        return 'Fuqaroligi yo\'q shaxs hujjati';
      case '519':
        return 'Boshqa davlat fuqarosi hujjati';
      default:
        return 'Hujjat turi: $docTypeId';
    }
  }

  /// Sessiya holatini aniqlash
  static String getSessionStatusMessage(String? status) {
    if (status == null) return 'Noma\'lum holat';

    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'Jarayon davom etmoqda';
      case 'completed':
        return 'Muvaffaqiyatli yakunlandi';
      case 'failed':
        return 'Xato yuz berdi';
      case 'expired':
        return 'Sessiya muddati tugadi';
      case 'cancelled':
        return 'Bekor qilindi';
      case 'closed':
        return 'Sessiya yopildi';
      default:
        return 'Holat: $status';
    }
  }

  /// Xato uchun tavsiyalar
  static String getErrorSuggestion(String code) {
    switch (code) {
      case '1':
      case '2':
        return 'Pasport seriya va raqamini to\'g\'ri kiriting';
      case '3':
      case '4':
      case '14':
      case '17':
        return 'Yaxshi yoritilgan joyda aniqroq fotosurat oling';
      case '5':
      case '11':
      case '13':
      case '15':
      case '16':
      case '18':
      case '19':
        return 'Internet aloqangizni tekshiring va qayta urinib ko\'ring';
      case '6':
        return 'Jarayonni davom ettirish uchun qaytadan boshlang';
      case '21':
        return 'Ma\'lumotlaringizni tekshiring yoki qo\'llab-quvvatlash xizmatiga murojaat qiling';
      case '22':
        return 'Yoshingiz 16 dan katta bo\'lishi kerak';
      case '23':
        return 'Kamera linzasini tozalang va qayta urinib ko\'ring';
      case '26':
        return 'Yuzingizni to\'siq bo\'lmagan holda ko\'rsating';
      case '122':
        return 'Qo\'llab-quvvatlash xizmatiga murojaat qiling';
      default:
        return 'Qayta urinib ko\'ring yoki qo\'llab-quvvatlash xizmatiga murojaat qiling';
    }
  }

  /// To'liq xato ma'lumoti
  static Map<String, String> getFullErrorInfo(String code) {
    return {
      'message': getErrorMessage(code),
      'suggestion': getErrorSuggestion(code),
      'code': code,
    };
  }

  /// Xato dialog ko'rsatish uchun ma'lumot
  static Map<String, dynamic> getErrorDialogData(String code) {
    final info = getFullErrorInfo(code);
    return {
      'title': 'Xatolik',
      'message': info['message'],
      'suggestion': info['suggestion'],
      'code': code,
      'icon': _getErrorIcon(code),
      'color': _getErrorColor(code),
    };
  }

  /// Xato uchun icon
  static String _getErrorIcon(String code) {
    switch (code) {
      case '0':
        return 'success';
      case '6':
        return 'cancel';
      case '21':
        return 'person_off';
      case '122':
        return 'block';
      default:
        return 'error';
    }
  }

  /// Xato uchun rang
  static String _getErrorColor(String code) {
    switch (code) {
      case '0':
        return 'green';
      case '6':
        return 'orange';
      case '122':
        return 'red';
      default:
        return 'red';
    }
  }
}
