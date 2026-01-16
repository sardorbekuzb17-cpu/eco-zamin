// GreenMarket - 100% Avtomatik Tarjima Tizimi
// Bu fayl sahifadagi BARCHA matnlarni avtomatik tarjima qiladi

const TRANSLATIONS = {
    uz: {}, // O'zbek tili - asl holat, tarjima kerak emas

    ru: {
        // ===== MENYU =====
        "Bosh sahifa": "Главная",
        "Yashil Do'kon": "Зелёный магазин",
        "Oshxona Bog'i": "Кухонный сад",
        "Katalog": "Каталог",
        "Mavsumiy": "Сезонное",
        "Reyting": "Рейтинг",
        "Kredit": "Кредит",
        "Yangiliklar": "Новости",
        "Qanday ishlaydi": "Как это работает",
        "AI Maslahatchi": "AI Советник",
        "Buyurtmalar": "Заказы",
        "Aloqa": "Контакты",

        // ===== HERO =====
        "Yashil kelajakni bugundan boshlab birga quramiz.": "Строим зелёное будущее вместе уже сегодня.",
        "Yashil kelajakni": "Зелёное будущее",
        "bugundan boshlab birga": "строим вместе",
        "quramiz.": "уже сегодня.",
        "GreenMarket - bu daraxt ekishni osonlashtiruvchi, tabiatga o'z hissangizni qo'shishga yordam beruvchi va ekologik mas'uliyatni rag'batlantiruvchi raqamli platforma.": "GreenMarket - это цифровая платформа, которая упрощает посадку деревьев, помогает внести свой вклад в природу и поощряет экологическую ответственность.",
        "Mahsulotlarni ko'rish": "Смотреть продукты",

        // ===== YASHIL DO'KON =====
        "Yashil Do'kon 🌿": "Зелёный магазин 🌿",
        "Tabiatga g'amxo'rlik qilish uchun barcha kerakli narsalar bir joyda": "Всё необходимое для заботы о природе в одном месте",
        "🌳 Daraxtlar": "🌳 Деревья",
        "🌱 Ko'chatlar": "🌱 Саженцы",
        "Savatga": "В корзину",
        "Olma daraxti": "Яблоня",
        "Mevali daraxt, yuqori hosil": "Плодовое дерево, высокий урожай",
        "Nok daraxti": "Груша",
        "Shirin mevali daraxt": "Сладкое плодовое дерево",
        "O'rik daraxti": "Абрикос",
        "Bahorgi gullari chiroyli": "Красивое весеннее цветение",
        "Gilos daraxti": "Черешня",
        "Mazali mevali daraxt": "Вкусное плодовое дерево",

        // ===== OSHXONA BOG'I =====
        "Oshxona Bog'i 🌿🍳": "Кухонный сад 🌿🍳",
        "Rayhon, ukrop, yalpiz - oshxonangizda doim yangi ko'kat!": "Базилик, укроп, мята - всегда свежая зелень на вашей кухне!",
        "🪴 Oshxonaga mos o'simliklar": "🪴 Растения для кухни",
        "Rayhon ko'chati": "Саженец базилика",
        "Kichik idishda, oshxonaga mos": "В маленьком горшке, подходит для кухни",
        "Ukrop ko'chati": "Саженец укропа",
        "Tez o'sadi, oson parvarish": "Быстро растёт, легко ухаживать",
        "Yalpiz ko'chati": "Саженец мяты",
        "Choy uchun ideal": "Идеально для чая",
        "Petrushka ko'chati": "Саженец петрушки",
        "Vitaminlarga boy": "Богат витаминами",
        "Oshxona Bog'i To'plami": "Набор для кухонного сада",
        "To'plamni olish": "Получить набор",

        // ===== KATALOG =====
        "Mahsulotlar katalogi 🌱": "Каталог продуктов 🌱",
        "Sizning hududingizga mos keladigan ba'zi o'simlik turlari.": "Некоторые виды растений, подходящие для вашего региона.",
        "Mahsulot nomini kiriting...": "Введите название продукта...",
        "Minimal narx (so'm)": "Минимальная цена (сум)",
        "Maksimal narx (so'm)": "Максимальная цена (сум)",
        "Mahsulot turi": "Тип продукта",
        "Barcha turlar": "Все типы",
        "Savatga qo'shish": "Добавить в корзину",
        "Narxi:": "Цена:",
        "Chinordan": "Платан",
        "Ushbu daraxt tez o'sadi, soyasi qalin va havo tozalashda juda samarali.": "Это дерево быстро растёт, даёт густую тень и очень эффективно очищает воздух.",
        "Olmali daraxt": "Яблоня",
        "Meva beruvchi daraxt. Havoni tozalash bilan birga, bog'ingizga chiroy beradi.": "Плодовое дерево. Очищает воздух и украшает ваш сад.",
        "Atirgul butasi": "Куст розы",
        "Bog' va hovlilarga chiroy beruvchi atirgul butasi, oson parvarish qilinadi.": "Украшает сады и дворы, легко ухаживать.",

        // ===== MAVSUMIY =====
        "Mavsumiy Eslatgich 📅🌱": "Сезонные напоминания 📅🌱",
        "Har bir mavsumda bog'ingiz uchun nima qilish kerakligini bilib oling": "Узнайте, что нужно делать для вашего сада в каждом сезоне",
        "Bahor (Mart-May)": "Весна (Март-Май)",
        "Ekish va ko'chatlar mavsumi": "Сезон посадки и саженцев",
        "Mevali daraxtlarni eking (olma, o'rik, nok)": "Посадите плодовые деревья (яблоня, абрикос, груша)",
        "Sabzavot ko'chatlarini eking (pomidor, bodring)": "Посадите рассаду овощей (помидоры, огурцы)",
        "O'g'it bering va tuproqni tayyorlang": "Внесите удобрения и подготовьте почву",
        "Gul urug'larini sepib boshlang": "Начните сеять семена цветов",
        "Yoz (Iyun-Avgust)": "Лето (Июнь-Август)",
        "Sug'orish va parvarish mavsumi": "Сезон полива и ухода",
        "Muntazam sug'oring (ertalab yoki kechqurun)": "Регулярно поливайте (утром или вечером)",
        "Begona o'tlarni olib tashlang": "Удаляйте сорняки",
        "Zararkunandalarga qarshi kurashing": "Боритесь с вредителями",
        "Hosilni yig'ib oling": "Собирайте урожай",
        "Kuz (Sentyabr-Noyabr)": "Осень (Сентябрь-Ноябрь)",
        "Hosil yig'ish mavsumi": "Сезон сбора урожая",
        "Qolgan hosilni yig'ib oling": "Соберите оставшийся урожай",
        "Daraxtlarni qishga tayyorlang": "Подготовьте деревья к зиме",
        "Tushgan barglarni yig'ing": "Соберите опавшие листья",
        "Yangi daraxtlar ekish uchun ideal vaqt": "Идеальное время для посадки новых деревьев",
        "Qish (Dekabr-Fevral)": "Зима (Декабрь-Февраль)",
        "Daraxtlarni himoya qilish mavsumi": "Сезон защиты деревьев",
        "Daraxt tanalarini oqlang": "Побелите стволы деревьев",
        "Yosh daraxtlarni sovuqdan himoya qiling": "Защитите молодые деревья от холода",
        "Quruq shoxlarni kesib oling": "Обрежьте сухие ветки",
        "Bahorgi ekish uchun reja tuzing": "Составьте план весенней посадки",

        // ===== REYTING =====
        "Mahalla Reytingi 🏆🌳": "Рейтинг районов 🏆🌳",
        "O'zbekiston bo'ylab eng yashil mahallalar, eng faol oilalar. O'z mahallangizni topib, ball to'plang!": "Самые зелёные районы по всему Узбекистану. Найдите свой район и набирайте баллы!",
        "🥇 Top 3 Mahallalar": "🥇 Топ 3 района",
        "daraxt": "деревьев",
        "ball": "баллов",
        "oila": "семей",
        "1-o'rin": "1-е место",
        "2-o'rin": "2-е место",
        "3-o'rin": "3-е место",
        "Ball qanday to'planadi?": "Как заработать баллы?",
        "Daraxt ekish": "Посадка дерева",
        "Parvarish qilish": "Уход за деревьями",
        "Do'stlarni taklif qilish": "Приглашение друзей",
        "Sadaqa berish": "Пожертвование",

        // ===== KREDIT =====
        "Yashil Kredit va Sug'urta 💳🛡️": "Зелёный кредит и страхование 💳🛡️",
        "Bo'lib to'lang, xavfsiz eking. Daraxtingiz qurisa - pul qaytadi!": "Платите в рассрочку, сажайте безопасно. Если дерево засохнет - деньги вернутся!",
        "Bo'lib to'lash": "Рассрочка",
        "0% foiz bilan 3-6-12 oyga": "0% на 3-6-12 месяцев",
        "Daraxt sug'urtasi": "Страхование деревьев",
        "Daraxt qurisa - 100% pul qaytadi": "Если дерево засохнет - 100% возврат",
        "Oylik to'lov": "Ежемесячный платёж",
        "Ariza berish": "Подать заявку",
        "Hisoblash": "Рассчитать",
        "oy": "месяцев",
        "oyiga": "в месяц",

        // ===== YANGILIKLAR =====
        "Yashil Yangiliklar va Video 📺🌿": "Зелёные новости и видео 📺🌿",
        "Har kuni yangi video va buvilarimizning bog'dorchilik sirlari": "Каждый день новое видео и секреты садоводства от наших бабушек",
        "Bugungi video": "Видео дня",
        "Videoni ko'rish": "Смотреть видео",
        "Batafsil o'qish": "Читать далее",
        "ko'rildi": "просмотров",
        "Buvilarning sirlari": "Секреты бабушек",
        "So'nggi yangiliklar": "Последние новости",

        // ===== QANDAY ISHLAYDI =====
        "Qanday ishlaydi? ⚙️": "Как это работает? ⚙️",
        "Oddiy qadamlar bilan yashil harakatga qo'shiling.": "Присоединяйтесь к зелёному движению простыми шагами.",
        "Ro'yxatdan o'ting": "Зарегистрируйтесь",
        "Ilova yoki veb-sayt orqali profilingizni yarating. Bu sizning ekologik hissangizni kuzatish uchun shaxsiy maydonchangiz bo'ladi.": "Создайте профиль через приложение или веб-сайт. Это будет ваше личное пространство для отслеживания экологического вклада.",
        "Daraxt tanlang": "Выберите дерево",
        "Hududingizga mos daraxt turini tanlang. Biz sizga eng yaxshi variantlarni tavsiya qilamiz.": "Выберите подходящий вид дерева для вашего региона. Мы порекомендуем лучшие варианты.",
        "Buyurtma bering": "Сделайте заказ",
        "Onlayn to'lov qiling va yetkazib berishni kuting. Biz daraxtni uyingizgacha yetkazamiz.": "Оплатите онлайн и ждите доставку. Мы доставим дерево до вашего дома.",
        "Eking va kuzating": "Посадите и наблюдайте",
        "Daraxtingizni eking va ilovamiz orqali o'sishini kuzating. Biz sizga parvarish bo'yicha maslahatlar beramiz.": "Посадите дерево и следите за его ростом через наше приложение. Мы дадим советы по уходу.",

        // ===== AI MASLAHATCHI =====
        "AI Bog'bon (24/7 maslahatchi)": "AI Садовник (24/7 консультант)",
        "Hududingizning iqlimiga mos keladigan daraxtlarni aniqlash uchun sun'iy intellektdan foydalaning.": "Используйте искусственный интеллект для определения деревьев, подходящих для климата вашего региона.",
        "Iqlim sharoitingizni tasvirlang (masalan, \"Toshkent, yozda juda issiq va quruq iqlim\"):": "Опишите климатические условия (например, \"Ташкент, очень жаркий и сухой климат летом\"):",
        "Hududingizni kiriting...": "Введите ваш регион...",
        "Tavsiya olish": "Получить совет",
        "Tavsiyalar bu yerda paydo bo'ladi...": "Рекомендации появятся здесь...",

        // ===== ALOQA =====
        "Biz bilan bog'laning 📞": "Свяжитесь с нами 📞",
        "Loyiha bo'yicha savollaringiz bo'lsa yoki hamkorlikni boshlamoqchi bo'lsangiz, bizga murojaat qiling.": "Если у вас есть вопросы по проекту или вы хотите начать сотрудничество, свяжитесь с нами.",
        "Ism": "Имя",
        "Email": "Email",
        "Xabar": "Сообщение",
        "Yuborish": "Отправить",
        "Xabaringiz yuborildi!": "Ваше сообщение отправлено!",

        // ===== BUYURTMALAR =====
        "Mening buyurtmalarim 📦": "Мои заказы 📦",
        "Barcha buyurtmalaringiz va ularning holati": "Все ваши заказы и их статус",
        "Buyurtmalar yo'q": "Заказов нет",
        "Siz hali buyurtma bermagansiz": "Вы ещё не сделали заказ",
        "Katalogga o'tish": "Перейти в каталог",
        "Kutilmoqda": "Ожидает",
        "Tayyorlanmoqda": "Готовится",
        "Yo'lda": "В пути",
        "Yetkazildi": "Доставлен",
        "Buyurtma raqami": "Номер заказа",
        "Sana": "Дата",
        "Jami": "Итого",

        // ===== SAVAT =====
        "Savat": "Корзина",
        "Savat bo'sh": "Корзина пуста",
        "Hali mahsulot qo'shilmagan": "Товары ещё не добавлены",
        "Buyurtma berish": "Оформить заказ",
        "O'chirish": "Удалить",
        "Miqdor": "Количество",
        "Xarid qilishni davom ettirish": "Продолжить покупки",
        "Savatni tozalash": "Очистить корзину",

        // ===== UMUMIY =====
        "so'm": "сум",
        "dona": "шт",
        "Yopish": "Закрыть",
        "Saqlash": "Сохранить",
        "Bekor qilish": "Отмена",
        "Yuklanmoqda...": "Загрузка...",
        "Xatolik yuz berdi": "Произошла ошибка",
        "Muvaffaqiyatli": "Успешно",
        "Ha": "Да",
        "Yo'q": "Нет",
        "Orqaga": "Назад",
        "Keyingi": "Далее",
        "Barchasi": "Все",
        "Narxi": "Цена",
        "150,000 so'm": "150 000 сум",
        "120,000 so'm": "120 000 сум",
        "45,000 so'm": "45 000 сум",
        "50,000 so'm": "50 000 сум",
        "40,000 so'm": "40 000 сум",
        "8,000 so'm": "8 000 сум",
        "6,000 so'm": "6 000 сум",
        "7,000 so'm": "7 000 сум",
        "5,000 so'm": "5 000 сум",

        // ===== FOOTER =====
        "© 2024 GreenMarket. Barcha huquqlar himoyalangan.": "© 2024 GreenMarket. Все права защищены.",
        "Maxfiylik siyosati": "Политика конфиденциальности",
        "Foydalanish shartlari": "Условия использования",
        "Biz haqimizda": "О нас"
    },

    en: {
        // ===== MENYU =====
        "Bosh sahifa": "Home",
        "Yashil Do'kon": "Green Shop",
        "Oshxona Bog'i": "Kitchen Garden",
        "Katalog": "Catalog",
        "Mavsumiy": "Seasonal",
        "Reyting": "Rating",
        "Kredit": "Credit",
        "Yangiliklar": "News",
        "Qanday ishlaydi": "How it works",
        "AI Maslahatchi": "AI Advisor",
        "Buyurtmalar": "Orders",
        "Aloqa": "Contact",

        // ===== HERO =====
        "Yashil kelajakni bugundan boshlab birga quramiz.": "Building a green future together starting today.",
        "Yashil kelajakni": "A green future",
        "bugundan boshlab birga": "building together",
        "quramiz.": "starting today.",
        "GreenMarket - bu daraxt ekishni osonlashtiruvchi, tabiatga o'z hissangizni qo'shishga yordam beruvchi va ekologik mas'uliyatni rag'batlantiruvchi raqamli platforma.": "GreenMarket is a digital platform that simplifies tree planting, helps you contribute to nature, and encourages environmental responsibility.",
        "Mahsulotlarni ko'rish": "View Products",

        // ===== YASHIL DO'KON =====
        "Yashil Do'kon 🌿": "Green Shop 🌿",
        "Tabiatga g'amxo'rlik qilish uchun barcha kerakli narsalar bir joyda": "Everything you need to care for nature in one place",
        "🌳 Daraxtlar": "🌳 Trees",
        "🌱 Ko'chatlar": "🌱 Seedlings",
        "Savatga": "Add to Cart",
        "Olma daraxti": "Apple Tree",
        "Mevali daraxt, yuqori hosil": "Fruit tree, high yield",
        "Nok daraxti": "Pear Tree",
        "Shirin mevali daraxt": "Sweet fruit tree",
        "O'rik daraxti": "Apricot Tree",
        "Bahorgi gullari chiroyli": "Beautiful spring blossoms",
        "Gilos daraxti": "Cherry Tree",
        "Mazali mevali daraxt": "Delicious fruit tree",

        // ===== OSHXONA BOG'I =====
        "Oshxona Bog'i 🌿🍳": "Kitchen Garden 🌿🍳",
        "Rayhon, ukrop, yalpiz - oshxonangizda doim yangi ko'kat!": "Basil, dill, mint - always fresh herbs in your kitchen!",
        "🪴 Oshxonaga mos o'simliklar": "🪴 Kitchen-friendly plants",
        "Rayhon ko'chati": "Basil seedling",
        "Kichik idishda, oshxonaga mos": "In a small pot, suitable for kitchen",
        "Ukrop ko'chati": "Dill seedling",
        "Tez o'sadi, oson parvarish": "Grows fast, easy to care",
        "Yalpiz ko'chati": "Mint seedling",
        "Choy uchun ideal": "Perfect for tea",
        "Petrushka ko'chati": "Parsley seedling",
        "Vitaminlarga boy": "Rich in vitamins",
        "Oshxona Bog'i To'plami": "Kitchen Garden Set",
        "To'plamni olish": "Get the set",

        // ===== KATALOG =====
        "Mahsulotlar katalogi 🌱": "Product Catalog 🌱",
        "Sizning hududingizga mos keladigan ba'zi o'simlik turlari.": "Some plant species suitable for your region.",
        "Mahsulot nomini kiriting...": "Enter product name...",
        "Minimal narx (so'm)": "Minimum price (sum)",
        "Maksimal narx (so'm)": "Maximum price (sum)",
        "Mahsulot turi": "Product type",
        "Barcha turlar": "All types",
        "Savatga qo'shish": "Add to Cart",
        "Narxi:": "Price:",
        "Chinordan": "Plane Tree",
        "Ushbu daraxt tez o'sadi, soyasi qalin va havo tozalashda juda samarali.": "This tree grows fast, provides dense shade and is very effective at purifying air.",
        "Olmali daraxt": "Apple Tree",
        "Meva beruvchi daraxt. Havoni tozalash bilan birga, bog'ingizga chiroy beradi.": "Fruit tree. Purifies air and beautifies your garden.",
        "Atirgul butasi": "Rose Bush",
        "Bog' va hovlilarga chiroy beruvchi atirgul butasi, oson parvarish qilinadi.": "Beautifies gardens and yards, easy to care for.",

        // ===== MAVSUMIY =====
        "Mavsumiy Eslatgich 📅🌱": "Seasonal Reminders 📅🌱",
        "Har bir mavsumda bog'ingiz uchun nima qilish kerakligini bilib oling": "Learn what to do for your garden in each season",
        "Bahor (Mart-May)": "Spring (March-May)",
        "Ekish va ko'chatlar mavsumi": "Planting and seedling season",
        "Mevali daraxtlarni eking (olma, o'rik, nok)": "Plant fruit trees (apple, apricot, pear)",
        "Sabzavot ko'chatlarini eking (pomidor, bodring)": "Plant vegetable seedlings (tomatoes, cucumbers)",
        "O'g'it bering va tuproqni tayyorlang": "Add fertilizer and prepare the soil",
        "Gul urug'larini sepib boshlang": "Start sowing flower seeds",
        "Yoz (Iyun-Avgust)": "Summer (June-August)",
        "Sug'orish va parvarish mavsumi": "Watering and care season",
        "Muntazam sug'oring (ertalab yoki kechqurun)": "Water regularly (morning or evening)",
        "Begona o'tlarni olib tashlang": "Remove weeds",
        "Zararkunandalarga qarshi kurashing": "Fight pests",
        "Hosilni yig'ib oling": "Harvest crops",
        "Kuz (Sentyabr-Noyabr)": "Autumn (September-November)",
        "Hosil yig'ish mavsumi": "Harvest season",
        "Qolgan hosilni yig'ib oling": "Collect remaining harvest",
        "Daraxtlarni qishga tayyorlang": "Prepare trees for winter",
        "Tushgan barglarni yig'ing": "Collect fallen leaves",
        "Yangi daraxtlar ekish uchun ideal vaqt": "Ideal time to plant new trees",
        "Qish (Dekabr-Fevral)": "Winter (December-February)",
        "Daraxtlarni himoya qilish mavsumi": "Tree protection season",
        "Daraxt tanalarini oqlang": "Whitewash tree trunks",
        "Yosh daraxtlarni sovuqdan himoya qiling": "Protect young trees from cold",
        "Quruq shoxlarni kesib oling": "Prune dry branches",
        "Bahorgi ekish uchun reja tuzing": "Plan spring planting",

        // ===== REYTING =====
        "Mahalla Reytingi 🏆🌳": "Neighborhood Rating 🏆🌳",
        "O'zbekiston bo'ylab eng yashil mahallalar, eng faol oilalar. O'z mahallangizni topib, ball to'plang!": "The greenest neighborhoods across Uzbekistan. Find your neighborhood and earn points!",
        "🥇 Top 3 Mahallalar": "🥇 Top 3 Neighborhoods",
        "daraxt": "trees",
        "ball": "points",
        "oila": "families",
        "1-o'rin": "1st place",
        "2-o'rin": "2nd place",
        "3-o'rin": "3rd place",
        "Ball qanday to'planadi?": "How to earn points?",
        "Daraxt ekish": "Plant a tree",
        "Parvarish qilish": "Care for trees",
        "Do'stlarni taklif qilish": "Invite friends",
        "Sadaqa berish": "Donate",

        // ===== KREDIT =====
        "Yashil Kredit va Sug'urta 💳🛡️": "Green Credit and Insurance 💳🛡️",
        "Bo'lib to'lang, xavfsiz eking. Daraxtingiz qurisa - pul qaytadi!": "Pay in installments, plant safely. If your tree dies - money back!",
        "Bo'lib to'lash": "Installment",
        "0% foiz bilan 3-6-12 oyga": "0% interest for 3-6-12 months",
        "Daraxt sug'urtasi": "Tree Insurance",
        "Daraxt qurisa - 100% pul qaytadi": "If tree dies - 100% refund",
        "Oylik to'lov": "Monthly payment",
        "Ariza berish": "Apply",
        "Hisoblash": "Calculate",
        "oy": "months",
        "oyiga": "per month",

        // ===== YANGILIKLAR =====
        "Yashil Yangiliklar va Video 📺🌿": "Green News and Videos 📺🌿",
        "Har kuni yangi video va buvilarimizning bog'dorchilik sirlari": "New videos every day and gardening secrets from our grandmothers",
        "Bugungi video": "Today's video",
        "Videoni ko'rish": "Watch video",
        "Batafsil o'qish": "Read more",
        "ko'rildi": "views",
        "Buvilarning sirlari": "Grandma's secrets",
        "So'nggi yangiliklar": "Latest news",

        // ===== QANDAY ISHLAYDI =====
        "Qanday ishlaydi? ⚙️": "How does it work? ⚙️",
        "Oddiy qadamlar bilan yashil harakatga qo'shiling.": "Join the green movement with simple steps.",
        "Ro'yxatdan o'ting": "Register",
        "Ilova yoki veb-sayt orqali profilingizni yarating. Bu sizning ekologik hissangizni kuzatish uchun shaxsiy maydonchangiz bo'ladi.": "Create your profile through the app or website. This will be your personal space to track your ecological contribution.",
        "Daraxt tanlang": "Choose a tree",
        "Hududingizga mos daraxt turini tanlang. Biz sizga eng yaxshi variantlarni tavsiya qilamiz.": "Select a tree species suitable for your region. We'll recommend the best options.",
        "Buyurtma bering": "Place an order",
        "Onlayn to'lov qiling va yetkazib berishni kuting. Biz daraxtni uyingizgacha yetkazamiz.": "Pay online and wait for delivery. We'll deliver the tree to your home.",
        "Eking va kuzating": "Plant and monitor",
        "Daraxtingizni eking va ilovamiz orqali o'sishini kuzating. Biz sizga parvarish bo'yicha maslahatlar beramiz.": "Plant your tree and monitor its growth through our app. We'll give you care tips.",

        // ===== AI MASLAHATCHI =====
        "AI Bog'bon (24/7 maslahatchi)": "AI Gardener (24/7 consultant)",
        "Hududingizning iqlimiga mos keladigan daraxtlarni aniqlash uchun sun'iy intellektdan foydalaning.": "Use artificial intelligence to identify trees suitable for your region's climate.",
        "Iqlim sharoitingizni tasvirlang (masalan, \"Toshkent, yozda juda issiq va quruq iqlim\"):": "Describe your climate conditions (e.g., \"Tashkent, very hot and dry climate in summer\"):",
        "Hududingizni kiriting...": "Enter your region...",
        "Tavsiya olish": "Get advice",
        "Tavsiyalar bu yerda paydo bo'ladi...": "Recommendations will appear here...",

        // ===== ALOQA =====
        "Biz bilan bog'laning 📞": "Contact Us 📞",
        "Loyiha bo'yicha savollaringiz bo'lsa yoki hamkorlikni boshlamoqchi bo'lsangiz, bizga murojaat qiling.": "If you have questions about the project or want to start a partnership, contact us.",
        "Ism": "Name",
        "Email": "Email",
        "Xabar": "Message",
        "Yuborish": "Send",
        "Xabaringiz yuborildi!": "Your message has been sent!",

        // ===== BUYURTMALAR =====
        "Mening buyurtmalarim 📦": "My Orders 📦",
        "Barcha buyurtmalaringiz va ularning holati": "All your orders and their status",
        "Buyurtmalar yo'q": "No orders",
        "Siz hali buyurtma bermagansiz": "You haven't placed an order yet",
        "Katalogga o'tish": "Go to catalog",
        "Kutilmoqda": "Pending",
        "Tayyorlanmoqda": "Processing",
        "Yo'lda": "Shipped",
        "Yetkazildi": "Delivered",
        "Buyurtma raqami": "Order number",
        "Sana": "Date",
        "Jami": "Total",

        // ===== SAVAT =====
        "Savat": "Cart",
        "Savat bo'sh": "Cart is empty",
        "Hali mahsulot qo'shilmagan": "No products added yet",
        "Buyurtma berish": "Checkout",
        "O'chirish": "Remove",
        "Miqdor": "Quantity",
        "Xarid qilishni davom ettirish": "Continue shopping",
        "Savatni tozalash": "Clear cart",

        // ===== UMUMIY =====
        "so'm": "sum",
        "dona": "pcs",
        "Yopish": "Close",
        "Saqlash": "Save",
        "Bekor qilish": "Cancel",
        "Yuklanmoqda...": "Loading...",
        "Xatolik yuz berdi": "An error occurred",
        "Muvaffaqiyatli": "Success",
        "Ha": "Yes",
        "Yo'q": "No",
        "Orqaga": "Back",
        "Keyingi": "Next",
        "Barchasi": "All",
        "Narxi": "Price",
        "150,000 so'm": "150,000 sum",
        "120,000 so'm": "120,000 sum",
        "45,000 so'm": "45,000 sum",
        "50,000 so'm": "50,000 sum",
        "40,000 so'm": "40,000 sum",
        "8,000 so'm": "8,000 sum",
        "6,000 so'm": "6,000 sum",
        "7,000 so'm": "7,000 sum",
        "5,000 so'm": "5,000 sum",

        // ===== FOOTER =====
        "© 2024 GreenMarket. Barcha huquqlar himoyalangan.": "© 2024 GreenMarket. All rights reserved.",
        "Maxfiylik siyosati": "Privacy Policy",
        "Foydalanish shartlari": "Terms of Use",
        "Biz haqimizda": "About Us"
    }
};

