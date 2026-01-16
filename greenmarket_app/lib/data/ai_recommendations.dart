// Bog'bon AI uchun ma'lumotlar bazasi

// Daraxt va o'simlik ma'lumotlari
class PlantInfo {
  final String id;
  final Map<String, String> name;
  final Map<String, String> description;
  final String category;
  final List<String> suitableClimates;
  final Map<String, String> plantingTime;
  final Map<String, String> careInstructions;
  final List<String> benefits;
  final String difficulty;

  PlantInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.suitableClimates,
    required this.plantingTime,
    required this.careInstructions,
    required this.benefits,
    required this.difficulty,
  });
}

class ClimateZone {
  final String id;
  final String name;
  final List<String> regions;
  final Map<String, String> characteristics;
  final List<String> recommendedPlants;
  final List<String> seasonalTips;

  ClimateZone({
    required this.id,
    required this.name,
    required this.regions,
    required this.characteristics,
    required this.recommendedPlants,
    required this.seasonalTips,
  });
}

class PlantDisease {
  final String id;
  final String name;
  final Map<String, String> description;
  final List<String> symptoms;
  final List<String> treatment;
  final List<String> prevention;
  final String severity;

  PlantDisease({
    required this.id,
    required this.name,
    required this.description,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
    required this.severity,
  });
}

