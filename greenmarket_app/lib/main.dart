import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'l10n/app_localizations.dart';
import 'data/regions.dart';
import 'data/products.dart';
import 'screens/gardener_ai_screen.dart';
import 'screens/checkout_screen.dart';
import 'services/notification_service.dart';
import 'services/ad_service.dart';
import 'services/version_service.dart';
import 'services/security_service.dart';
import 'services/myid_backend_service.dart';
import 'widgets/force_update_dialog.dart';

import 'screens/myid_direct_sdk_screen.dart';
import 'screens/myid_oauth_test_screen.dart';
import 'screens/myid_oauth_full_login_screen.dart';
import 'screens/myid_complete_login_screen.dart';
import 'screens/myid_backend_login_screen.dart';
import 'screens/myid_passport_input_screen.dart';
import 'screens/myid_profile_screen.dart';
import 'screens/myid_main_login_screen.dart';
import 'screens/admin_users_screen.dart';
import 'screens/myid_simple_test_screen.dart';
import 'screens/myid_diagram_flow_screen.dart';
import 'screens/myid_api_flow_screen.dart';
import 'screens/myid_simple_flow_screen.dart';
import 'screens/myid_sdk_flow_screen.dart';
import 'screens/myid_simple_auth_screen.dart';
import 'screens/myid_empty_session_screen.dart';
import 'screens/myid_empty_session_simple_screen.dart';
import 'screens/myid_sdk_direct_screen.dart';
import 'screens/myid_complete_flow_screen.dart';
import 'screens/myid_passport_session_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔒 XAVFSIZLIK TEKSHIRUVI - vaqtincha o'chirilgan (test uchun)
  // final securityCheck = await SecurityService.performSecurityCheck();
  // if (!securityCheck.isPassed && !kDebugMode) {
  //   if (kDebugMode) {
  //     debugPrint('⚠️ Xavfsizlik tekshiruvi: ${securityCheck.message}');
  //   }
  //   await SecurityService.onSecurityViolation();
  //   return;
  // }

  // Bildirishnomalarni sozlash
  try {
    await initializeTimezone();
    await NotificationService.initialize();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Bildirishnoma sozlashda xato: $e');
    }
  }

  // Reklamalarni sozlash
  try {
    await AdService.initialize();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Reklama sozlashda xato: $e');
    }
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const GreenMarketApp());
}

class GreenMarketApp extends StatefulWidget {
  const GreenMarketApp({super.key});

  static void setLocale(BuildContext context, Locale locale) {
    _GreenMarketAppState? state = context
        .findAncestorStateOfType<_GreenMarketAppState>();
    state?.setLocale(locale);
  }

  @override
  State<GreenMarketApp> createState() => _GreenMarketAppState();
}

class _GreenMarketAppState extends State<GreenMarketApp> {
  Locale _locale = const Locale('uz');

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  // Saqlangan tilni yuklash
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language');
    if (savedLanguage != null) {
      setState(() {
        _locale = Locale(savedLanguage);
      });
    }
  }

  // Tilni o'zgartirish va saqlash
  void setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });

    // Tanlangan tilni local storage'da saqlash
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenMarket',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [Locale('uz'), Locale('ru'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        scaffoldBackgroundColor: const Color(0xFFF8FAF9),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF15803D),
          secondary: Color(0xFFDCFCE7),
          surface: Color(0xFFFFFFFF),
          error: Color(0xFFEF4444),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => MyIdSdkFlowScreen(),
        '/direct-sdk': (context) => const MyIdDirectSdkScreen(),
        '/api-flow': (context) => const MyIdApiFlowScreen(),
        '/sdk-flow': (context) => const MyIdSimpleFlowScreen(),
        '/simple-auth': (context) => const MyIdSimpleAuthScreen(),
        '/empty-session': (context) => const MyIdEmptySessionScreen(),
        '/empty-session-simple': (context) =>
            const MyIdEmptySessionSimpleScreen(),
        '/sdk-direct': (context) => const MyIdSdkDirectScreen(),
        '/passport-session': (context) => const MyIdPassportSessionScreen(),
        '/complete-flow': (context) => const MyIdCompleteFlowScreen(),
        '/oauth-test': (context) => const MyIdOAuthTestScreen(),
        '/oauth-login': (context) => const MyIdOAuthFullLoginScreen(),
        '/complete-login': (context) => const MyIdCompleteLoginScreen(),
        '/backend-login': (context) => const MyIdBackendLoginScreen(),
        '/passport-input': (context) => const MyIdPassportInputScreen(),
        '/profile': (context) => const MyIdProfileScreen(),
        '/admin-users': (context) => const AdminUsersScreen(),
        '/simple-test': (context) => const MyIdSimpleTestScreen(),
        '/diagram-flow': (context) => const MyIdDiagramFlowScreen(),
      },
    );
  }
}