// ===== TARJIMA TIZIMI =====
let currentLang = localStorage.getItem('lang') || 'uz';

// Sahifadagi barcha matnlarni tarjima qilish
function translatePage() {
    if (currentLang === 'uz') {
        location.reload();
        return;
    }

    const dict = TRANSLATIONS[currentLang];
    if (!dict) return;

    // Matnni normallashtirish funksiyasi
    function normalizeText(text) {
        return text.replace(/\s+/g, ' ').trim();
    }

    // Lug'atdan tarjima topish
    function findTranslation(text) {
        const normalized = normalizeText(text);
        if (dict[normalized]) return dict[normalized];
        if (dict[text]) return dict[text];
        if (dict[text.trim()]) return dict[text.trim()];
        return null;
    }

    // 1. Barcha matn tugunlarini topish va tarjima qilish
    const walker = document.createTreeWalker(
        document.body,
        NodeFilter.SHOW_TEXT,
        null,
        false
    );

    const nodes = [];
    while (walker.nextNode()) nodes.push(walker.currentNode);

    nodes.forEach(node => {
        const originalText = node.textContent;
        const text = normalizeText(originalText);
        const translation = findTranslation(text);
        if (translation) {
            // Bo'sh joylarni saqlash
            const leadingSpace = originalText.match(/^\s*/)[0];
            const trailingSpace = originalText.match(/\s*$/)[0];
            node.textContent = leadingSpace + translation + trailingSpace;
        }
    });

    // 2. Placeholder larni tarjima qilish
    document.querySelectorAll('input[placeholder], textarea[placeholder]').forEach(el => {
        const translation = findTranslation(el.placeholder);
        if (translation) {
            el.placeholder = translation;
        }
    });

    // 3. Title, alt, aria-label atributlarini tarjima qilish
    document.querySelectorAll('[title], [alt], [aria-label]').forEach(el => {
        ['title', 'alt', 'aria-label'].forEach(attr => {
            if (el.hasAttribute(attr)) {
                const translation = findTranslation(el.getAttribute(attr));
                if (translation) {
                    el.setAttribute(attr, translation);
                }
            }
        });
    });

    // 4. Button va span ichidagi matnlarni alohida tekshirish
    document.querySelectorAll('button, span, label, h1, h2, h3, h4, h5, h6, p, a, li, td, th, div').forEach(el => {
        el.childNodes.forEach(child => {
            if (child.nodeType === Node.TEXT_NODE) {
                const originalText = child.textContent;
                const text = normalizeText(originalText);
                const translation = findTranslation(text);
                if (translation) {
                    const leadingSpace = originalText.match(/^\s*/)[0];
                    const trailingSpace = originalText.match(/\s*$/)[0];
                    child.textContent = leadingSpace + translation + trailingSpace;
                }
            }
        });
    });

    // 5. Title ni o'zgartirish
    if (currentLang === 'ru') {
        document.title = "GreenMarket - Цифровая платформа для зелёного будущего";
    } else if (currentLang === 'en') {
        document.title = "GreenMarket - Digital Platform for a Green Future";
    }
}