// Batafsil o'simlik ma'lumotlari
final List<PlantInfo> plantDatabase = [
  // Mevali daraxtlar
  PlantInfo(
    id: 'apple',
    name: {'uz': 'Olma daraxti', 'ru': 'Яблоня', 'en': 'Apple tree'},
    description: {
      'uz':
          'Salqin iqlimga mos, yuqori hosildor mevali daraxt. Bahor gullab, kuzda meva beradi.',
      'ru':
          'Плодовое дерево, подходящее для прохладного климата. Цветет весной, плодоносит осенью.',
      'en':
          'Fruit tree suitable for cool climate. Blooms in spring, bears fruit in autumn.',
    },
    category: 'mevali_daraxt',
    suitableClimates: ['steppe', 'mountain'],
    plantingTime: {
      'uz': 'Bahor (mart-aprel) yoki kuz (oktyabr-noyabr)',
      'ru': 'Весна (март-апрель) или осень (октябрь-ноябрь)',
      'en': 'Spring (March-April) or autumn (October-November)',
    },
    careInstructions: {
      'uz':
          'Haftada 2-3 marta sug\'oring. Yiliga 2 marta budang. Qishda sovuqdan himoyalang.',
      'ru':
          'Поливайте 2-3 раза в неделю. Обрезайте 2 раза в год. Защищайте от холода зимой.',
      'en':
          'Water 2-3 times a week. Prune twice a year. Protect from cold in winter.',
    },
    benefits: ['Vitamin C manbai', 'Uzoq saqlash mumkin', 'Yuqori hosildorlik'],
    difficulty: 'o\'rta',
  ),

  PlantInfo(
    id: 'pomegranate',
    name: {'uz': 'Anor daraxti', 'ru': 'Гранат', 'en': 'Pomegranate tree'},
    description: {
      'uz':
          'Issiq va quruq iqlimga mos, dorivor xususiyatli meva. Uzoq umr ko\'radi.',
      'ru':
          'Подходит для жаркого и сухого климата, лечебные свойства. Долговечное дерево.',
      'en':
          'Suitable for hot and dry climate, medicinal properties. Long-lived tree.',
    },
    category: 'mevali_daraxt',
    suitableClimates: ['desert', 'subtropical'],
    plantingTime: {
      'uz': 'Bahor (mart-aprel)',
      'ru': 'Весна (март-апрель)',
      'en': 'Spring (March-April)',
    },
    careInstructions: {
      'uz':
          'Kam sug\'orish kerak. Qurg\'oqchilikka chidamli. Yiliga 1 marta budang.',
      'ru': 'Требует мало полива. Засухоустойчив. Обрезайте раз в год.',
      'en': 'Requires little watering. Drought resistant. Prune once a year.',
    },
    benefits: [
      'Antioksidant boy',
      'Qurg\'oqchilikka chidamli',
      'Dorivor xususiyatli',
    ],
    difficulty: 'oson',
  ),

  PlantInfo(
    id: 'walnut',
    name: {'uz': 'Yong\'oq daraxti', 'ru': 'Грецкий орех', 'en': 'Walnut tree'},
    description: {
      'uz':
          'Katta o\'sadigan, soyali daraxt. Foydali yong\'oq beradi. Uzoq umr ko\'radi.',
      'ru': 'Крупное теневое дерево. Дает полезные орехи. Долговечное.',
      'en': 'Large shade tree. Produces healthy nuts. Long-lived.',
    },
    category: 'mevali_daraxt',
    suitableClimates: ['steppe', 'mountain'],
    plantingTime: {
      'uz': 'Kuz (oktyabr-noyabr)',
      'ru': 'Осень (октябрь-ноябрь)',
      'en': 'Autumn (October-November)',
    },
    careInstructions: {
      'uz':
          'Chuqur sug\'orish kerak. Keng joy ajrating. Dastlabki 3 yil parvarish qiling.',
      'ru':
          'Требует глубокого полива. Выделите широкое место. Ухаживайте первые 3 года.',
      'en':
          'Requires deep watering. Allocate wide space. Care for the first 3 years.',
    },
    benefits: ['Soya beradi', 'Foydali yong\'oq', 'Uzoq umr ko\'radi'],
    difficulty: 'qiyin',
  ),

  // Bezak daraxtlari
  PlantInfo(
    id: 'plane_tree',
    name: {'uz': 'Chinor daraxti', 'ru': 'Платан', 'en': 'Plane tree'},
    description: {
      'uz':
          'Katta soyali daraxt. Shahar muhitiga mos. Chiroyli po\'st va barglar.',
      'ru':
          'Крупное теневое дерево. Подходит для городской среды. Красивая кора и листья.',
      'en':
          'Large shade tree. Suitable for urban environment. Beautiful bark and leaves.',
    },
    category: 'bezak_daraxt',
    suitableClimates: ['steppe', 'mountain'],
    plantingTime: {
      'uz': 'Bahor (mart-aprel)',
      'ru': 'Весна (март-апрель)',
      'en': 'Spring (March-April)',
    },
    careInstructions: {
      'uz': 'Ko\'p sug\'orish kerak. Tez o\'sadi. Yiliga 1 marta budang.',
      'ru': 'Требует много воды. Быстро растет. Обрезайте раз в год.',
      'en': 'Requires a lot of water. Grows fast. Prune once a year.',
    },
    benefits: ['Katta soya', 'Tez o\'sadi', 'Chiroyli ko\'rinish'],
    difficulty: 'o\'rta',
  ),

  PlantInfo(
    id: 'poplar',
    name: {'uz': 'Terak daraxti', 'ru': 'Тополь', 'en': 'Poplar tree'},
    description: {
      'uz':
          'Tez o\'sadigan, baland daraxt. Shamol to\'siq sifatida ishlatiladi.',
      'ru': 'Быстрорастущее высокое дерево. Используется как ветрозащита.',
      'en': 'Fast-growing tall tree. Used as windbreak.',
    },
    category: 'bezak_daraxt',
    suitableClimates: ['desert', 'steppe'],
    plantingTime: {
      'uz': 'Bahor (mart-may)',
      'ru': 'Весна (март-май)',
      'en': 'Spring (March-May)',
    },
    careInstructions: {
      'uz': 'Kam parvarish kerak. Qurg\'oqchilikka chidamli. Tez o\'sadi.',
      'ru': 'Требует мало ухода. Засухоустойчив. Быстро растет.',
      'en': 'Requires little care. Drought resistant. Grows fast.',
    },
    benefits: ['Tez o\'sadi', 'Shamol to\'siq', 'Kam parvarish'],
    difficulty: 'oson',
  ),
];

