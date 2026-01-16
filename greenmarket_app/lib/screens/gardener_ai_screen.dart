import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../l10n/app_localizations.dart';
import '../data/regions.dart';

class GardenerAIScreen extends StatefulWidget {
  const GardenerAIScreen({super.key});

  @override
  State<GardenerAIScreen> createState() => _GardenerAIScreenState();
}

class _GardenerAIScreenState extends State<GardenerAIScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRegion = 'tashkent_city';
  String _selectedDistrict = 'chilonzor';
  String _selectedSeason = 'bahor';
  final List<String> _selectedSymptoms = [];
  List<String> _aiResponse = [];
  bool _isLoading = false;

  final List<String> _seasons = ['bahor', 'yoz', 'kuz', 'qish'];
  final List<String> _commonSymptoms = [
    'Barglar sarg\'ayadi',
    'Barglar qiyshayadi',
    'Oq dog\'lar paydo bo\'ladi',
    'O\'simlik so\'lib ketadi',
    'Barglar qurib ketadi',
    'Yomon hid chiqadi',
    'Hasharotlar ko\'rinadi',
    'O\'sish sekin',
    'Barglar tushib ketadi',
    'Ildizlar qorayadi',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  AppLocalizations get l10n => AppLocalizations.of(context)!;
  String get _langCode => Localizations.localeOf(context).languageCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A2E1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF15803D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Bog\'bon AI',
              style: TextStyle(
                color: Color(0xFF1A2E1A),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF15803D),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF15803D),
          tabs: const [
            Tab(text: 'Tavsiyalar', icon: Icon(Icons.lightbulb_outline)),
            Tab(text: 'Doktor', icon: Icon(Icons.medical_services_outlined)),
            Tab(text: 'Mavsumiy', icon: Icon(Icons.calendar_today_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecommendationsTab(),
          _buildDoctorTab(),
          _buildSeasonalTab(),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildLocationSelector(),
          const SizedBox(height: 20),
          _buildGetRecommendationsButton(),
          if (_aiResponse.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildAIResponseCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildDoctorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDoctorWelcomeCard(),
          const SizedBox(height: 20),
          _buildSymptomsSelector(),
          const SizedBox(height: 20),
          _buildDiagnoseButton(),
          if (_aiResponse.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildAIResponseCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildSeasonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSeasonalWelcomeCard(),
          const SizedBox(height: 20),
          _buildSeasonSelector(),
          const SizedBox(height: 20),
          _buildLocationSelector(),
          const SizedBox(height: 20),
          _buildGetSeasonalTipsButton(),
          if (_aiResponse.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildAIResponseCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF15803D), Color(0xFF22C55E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF15803D).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Bog\'bon AI Yordamchisi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'O\'zbekiston hududlari bo\'yicha iqlim sharoitlariga mos daraxt va o\'simliklar tavsiya beraman. Viloyat va tumaningizni tanlang!',
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFF87171)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'O\'simlik Doktori',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'O\'simliklaringizning kasalliklari va zararkunandalarini aniqlashda yordam beraman. Belgilarni tanlang va tashxis oling!',
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonalWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Mavsumiy Maslahatlar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Har bir mavsum uchun maxsus maslahatlar beraman. Mavsumni va hududingizni tanlang!',
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelector() {
    final region = uzbekistanRegions.firstWhere(
      (r) => r.name == _selectedRegion,
    );
    final district = region.districts.firstWhere(
      (d) => d.name == _selectedDistrict,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Joylashuvingizni tanlang:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showLocationDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF15803D).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF15803D)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${region.getName(_langCode)}, ${district.getName(_langCode)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A2E1A),
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'O\'simliklaringizda qanday belgilar bor?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonSymptoms.map((symptom) {
              final isSelected = _selectedSymptoms.contains(symptom);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedSymptoms.remove(symptom);
                    } else {
                      _selectedSymptoms.add(symptom);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFEF4444)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFEF4444)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    symptom,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mavsumni tanlang:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _seasons.map((season) {
              final isSelected = _selectedSeason == season;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSeason = season;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF3B82F6)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      season.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGetRecommendationsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _getRecommendations,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF15803D),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Tavsiyalar olish',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildDiagnoseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedSymptoms.isEmpty || _isLoading
            ? null
            : _diagnosePlant,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Tashxis qo\'yish',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildGetSeasonalTipsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _getSeasonalTips,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Mavsumiy maslahatlar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildAIResponseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF15803D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Javobi:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2E1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._aiResponse.map(
            (response) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                response,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ),
        ],
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

  void _getRecommendations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Online API dan ma'lumot olish
      final response = await http
          .post(
            Uri.parse('https://greenmarket-api.vercel.app/api/gardener-ai'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'action': 'recommendations',
              'region': _selectedRegion,
              'district': _selectedDistrict,
              'language': _langCode,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> recommendations = [];

        recommendations.add('🌍 ${data['climate']['name']}');
        recommendations.add('');
        recommendations.add('📊 Iqlim xususiyatlari:');
        recommendations.add(data['climate']['characteristics']);
        recommendations.add('');

        if (data['plants'] != null && (data['plants'] as List).isNotEmpty) {
          recommendations.add('🌳 Tavsiya etiladigan daraxtlar:');
          for (var plant in data['plants']) {
            recommendations.add('');
            recommendations.add('• ${plant['name']}');
            recommendations.add('  📝 ${plant['description']}');
            recommendations.add('  📅 Ekish vaqti: ${plant['plantingTime']}');
            recommendations.add('  💧 Sug\'orish: ${plant['waterNeeds']}');
            recommendations.add('  ☀️ Quyosh: ${plant['sunlight']}');
            recommendations.add('  🌱 Tuproq: ${plant['soilType']}');
            recommendations.add('  🔧 Qiyinlik: ${plant['difficulty']}');
          }
        }

        setState(() {
          _aiResponse = recommendations;
          _isLoading = false;
        });
      } else {
        throw Exception('Server javob bermadi');
      }
    } catch (e) {
      // Offline rejim - mahalliy ma'lumotlardan foydalanish
      debugPrint('Online xatolik: $e - Offline rejimga o\'tilmoqda');

      List<String> recommendations = [];
      recommendations.add('📡 Offline rejim (Internet aloqasi yo\'q)');
      recommendations.add('');

      // Viloyat bo'yicha oddiy tavsiyalar
      if (_selectedRegion.contains('tashkent') ||
          _selectedRegion.contains('samarqand')) {
        recommendations.add('🌍 Dasht va tog\'oldi iqlim zonasi');
        recommendations.add('');
        recommendations.add('📊 Iqlim: Mo\'tadil, yaxshi yog\'ingarchilik');
        recommendations.add('');
        recommendations.add('🌳 Tavsiya etiladigan daraxtlar:');
        recommendations.add('');
        recommendations.add('• Olma daraxti');
        recommendations.add('  📅 Ekish: Mart-Aprel yoki Oktyabr-Noyabr');
        recommendations.add('  💧 Sug\'orish: Haftada 2-3 marta');
        recommendations.add('  🔧 Qiyinlik: O\'rta');
        recommendations.add('');
        recommendations.add('• Yong\'oq daraxti');
        recommendations.add('  📅 Ekish: Oktyabr-Noyabr');
        recommendations.add('  💧 Sug\'orish: Chuqur sug\'orish');
        recommendations.add('  🔧 Qiyinlik: Qiyin');
      } else if (_selectedRegion.contains('fargona') ||
          _selectedRegion.contains('namangan')) {
        recommendations.add('🌍 Tog\' va tog\'oldi iqlim zonasi');
        recommendations.add('');
        recommendations.add('📊 Iqlim: Salqin, ko\'p yog\'ingarchilik');
        recommendations.add('');
        recommendations.add('🌳 Tavsiya etiladigan daraxtlar:');
        recommendations.add('');
        recommendations.add('• Olma daraxti');
        recommendations.add('  📅 Ekish: Mart-Aprel');
        recommendations.add('  💧 Sug\'orish: Kam kerak');
        recommendations.add('  🔧 Qiyinlik: O\'rta');
      } else {
        recommendations.add('🌍 Cho\'l va yarim cho\'l iqlim zonasi');
        recommendations.add('');
        recommendations.add('📊 Iqlim: Quruq, kam yog\'ingarchilik');
        recommendations.add('');
        recommendations.add('🌳 Tavsiya etiladigan daraxtlar:');
        recommendations.add('');
        recommendations.add('• Anor daraxti');
        recommendations.add('  📅 Ekish: Mart-Aprel');
        recommendations.add('  💧 Sug\'orish: Kam kerak');
        recommendations.add('  🔧 Qiyinlik: Oson');
        recommendations.add('');
        recommendations.add('• Uzum toki');
        recommendations.add('  📅 Ekish: Mart-Aprel');
        recommendations.add('  💧 Sug\'orish: Haftada 2-3 marta');
        recommendations.add('  🔧 Qiyinlik: O\'rta');
      }

      setState(() {
        _aiResponse = recommendations;
        _isLoading = false;
      });
    }
  }

  void _diagnosePlant() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Online API dan tashxis olish
      final response = await http.post(
        Uri.parse('https://greenmarket-api.vercel.app/api/gardener-ai'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'diagnose',
          'symptoms': _selectedSymptoms,
          'language': _langCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final diagnosis = data['diagnosis'];

        List<String> result = [];
        result.add('🔍 Tashxis: ${diagnosis['disease']}');
        result.add('');
        result.add('📝 Tavsif:');
        result.add(diagnosis['description']);
        result.add('');
        result.add('💊 Davolash usullari:');
        for (var treatment in diagnosis['treatment']) {
          result.add('• $treatment');
        }
        result.add('');
        result.add('🛡️ Oldini olish:');
        for (var prevention in diagnosis['prevention']) {
          result.add('• $prevention');
        }

        setState(() {
          _aiResponse = result;
          _isLoading = false;
        });
      } else {
        throw Exception('Tashxis qo\'yishda xatolik');
      }
    } catch (e) {
      setState(() {
        _aiResponse = [
          '❌ Xatolik yuz berdi: $e',
          '',
          '📡 Internet aloqasini tekshiring',
          '🔄 Qaytadan urinib ko\'ring',
        ];
        _isLoading = false;
      });
    }
  }

  void _getSeasonalTips() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Online API dan mavsumiy maslahatlar olish
      final response = await http.post(
        Uri.parse('https://greenmarket-api.vercel.app/api/gardener-ai'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'seasonal',
          'season': _selectedSeason,
          'region': _selectedRegion,
          'language': _langCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<String> tips = [];
        tips.add(
          '📅 ${_selectedSeason.toUpperCase()} mavsumi uchun maslahatlar:',
        );
        tips.add('');

        for (var tip in data['tips']) {
          tips.add('• $tip');
        }

        setState(() {
          _aiResponse = tips;
          _isLoading = false;
        });
      } else {
        throw Exception('Maslahatlar olishda xatolik');
      }
    } catch (e) {
      setState(() {
        _aiResponse = [
          '❌ Xatolik yuz berdi: $e',
          '',
          '📡 Internet aloqasini tekshiring',
          '🔄 Qaytadan urinib ko\'ring',
        ];
        _isLoading = false;
      });
    }
  }
}

