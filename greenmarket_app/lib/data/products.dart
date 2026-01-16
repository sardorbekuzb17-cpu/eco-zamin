class Product {
  final String id;
  final Map<String, String> name;
  final Map<String, String> unit;
  final int price;
  final String image;
  final String category;
  final bool isNew;
  bool isFavorite;
  int likeCount;

  Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    required this.image,
    required this.category,
    this.isNew = false,
    this.isFavorite = false,
    this.likeCount = 0,
  });

  String getName(String langCode) => name[langCode] ?? name['uz']!;
  String getUnit(String langCode) => unit[langCode] ?? unit['uz']!;
}

final List<Product> allProducts = [
  // Daraxtlar (Trees)
  Product(
    id: '1',
    name: {'uz': 'Olma daraxti', 'ru': 'Яблоня', 'en': 'Apple Tree'},
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 80000,
    image: 'assets/images/apple_tree.jpg',
    category: 'trees',
  ),
  Product(
    id: '2',
    name: {'uz': 'Nok daraxti', 'ru': 'Груша', 'en': 'Pear Tree'},
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 85000,
    image: 'assets/images/pear_tree.jpg',
    category: 'trees',
  ),
  Product(
    id: '3',
    name: {'uz': 'Gilos daraxti', 'ru': 'Черешня', 'en': 'Cherry Tree'},
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 90000,
    image: 'assets/images/cherry_tree.jpg',
    category: 'trees',
    isNew: true,
  ),
  Product(
    id: '4',
    name: {'uz': 'Anor daraxti', 'ru': 'Гранат', 'en': 'Pomegranate Tree'},
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 70000,
    image:
        'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?q=80&w=300',
    category: 'trees',
  ),
  Product(
    id: '5',
    name: {'uz': 'Uzum daraxti', 'ru': 'Виноград', 'en': 'Grape Vine'},
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 45000,
    image:
        'https://images.unsplash.com/photo-1537640538966-79f369143f8f?q=80&w=300',
    category: 'trees',
    isFavorite: true,
  ),

  // Gullar (Flowers)
  Product(
    id: '6',
    name: {'uz': 'Atirgul', 'ru': 'Роза', 'en': 'Rose'},
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 25000,
    image:
        'https://images.unsplash.com/photo-1490750967868-88aa4486c946?q=80&w=300',
    category: 'flowers',
    isFavorite: true,
  ),
  Product(
    id: '7',
    name: {'uz': 'Lola', 'ru': 'Тюльпан', 'en': 'Tulip'},
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 15000,
    image:
        'https://images.unsplash.com/photo-1520763185298-1b434c919102?q=80&w=300',
    category: 'flowers',
  ),
  Product(
    id: '8',
    name: {'uz': 'Gladiolus', 'ru': 'Гладиолус', 'en': 'Gladiolus'},
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 20000,
    image:
        'https://images.unsplash.com/photo-1597848212624-a19eb35e2651?q=80&w=300',
    category: 'flowers',
    isNew: true,
  ),
  Product(
    id: '9',
    name: {'uz': 'Pion', 'ru': 'Пион', 'en': 'Peony'},
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 35000,
    image:
        'https://images.unsplash.com/photo-1527061011665-3652c757a4d4?q=80&w=300',
    category: 'flowers',
  ),
  Product(
    id: '10',
    name: {'uz': 'Xrizantema', 'ru': 'Хризантема', 'en': 'Chrysanthemum'},
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 18000,
    image:
        'https://images.unsplash.com/photo-1508610048659-a06b669e3321?q=80&w=300',
    category: 'flowers',
  ),

  // Ko'chatlar (Seedlings)
  Product(
    id: '11',
    name: {
      'uz': 'Pomidor ko\'chati',
      'ru': 'Рассада помидоров',
      'en': 'Tomato Seedling',
    },
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 3000,
    image:
        'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?q=80&w=300',
    category: 'seedlings',
  ),
  Product(
    id: '12',
    name: {
      'uz': 'Bodring ko\'chati',
      'ru': 'Рассада огурцов',
      'en': 'Cucumber Seedling',
    },
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 2500,
    image:
        'https://images.unsplash.com/photo-1591857177580-dc82b9ac4e1e?q=80&w=300',
    category: 'seedlings',
  ),
  Product(
    id: '13',
    name: {
      'uz': 'Qalampir ko\'chati',
      'ru': 'Рассада перца',
      'en': 'Pepper Seedling',
    },
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 3500,
    image:
        'https://images.unsplash.com/photo-1518977676601-b53f82ber633?q=80&w=300',
    category: 'seedlings',
    isNew: true,
  ),
  Product(
    id: '14',
    name: {
      'uz': 'Karam ko\'chati',
      'ru': 'Рассада капусты',
      'en': 'Cabbage Seedling',
    },
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 2000,
    image:
        'https://images.unsplash.com/photo-1594282486552-05b4d80fbb9f?q=80&w=300',
    category: 'seedlings',
  ),

  // Urug'lar (Seeds)
  Product(
    id: '15',
    name: {
      'uz': 'Pomidor urug\'i',
      'ru': 'Семена помидоров',
      'en': 'Tomato Seeds',
    },
    unit: {'uz': '1 paket', 'ru': '1 пакет', 'en': '1 packet'},
    price: 8000,
    image:
        'https://images.unsplash.com/photo-1592841200221-a6898f307baa?q=80&w=300',
    category: 'seeds',
  ),
  Product(
    id: '16',
    name: {'uz': 'Sabzi urug\'i', 'ru': 'Семена моркови', 'en': 'Carrot Seeds'},
    unit: {'uz': '1 paket', 'ru': '1 пакет', 'en': '1 packet'},
    price: 6000,
    image:
        'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?q=80&w=300',
    category: 'seeds',
  ),
  Product(
    id: '17',
    name: {'uz': 'Gul urug\'i', 'ru': 'Семена цветов', 'en': 'Flower Seeds'},
    unit: {'uz': '1 paket', 'ru': '1 пакет', 'en': '1 packet'},
    price: 10000,
    image:
        'https://images.unsplash.com/photo-1490750967868-88aa4486c946?q=80&w=300',
    category: 'seeds',
    isNew: true,
  ),
  Product(
    id: '18',
    name: {'uz': 'Piyoz urug\'i', 'ru': 'Семена лука', 'en': 'Onion Seeds'},
    unit: {'uz': '1 paket', 'ru': '1 пакет', 'en': '1 packet'},
    price: 5000,
    image:
        'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?q=80&w=300',
    category: 'seeds',
  ),

  // Gul tuvaklari (Bulbs)
  Product(
    id: '19',
    name: {'uz': 'Lola tuvagi', 'ru': 'Луковица тюльпана', 'en': 'Tulip Bulb'},
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 5000,
    image: 'assets/images/1.jpg',
    category: 'bulbs',
  ),
  Product(
    id: '20',
    name: {
      'uz': 'Gladiolus tuvagi',
      'ru': 'Луковица гладиолуса',
      'en': 'Gladiolus Bulb',
    },
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 7000,
    image: 'assets/images/2.jpg',
    category: 'bulbs',
    isNew: true,
  ),
  Product(
    id: '21',
    name: {
      'uz': 'Nargiz tuvagi',
      'ru': 'Луковица нарцисса',
      'en': 'Daffodil Bulb',
    },
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 6000,
    image: 'assets/images/3.jpg',
    category: 'bulbs',
  ),
  Product(
    id: '22',
    name: {
      'uz': 'Sarimsoq tuvagi',
      'ru': 'Чеснок посадочный',
      'en': 'Garlic Bulb',
    },
    unit: {'uz': '1 kg', 'ru': '1 кг', 'en': '1 kg'},
    price: 25000,
    image: 'assets/images/4.jpg',
    category: 'bulbs',
    isFavorite: true,
  ),
  Product(
    id: '28',
    name: {
      'uz': 'Giyosin tuvagi',
      'ru': 'Луковица гиацинта',
      'en': 'Hyacinth Bulb',
    },
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 8000,
    image: 'assets/images/5.jpg',
    category: 'bulbs',
  ),
  Product(
    id: '29',
    name: {'uz': 'Iris tuvagi', 'ru': 'Луковица ириса', 'en': 'Iris Bulb'},
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 9000,
    image: 'assets/images/6.jpg',
    category: 'bulbs',
    isNew: true,
  ),
  Product(
    id: '30',
    name: {
      'uz': 'Krokus tuvagi',
      'ru': 'Луковица крокуса',
      'en': 'Crocus Bulb',
    },
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 4500,
    image: 'assets/images/7.jpg',
    category: 'bulbs',
  ),

  // Aksessuarlar (Accessories)
  Product(
    id: '23',
    name: {'uz': 'Guldon', 'ru': 'Горшок для цветов', 'en': 'Flower Pot'},
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 35000,
    image:
        'https://images.unsplash.com/photo-1485955900006-10f4d324d411?q=80&w=300',
    category: 'accessories',
  ),
  Product(
    id: '24',
    name: {
      'uz': 'Bog\' qaychi',
      'ru': 'Садовые ножницы',
      'en': 'Garden Scissors',
    },
    unit: {'uz': '1 dona', 'ru': '1 штука', 'en': '1 piece'},
    price: 45000,
    image:
        'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?q=80&w=300',
    category: 'accessories',
    isNew: true,
  ),
  Product(
    id: '25',
    name: {
      'uz': 'Sug\'orish shlangasi',
      'ru': 'Шланг для полива',
      'en': 'Garden Hose',
    },
    unit: {'uz': '10 metr', 'ru': '10 метров', 'en': '10 meters'},
    price: 120000,
    image:
        'https://images.unsplash.com/photo-1563293958-6c67e1ab6f8e?q=80&w=300',
    category: 'accessories',
  ),
  Product(
    id: '26',
    name: {'uz': 'O\'g\'it', 'ru': 'Удобрение', 'en': 'Fertilizer'},
    unit: {'uz': '1 kg', 'ru': '1 кг', 'en': '1 kg'},
    price: 15000,
    image:
        'https://images.unsplash.com/photo-1592419044706-39796d40f98c?q=80&w=300',
    category: 'accessories',
    isFavorite: true,
  ),
  Product(
    id: '27',
    name: {'uz': 'Tuproq', 'ru': 'Грунт', 'en': 'Soil'},
    unit: {'uz': '5 kg', 'ru': '5 кг', 'en': '5 kg'},
    price: 25000,
    image:
        'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?q=80&w=300',
    category: 'accessories',
  ),
];