// Auth Wrapper - foydalanuvchi kirganmi tekshiradi
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAuthentication(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return const HomePage();
        }

        return const MyIdMainLoginScreen();
      },
    );
  }

  Future<bool> _checkAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    return userData != null;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _currentIndex = 0;
  String _selectedRegion = 'tashkent_city';
  String _selectedDistrict = 'chilonzor';
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Like'lar uchun
  Set<String> _userLikedProducts = {};

  // Mavsumiy eslatgichlar
  bool _seasonalRemindersEnabled = false;

  // MyID autentifikatsiya holati
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;

  // Bildirishnomalar uchun
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': {
        'uz': 'Xush kelibsiz!',
        'ru': 'Добро пожаловать!',
        'en': 'Welcome!',
      },
      'message': {
        'uz':
            'Green Market ilovasiga xush kelibsiz. Yangi mahsulotlarimiz bilan tanishing!',
        'ru':
            'Добро пожаловать в приложение Green Market. Ознакомьтесь с нашими новыми продуктами!',
        'en': 'Welcome to Green Market app. Check out our new products!',
      },
      'time': '5 min',
      'isRead': false,
      'icon': Icons.celebration,
    },
    {
      'id': '2',
      'title': {'uz': 'Chegirma!', 'ru': 'Скидка!', 'en': 'Discount!'},
      'message': {
        'uz': 'Bahorgi ko\'chatlar to\'plamiga 30% chegirma!',
        'ru': 'Скидка 30% на весенний набор саженцев!',
        'en': '30% off on spring seedlings collection!',
      },
      'time': '1 soat',
      'isRead': false,
      'icon': Icons.local_offer,
    },
    {
      'id': '3',
      'title': {
        'uz': 'Yangi mahsulotlar',
        'ru': 'Новые товары',
        'en': 'New products',
      },
      'message': {
        'uz': 'Yangi gul tuvaklari qo\'shildi. Ko\'rib chiqing!',
        'ru': 'Добавлены новые луковицы цветов. Посмотрите!',
        'en': 'New flower bulbs added. Check them out!',
      },
      'time': '2 soat',
      'isRead': true,
      'icon': Icons.new_releases,
    },
  ];

  int get _unreadNotificationCount =>
      _notifications.where((n) => !n['isRead']).length;

  // Savat uchun
  final Map<String, int> _cartItems = {}; // productId -> quantity

  // Vercel API URL
  static const String _apiUrl = 'https://greenmarket-api.vercel.app/api/likes';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Lifecycle observer
    _loadLikes();
    _loadSeasonalRemindersStatus();
    _checkForUpdate(); // Versiyani tekshirish
    _startSecurityMonitoring(); // Xavfsizlik monitoringi
    _checkLoginStatus(); // MyID holatini tekshirish
  }

  // Davriy xavfsizlik tekshiruvi
  void _startSecurityMonitoring() {
    // Har 5 daqiqada xavfsizlikni tekshirish
    Future.delayed(const Duration(minutes: 5), () async {
      if (!mounted) return;

      final securityCheck = await SecurityService.performSecurityCheck();
      if (!securityCheck.isPassed && !kDebugMode) {
        await SecurityService.onSecurityViolation();
      } else {
        _startSecurityMonitoring(); // Keyingi tekshiruv
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  // Versiya yangilanishini tekshirish
  Future<void> _checkForUpdate() async {
    final updateInfo = await VersionService.checkForUpdate();

    if (updateInfo['needsUpdate'] == true && mounted) {
      // Majburiy yangilanish dialog'ini ko'rsatish
      showDialog(
        context: context,
        barrierDismissible:
            !updateInfo['isForceUpdate'], // Majburiy bo'lsa yopib bo'lmaydi
        builder: (context) => ForceUpdateDialog(
          currentVersion: updateInfo['currentVersion'],
          latestVersion: updateInfo['latestVersion'],
          updateMessage: updateInfo['updateMessage'],
          downloadUrl: updateInfo['downloadUrl'],
          langCode: _langCode,
          isForceUpdate: updateInfo['isForceUpdate'],
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Ilova qayta ochilganda tekshirish
    if (state == AppLifecycleState.resumed) {
      _checkForUpdate();
    }
  }

  Future<void> _loadLikes() async {
    final prefs = await SharedPreferences.getInstance();
    final userLiked = prefs.getStringList('user_liked') ?? [];

    // Serverdan like'larni yuklash
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final likes = data['likes'] as Map<String, dynamic>? ?? {};
        for (var product in allProducts) {
          product.likeCount = (likes[product.id] ?? 0) as int;
        }
      }
    } catch (e) {
      debugPrint('Server error: $e');
    }

    setState(() {
      _userLikedProducts = userLiked.toSet();
      for (var product in allProducts) {
        product.isFavorite = _userLikedProducts.contains(product.id);
      }
    });
  }

  Future<void> _toggleLike(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final isLiking = !_userLikedProducts.contains(product.id);

    setState(() {
      if (isLiking) {
        _userLikedProducts.add(product.id);
        product.isFavorite = true;
        product.likeCount++;
      } else {
        _userLikedProducts.remove(product.id);
        product.isFavorite = false;
        if (product.likeCount > 0) product.likeCount--;
      }
    });

    await prefs.setStringList('user_liked', _userLikedProducts.toList());

    // Serverga saqlash
    try {
      await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'productId': product.id,
          'action': isLiking ? 'like' : 'unlike',
        }),
      );
    } catch (e) {
      debugPrint('Server error: $e');
    }
  }

  AppLocalizations get l10n => AppLocalizations.of(context)!;
  String get _langCode => Localizations.localeOf(context).languageCode;

  // Qidiruv bo'yicha filter - rus va o'zbek tillarida
  List<Product> get _filteredProducts {
    List<Product> products = allProducts;

    // Kategoriya bo'yicha filter
    if (_selectedCategory != 'all') {
      products = products
          .where((p) => p.category == _selectedCategory)
          .toList();
    }

    // Qidiruv bo'yicha filter - barcha tillarda qidiradi
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      products = products.where((p) {
        // Barcha tillarda qidirish
        final nameUz = p.getName('uz').toLowerCase();
        final nameRu = p.getName('ru').toLowerCase();
        final nameTr = p.getName('tr').toLowerCase();
        return nameUz.contains(query) ||
            nameRu.contains(query) ||
            nameTr.contains(query);
      }).toList();
    }

    return products;
  }

  String get _locationText {
    final region = uzbekistanRegions.firstWhere(
      (r) => r.name == _selectedRegion,
    );
    final district = region.districts.firstWhere(
      (d) => d.name == _selectedDistrict,
    );
    return '${region.getName(_langCode)}, ${district.getName(_langCode)}';
  }

  // Bildirishnomalar sahifasini ko'rsatish
  void _showNotificationsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: const Color(0xFFF8FAF9),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1A2E1A)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              l10n.translate('notifications'),
              style: const TextStyle(
                color: Color(0xFF1A2E1A),
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (_notifications.any((n) => !n['isRead']))
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (var n in _notifications) {
                        n['isRead'] = true;
                      }
                    });
                    Navigator.pop(context);
                    _showNotificationsPage();
                  },
                  child: Text(
                    l10n.translate('mark_all_read'),
                    style: const TextStyle(color: Color(0xFF15803D)),
                  ),
                ),
            ],
          ),
          body: _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.translate('no_notifications'),
                        style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final isRead = notification['isRead'] as bool;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.white : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isRead
                              ? Colors.grey[200]!
                              : const Color(0xFF15803D).withValues(alpha: 0.3),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isRead
                                ? Colors.grey[100]
                                : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            notification['icon'] as IconData,
                            color: isRead
                                ? Colors.grey
                                : const Color(0xFF15803D),
                          ),
                        ),
                        title: Text(
                          (notification['title']
                                  as Map<String, String>)[_langCode] ??
                              '',
                          style: TextStyle(
                            fontWeight: isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                            color: const Color(0xFF1A2E1A),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              (notification['message']
                                      as Map<String, String>)[_langCode] ??
                                  '',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notification['time'] as String,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: !isRead
                            ? Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF15803D),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            notification['isRead'] = true;
                          });
                          Navigator.pop(context);
                          _showNotificationsPage();
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _showLocationDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => LocationSelector(
          scrollController: scrollController,
          selectedRegion: _selectedRegion,
          selectedDistrict: _selectedDistrict,
          langCode: _langCode,
          onLocationSelected: (region, district) {
            setState(() {
              _selectedRegion = region;
              _selectedDistrict = district;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('language'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2E1A),
              ),
            ),
            const SizedBox(height: 20),
            _buildLanguageOption(
              "🇺🇿",
              l10n.translate('uzbek'),
              const Locale('uz'),
            ),
            _buildLanguageOption(
              "🇷🇺",
              l10n.translate('russian'),
              const Locale('ru'),
            ),
            _buildLanguageOption(
              "🇬🇧",
              l10n.translate('english'),
              const Locale('en'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String flag, String name, Locale locale) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 28)),
      title: Text(
        name,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing:
          Localizations.localeOf(context).languageCode == locale.languageCode
          ? const Icon(Icons.check_circle, color: Color(0xFF15803D))
          : null,
      onTap: () {
        GreenMarketApp.setLocale(context, locale);
        Navigator.pop(context);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor:
          Localizations.localeOf(context).languageCode == locale.languageCode
          ? const Color(0xFFF0FDF4)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Orqaga qaytishni to'xtatamiz
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Async gap dan OLDIN context va langCode'ni saqlaymiz
        final savedContext = context;
        final currentLangCode = _langCode;

        // Orqaga qaytganda versiyani tekshiramiz
        await _checkForUpdate();

        // Agar yangilanish kerak bo'lmasa, ilovadan chiqish
        if (!mounted) return;

        final shouldExit = await showDialog<bool>(
          // ignore: use_build_context_synchronously
          context: savedContext,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              currentLangCode == 'uz'
                  ? 'Ilovadan chiqish'
                  : currentLangCode == 'ru'
                  ? 'Выход из приложения'
                  : 'Exit App',
            ),
            content: Text(
              currentLangCode == 'uz'
                  ? 'Ilovadan chiqmoqchimisiz?'
                  : currentLangCode == 'ru'
                  ? 'Вы хотите выйти из приложения?'
                  : 'Do you want to exit the app?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  currentLangCode == 'uz'
                      ? 'Yo\'q'
                      : currentLangCode == 'ru'
                      ? 'Нет'
                      : 'No',
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  currentLangCode == 'uz'
                      ? 'Ha'
                      : currentLangCode == 'ru'
                      ? 'Да'
                      : 'Yes',
                  style: const TextStyle(color: Color(0xFFEF4444)),
                ),
              ),
            ],
          ),
        );

        // showDialog dan keyin yana mounted tekshiruvi
        if (!mounted) return;

        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: SafeArea(child: _buildCurrentPage()),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildCurrentPage() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        _buildHomePage(),
        _buildCatalogPage(),
        const GardenerAIScreen(),
        _buildCartPage(),
        _buildProfilePage(),
      ],
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 24),
          _buildSeasonalOffers(),
          const SizedBox(height: 24),
          _buildCategories(),
          const SizedBox(height: 24),
          _buildPopularProducts(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('location'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _showLocationDialog,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF15803D),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _locationText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2E1A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[500],
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              // Til tanlash tugmasi
              GestureDetector(
                onTap: _showLanguageDialog,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.language,
                      size: 24,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Bildirishnoma tugmasi
              GestureDetector(
                onTap: _showNotificationsPage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(Icons.notifications_outlined, size: 24),
                      ),
                      if (_unreadNotificationCount > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '$_unreadNotificationCount',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search, color: Colors.grey[400], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: l10n.translate('search_hint'),
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close, color: Colors.grey, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonalOffers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.translate('seasonal_offers'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2E1A),
                ),
              ),
              Text(
                l10n.translate('view_all'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF15803D),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildPromoCard(
                title: l10n.translate('summer_fruits'),
                badge: l10n.translate('discount'),
                buttonText: l10n.translate('buy_now'),
                isPrimary: true,
                imagePath: 'assets/images/spring_seedlings.jpg',
              ),
              const SizedBox(width: 16),
              _buildPromoCard(
                title: l10n.translate('green_vegetables'),
                badge: l10n.translate('organic'),
                buttonText: l10n.translate('view'),
                isPrimary: false,
                imageUrl:
                    'https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=300',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard({
    required String title,
    required String badge,
    required String buttonText,
    required bool isPrimary,
    String? imageUrl,
    String? imagePath,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF15803D) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(24),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: const Color(0xFF15803D).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
        border: isPrimary
            ? null
            : Border.all(color: const Color(0xFF15803D).withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? Colors.white.withValues(alpha: 0.2)
                        : const Color(0xFF15803D).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPrimary ? Colors.white : const Color(0xFF15803D),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 160,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isPrimary ? Colors.white : const Color(0xFF14532D),
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isPrimary ? Colors.white : const Color(0xFF15803D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isPrimary ? const Color(0xFF15803D) : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -10,
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imagePath != null
                  ? Image.asset(
                      imagePath,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 140,
                        height: 140,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Image.network(
                      imageUrl ?? '',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 140,
                        height: 140,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'key': 'all', 'value': 'all'},
      {'key': 'trees', 'value': 'trees'},
      {'key': 'flowers', 'value': 'flowers'},
      {'key': 'seedlings', 'value': 'seedlings'},
      {'key': 'seeds', 'value': 'seeds'},
      {'key': 'bulbs', 'value': 'bulbs'},
      {'key': 'accessories', 'value': 'accessories'},
    ];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = _selectedCategory == cat['value'];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat['value'] as String;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF15803D) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: isActive
                      ? null
                      : Border.all(color: Colors.grey[300]!),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF15803D,
                            ).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  l10n.translate(cat['key'] as String),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularProducts() {
    final products = _filteredProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _searchQuery.isNotEmpty
                    ? 'Natijalar: ${products.length} ta'
                    : l10n.translate('popular_products'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2E1A),
                ),
              ),
              Text(
                l10n.translate('filter'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF15803D),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (products.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Mahsulot topilmadi',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) =>
                  _buildProductCardNew(products[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildProductCardNew(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showProductImage(product),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAF9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: product.image.startsWith('assets/')
                            ? Image.asset(
                                product.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                              )
                            : Image.network(
                                product.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  product.getName(_langCode),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2E1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.getUnit(_langCode),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.price.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (m) => '${m[1]},',
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15803D),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _addToCart(product),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF15803D),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF15803D,
                              ).withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => _toggleLike(product),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: product.isFavorite
                      ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                      : Colors.grey[100]!.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      product.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 16,
                      color: product.isFavorite
                          ? const Color(0xFFEF4444)
                          : Colors.grey[400],
                    ),
                    if (product.likeCount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '${product.likeCount}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: product.isFavorite
                              ? const Color(0xFFEF4444)
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (product.isNew)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l10n.translate('new_badge'),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Savatga qo'shish
  void _addToCart(Product product) {
    setState(() {
      _cartItems[product.id] = (_cartItems[product.id] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.getName(_langCode)} savatga qo\'shildi'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF15803D),
      ),
    );
  }

  // Savat soni
  int get _cartItemCount {
    return _cartItems.values.fold(0, (sum, qty) => sum + qty);
  }

  // Rasmni kattalashtirish
  void _showProductImage(Product product) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // Rasm
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: product.image.startsWith('assets/')
                    ? Image.asset(product.image, fit: BoxFit.contain)
                    : Image.network(product.image, fit: BoxFit.contain),
              ),
            ),
            // Yopish tugmasi
            Positioned(
              top: 40,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
            // Mahsulot nomi
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.getName(_langCode),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} so\'m',
                      style: const TextStyle(
                        color: Color(0xFF4ADE80),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Katalog sahifasi
  Widget _buildCatalogPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Text(
              l10n.translate('catalog'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2E1A),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 24),
          _buildCategories(),
          const SizedBox(height: 24),
          _buildPopularProducts(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // Savat sahifasi
  Widget _buildCartPage() {
    final cartProducts = allProducts
        .where((p) => _cartItems.containsKey(p.id))
        .toList();
    final total = cartProducts.fold<int>(
      0,
      (sum, p) => sum + (p.price * (_cartItems[p.id] ?? 0)),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.translate('cart'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2E1A),
                ),
              ),
              if (_cartItems.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() => _cartItems.clear());
                  },
                  child: Text(
                    l10n.translate('clear'),
                    style: const TextStyle(color: Color(0xFFEF4444)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.translate('cart_empty'),
                        style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: cartProducts.length,
                  itemBuilder: (context, index) {
                    final product = cartProducts[index];
                    final qty = _cartItems[product.id] ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: product.image.startsWith('assets/')
                                ? Image.asset(
                                    product.image,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    product.image,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.getName(_langCode),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} so\'m',
                                  style: const TextStyle(
                                    color: Color(0xFF15803D),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (qty > 1) {
                                      _cartItems[product.id] = qty - 1;
                                    } else {
                                      _cartItems.remove(product.id);
                                    }
                                  });
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                                color: Colors.grey,
                              ),
                              Text(
                                '$qty',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _cartItems[product.id] = qty + 1;
                                  });
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                color: const Color(0xFF15803D),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        if (_cartItems.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('total'),
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    Text(
                      '${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} so\'m',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(
                          cartItems: _cartItems,
                          total: total,
                          products: allProducts,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.translate('checkout'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Profil sahifasi
  Widget _buildProfilePage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.person, size: 50, color: Color(0xFF15803D)),
          ),
          const SizedBox(height: 16),
          Text(
            _isLoggedIn && _userData != null
                ? _userData!['name'] ?? 'Foydalanuvchi'
                : l10n.translate('guest'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2E1A),
            ),
          ),
          if (_isLoggedIn &&
              _userData != null &&
              _userData!['phone'] != null &&
              _userData!['phone'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _userData!['phone'],
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          const SizedBox(height: 32),

          // MyID orqali kirish yoki chiqish
          if (!_isLoggedIn)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loginWithMyID,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066cc),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Profilga kirish',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (!_isLoggedIn) const SizedBox(height: 32),

          // Menu items
          _buildProfileMenuItem(
            Icons.favorite_outline,
            l10n.translate('favorites'),
            () {},
          ),
          _buildProfileMenuItem(Icons.history, l10n.translate('orders'), () {}),
          _buildProfileMenuItem(
            Icons.location_on_outlined,
            l10n.translate('addresses'),
            () {},
          ),
          _buildProfileMenuItem(
            Icons.language,
            l10n.translate('language'),
            _showLanguageDialog,
          ),
          _buildSeasonalReminderSwitch(),
          _buildProfileMenuItem(
            Icons.help_outline,
            l10n.translate('help'),
            () {},
          ),
          _buildProfileMenuItem(
            Icons.info_outline,
            l10n.translate('about'),
            () {},
          ),

          // Chiqish tugmasi (agar kirgan bo'lsa)
          if (_isLoggedIn)
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _logout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text(
                        'Chiqish',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF15803D)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSeasonalReminderSwitch() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.notifications_active, color: Color(0xFF15803D)),
      ),
      title: const Text(
        'Mavsumiy eslatgichlar',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: const Text(
        'Bog\'bonchilik maslahatlari',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Switch(
        value: _seasonalRemindersEnabled,
        onChanged: (value) async {
          setState(() {
            _seasonalRemindersEnabled = value;
          });
          await NotificationService.toggleSeasonalReminders(value);

          if (value) {
            // Darhol test bildirishnomasi ko'rsatish
            await NotificationService.showNotification(
              id: 999,
              title: '🌱 Mavsumiy eslatgichlar yoqildi',
              body:
                  'Endi siz bog\'bonchilik bo\'yicha muntazam maslahatlar olasiz!',
            );
          }
        },
        activeTrackColor: const Color(0xFF15803D).withValues(alpha: 0.5),
        activeThumbColor: const Color(0xFF15803D),
      ),
    );
  }

  Future<void> _loadSeasonalRemindersStatus() async {
    final status = await NotificationService.getSeasonalRemindersStatus();
    setState(() {
      _seasonalRemindersEnabled = status;
    });
  }

  // MyID login holatini tekshirish
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (userData != null) {
      setState(() {
        _isLoggedIn = true;
        _userData = json.decode(userData);
      });
    }
  }

  // MyID orqali kirish
  Future<void> _loginWithMyID() async {
    // Pasport va tug'ilgan sana bilan login dialog
    final TextEditingController nameController = TextEditingController();
    final TextEditingController passportSeriesController =
        TextEditingController();
    final TextEditingController passportNumberController =
        TextEditingController();
    final TextEditingController birthDateController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.badge, color: Color(0xFF15803D)),
            SizedBox(width: 8),
            Text('Profilga kirish'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Ism va Familiya',
                  hintText: 'Masalan: Sardor Karimov',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: passportSeriesController,
                      decoration: InputDecoration(
                        labelText: 'Seriya',
                        hintText: 'AA',
                        prefixIcon: const Icon(Icons.credit_card),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: passportNumberController,
                      decoration: InputDecoration(
                        labelText: 'Raqam',
                        hintText: '1234567',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 7,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: birthDateController,
                decoration: InputDecoration(
                  labelText: 'Tug\'ilgan sana',
                  hintText: 'KK.OO.YYYY',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.datetime,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1940),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    birthDateController.text =
                        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                  }
                },
                readOnly: true,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ma\'lumotlaringiz xavfsiz saqlanadi',
                        style: TextStyle(color: Colors.blue[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Iltimos, ism va familiyangizni kiriting'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              if (passportSeriesController.text.trim().isEmpty ||
                  passportNumberController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Iltimos, pasport ma\'lumotlarini kiriting'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              if (birthDateController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Iltimos, tug\'ilgan sanangizni kiriting'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Kirish'),
          ),
        ],
      ),
    );

    if (result == true) {
      // Loading dialog ko'rsatish
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('MyID orqali tekshirilmoqda...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Backend orqali pasport tekshirish
      final backendResponse = await MyIdBackendService.verifyPassport(
        passportSeries: passportSeriesController.text.trim().toUpperCase(),
        passportNumber: passportNumberController.text.trim(),
        birthDate: birthDateController.text.trim(),
      );

      // Loading dialog yopish
      if (mounted) {
        Navigator.pop(context);
      }

      // Backend javobini tekshirish
      if (backendResponse['success'] == true) {
        // Backend muvaffaqiyatli javob berdi
        final userData = {
          'name': nameController.text.trim(),
          'passport':
              '${passportSeriesController.text.trim().toUpperCase()}${passportNumberController.text.trim()}',
          'birthDate': birthDateController.text.trim(),
          'timestamp': DateTime.now().toIso8601String(),
          'verified': true, // Backend orqali tasdiqlangan
          'verificationData': backendResponse['data'],
        };

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(userData));

        setState(() {
          _isLoggedIn = true;
          _userData = userData;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ MyID orqali tasdiqlandi! Xush kelibsiz, ${userData['name']}!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Backend xato qaytardi - lekin local saqlaymiz
        final userData = {
          'name': nameController.text.trim(),
          'passport':
              '${passportSeriesController.text.trim().toUpperCase()}${passportNumberController.text.trim()}',
          'birthDate': birthDateController.text.trim(),
          'timestamp': DateTime.now().toIso8601String(),
          'verified': false, // Backend orqali tasdiqlanmagan
        };

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(userData));

        setState(() {
          _isLoggedIn = true;
          _userData = userData;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '⚠️ MyID tekshiruvida xatolik: ${backendResponse['error']}\nLekin mahalliy saqlandingiz.',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }

    nameController.dispose();
    passportSeriesController.dispose();
    passportNumberController.dispose();
    birthDateController.dispose();
  }

  // Chiqish
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('myid_code');

    setState(() {
      _isLoggedIn = false;
      _userData = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tizimdan chiqdingiz'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              _buildNavItem(Icons.home, l10n.translate('home'), 0),
              _buildNavItem(Icons.search, l10n.translate('catalog'), 1),
              _buildNavItem(Icons.psychology, 'Bog\'bon AI', 2),
              _buildNavItem(
                Icons.shopping_cart,
                l10n.translate('cart'),
                3,
                badge: _cartItemCount > 0 ? '$_cartItemCount' : null,
              ),
              _buildNavItem(Icons.person_outline, l10n.translate('profile'), 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index, {
    String? badge,
  }) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _currentIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isActive)
                Container(
                  width: 44,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF15803D).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: const Color(0xFF15803D), size: 22),
                )
              else
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(icon, color: Colors.grey[500], size: 26),
                    if (badge != null)
                      Positioned(
                        top: -4,
                        right: -8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              badge,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? const Color(0xFF15803D) : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Joylashuv tanlash widgeti
class LocationSelector extends StatefulWidget {
  final ScrollController scrollController;
  final String selectedRegion;
  final String selectedDistrict;
  final String langCode;
  final Function(String region, String district) onLocationSelected;

  const LocationSelector({
    super.key,
    required this.scrollController,
    required this.selectedRegion,
    required this.selectedDistrict,
    required this.langCode,
    required this.onLocationSelected,
  });

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  late String _tempRegion;
  late String _tempDistrict;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tempRegion = widget.selectedRegion;
    _tempDistrict = widget.selectedDistrict;
  }

  List<Region> get _filteredRegions {
    if (_searchQuery.isEmpty) return uzbekistanRegions;
    return uzbekistanRegions.where((r) {
      final regionMatch = r
          .getName(widget.langCode)
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final districtMatch = r.districts.any(
        (d) => d
            .getName(widget.langCode)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()),
      );
      return regionMatch || districtMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sarlavha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Joylashuvni tanlang',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2E1A),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Qidiruv
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Viloyat yoki tumanni qidiring...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF15803D)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Viloyatlar ro'yxati
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: _filteredRegions.length,
              itemBuilder: (context, index) {
                final region = _filteredRegions[index];
                final isSelected = region.name == _tempRegion;

                return ExpansionTile(
                  initiallyExpanded: isSelected,
                  leading: Icon(
                    Icons.location_city,
                    color: isSelected
                        ? const Color(0xFF15803D)
                        : Colors.grey[400],
                  ),
                  title: Text(
                    region.getName(widget.langCode),
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF15803D)
                          : const Color(0xFF1A2E1A),
                    ),
                  ),
                  children: region.districts.map((district) {
                    final isDistrictSelected =
                        region.name == _tempRegion &&
                        district.name == _tempDistrict;
                    return ListTile(
                      contentPadding: const EdgeInsets.only(
                        left: 56,
                        right: 16,
                      ),
                      leading: Icon(
                        isDistrictSelected
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: isDistrictSelected
                            ? const Color(0xFF15803D)
                            : Colors.grey[400],
                        size: 20,
                      ),
                      title: Text(
                        district.getName(widget.langCode),
                        style: TextStyle(
                          fontWeight: isDistrictSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isDistrictSelected
                              ? const Color(0xFF15803D)
                              : const Color(0xFF1A2E1A),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _tempRegion = region.name;
                          _tempDistrict = district.name;
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // Tasdiqlash tugmasi
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () =>
                  widget.onLocationSelected(_tempRegion, _tempDistrict),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Tasdiqlash',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