// Radio tugmalarni yangilash
function updateLangRadios() {
    document.querySelectorAll('input[name="language"]').forEach(r => {
        r.checked = r.value === currentLang;
    });
}

// Tilni o'zgartirish
function changeLanguage(lang) {
    if (lang === currentLang) return;
    currentLang = lang;
    localStorage.setItem('lang', lang);
    location.reload(); // Sahifani yangilash
}

// ===== QO'SHIMCHA TARJIMALAR =====
// Rus tiliga qo'shimcha
Object.assign(TRANSLATIONS.ru, {
    // Yangiliklar bo'limi
    "Share your story!": "Поделитесь своей историей!",
    "What gardening secrets does your family have?": "Какие секреты садоводства есть у вашей семьи?",
    "Ertalab 7:00": "Утро 7:00",
    "Kunlik maslahatlar": "Ежедневные советы",
    "Yoqilgan": "Включено",
    "Kunduzi 12:00": "День 12:00",
    "Ob-havo ogohlantirishlari": "Погодные предупреждения",
    "Ob-havo ogohlantirish": "Погодное предупреждение",
    "Kechqurun 18:00": "Вечер 18:00",
    "Sug'orish eslatmasi": "Напоминание о поливе",
    "O'chirilgan": "Выключено",

    // Kunlik eslatmalar bo'limi
    "Kunlik eslatmalar": "Ежедневные напоминания",
    "Har kuni ertalab sizga maxsus eslatmalar yuboramiz": "Каждое утро мы отправляем вам специальные напоминания",
    "Eslatma misollari:": "Примеры напоминаний:",
    "\"Bugun pomidorlaringizni sug'orish vaqti keldi 💧\"": "\"Сегодня пора полить ваши помидоры 💧\"",
    "\"Ertaga yomg'ir kutilmoqda - sug'orishni kechiktiring ☔\"": "\"Завтра ожидается дождь - отложите полив ☔\"",
    "\"Bahor keldi! Pomidor ko'chatlarini ekish vaqti 🌱\"": "\"Весна пришла! Время сажать рассаду помидоров 🌱\"",
    "\"Daraxtlaringizga o'g'it berish vaqti keldi 🧪\"": "\"Пора удобрять ваши деревья 🧪\"",

    // Hozirgi mavsum
    "Hozirgi mavsum: Kuz 🍂": "Текущий сезон: Осень 🍂",
    "Kuz - hosil yig'ish va qishga tayyorgarlik ko'rish vaqti. Daraxtlaringizni qirqing va organik": "Осень - время сбора урожая и подготовки к зиме. Обрежьте деревья и органические",

    // Qo'shimcha matnlar
    "Hikoyangizni ulashing!": "Поделитесь своей историей!",
    "Oilangizda qanday bog'dorchilik sirlari bor?": "Какие секреты садоводства есть у вашей семьи?",
    "Bugun": "Сегодня",
    "Kecha": "Вчера",
    "Hafta": "Неделя",
    "Oy": "Месяц",
    "Yil": "Год",
    "Bepul": "Бесплатно",
    "Chegirma": "Скидка",
    "Yangi": "Новое",
    "Mashhur": "Популярное",
    "Tavsiya etilgan": "Рекомендуемое",
    "Ko'proq ko'rish": "Показать больше",
    "Kamroq ko'rish": "Показать меньше",
    "Izlash": "Поиск",
    "Filtr": "Фильтр",
    "Saralash": "Сортировка",
    "Narx bo'yicha": "По цене",
    "Nom bo'yicha": "По названию",
    "Sana bo'yicha": "По дате",
    "Reyting bo'yicha": "По рейтингу",
    "Arzondan qimmatga": "От дешёвых к дорогим",
    "Qimmatdan arzonga": "От дорогих к дешёвым",
    "Eng yangi": "Самые новые",
    "Eng eski": "Самые старые",

    // Bildirishnomalar
    "Bildirishnomalar": "Уведомления",
    "Barcha bildirishnomalar": "Все уведомления",
    "Yangi bildirishnoma": "Новое уведомление",
    "O'qilmagan": "Непрочитанное",
    "O'qilgan": "Прочитанное",

    // Foydalanuvchi
    "Profil": "Профиль",
    "Sozlamalar": "Настройки",
    "Chiqish": "Выход",
    "Kirish": "Вход",
    "Ro'yxatdan o'tish": "Регистрация",
    "Parol": "Пароль",
    "Parolni unutdingizmi?": "Забыли пароль?",
    "Eslab qolish": "Запомнить",

    // Vaqt
    "soat": "часов",
    "daqiqa": "минут",
    "soniya": "секунд",
    "kun": "дней",
    "hafta": "недель",
    "oy": "месяцев",
    "yil": "лет",
    "oldin": "назад",
    "keyin": "спустя",

    // Holatlar
    "Faol": "Активно",
    "Nofaol": "Неактивно",
    "Kutilmoqda": "Ожидается",
    "Bajarildi": "Выполнено",
    "Bekor qilindi": "Отменено",
    "Xatolik": "Ошибка",

    // Tugmalar
    "Tasdiqlash": "Подтвердить",
    "Rad etish": "Отклонить",
    "Tahrirlash": "Редактировать",
    "Ko'rish": "Просмотр",
    "Yuklab olish": "Скачать",
    "Ulashish": "Поделиться",
    "Nusxa olish": "Копировать",
    "Qo'shish": "Добавить",
    "Olib tashlash": "Удалить"
});

