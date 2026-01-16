class Region {
  final String name;
  final Map<String, String> translations;
  final List<District> districts;

  Region({
    required this.name,
    required this.translations,
    required this.districts,
  });

  String getName(String langCode) =>
      translations[langCode] ?? translations['uz']!;
}

class District {
  final String name;
  final Map<String, String> translations;

  District({required this.name, required this.translations});

  String getName(String langCode) =>
      translations[langCode] ?? translations['uz']!;
}

final List<Region> uzbekistanRegions = [
  // Toshkent shahri
  Region(
    name: 'tashkent_city',
    translations: {
      'uz': 'Toshkent shahri',
      'ru': 'Город Ташкент',
      'tr': 'Taşkent Şehri',
    },
    districts: [
      District(
        name: 'bektemir',
        translations: {'uz': 'Bektemir', 'ru': 'Бектемир', 'tr': 'Bektemir'},
      ),
      District(
        name: 'chilonzor',
        translations: {'uz': 'Chilonzor', 'ru': 'Чиланзар', 'tr': 'Çilanzar'},
      ),
      District(
        name: 'yashnobod',
        translations: {'uz': 'Yashnobod', 'ru': 'Яшнабад', 'tr': 'Yaşnabad'},
      ),
      District(
        name: 'mirobod',
        translations: {'uz': 'Mirobod', 'ru': 'Мирабад', 'tr': 'Mirabad'},
      ),
      District(
        name: 'mirzo_ulugbek',
        translations: {
          'uz': 'Mirzo Ulug\'bek',
          'ru': 'Мирзо Улугбек',
          'tr': 'Mirzo Uluğbek',
        },
      ),
      District(
        name: 'sergeli',
        translations: {'uz': 'Sergeli', 'ru': 'Сергели', 'tr': 'Sergeli'},
      ),
      District(
        name: 'shayxontohur',
        translations: {
          'uz': 'Shayxontohur',
          'ru': 'Шайхантахур',
          'tr': 'Şayhantahur',
        },
      ),
      District(
        name: 'olmazor',
        translations: {'uz': 'Olmazor', 'ru': 'Алмазар', 'tr': 'Almazar'},
      ),
      District(
        name: 'uchtepa',
        translations: {'uz': 'Uchtepa', 'ru': 'Учтепа', 'tr': 'Üçtepe'},
      ),
      District(
        name: 'yakkasaroy',
        translations: {
          'uz': 'Yakkasaroy',
          'ru': 'Яккасарай',
          'tr': 'Yakkasaray',
        },
      ),
      District(
        name: 'yunusobod',
        translations: {'uz': 'Yunusobod', 'ru': 'Юнусабад', 'tr': 'Yunusabad'},
      ),
    ],
  ),

  // Toshkent viloyati
  Region(
    name: 'tashkent_region',
    translations: {
      'uz': 'Toshkent viloyati',
      'ru': 'Ташкентская область',
      'tr': 'Taşkent Vilayeti',
    },
    districts: [
      District(
        name: 'nurafshon',
        translations: {'uz': 'Nurafshon', 'ru': 'Нурафшан', 'tr': 'Nurafşan'},
      ),
      District(
        name: 'olmaliq',
        translations: {'uz': 'Olmaliq', 'ru': 'Алмалык', 'tr': 'Almalık'},
      ),
      District(
        name: 'angren',
        translations: {'uz': 'Angren', 'ru': 'Ангрен', 'tr': 'Angren'},
      ),
      District(
        name: 'bekobod',
        translations: {'uz': 'Bekobod', 'ru': 'Бекабад', 'tr': 'Bekabad'},
      ),
      District(
        name: 'chirchiq',
        translations: {'uz': 'Chirchiq', 'ru': 'Чирчик', 'tr': 'Çirçik'},
      ),
      District(
        name: 'ohangaron',
        translations: {'uz': 'Ohangaron', 'ru': 'Ахангаран', 'tr': 'Ahangaran'},
      ),
      District(
        name: 'bostonliq',
        translations: {
          'uz': 'Bo\'stonliq',
          'ru': 'Бостанлык',
          'tr': 'Bostanlık',
        },
      ),
      District(
        name: 'zangiota',
        translations: {'uz': 'Zangiota', 'ru': 'Зангиата', 'tr': 'Zangiata'},
      ),
      District(
        name: 'qibray',
        translations: {'uz': 'Qibray', 'ru': 'Кибрай', 'tr': 'Kibray'},
      ),
      District(
        name: 'parkent',
        translations: {'uz': 'Parkent', 'ru': 'Паркент', 'tr': 'Parkent'},
      ),
      District(
        name: 'piskent',
        translations: {'uz': 'Piskent', 'ru': 'Пскент', 'tr': 'Piskent'},
      ),
      District(
        name: 'quyichirchiq',
        translations: {
          'uz': 'Quyi Chirchiq',
          'ru': 'Нижнечирчикский',
          'tr': 'Aşağı Çirçik',
        },
      ),
      District(
        name: 'ortachirchiq',
        translations: {
          'uz': 'O\'rta Chirchiq',
          'ru': 'Среднечирчикский',
          'tr': 'Orta Çirçik',
        },
      ),
      District(
        name: 'yuqorichirchiq',
        translations: {
          'uz': 'Yuqori Chirchiq',
          'ru': 'Верхнечирчикский',
          'tr': 'Yukarı Çirçik',
        },
      ),
    ],
  ),

  // Andijon viloyati
  Region(
    name: 'andijan',
    translations: {
      'uz': 'Andijon viloyati',
      'ru': 'Андижанская область',
      'tr': 'Andican Vilayeti',
    },
    districts: [
      District(
        name: 'andijon_sh',
        translations: {
          'uz': 'Andijon shahri',
          'ru': 'Город Андижан',
          'tr': 'Andican Şehri',
        },
      ),
      District(
        name: 'xonobod',
        translations: {'uz': 'Xonobod', 'ru': 'Ханабад', 'tr': 'Hanabad'},
      ),
      District(
        name: 'andijon_t',
        translations: {
          'uz': 'Andijon tumani',
          'ru': 'Андижанский район',
          'tr': 'Andican İlçesi',
        },
      ),
      District(
        name: 'asaka',
        translations: {'uz': 'Asaka', 'ru': 'Асака', 'tr': 'Asaka'},
      ),
      District(
        name: 'baliqchi',
        translations: {'uz': 'Baliqchi', 'ru': 'Балыкчи', 'tr': 'Balıkçı'},
      ),
      District(
        name: 'boz',
        translations: {'uz': 'Bo\'z', 'ru': 'Боз', 'tr': 'Boz'},
      ),
      District(
        name: 'buloqboshi',
        translations: {
          'uz': 'Buloqboshi',
          'ru': 'Булакбаши',
          'tr': 'Bulakbaşı',
        },
      ),
      District(
        name: 'izboskan',
        translations: {'uz': 'Izboskan', 'ru': 'Избоскан', 'tr': 'İzboskan'},
      ),
      District(
        name: 'jalaquduq',
        translations: {
          'uz': 'Jalaquduq',
          'ru': 'Джалакудук',
          'tr': 'Calakuduk',
        },
      ),
      District(
        name: 'xojaobod',
        translations: {'uz': 'Xo\'jaobod', 'ru': 'Ходжаабад', 'tr': 'Hocaabad'},
      ),
      District(
        name: 'qorgontepa',
        translations: {
          'uz': 'Qo\'rg\'ontepa',
          'ru': 'Кургантепа',
          'tr': 'Kurgantepe',
        },
      ),
      District(
        name: 'marhamat',
        translations: {'uz': 'Marhamat', 'ru': 'Мархамат', 'tr': 'Merhamet'},
      ),
      District(
        name: 'oltinkol',
        translations: {'uz': 'Oltinko\'l', 'ru': 'Алтынкуль', 'tr': 'Altınköl'},
      ),
      District(
        name: 'paxtaobod',
        translations: {'uz': 'Paxtaobod', 'ru': 'Пахтаабад', 'tr': 'Pahtaabad'},
      ),
      District(
        name: 'shahrixon',
        translations: {'uz': 'Shahrixon', 'ru': 'Шахрихан', 'tr': 'Şahrihan'},
      ),
      District(
        name: 'ulugnar',
        translations: {'uz': 'Ulug\'nor', 'ru': 'Улугнор', 'tr': 'Uluğnor'},
      ),
    ],
  ),

  // Buxoro viloyati
  Region(
    name: 'bukhara',
    translations: {
      'uz': 'Buxoro viloyati',
      'ru': 'Бухарская область',
      'tr': 'Buhara Vilayeti',
    },
    districts: [
      District(
        name: 'buxoro_sh',
        translations: {
          'uz': 'Buxoro shahri',
          'ru': 'Город Бухара',
          'tr': 'Buhara Şehri',
        },
      ),
      District(
        name: 'kogon',
        translations: {'uz': 'Kogon', 'ru': 'Каган', 'tr': 'Kagan'},
      ),
      District(
        name: 'buxoro_t',
        translations: {
          'uz': 'Buxoro tumani',
          'ru': 'Бухарский район',
          'tr': 'Buhara İlçesi',
        },
      ),
      District(
        name: 'gijduvon',
        translations: {'uz': 'G\'ijduvon', 'ru': 'Гиждуван', 'tr': 'Gijduvan'},
      ),
      District(
        name: 'jondor',
        translations: {'uz': 'Jondor', 'ru': 'Жондор', 'tr': 'Condor'},
      ),
      District(
        name: 'kogon_t',
        translations: {
          'uz': 'Kogon tumani',
          'ru': 'Каганский район',
          'tr': 'Kagan İlçesi',
        },
      ),
      District(
        name: 'olot',
        translations: {'uz': 'Olot', 'ru': 'Алат', 'tr': 'Alat'},
      ),
      District(
        name: 'peshku',
        translations: {'uz': 'Peshku', 'ru': 'Пешку', 'tr': 'Peşku'},
      ),
      District(
        name: 'qorakol',
        translations: {'uz': 'Qorako\'l', 'ru': 'Каракуль', 'tr': 'Karaköl'},
      ),
      District(
        name: 'qorovulbozor',
        translations: {
          'uz': 'Qorovulbozor',
          'ru': 'Караулбазар',
          'tr': 'Karaulbazar',
        },
      ),
      District(
        name: 'romitan',
        translations: {'uz': 'Romitan', 'ru': 'Ромитан', 'tr': 'Romitan'},
      ),
      District(
        name: 'shofirkon',
        translations: {'uz': 'Shofirkon', 'ru': 'Шафиркан', 'tr': 'Şafirkan'},
      ),
      District(
        name: 'vobkent',
        translations: {'uz': 'Vobkent', 'ru': 'Вабкент', 'tr': 'Vabkent'},
      ),
    ],
  ),

  // Farg'ona viloyati
  Region(
    name: 'fergana',
    translations: {
      'uz': 'Farg\'ona viloyati',
      'ru': 'Ферганская область',
      'tr': 'Fergana Vilayeti',
    },
    districts: [
      District(
        name: 'fargona_sh',
        translations: {
          'uz': 'Farg\'ona shahri',
          'ru': 'Город Фергана',
          'tr': 'Fergana Şehri',
        },
      ),
      District(
        name: 'qoqon',
        translations: {'uz': 'Qo\'qon', 'ru': 'Коканд', 'tr': 'Kokand'},
      ),
      District(
        name: 'marg\'ilon',
        translations: {'uz': 'Marg\'ilon', 'ru': 'Маргилан', 'tr': 'Margilan'},
      ),
      District(
        name: 'quvasoy',
        translations: {'uz': 'Quvasoy', 'ru': 'Кувасай', 'tr': 'Kuvasay'},
      ),
      District(
        name: 'beshariq',
        translations: {'uz': 'Beshariq', 'ru': 'Бешарык', 'tr': 'Beşarık'},
      ),
      District(
        name: 'bogdod',
        translations: {'uz': 'Bog\'dod', 'ru': 'Багдад', 'tr': 'Bağdat'},
      ),
      District(
        name: 'buvayda',
        translations: {'uz': 'Buvayda', 'ru': 'Бувайда', 'tr': 'Buvayda'},
      ),
      District(
        name: 'dangara',
        translations: {'uz': 'Dang\'ara', 'ru': 'Дангара', 'tr': 'Dangara'},
      ),
      District(
        name: 'fargona_t',
        translations: {
          'uz': 'Farg\'ona tumani',
          'ru': 'Ферганский район',
          'tr': 'Fergana İlçesi',
        },
      ),
      District(
        name: 'furqat',
        translations: {'uz': 'Furqat', 'ru': 'Фуркат', 'tr': 'Furkat'},
      ),
      District(
        name: 'qoshtepa',
        translations: {'uz': 'Qo\'shtepa', 'ru': 'Куштепа', 'tr': 'Koştepe'},
      ),
      District(
        name: 'oltiariq',
        translations: {'uz': 'Oltiariq', 'ru': 'Алтыарык', 'tr': 'Altıarık'},
      ),
      District(
        name: 'ozbekiston',
        translations: {
          'uz': 'O\'zbekiston',
          'ru': 'Узбекистан',
          'tr': 'Özbekistan',
        },
      ),
      District(
        name: 'rishton',
        translations: {'uz': 'Rishton', 'ru': 'Риштан', 'tr': 'Riştan'},
      ),
      District(
        name: 'sox',
        translations: {'uz': 'So\'x', 'ru': 'Сох', 'tr': 'Soh'},
      ),
      District(
        name: 'toshloq',
        translations: {'uz': 'Toshloq', 'ru': 'Ташлак', 'tr': 'Taşlak'},
      ),
      District(
        name: 'uchkoprik',
        translations: {'uz': 'Uchko\'prik', 'ru': 'Учкуприк', 'tr': 'Üçköprü'},
      ),
      District(
        name: 'yozyovon',
        translations: {'uz': 'Yozyovon', 'ru': 'Язъяван', 'tr': 'Yazyavan'},
      ),
    ],
  ),

  // Jizzax viloyati
  Region(
    name: 'jizzakh',
    translations: {
      'uz': 'Jizzax viloyati',
      'ru': 'Джизакская область',
      'tr': 'Cizzah Vilayeti',
    },
    districts: [
      District(
        name: 'jizzax_sh',
        translations: {
          'uz': 'Jizzax shahri',
          'ru': 'Город Джизак',
          'tr': 'Cizzah Şehri',
        },
      ),
      District(
        name: 'arnasoy',
        translations: {'uz': 'Arnasoy', 'ru': 'Арнасай', 'tr': 'Arnasay'},
      ),
      District(
        name: 'baxmal',
        translations: {'uz': 'Baxmal', 'ru': 'Бахмал', 'tr': 'Bahmal'},
      ),
      District(
        name: 'dostlik',
        translations: {'uz': 'Do\'stlik', 'ru': 'Дустлик', 'tr': 'Dostluk'},
      ),
      District(
        name: 'forish',
        translations: {'uz': 'Forish', 'ru': 'Фориш', 'tr': 'Foriş'},
      ),
      District(
        name: 'gallaorol',
        translations: {'uz': 'Gallaorol', 'ru': 'Галляарал', 'tr': 'Gallaaral'},
      ),
      District(
        name: 'sharof_rashidov',
        translations: {
          'uz': 'Sh. Rashidov',
          'ru': 'Ш. Рашидов',
          'tr': 'Ş. Raşidov',
        },
      ),
      District(
        name: 'mirzachol',
        translations: {
          'uz': 'Mirzacho\'l',
          'ru': 'Мирзачуль',
          'tr': 'Mirzaçöl',
        },
      ),
      District(
        name: 'paxtakor',
        translations: {'uz': 'Paxtakor', 'ru': 'Пахтакор', 'tr': 'Pahtakor'},
      ),
      District(
        name: 'yangiobod',
        translations: {'uz': 'Yangiobod', 'ru': 'Янгиабад', 'tr': 'Yangiabad'},
      ),
      District(
        name: 'zomin',
        translations: {'uz': 'Zomin', 'ru': 'Зомин', 'tr': 'Zomin'},
      ),
      District(
        name: 'zarbdor',
        translations: {'uz': 'Zarbdor', 'ru': 'Зарбдор', 'tr': 'Zarbdor'},
      ),
    ],
  ),

  // Xorazm viloyati
  Region(
    name: 'khorezm',
    translations: {
      'uz': 'Xorazm viloyati',
      'ru': 'Хорезмская область',
      'tr': 'Harezm Vilayeti',
    },
    districts: [
      District(
        name: 'urganch_sh',
        translations: {
          'uz': 'Urganch shahri',
          'ru': 'Город Ургенч',
          'tr': 'Ürgenç Şehri',
        },
      ),
      District(
        name: 'xiva',
        translations: {'uz': 'Xiva', 'ru': 'Хива', 'tr': 'Hive'},
      ),
      District(
        name: 'bogot',
        translations: {'uz': 'Bog\'ot', 'ru': 'Багат', 'tr': 'Bağat'},
      ),
      District(
        name: 'gurlan',
        translations: {'uz': 'Gurlan', 'ru': 'Гурлен', 'tr': 'Gurlen'},
      ),
      District(
        name: 'xonqa',
        translations: {'uz': 'Xonqa', 'ru': 'Ханка', 'tr': 'Hanka'},
      ),
      District(
        name: 'hazorasp',
        translations: {'uz': 'Hazorasp', 'ru': 'Хазарасп', 'tr': 'Hazarasp'},
      ),
      District(
        name: 'qoshkopir',
        translations: {
          'uz': 'Qo\'shko\'pir',
          'ru': 'Кошкупыр',
          'tr': 'Koşköpür',
        },
      ),
      District(
        name: 'shovot',
        translations: {'uz': 'Shovot', 'ru': 'Шават', 'tr': 'Şavat'},
      ),
      District(
        name: 'urganch_t',
        translations: {
          'uz': 'Urganch tumani',
          'ru': 'Ургенчский район',
          'tr': 'Ürgenç İlçesi',
        },
      ),
      District(
        name: 'yangiariq',
        translations: {'uz': 'Yangiariq', 'ru': 'Янгиарык', 'tr': 'Yangiarık'},
      ),
      District(
        name: 'yangibozor',
        translations: {
          'uz': 'Yangibozor',
          'ru': 'Янгибазар',
          'tr': 'Yangibazar',
        },
      ),
    ],
  ),

  // Namangan viloyati
  Region(
    name: 'namangan',
    translations: {
      'uz': 'Namangan viloyati',
      'ru': 'Наманганская область',
      'tr': 'Namangan Vilayeti',
    },
    districts: [
      District(
        name: 'namangan_sh',
        translations: {
          'uz': 'Namangan shahri',
          'ru': 'Город Наманган',
          'tr': 'Namangan Şehri',
        },
      ),
      District(
        name: 'chortoq',
        translations: {'uz': 'Chortoq', 'ru': 'Чартак', 'tr': 'Çartak'},
      ),
      District(
        name: 'chust',
        translations: {'uz': 'Chust', 'ru': 'Чуст', 'tr': 'Çust'},
      ),
      District(
        name: 'kosonsoy',
        translations: {'uz': 'Kosonsoy', 'ru': 'Касансай', 'tr': 'Kasansay'},
      ),
      District(
        name: 'mingbuloq',
        translations: {'uz': 'Mingbuloq', 'ru': 'Мингбулак', 'tr': 'Mingbulak'},
      ),
      District(
        name: 'namangan_t',
        translations: {
          'uz': 'Namangan tumani',
          'ru': 'Наманганский район',
          'tr': 'Namangan İlçesi',
        },
      ),
      District(
        name: 'norin',
        translations: {'uz': 'Norin', 'ru': 'Нарын', 'tr': 'Narın'},
      ),
      District(
        name: 'pop',
        translations: {'uz': 'Pop', 'ru': 'Пап', 'tr': 'Pap'},
      ),
      District(
        name: 'toqmaqorgon',
        translations: {
          'uz': 'To\'raqo\'rg\'on',
          'ru': 'Туракурган',
          'tr': 'Turakurgan',
        },
      ),
      District(
        name: 'uchqorgon',
        translations: {
          'uz': 'Uchqo\'rg\'on',
          'ru': 'Учкурган',
          'tr': 'Üçkurgan',
        },
      ),
      District(
        name: 'uychi',
        translations: {'uz': 'Uychi', 'ru': 'Уйчи', 'tr': 'Uyçi'},
      ),
      District(
        name: 'yangiqorgon',
        translations: {
          'uz': 'Yangiqo\'rg\'on',
          'ru': 'Янгикурган',
          'tr': 'Yangikurgan',
        },
      ),
    ],
  ),

  // Navoiy viloyati
  Region(
    name: 'navoi',
    translations: {
      'uz': 'Navoiy viloyati',
      'ru': 'Навоийская область',
      'tr': 'Nevayi Vilayeti',
    },
    districts: [
      District(
        name: 'navoiy_sh',
        translations: {
          'uz': 'Navoiy shahri',
          'ru': 'Город Навои',
          'tr': 'Nevayi Şehri',
        },
      ),
      District(
        name: 'zarafshon',
        translations: {'uz': 'Zarafshon', 'ru': 'Зарафшан', 'tr': 'Zerefşan'},
      ),
      District(
        name: 'karmana',
        translations: {'uz': 'Karmana', 'ru': 'Кармана', 'tr': 'Karmana'},
      ),
      District(
        name: 'konimex',
        translations: {'uz': 'Konimex', 'ru': 'Конимех', 'tr': 'Konimeh'},
      ),
      District(
        name: 'navbahor',
        translations: {'uz': 'Navbahor', 'ru': 'Навбахор', 'tr': 'Nevbahor'},
      ),
      District(
        name: 'nurota',
        translations: {'uz': 'Nurota', 'ru': 'Нурата', 'tr': 'Nurata'},
      ),
      District(
        name: 'qiziltepa',
        translations: {'uz': 'Qiziltepa', 'ru': 'Кызылтепа', 'tr': 'Kızıltepe'},
      ),
      District(
        name: 'tomdi',
        translations: {'uz': 'Tomdi', 'ru': 'Тамды', 'tr': 'Tamdi'},
      ),
      District(
        name: 'uchquduq',
        translations: {'uz': 'Uchquduq', 'ru': 'Учкудук', 'tr': 'Üçkuduk'},
      ),
      District(
        name: 'xatirchi',
        translations: {'uz': 'Xatirchi', 'ru': 'Хатырчи', 'tr': 'Hatırçı'},
      ),
    ],
  ),

  // Qashqadaryo viloyati
  Region(
    name: 'kashkadarya',
    translations: {
      'uz': 'Qashqadaryo viloyati',
      'ru': 'Кашкадарьинская область',
      'tr': 'Kaşkaderya Vilayeti',
    },
    districts: [
      District(
        name: 'qarshi_sh',
        translations: {
          'uz': 'Qarshi shahri',
          'ru': 'Город Карши',
          'tr': 'Karşi Şehri',
        },
      ),
      District(
        name: 'shahrisabz',
        translations: {
          'uz': 'Shahrisabz',
          'ru': 'Шахрисабз',
          'tr': 'Şehrisebz',
        },
      ),
      District(
        name: 'chiroqchi',
        translations: {'uz': 'Chiroqchi', 'ru': 'Чиракчи', 'tr': 'Çirakçı'},
      ),
      District(
        name: 'dehqonobod',
        translations: {
          'uz': 'Dehqonobod',
          'ru': 'Дехканабад',
          'tr': 'Dehkanabad',
        },
      ),
      District(
        name: 'guzor',
        translations: {'uz': 'G\'uzor', 'ru': 'Гузар', 'tr': 'Guzar'},
      ),
      District(
        name: 'qamashi',
        translations: {'uz': 'Qamashi', 'ru': 'Камаши', 'tr': 'Kamaşi'},
      ),
      District(
        name: 'qarshi_t',
        translations: {
          'uz': 'Qarshi tumani',
          'ru': 'Каршинский район',
          'tr': 'Karşi İlçesi',
        },
      ),
      District(
        name: 'kasbi',
        translations: {'uz': 'Kasbi', 'ru': 'Касби', 'tr': 'Kasbi'},
      ),
      District(
        name: 'kitob',
        translations: {'uz': 'Kitob', 'ru': 'Китаб', 'tr': 'Kitap'},
      ),
      District(
        name: 'koson',
        translations: {'uz': 'Koson', 'ru': 'Косон', 'tr': 'Koson'},
      ),
      District(
        name: 'mirishkor',
        translations: {'uz': 'Mirishkor', 'ru': 'Миришкор', 'tr': 'Mirişkor'},
      ),
      District(
        name: 'muborak',
        translations: {'uz': 'Muborak', 'ru': 'Мубарек', 'tr': 'Mübarek'},
      ),
      District(
        name: 'nishon',
        translations: {'uz': 'Nishon', 'ru': 'Нишан', 'tr': 'Nişan'},
      ),
      District(
        name: 'yakkabog',
        translations: {'uz': 'Yakkabog\'', 'ru': 'Яккабаг', 'tr': 'Yakkabağ'},
      ),
    ],
  ),

  // Samarqand viloyati
  Region(
    name: 'samarkand',
    translations: {
      'uz': 'Samarqand viloyati',
      'ru': 'Самаркандская область',
      'tr': 'Semerkant Vilayeti',
    },
    districts: [
      District(
        name: 'samarqand_sh',
        translations: {
          'uz': 'Samarqand shahri',
          'ru': 'Город Самарканд',
          'tr': 'Semerkant Şehri',
        },
      ),
      District(
        name: 'kattaqorgon',
        translations: {
          'uz': 'Kattaqo\'rg\'on',
          'ru': 'Каттакурган',
          'tr': 'Kattakurgan',
        },
      ),
      District(
        name: 'bulung\'ur',
        translations: {'uz': 'Bulung\'ur', 'ru': 'Булунгур', 'tr': 'Bulungur'},
      ),
      District(
        name: 'ishtixon',
        translations: {'uz': 'Ishtixon', 'ru': 'Иштыхан', 'tr': 'İştihan'},
      ),
      District(
        name: 'jomboy',
        translations: {'uz': 'Jomboy', 'ru': 'Джамбай', 'tr': 'Cambay'},
      ),
      District(
        name: 'kattaqorgon_t',
        translations: {
          'uz': 'Kattaqo\'rg\'on tumani',
          'ru': 'Каттакурганский район',
          'tr': 'Kattakurgan İlçesi',
        },
      ),
      District(
        name: 'qoshrabot',
        translations: {'uz': 'Qo\'shrabot', 'ru': 'Кушрабат', 'tr': 'Koşrabat'},
      ),
      District(
        name: 'narpay',
        translations: {'uz': 'Narpay', 'ru': 'Нарпай', 'tr': 'Narpay'},
      ),
      District(
        name: 'nurobod',
        translations: {'uz': 'Nurobod', 'ru': 'Нурабад', 'tr': 'Nurabad'},
      ),
      District(
        name: 'oqdaryo',
        translations: {'uz': 'Oqdaryo', 'ru': 'Акдарья', 'tr': 'Akderya'},
      ),
      District(
        name: 'pastdargom',
        translations: {
          'uz': 'Pastdarg\'om',
          'ru': 'Пастдаргом',
          'tr': 'Pastdargom',
        },
      ),
      District(
        name: 'paxtachi',
        translations: {'uz': 'Paxtachi', 'ru': 'Пахтачи', 'tr': 'Pahtaçı'},
      ),
      District(
        name: 'payariq',
        translations: {'uz': 'Payariq', 'ru': 'Пайарык', 'tr': 'Payarık'},
      ),
      District(
        name: 'samarqand_t',
        translations: {
          'uz': 'Samarqand tumani',
          'ru': 'Самаркандский район',
          'tr': 'Semerkant İlçesi',
        },
      ),
      District(
        name: 'toyloq',
        translations: {'uz': 'Toyloq', 'ru': 'Тайлак', 'tr': 'Taylak'},
      ),
      District(
        name: 'urgut',
        translations: {'uz': 'Urgut', 'ru': 'Ургут', 'tr': 'Urgut'},
      ),
    ],
  ),

  // Sirdaryo viloyati
  Region(
    name: 'syrdarya',
    translations: {
      'uz': 'Sirdaryo viloyati',
      'ru': 'Сырдарьинская область',
      'tr': 'Sirderya Vilayeti',
    },
    districts: [
      District(
        name: 'guliston_sh',
        translations: {
          'uz': 'Guliston shahri',
          'ru': 'Город Гулистан',
          'tr': 'Gülistan Şehri',
        },
      ),
      District(
        name: 'yangiyer',
        translations: {'uz': 'Yangiyer', 'ru': 'Янгиер', 'tr': 'Yangiyer'},
      ),
      District(
        name: 'shirin',
        translations: {'uz': 'Shirin', 'ru': 'Ширин', 'tr': 'Şirin'},
      ),
      District(
        name: 'boyovut',
        translations: {'uz': 'Boyovut', 'ru': 'Баяут', 'tr': 'Bayavut'},
      ),
      District(
        name: 'guliston_t',
        translations: {
          'uz': 'Guliston tumani',
          'ru': 'Гулистанский район',
          'tr': 'Gülistan İlçesi',
        },
      ),
      District(
        name: 'xovos',
        translations: {'uz': 'Xovos', 'ru': 'Хавас', 'tr': 'Havas'},
      ),
      District(
        name: 'mirzaobod',
        translations: {'uz': 'Mirzaobod', 'ru': 'Мирзаабад', 'tr': 'Mirzaabad'},
      ),
      District(
        name: 'oqoltin',
        translations: {'uz': 'Oqoltin', 'ru': 'Акалтын', 'tr': 'Akaltın'},
      ),
      District(
        name: 'sardoba',
        translations: {'uz': 'Sardoba', 'ru': 'Сардоба', 'tr': 'Sardoba'},
      ),
      District(
        name: 'sayxunobod',
        translations: {
          'uz': 'Sayxunobod',
          'ru': 'Сайхунабад',
          'tr': 'Sayhunabad',
        },
      ),
    ],
  ),

  // Surxondaryo viloyati
  Region(
    name: 'surkhandarya',
    translations: {
      'uz': 'Surxondaryo viloyati',
      'ru': 'Сурхандарьинская область',
      'tr': 'Surhanderya Vilayeti',
    },
    districts: [
      District(
        name: 'termiz_sh',
        translations: {
          'uz': 'Termiz shahri',
          'ru': 'Город Термез',
          'tr': 'Termez Şehri',
        },
      ),
      District(
        name: 'angor',
        translations: {'uz': 'Angor', 'ru': 'Ангор', 'tr': 'Angor'},
      ),
      District(
        name: 'bandixon',
        translations: {'uz': 'Bandixon', 'ru': 'Бандихан', 'tr': 'Bandihan'},
      ),
      District(
        name: 'boysun',
        translations: {'uz': 'Boysun', 'ru': 'Байсун', 'tr': 'Baysun'},
      ),
      District(
        name: 'denov',
        translations: {'uz': 'Denov', 'ru': 'Денау', 'tr': 'Denav'},
      ),
      District(
        name: 'jarqorgon',
        translations: {
          'uz': 'Jarqo\'rg\'on',
          'ru': 'Джаркурган',
          'tr': 'Carkurgan',
        },
      ),
      District(
        name: 'qiziriq',
        translations: {'uz': 'Qiziriq', 'ru': 'Кизирик', 'tr': 'Kızırık'},
      ),
      District(
        name: 'qumqorgon',
        translations: {
          'uz': 'Qumqo\'rg\'on',
          'ru': 'Кумкурган',
          'tr': 'Kumkurgan',
        },
      ),
      District(
        name: 'muzrabot',
        translations: {'uz': 'Muzrabot', 'ru': 'Музрабад', 'tr': 'Muzrabad'},
      ),
      District(
        name: 'oltinsoy',
        translations: {'uz': 'Oltinsoy', 'ru': 'Алтынсай', 'tr': 'Altınsay'},
      ),
      District(
        name: 'sariosiyo',
        translations: {'uz': 'Sariosiyo', 'ru': 'Сариасия', 'tr': 'Sarıasya'},
      ),
      District(
        name: 'sherobod',
        translations: {'uz': 'Sherobod', 'ru': 'Шерабад', 'tr': 'Şerabad'},
      ),
      District(
        name: 'shorchi',
        translations: {'uz': 'Sho\'rchi', 'ru': 'Шурчи', 'tr': 'Şurçi'},
      ),
      District(
        name: 'termiz_t',
        translations: {
          'uz': 'Termiz tumani',
          'ru': 'Термезский район',
          'tr': 'Termez İlçesi',
        },
      ),
      District(
        name: 'uzun',
        translations: {'uz': 'Uzun', 'ru': 'Узун', 'tr': 'Uzun'},
      ),
    ],
  ),

  // Qoraqalpog'iston Respublikasi
  Region(
    name: 'karakalpakstan',
    translations: {
      'uz': 'Qoraqalpog\'iston',
      'ru': 'Каракалпакстан',
      'tr': 'Karakalpakistan',
    },
    districts: [
      District(
        name: 'nukus_sh',
        translations: {
          'uz': 'Nukus shahri',
          'ru': 'Город Нукус',
          'tr': 'Nukus Şehri',
        },
      ),
      District(
        name: 'amudaryo',
        translations: {'uz': 'Amudaryo', 'ru': 'Амударья', 'tr': 'Amuderya'},
      ),
      District(
        name: 'beruniy',
        translations: {'uz': 'Beruniy', 'ru': 'Беруни', 'tr': 'Biruni'},
      ),
      District(
        name: 'chimboy',
        translations: {'uz': 'Chimboy', 'ru': 'Чимбай', 'tr': 'Çimbay'},
      ),
      District(
        name: 'ellikqala',
        translations: {
          'uz': 'Ellikqal\'a',
          'ru': 'Элликкала',
          'tr': 'Ellikkala',
        },
      ),
      District(
        name: 'kegeyli',
        translations: {'uz': 'Kegeyli', 'ru': 'Кегейли', 'tr': 'Kegeyli'},
      ),
      District(
        name: 'moynaq',
        translations: {'uz': 'Mo\'ynoq', 'ru': 'Муйнак', 'tr': 'Moynak'},
      ),
      District(
        name: 'nukus_t',
        translations: {
          'uz': 'Nukus tumani',
          'ru': 'Нукусский район',
          'tr': 'Nukus İlçesi',
        },
      ),
      District(
        name: 'qongirot',
        translations: {'uz': 'Qo\'ng\'irot', 'ru': 'Кунград', 'tr': 'Kungrad'},
      ),
      District(
        name: 'qoraozak',
        translations: {'uz': 'Qorao\'zak', 'ru': 'Караузяк', 'tr': 'Karaözek'},
      ),
      District(
        name: 'shumanay',
        translations: {'uz': 'Shumanay', 'ru': 'Шуманай', 'tr': 'Şumanay'},
      ),
      District(
        name: 'taxtakopir',
        translations: {
          'uz': 'Taxtako\'pir',
          'ru': 'Тахтакупыр',
          'tr': 'Tahtaköpür',
        },
      ),
      District(
        name: 'tortkol',
        translations: {'uz': 'To\'rtko\'l', 'ru': 'Турткуль', 'tr': 'Türtköl'},
      ),
      District(
        name: 'xojayli',
        translations: {'uz': 'Xo\'jayli', 'ru': 'Ходжейли', 'tr': 'Hocayli'},
      ),
    ],
  ),
];