// Location Selector Widget (regions.dart dan import qilinadi)
class LocationSelector extends StatefulWidget {
  final ScrollController scrollController;
  final String selectedRegion;
  final String selectedDistrict;
  final String langCode;
  final Function(String, String) onLocationSelected;

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
  late String _selectedRegion;
  late String _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _selectedRegion = widget.selectedRegion;
    _selectedDistrict = widget.selectedDistrict;
  }

  @override
  Widget build(BuildContext context) {
    final selectedRegionData = uzbekistanRegions.firstWhere(
      (r) => r.name == _selectedRegion,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Joylashuvni tanlang',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Viloyat:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: uzbekistanRegions.length,
              itemBuilder: (context, index) {
                final region = uzbekistanRegions[index];
                final isSelected = region.name == _selectedRegion;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRegion = region.name;
                      _selectedDistrict = region.districts.first.name;
                    });
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF15803D)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF15803D)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_city,
                          color: isSelected ? Colors.white : Colors.grey[600],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          region.getName(widget.langCode),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tuman:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: selectedRegionData.districts.length,
              itemBuilder: (context, index) {
                final district = selectedRegionData.districts[index];
                final isSelected = district.name == _selectedDistrict;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDistrict = district.name;
                    });
                    widget.onLocationSelected(
                      _selectedRegion,
                      _selectedDistrict,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF15803D)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF15803D)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF15803D),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          district.getName(widget.langCode),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF1A2E1A),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