// O'zbekiston iqlim zonalari
final List<ClimateZone> climateZones = [
  ClimateZone(
    id: 'desert',
    name: 'Cho\'l va yarim cho\'l',
    regions: ['qoraqalpogiston', 'navoiy', 'buxoro_south'],
    characteristics: {
      'uz':
          'Quruq iqlim, kam yog\'ingarchilik (100-200mm/yil), issiq yoz (+45°C), sovuq qish (-15°C). Tuproq sho\'rlangan.',
      'ru':
          'Сухой климат, мало осадков (100-200мм/год), жаркое лето (+45°C), холодная зима (-15°C). Засоленные почвы.',
      'en':
          'Dry climate, low precipitation (100-200mm/year), hot summer (+45°C), cold winter (-15°C). Saline soils.',
    },
    recommendedPlants: [
      'anor',
      'terak',
      'tut',
      'uzum',
      'pistaxio',
      'badam',
      'saxaul',
      'qandak',
    ],
    seasonalTips: [
      'Bahor (mart-may): Ko\'chatlarni erta eking, sug\'orishni boshlang. Tuproqni tayyorlang.',
      'Yoz (iyun-avgust): Kuniga 2-3 marta sug\'oring. Soyali joylar yarating. Mulch qo\'ying.',
      'Kuz (sentyabr-noyabr): Qish uchun tayyorlang. Daraxtlarni budang. Sug\'orishni kamaytiring.',
      'Qish (dekabr-fevral): Sovuqdan himoyalang. Kam sug\'oring. Keyingi yil rejasini tuzing.',
    ],
  ),

  ClimateZone(
    id: 'steppe',
    name: 'Dasht va tog\'oldi',
    regions: [
      'tashkent_city',
      'tashkent',
      'sirdaryo',
      'jizzax',
      'samarqand',
      'qashqadaryo',
    ],
    characteristics: {
      'uz':
          'Mo\'tadil iqlim, yaxshi yog\'ingarchilik (300-600mm/yil), issiq yoz (+35°C), sovuq qish (-10°C). Unumli tuproq.',
      'ru':
          'Умеренный климат, хорошие осадки (300-600мм/год), жаркое лето (+35°C), холодная зима (-10°C). Плодородная почва.',
      'en':
          'Moderate climate, good precipitation (300-600mm/year), hot summer (+35°C), cold winter (-10°C). Fertile soil.',
    },
    recommendedPlants: [
      'olma',
      'nok',
      'olcha',
      'shaftoli',
      'uzum',
      'yong\'oq',
      'chinor',
      'terak',
    ],
    seasonalTips: [
      'Bahor (mart-may): Ekin ekish eng yaxshi vaqt. Tuproqni haydang va o\'g\'itlang.',
      'Yoz (iyun-avgust): Muntazam sug\'orish. Begona o\'tlarni tozalang. Kasalliklarni kuzating.',
      'Kuz (sentyabr-noyabr): Hosil yig\'ing. Qish uchun tayyorlang. Daraxtlarni budang.',
      'Qish (dekabr-fevral): Daraxtlarni budash. Qor ostida saqlash. Asboblarni ta\'mirlash.',
    ],
  ),

  ClimateZone(
    id: 'mountain',
    name: 'Tog\' va tog\'oldi',
    regions: ['fargona', 'namangan', 'andijon', 'surxondaryo_north'],
    characteristics: {
      'uz':
          'Salqin iqlim, ko\'p yog\'ingarchilik (400-800mm/yil), salqin yoz (+30°C), sovuq qish (-20°C). Tog\' tuprogi.',
      'ru':
          'Прохладный климат, много осадков (400-800мм/год), прохладное лето (+30°C), холодная зима (-20°C). Горная почва.',
      'en':
          'Cool climate, high precipitation (400-800mm/year), cool summer (+30°C), cold winter (-20°C). Mountain soil.',
    },
    recommendedPlants: [
      'olma',
      'nok',
      'gilos',
      'olcha',
      'yong\'oq',
      'chinor',
      'kartoshka',
      'karam',
    ],
    seasonalTips: [
      'Bahor (mart-may): Bahorgi sovuqdan ehtiyot bo\'ling. Asta-sekin ekishni boshlang.',
      'Yoz (iyun-avgust): Sug\'orish kam kerak. Tabiiy namlik yetarli. Begona o\'tlarni tozalang.',
      'Kuz (sentyabr-noyabr): Erta hosil yig\'ing. Qish uzoq davom etadi.',
      'Qish (dekabr-fevral): Qor ostida saqlang. Sovuqdan himoyalang. Budashni kechiktiring.',
    ],
  ),

  ClimateZone(
    id: 'subtropical',
    name: 'Subtropik',
    regions: ['surxondaryo_south', 'qashqadaryo_south'],
    characteristics: {
      'uz':
          'Issiq nam iqlim, uzun yoz (+40°C), qisqa qish (+5°C), ko\'p yog\'ingarchilik (500-700mm/yil).',
      'ru':
          'Жаркий влажный климат, долгое лето (+40°C), короткая зима (+5°C), много осадков (500-700мм/год).',
      'en':
          'Hot humid climate, long summer (+40°C), short winter (+5°C), high precipitation (500-700mm/year).',
    },
    recommendedPlants: [
      'anor',
      'anjir',
      'xurmo',
      'limon',
      'apelsin',
      'uzum',
      'paxta',
      'kungaboqar',
    ],
    seasonalTips: [
      'Bahor (mart-may): Erta ekish mumkin. Nam iqlimdan foydalaning.',
      'Yoz (iyun-avgust): Soyali joylar yarating. Ko\'p sug\'orish kerak emas.',
      'Kuz (sentyabr-noyabr): Ikkinchi hosil olish mumkin. Uzun o\'sish mavsumi.',
      'Qish (dekabr-fevral): Yengil sovuqdan himoyalang. Deyarli butun yil o\'sadi.',
    ],
  ),
];

