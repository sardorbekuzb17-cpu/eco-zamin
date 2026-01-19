import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'uz': {
      // Header
      'location': 'Joylashuv',

      // Search
      'search_hint': "Mahsulotlarni qidirish...",

      // Seasonal offers
      'seasonal_offers': 'Mavsumiy Takliflar',
      'view_all': 'Barchasi',
      'discount': '30% Chegirma',
      'summer_fruits': "Bahorgi Ko'chatlar To'plami",
      'buy_now': 'Xarid qilish',
      'organic': 'Organik',
      'green_vegetables': 'Mevali Daraxtlar',
      'view': "Ko'rish",

      // Categories
      'all': 'Barchasi',
      'trees': 'Daraxtlar 🌳',
      'flowers': 'Gullar 🌸',
      'seedlings': "Ko'chatlar 🌱",
      'seeds': "Urug'lar 🌾",
      'bulbs': 'Gul tuvagi 🌷',
      'accessories': 'Aksessuar 🧰',

      // Products
      'popular_products': 'Ommabop Mahsulotlar',
      'filter': 'Filtr',
      'new_badge': 'Yangi',

      // Bottom nav
      'home': 'Bosh sahifa',
      'catalog': 'Katalog',
      'cart': 'Savatcha',
      'profile': 'Profil',

      // Language
      'language': 'Til',
      'uzbek': "O'zbekcha",
      'russian': 'Ruscha',
      'english': 'Inglizcha',

      // Cart & Profile
      'clear': 'Tozalash',
      'cart_empty': 'Savat bo\'sh',
      'total': 'Jami',
      'checkout': 'Buyurtma berish',
      'guest': 'Mehmon',
      'favorites': 'Sevimlilar',
      'orders': 'Buyurtmalar',
      'addresses': 'Manzillar',
      'help': 'Yordam',
      'about': 'Ilova haqida',

      // Notifications
      'notifications': 'Bildirishnomalar',
      'mark_all_read': 'Barchasini o\'qilgan deb belgilash',
      'no_notifications': 'Bildirishnomalar yo\'q',

      // MyID
      'myid_title': 'MyID orqali kirish',
      'myid_subtitle':
          'O\'zbekiston Respublikasining rasmiy identifikatsiya tizimi',
      'myid_login_button': 'MyID orqali kirish',
      'myid_sdk_button': 'MyID SDK ni boshlash',
      'myid_session_ready': 'Session tayyor',
      'myid_session_ready_desc':
          'MyID SDK orqali identifikatsiya qilish uchun tayyor',
      'myid_session_expiry': 'Session 10 daqiqa amal qiladi',
      'myid_info_message':
          'MyID ilovasini telefoningizga o\'rnatgan bo\'lishingiz kerak',
      'myid_creating_session': 'Session yaratilmoqda...',
      'myid_verifying': 'Identifikatsiya qilinmoqda...',
      'myid_saving_data': 'Ma\'lumotlar saqlanmoqda...',
      'myid_please_wait': 'Iltimos, kuting...',
      'myid_success_title': 'Muvaffaqiyatli!',
      'myid_success_message':
          'MyID orqali identifikatsiya muvaffaqiyatli o\'tdi',
      'myid_verified': 'Tasdiqlandi',
      'myid_redirecting': 'Bosh sahifaga yo\'naltirilmoqda...',
      'myid_error_title': 'Xatolik yuz berdi',
      'myid_network_error': 'Tarmoq bilan bog\'lanishda xatolik',
      'myid_network_error_desc':
          'Internet aloqangizni tekshiring va qayta urinib ko\'ring',
      'myid_session_error': 'Session yaratishda xatolik',
      'myid_session_error_desc':
          'Session yaratib bo\'lmadi. Iltimos, qayta urinib ko\'ring',
      'myid_session_not_found': 'Session ID topilmadi',
      'myid_session_expired': 'Session muddati tugadi',
      'myid_session_expired_desc':
          'Session muddati tugagan. Iltimos, qayta boshlang',
      'myid_verification_failed': 'Identifikatsiya muvaffaqiyatsiz',
      'myid_verification_failed_desc':
          'Yuzingizni aniq ko\'rsating va qayta urinib ko\'ring',
      'myid_cancelled': 'Bekor qilindi',
      'myid_cancelled_desc': 'MyID jarayoni bekor qilindi',
      'myid_sdk_error': 'MyID SDK xatosi',
      'myid_sdk_error_desc':
          'SDK ishga tushmadi. Iltimos, qayta urinib ko\'ring',
      'myid_data_error': 'Ma\'lumotlarni saqlashda xatolik',
      'myid_data_error_desc': 'Ma\'lumotlarni saqlash muvaffaqiyatsiz bo\'ldi',
      'myid_server_error': 'Server xatosi',
      'myid_server_error_desc':
          'Server bilan bog\'lanishda muammo. Keyinroq qayta urinib ko\'ring',
      'myid_timeout': 'Vaqt tugadi',
      'myid_timeout_desc':
          'Jarayon juda uzoq davom etdi. Qayta urinib ko\'ring',
      'myid_unknown_error': 'Noma\'lum xato',
      'myid_unknown_error_desc': 'Kutilmagan xatolik yuz berdi',
      'myid_try_again': 'Qayta urinish',
      'myid_go_back': 'Orqaga',
      'myid_contact_support': 'Yordam xizmatiga murojaat qiling',
    },
    'ru': {
      // Header
      'location': 'Местоположение',

      // Search
      'search_hint': 'Поиск товаров...',

      // Seasonal offers
      'seasonal_offers': 'Сезонные Предложения',
      'view_all': 'Все',
      'discount': 'Скидка 30%',
      'summer_fruits': 'Весенний Набор Саженцев',
      'buy_now': 'Купить',
      'organic': 'Органик',
      'green_vegetables': 'Плодовые Деревья',
      'view': 'Смотреть',

      // Categories
      'all': 'Все',
      'trees': 'Деревья 🌳',
      'flowers': 'Цветы 🌸',
      'seedlings': 'Рассада 🌱',
      'seeds': 'Семена 🌾',
      'bulbs': 'Луковицы 🌷',
      'accessories': 'Аксессуары 🧰',

      // Products
      'popular_products': 'Популярные Товары',
      'filter': 'Фильтр',
      'new_badge': 'Новинка',

      // Bottom nav
      'home': 'Главная',
      'catalog': 'Каталог',
      'cart': 'Корзина',
      'profile': 'Профиль',

      // Language
      'language': 'Язык',
      'uzbek': 'Узбекский',
      'russian': 'Русский',
      'english': 'Английский',

      // Cart & Profile
      'clear': 'Очистить',
      'cart_empty': 'Корзина пуста',
      'total': 'Итого',
      'checkout': 'Оформить заказ',
      'guest': 'Гость',
      'favorites': 'Избранное',
      'orders': 'Заказы',
      'addresses': 'Адреса',
      'help': 'Помощь',
      'about': 'О приложении',

      // Notifications
      'notifications': 'Уведомления',
      'mark_all_read': 'Отметить все как прочитанные',
      'no_notifications': 'Нет уведомлений',

      // MyID
      'myid_title': 'Вход через MyID',
      'myid_subtitle':
          'Официальная система идентификации Республики Узбекистан',
      'myid_login_button': 'Войти через MyID',
      'myid_sdk_button': 'Запустить MyID SDK',
      'myid_session_ready': 'Сессия готова',
      'myid_session_ready_desc': 'Готово к идентификации через MyID SDK',
      'myid_session_expiry': 'Сессия действительна 10 минут',
      'myid_info_message':
          'У вас должно быть установлено приложение MyID на телефоне',
      'myid_creating_session': 'Создание сессии...',
      'myid_verifying': 'Идентификация...',
      'myid_saving_data': 'Сохранение данных...',
      'myid_please_wait': 'Пожалуйста, подождите...',
      'myid_success_title': 'Успешно!',
      'myid_success_message': 'Идентификация через MyID прошла успешно',
      'myid_verified': 'Подтверждено',
      'myid_redirecting': 'Перенаправление на главную страницу...',
      'myid_error_title': 'Произошла ошибка',
      'myid_network_error': 'Ошибка подключения к сети',
      'myid_network_error_desc':
          'Проверьте подключение к интернету и попробуйте снова',
      'myid_session_error': 'Ошибка создания сессии',
      'myid_session_error_desc':
          'Не удалось создать сессию. Пожалуйста, попробуйте снова',
      'myid_session_not_found': 'Session ID не найден',
      'myid_session_expired': 'Срок действия сессии истёк',
      'myid_session_expired_desc':
          'Срок действия сессии истёк. Пожалуйста, начните заново',
      'myid_verification_failed': 'Идентификация не удалась',
      'myid_verification_failed_desc': 'Покажите лицо чётко и попробуйте снова',
      'myid_cancelled': 'Отменено',
      'myid_cancelled_desc': 'Процесс MyID был отменён',
      'myid_sdk_error': 'Ошибка MyID SDK',
      'myid_sdk_error_desc': 'SDK не запустился. Пожалуйста, попробуйте снова',
      'myid_data_error': 'Ошибка сохранения данных',
      'myid_data_error_desc': 'Не удалось сохранить данные',
      'myid_server_error': 'Ошибка сервера',
      'myid_server_error_desc':
          'Проблема с подключением к серверу. Попробуйте позже',
      'myid_timeout': 'Время истекло',
      'myid_timeout_desc':
          'Процесс занял слишком много времени. Попробуйте снова',
      'myid_unknown_error': 'Неизвестная ошибка',
      'myid_unknown_error_desc': 'Произошла непредвиденная ошибка',
      'myid_try_again': 'Попробовать снова',
      'myid_go_back': 'Назад',
      'myid_contact_support': 'Обратитесь в службу поддержки',
    },
    'en': {
      // Header
      'location': 'Location',

      // Search
      'search_hint': 'Search products...',

      // Seasonal offers
      'seasonal_offers': 'Seasonal Offers',
      'view_all': 'View All',
      'discount': '30% Off',
      'summer_fruits': 'Spring Seedlings Collection',
      'buy_now': 'Buy Now',
      'organic': 'Organic',
      'green_vegetables': 'Fruit Trees',
      'view': 'View',

      // Categories
      'all': 'All',
      'trees': 'Trees 🌳',
      'flowers': 'Flowers 🌸',
      'seedlings': 'Seedlings 🌱',
      'seeds': 'Seeds 🌾',
      'bulbs': 'Bulbs 🌷',
      'accessories': 'Accessories 🧰',

      // Products
      'popular_products': 'Popular Products',
      'filter': 'Filter',
      'new_badge': 'New',

      // Bottom nav
      'home': 'Home',
      'catalog': 'Catalog',
      'cart': 'Cart',
      'profile': 'Profile',

      // Language
      'language': 'Language',
      'uzbek': 'Uzbek',
      'russian': 'Russian',
      'english': 'English',

      // Cart & Profile
      'clear': 'Clear',
      'cart_empty': 'Cart is empty',
      'total': 'Total',
      'checkout': 'Checkout',
      'guest': 'Guest',
      'favorites': 'Favorites',
      'orders': 'Orders',
      'addresses': 'Addresses',
      'help': 'Help',
      'about': 'About',

      // Notifications
      'notifications': 'Notifications',
      'mark_all_read': 'Mark all as read',
      'no_notifications': 'No notifications',

      // MyID
      'myid_title': 'Login with MyID',
      'myid_subtitle':
          'Official identification system of the Republic of Uzbekistan',
      'myid_login_button': 'Login with MyID',
      'myid_sdk_button': 'Start MyID SDK',
      'myid_session_ready': 'Session ready',
      'myid_session_ready_desc': 'Ready for identification via MyID SDK',
      'myid_session_expiry': 'Session valid for 10 minutes',
      'myid_info_message': 'You must have the MyID app installed on your phone',
      'myid_creating_session': 'Creating session...',
      'myid_verifying': 'Verifying...',
      'myid_saving_data': 'Saving data...',
      'myid_please_wait': 'Please wait...',
      'myid_success_title': 'Success!',
      'myid_success_message': 'MyID identification completed successfully',
      'myid_verified': 'Verified',
      'myid_redirecting': 'Redirecting to home page...',
      'myid_error_title': 'An error occurred',
      'myid_network_error': 'Network connection error',
      'myid_network_error_desc': 'Check your internet connection and try again',
      'myid_session_error': 'Session creation error',
      'myid_session_error_desc': 'Failed to create session. Please try again',
      'myid_session_not_found': 'Session ID not found',
      'myid_session_expired': 'Session expired',
      'myid_session_expired_desc': 'Session has expired. Please start over',
      'myid_verification_failed': 'Verification failed',
      'myid_verification_failed_desc': 'Show your face clearly and try again',
      'myid_cancelled': 'Cancelled',
      'myid_cancelled_desc': 'MyID process was cancelled',
      'myid_sdk_error': 'MyID SDK error',
      'myid_sdk_error_desc': 'SDK failed to start. Please try again',
      'myid_data_error': 'Data saving error',
      'myid_data_error_desc': 'Failed to save data',
      'myid_server_error': 'Server error',
      'myid_server_error_desc': 'Problem connecting to server. Try again later',
      'myid_timeout': 'Timeout',
      'myid_timeout_desc': 'Process took too long. Try again',
      'myid_unknown_error': 'Unknown error',
      'myid_unknown_error_desc': 'An unexpected error occurred',
      'myid_try_again': 'Try again',
      'myid_go_back': 'Go back',
      'myid_contact_support': 'Contact support',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['uz']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['uz', 'ru', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