// Ingliz tiliga qo'shimcha
Object.assign(TRANSLATIONS.en, {
    // Yangiliklar bo'limi
    "Share your story!": "Share your story!",
    "What gardening secrets does your family have?": "What gardening secrets does your family have?",
    "Ertalab 7:00": "Morning 7:00",
    "Kunlik maslahatlar": "Daily tips",
    "Yoqilgan": "Enabled",
    "Kunduzi 12:00": "Noon 12:00",
    "Ob-havo ogohlantirishlari": "Weather alerts",
    "Ob-havo ogohlantirish": "Weather alert",
    "Kechqurun 18:00": "Evening 18:00",
    "Sug'orish eslatmasi": "Watering reminder",
    "O'chirilgan": "Disabled",

    // Kunlik eslatmalar bo'limi
    "Kunlik eslatmalar": "Daily reminders",
    "Har kuni ertalab sizga maxsus eslatmalar yuboramiz": "We send you special reminders every morning",
    "Eslatma misollari:": "Reminder examples:",
    "\"Bugun pomidorlaringizni sug'orish vaqti keldi 💧\"": "\"It's time to water your tomatoes today 💧\"",
    "\"Ertaga yomg'ir kutilmoqda - sug'orishni kechiktiring ☔\"": "\"Rain expected tomorrow - delay watering ☔\"",
    "\"Bahor keldi! Pomidor ko'chatlarini ekish vaqti 🌱\"": "\"Spring is here! Time to plant tomato seedlings 🌱\"",
    "\"Daraxtlaringizga o'g'it berish vaqti keldi 🧪\"": "\"It's time to fertilize your trees 🧪\"",

    // Hozirgi mavsum
    "Hozirgi mavsum: Kuz 🍂": "Current season: Autumn 🍂",
    "Kuz - hosil yig'ish va qishga tayyorgarlik ko'rish vaqti. Daraxtlaringizni qirqing va organik": "Autumn - time to harvest and prepare for winter. Prune your trees and organic",

    // Qo'shimcha matnlar
    "Hikoyangizni ulashing!": "Share your story!",
    "Oilangizda qanday bog'dorchilik sirlari bor?": "What gardening secrets does your family have?",
    "Bugun": "Today",
    "Kecha": "Yesterday",
    "Hafta": "Week",
    "Oy": "Month",
    "Yil": "Year",
    "Bepul": "Free",
    "Chegirma": "Discount",
    "Yangi": "New",
    "Mashhur": "Popular",
    "Tavsiya etilgan": "Recommended",
    "Ko'proq ko'rish": "Show more",
    "Kamroq ko'rish": "Show less",
    "Izlash": "Search",
    "Filtr": "Filter",
    "Saralash": "Sort",
    "Narx bo'yicha": "By price",
    "Nom bo'yicha": "By name",
    "Sana bo'yicha": "By date",
    "Reyting bo'yicha": "By rating",
    "Arzondan qimmatga": "Low to high",
    "Qimmatdan arzonga": "High to low",
    "Eng yangi": "Newest",
    "Eng eski": "Oldest",

    // Bildirishnomalar
    "Bildirishnomalar": "Notifications",
    "Barcha bildirishnomalar": "All notifications",
    "Yangi bildirishnoma": "New notification",
    "O'qilmagan": "Unread",
    "O'qilgan": "Read",

    // Foydalanuvchi
    "Profil": "Profile",
    "Sozlamalar": "Settings",
    "Chiqish": "Logout",
    "Kirish": "Login",
    "Ro'yxatdan o'tish": "Register",
    "Parol": "Password",
    "Parolni unutdingizmi?": "Forgot password?",
    "Eslab qolish": "Remember me",

    // Vaqt
    "soat": "hours",
    "daqiqa": "minutes",
    "soniya": "seconds",
    "kun": "days",
    "hafta": "weeks",
    "oy": "months",
    "yil": "years",
    "oldin": "ago",
    "keyin": "later",

    // Holatlar
    "Faol": "Active",
    "Nofaol": "Inactive",
    "Kutilmoqda": "Pending",
    "Bajarildi": "Completed",
    "Bekor qilindi": "Cancelled",
    "Xatolik": "Error",

    // Tugmalar
    "Tasdiqlash": "Confirm",
    "Rad etish": "Reject",
    "Tahrirlash": "Edit",
    "Ko'rish": "View",
    "Yuklab olish": "Download",
    "Ulashish": "Share",
    "Nusxa olish": "Copy",
    "Qo'shish": "Add",
    "Olib tashlash": "Remove"
});

// ===== SAHIFA YUKLANGANDA =====
document.addEventListener('DOMContentLoaded', () => {
    updateLangRadios();
    if (currentLang !== 'uz') {
        translatePage();
    }
});