// O'simlik kasalliklari va zararkunandalar
final List<PlantDisease> plantDiseases = [
  PlantDisease(
    id: 'aphid',
    name: 'Shiralar (Aphids)',
    description: {
      'uz':
          'Kichik yashil, qora yoki oq hasharotlar. Barglar va novda shiralarini so\'radi.',
      'ru':
          'Мелкие зеленые, черные или белые насекомые. Высасывают соки листьев и побегов.',
      'en':
          'Small green, black or white insects. Suck juices from leaves and shoots.',
    },
    symptoms: [
      'Barglar sarg\'ayadi va qiyshayadi',
      'Shirin shiralar ajraladi (honeydew)',
      'Chumolilar ko\'payadi',
      'O\'simlik sekin o\'sadi',
      'Barglar tushib ketadi',
    ],
    treatment: [
      'Sovun eritmasi (1 osh qoshiq sovun + 1 litr suv) bilan purkash',
      'Neem yog\'i ishlatish',
      'Tabiiy dushmanlarni jalb qilish (ladybug, lacewing)',
      'Zarar ko\'rgan qismlarni kesib tashlash',
      'Kuchli suv oqimi bilan yuvish',
    ],
    prevention: [
      'Muntazam tekshirish (haftada 1 marta)',
      'Ortiqcha azot o\'g\'iti bermaslik',
      'Havo almashinuvini yaxshilash',
      'Foydali hasharotlarni himoyalash',
      'Sog\'lom o\'simliklarni tanlash',
    ],
    severity: 'o\'rta',
  ),

  PlantDisease(
    id: 'powdery_mildew',
    name: 'Oq chirish (Powdery Mildew)',
    description: {
      'uz':
          'Barglar ustida oq kukun kabi qoplam paydo bo\'ladi. Zamburug\' kasalligi.',
      'ru':
          'На листьях появляется белый мучнистый налет. Грибковое заболевание.',
      'en': 'White powdery coating appears on leaves. Fungal disease.',
    },
    symptoms: [
      'Barglar ustida oq dog\'lar',
      'Barglar sarg\'ayadi va qurib ketadi',
      'O\'simlik zaiflanadi',
      'Hosil kamayadi',
      'Yomon hid chiqadi',
    ],
    treatment: [
      'Soda eritmasi (1 choy qoshiq soda + 1 litr suv) bilan purkash',
      'Fungitsid ishlatish (Bordeaux mixture)',
      'Zarar ko\'rgan barglarni olib tashlash',
      'Havo almashinuvini yaxshilash',
      'Quyosh nurini ko\'paytirish',
    ],
    prevention: [
      'Ortiqcha namlikdan saqlash',
      'Muntazam shamollash',
      'Zich ekmaslik',
      'Toza asboblar ishlatish',
      'Chidamli navlarni tanlash',
    ],
    severity: 'yuqori',
  ),

  PlantDisease(
    id: 'root_rot',
    name: 'Ildiz chirishi (Root Rot)',
    description: {
      'uz':
          'Ildizlar qorayadi va chirib ketadi. Ortiqcha namlik sabab bo\'ladi.',
      'ru': 'Корни чернеют и гниют. Причина - избыточная влажность.',
      'en': 'Roots turn black and rot. Caused by excessive moisture.',
    },
    symptoms: [
      'O\'simlik so\'lib ketadi',
      'Barglar sarg\'ayadi',
      'O\'sish to\'xtaydi',
      'Yomon hid chiqadi',
      'Ildizlar qorayadi',
    ],
    treatment: [
      'Sug\'orishni to\'xtatish',
      'Drenaj yaxshilash',
      'Fungitsid bilan davolash',
      'Sog\'lom tuproqqa ko\'chirish',
      'Chirigan qismlarni kesish',
    ],
    prevention: [
      'Ortiqcha sug\'ormaslik',
      'Yaxshi drenaj ta\'minlash',
      'Sifatli tuproq ishlatish',
      'Muntazam tekshirish',
      'To\'g\'ri sug\'orish rejimi',
    ],
    severity: 'yuqori',
  ),
];

