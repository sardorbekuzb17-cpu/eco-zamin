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