// AI tavsiyalar generatori
class GardenerAI {
  static List<String> getRegionRecommendations(String region, String district) {
    // Viloyat bo'yicha iqlim zonasini aniqlash
    ClimateZone? zone;
    for (var z in climateZones) {
      if (z.regions.contains(region)) {
        zone = z;
        break;
      }
    }

    if (zone == null) {
      return [
        '❌ Kechirasiz, bu hudud uchun ma\'lumot topilmadi.',
        '📍 Mahalliy iqlim sharoitini o\'rganing',
        '🌱 Tuproq sifatini tekshiring',
        '📅 Mavsumiy o\'zgarishlarga e\'tibor bering',
        '👨‍🌾 Mahalliy bog\'bonlar bilan maslahatlashing',
      ];
    }

    List<String> recommendations = [];
    recommendations.add('🌍 ${zone.name} iqlim zonasi uchun tavsiyalar:');
    recommendations.add('');
    recommendations.add('📊 Iqlim xususiyatlari:');
    recommendations.add(zone.characteristics['uz'] ?? '');
    recommendations.add('');

    // Mos daraxtlarni topish
    List<PlantInfo> suitablePlants = plantDatabase
        .where((plant) => plant.suitableClimates.contains(zone!.id))
        .toList();

    if (suitablePlants.isNotEmpty) {
      recommendations.add('🌳 Tavsiya etiladigan daraxtlar:');
      for (var plant in suitablePlants.take(5)) {
        recommendations.add(
          '• ${plant.name['uz']} - ${plant.description['uz']}',
        );
        recommendations.add('  📅 Ekish vaqti: ${plant.plantingTime['uz']}');
        recommendations.add('  🔧 Qiyinlik darajasi: ${plant.difficulty}');
        recommendations.add('');
      }
    }

    recommendations.add('📅 Mavsumiy maslahatlar:');
    for (var tip in zone.seasonalTips) {
      recommendations.add('• $tip');
    }

    return recommendations;
  }

  static List<String> diagnosePlantProblem(List<String> symptoms) {
    List<String> diagnosis = [];
    List<PlantDisease> matchedDiseases = [];

    for (var disease in plantDiseases) {
      int matchCount = 0;
      for (var symptom in symptoms) {
        for (var diseaseSymptom in disease.symptoms) {
          if (diseaseSymptom.toLowerCase().contains(symptom.toLowerCase()) ||
              symptom.toLowerCase().contains(diseaseSymptom.toLowerCase())) {
            matchCount++;
            break;
          }
        }
      }

      if (matchCount > 0) {
        matchedDiseases.add(disease);
      }
    }

    if (matchedDiseases.isEmpty) {
      diagnosis.add(
        '❌ Aniq tashxis qo\'yish uchun qo\'shimcha ma\'lumot kerak.',
      );
      diagnosis.add('📸 Rasmlar yuklang yoki batafsil tavsif bering.');
      diagnosis.add('👨‍⚕️ Mahalliy mutaxassis bilan maslahatlashing.');
      return diagnosis;
    }

    // Eng mos kelgan kasallikni topish
    matchedDiseases.sort((a, b) {
      int aMatches = 0, bMatches = 0;
      for (var symptom in symptoms) {
        if (a.symptoms.any(
          (s) => s.toLowerCase().contains(symptom.toLowerCase()),
        )) {
          aMatches++;
        }
        if (b.symptoms.any(
          (s) => s.toLowerCase().contains(symptom.toLowerCase()),
        )) {
          bMatches++;
        }
      }
      return bMatches.compareTo(aMatches);
    });

    var topDisease = matchedDiseases.first;

    diagnosis.add('🔍 Ehtimoliy tashxis: ${topDisease.name}');
    diagnosis.add('📝 Tavsif: ${topDisease.description['uz']}');
    diagnosis.add('⚠️ Xavflilik darajasi: ${topDisease.severity}');
    diagnosis.add('');

    diagnosis.add('💊 Davolash usullari:');
    for (var treatment in topDisease.treatment) {
      diagnosis.add('• $treatment');
    }
    diagnosis.add('');

    diagnosis.add('🛡️ Oldini olish choralari:');
    for (var prevention in topDisease.prevention) {
      diagnosis.add('• $prevention');
    }

    if (matchedDiseases.length > 1) {
      diagnosis.add('');
      diagnosis.add('🔄 Boshqa ehtimoliy kasalliklar:');
      for (var disease in matchedDiseases.skip(1).take(2)) {
        diagnosis.add('• ${disease.name}');
      }
    }

    return diagnosis;
  }

  static List<String> getSeasonalTips(String season, String region) {
    // Viloyat bo'yicha iqlim zonasini aniqlash
    ClimateZone? zone;
    for (var z in climateZones) {
      if (z.regions.contains(region)) {
        zone = z;
        break;
      }
    }

    List<String> tips = [];

    // Umumiy mavsumiy maslahatlar
    Map<String, List<String>> generalTips = {
      'bahor': [
        '🌱 Tuproqni tayyorlang va o\'g\'itlang',
        '🌰 Urug\' va ko\'chatlarni eking',
        '🐛 Zararkunandalarga qarshi choralar ko\'ring',
        '💧 Sug\'orish tizimini tekshiring',
        '✂️ Qish budashini tugallang',
      ],
      'yoz': [
        '💧 Muntazam sug\'orish rejimini saqlang',
        '🌿 Begona o\'tlarni tozalang',
        '☂️ Soyali joylar yarating',
        '🔍 Kasalliklarni kuzatib boring',
        '🍃 Mulch qo\'ying (namlikni saqlash uchun)',
      ],
      'kuz': [
        '🍎 Hosil yig\'ing va saqlang',
        '❄️ Qish uchun tayyorgarlik ko\'ring',
        '✂️ Daraxtlarni budang',
        '🌱 Tuproqni qish uchun tayyorlang',
        '🍂 Qurugan barglarni yig\'ing',
      ],
      'qish': [
        '🧥 O\'simliklarni sovuqdan himoyalang',
        '❄️ Qor ostida saqlanishini ta\'minlang',
        '📋 Keyingi yil uchun reja tuzing',
        '🔧 Asboblarni ta\'mirlang va tayyorlang',
        '📚 Bog\'bonchilik bilimlarini oshiring',
      ],
    };

    tips.add('📅 ${season.toUpperCase()} mavsumi uchun maslahatlar:');
    tips.add('');

    // Umumiy maslahatlar
    tips.add('🌍 Umumiy maslahatlar:');
    for (var tip in generalTips[season] ?? []) {
      tips.add('• $tip');
    }
    tips.add('');

    // Iqlim zonasi bo'yicha maxsus maslahatlar
    if (zone != null) {
      tips.add('🏞️ ${zone.name} uchun maxsus maslahatlar:');
      var seasonalTip = zone.seasonalTips.firstWhere(
        (tip) => tip.toLowerCase().contains(season.toLowerCase()),
        orElse: () => 'Ushbu mavsum uchun maxsus maslahat topilmadi.',
      );
      tips.add('• $seasonalTip');
      tips.add('');

      // Mos o'simliklar
      List<PlantInfo> seasonalPlants = plantDatabase
          .where((plant) => plant.suitableClimates.contains(zone!.id))
          .toList();

      if (seasonalPlants.isNotEmpty) {
        tips.add('🌳 Bu mavsumda e\'tibor berish kerak bo\'lgan o\'simliklar:');
        for (var plant in seasonalPlants.take(3)) {
          tips.add('• ${plant.name['uz']}: ${plant.careInstructions['uz']}');
        }
      }
    }

    return tips;
  }
}
