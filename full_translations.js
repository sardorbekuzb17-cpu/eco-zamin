// BARCHA SAHIFADAGI MATNLARNI 100% TARJIMA QILISH

const allTranslations = {
    uz: {
        'kitchen-basil-name': "Rayhon ko'chati",
        'kitchen-basil-desc': "Kichik idishda, oshxonaga mos",
        'kitchen-basil-recipe': "Palov, sho'rva, salat",
        'kitchen-dill-name': "Ukrop ko'chati",
        'kitchen-dill-desc': "Tez o'sadigan, oshxona uchun",
        'kitchen-dill-recipe': "Salat, sho'rva, baliq",
        'kitchen-mint-name': "Yalpiz ko'chati",
        'kitchen-mint-desc': "Xushbo'y, choy uchun ideal",
        'kitchen-mint-recipe': "Choy, limonad, salat",
        'kitchen-cherry-name': "Cherry pomidor",
        'kitchen-cherry-desc': "Kichik, oshxona uchun",
        'kitchen-cherry-recipe': "Salat, pizza, pasta",
        'kitchen-recipe-label': "🍝 Retsept:",
        'kitchen-add-cart': "Savatga + Retsept",
        'kitchen-title': "🪴 Oshxonaga mos o'simliklar",
        'price-currency': "so'm",
        'fruit-apple-name': "Olma daraxti",
        'fruit-apple-desc': "Mevali daraxt, yuqori hosil",
        'fruit-pear-name': "Nok daraxti",
        'fruit-pear-desc': "Shirin mevali daraxt",
        'fruit-apricot-name': "O'rik daraxti",
        'fruit-apricot-desc': "Mazali mevali daraxt",
        'fruit-cherry-name': "Cherry Tree",
        'fruit-cherry-desc': "Delicious fruit tree",
        'add-to-cart': "Add to Cart",
        'kitchen-set-title': "Kitchen Garden Set",
        'kitchen-set-desc': "All necessary greens in one set! Together with small pots.",
        'kitchen-set-separate': "Separately:",
        'kitchen-set-save': "savings!",
        'kitchen-set-button': "Get the Set",
        'kitchen-set-bonus': "Bonus:",
        'kitchen-set-bonus-text': "10 kitchen recipes in PDF format for free!",
        'kitchen-tips-title': "🌱 Kitchen Garden Tips",
        'kitchen-tip-light': "Light",
        'kitchen-tip-light-desc': "Place near window, needs 4-6 hours of light per day",
        'kitchen-tip-water': "Watering",
        'kitchen-tip-water-desc': "Water when soil is dry, don't overwater",
        'kitchen-tip-harvest': "Harvesting",
        'kitchen-tip-harvest-desc': "Cut from the top, new shoots will grow",
        'kitchen-set-title': "Oshxona Bog'i To'plami",
        'kitchen-set-desc': "Barcha kerakli ko'katlar bir to'plamda! Kichik idishlar bilan birga.",
        'kitchen-set-separate': "Alohida:",
        'kitchen-set-save': "tejash!",
        'kitchen-set-button': "To'plamni olish",
        'kitchen-set-bonus': "Bonus:",
        'kitchen-set-bonus-text': "10 ta oshxona retsepti PDF formatda bepul!",
        'kitchen-tips-title': "🌱 Oshxona bog'i uchun maslahatlar",
        'kitchen-tip-light': "Yorug'lik",
        'kitchen-tip-light-desc': "Deraza yoniga qo'ying, kuniga 4-6 soat yorug'lik kerak",
        'kitchen-tip-water': "Sug'orish",
        'kitchen-tip-water-desc': "Tuproq quriganda sug'oring, ortiqcha suv bermaslik",
        'kitchen-tip-harvest': "Yig'ish",
        'kitchen-tip-harvest-desc': "Yuqori qismidan kesib oling, yangi novdalar o'sadi",
        'sadaqah-title': "Yashil Jamg'arma 🌳💚",
        'sadaqah-subtitle': "Duo uchun daraxt eking - Sadaqai Joriya. Yaqinlaringiz nomi bilan daraxt ekib, ularning ruhiga savob ulashing.",
        'sadaqah-prayer-tree-title': "Duo uchun daraxt",
        'sadaqah-prayer-tree-desc': "Masjid, qabriston yoki biror tashkilot uchun daraxt",
        'sadaqah-continuous-title': "Sadaqai Joriya",
        'sadaqah-continuous-subtitle': "Doimiy savob",
        'sadaqah-continuous-desc': "Daraxt o'sib, meva bergan sari savob davom etadi",
        'sadaqah-certificate-title': "Shaxsiy sertifikat",
        'sadaqah-certificate-desc': "Yaqiningiz nomi va duo bilan maxsus sertifikat",
        'sadaqah-location-title': "Joylashuv ma'lumoti",
        'sadaqah-location-desc': "Daraxt qayerda ekilganini bilib boring",
        'sadaqah-plant-button': "Duo uchun daraxt ekish",
        'sadaqah-gift-title': "Hayot voqealari uchun",
        'sadaqah-gift-desc': "Tug'ilgan kun, to'y, yubiley uchun daraxt sovg'a qiling",
        'sadaqah-birthday-title': "Tug'ilgan kun",
        'sadaqah-birthday-desc': "Har yili o'sib boradigan esdalik",
        'sadaqah-wedding-title': "To'y sovg'asi",
        'sadaqah-wedding-desc': "Oila bilan birga o'sadigan daraxt",
        'sadaqah-achievement-title': "Yutuq nishonasi",
        'sadaqah-achievement-desc': "Muvaffaqiyatni daraxt bilan nishonlang",
        'sadaqah-gift-button': "Sovg'a daraxt ekish",
        'sadaqah-how-title': "Qanday ishlaydi?",
        'sadaqah-step1-title': "Daraxt tanlang",
        'sadaqah-step1-desc': "Mevali yoki soyali daraxt tanlang",
        'sadaqah-step2-title': "Ma'lumot kiriting",
        'sadaqah-step2-desc': "Yaqiningiz nomi va duo matnini yozing",
        'sadaqah-step3-title': "Daraxt ekiladi",
        'sadaqah-step3-desc': "Biz daraxtni professional ekamiz",
        'sadaqah-step4-title': "Sertifikat oling",
        'sadaqah-step4-desc': "QR-kodli raqamli sertifikat",
        'sadaqah-hadith': "📖\n\"Musulmon kishi daraxt eksa yoki ekin eksa, undan odam, qush yoki hayvon yesa, bu unga sadaqa bo'ladi\"\n\n- Hadisi Sharif (Buxoriy va Muslim)",
        'seasonal-title': "Mavsumiy Eslatgich 📅🌱",
        'seasonal-subtitle': "Har bir mavsumda bog'ingiz uchun nima qilish kerakligini bilib oling"
    },
    ru: {
        'kitchen-basil-name': "Рассада базилика",
        'kitchen-basil-desc': "В маленьком горшке, для кухни",
        'kitchen-basil-recipe': "Плов, суп, салат",
        'kitchen-dill-name': "Рассада укропа",
        'kitchen-dill-desc': "Быстрорастущий, для кухни",
        'kitchen-dill-recipe': "Салат, суп, рыба",
        'kitchen-mint-name': "Рассада мяты",
        'kitchen-mint-desc': "Ароматная, идеальна для чая",
        'kitchen-mint-recipe': "Чай, лимонад, салат",
        'kitchen-cherry-name': "Черри помидоры",
        'kitchen-cherry-desc': "Маленькие, для кухни",
        'kitchen-cherry-recipe': "Салат, пицца, паста",
        'kitchen-recipe-label': "🍝 Рецепт:",
        'kitchen-add-cart': "В корзину + Рецепт",
        'kitchen-title': "🪴 Растения для кухни",
        'price-currency': "сум",
        'fruit-apple-name': "Яблоня",
        'fruit-apple-desc': "Плодовое дерево, высокий урожай",
        'fruit-pear-name': "Груша",
        'fruit-pear-desc': "Сладкое плодовое дерево",
        'fruit-apricot-name': "Абрикос",
        'fruit-apricot-desc': "Вкусное плодовое дерево",
        'fruit-cherry-name': "Вишня",
        'fruit-cherry-desc': "Вкусное плодовое дерево",
        'add-to-cart': "В корзину",
        'kitchen-set-title': "Набор для кухни",
        'kitchen-set-desc': "Вся необходимая зелень в одном наборе! Вместе с маленькими горшками.",
        'kitchen-set-separate': "Отдельно:",
        'kitchen-set-save': "экономия!",
        'kitchen-set-button': "Получить набор",
        'kitchen-set-bonus': "Бонус:",
        'kitchen-set-bonus-text': "10 кухонных рецептов в формате PDF бесплатно!",
        'kitchen-tips-title': "🌱 Советы по кухонному саду",
        'kitchen-tip-light': "Освещение",
        'kitchen-tip-light-desc': "Поставьте у окна, нужно 4-6 часов света в день",
        'kitchen-tip-water': "Полив",
        'kitchen-tip-water-desc': "Поливайте когда почва сухая, не переливайте",
        'kitchen-tip-harvest': "Сбор урожая",
        'kitchen-tip-harvest-desc': "Срезайте сверху, вырастут новые побеги",
        'sadaqah-title': "Зеленые Сбережения 🌳💚",
        'sadaqah-subtitle': "Посадите дерево для молитвы - Садака Джария. Посадите дерево от имени близких и подарите им награду.",
        'sadaqah-prayer-tree-title': "Дерево для молитвы",
        'sadaqah-prayer-tree-desc': "Дерево для мечети, кладбища или организации",
        'sadaqah-continuous-title': "Садака Джария",
        'sadaqah-continuous-subtitle': "Постоянная награда",
        'sadaqah-continuous-desc': "По мере роста дерева и плодоношения награда продолжается",
        'sadaqah-certificate-title': "Личный сертификат",
        'sadaqah-certificate-desc': "Специальный сертификат с именем близкого и молитвой",
        'sadaqah-location-title': "Информация о местоположении",
        'sadaqah-location-desc': "Узнайте, где было посажено дерево",
        'sadaqah-plant-button': "Посадить дерево для молитвы",
        'sadaqah-gift-title': "Для жизненных событий",
        'sadaqah-gift-desc': "Подарите дерево на день рождения, свадьбу, юбилей",
        'sadaqah-birthday-title': "День рождения",
        'sadaqah-birthday-desc': "Память, растущая каждый год",
        'sadaqah-wedding-title': "Свадебный подарок",
        'sadaqah-wedding-desc': "Дерево, растущее вместе с семьей",
        'sadaqah-achievement-title': "Знак достижения",
        'sadaqah-achievement-desc': "Отметьте успех деревом",
        'sadaqah-gift-button': "Посадить подарочное дерево",
        'sadaqah-how-title': "Как это работает?",
        'sadaqah-step1-title': "Выберите дерево",
        'sadaqah-step1-desc': "Выберите плодовое или тенистое дерево",
        'sadaqah-step2-title': "Введите информацию",
        'sadaqah-step2-desc': "Напишите имя близкого и текст молитвы",
        'sadaqah-step3-title': "Дерево будет посажено",
        'sadaqah-step3-desc': "Мы профессионально посадим дерево",
        'sadaqah-step4-title': "Получите сертификат",
        'sadaqah-step4-desc': "Цифровой сертификат с QR-кодом",
        'sadaqah-hadith': "📖\n\"Если мусульманин посадит дерево или посеет урожай, и человек, птица или животное съест из него, это будет для него милостыней\"\n\n- Хадис Шариф (Бухари и Муслим)",
        'seasonal-title': "Сезонное Напоминание 📅🌱",
        'seasonal-subtitle': "Узнайте, что нужно делать для вашего сада в каждом сезоне"
    },
    en: {
        'kitchen-basil-name': "Basil Seedling",
        'kitchen-basil-desc': "In small pot, for kitchen",
        'kitchen-basil-recipe': "Rice, soup, salad",
        'kitchen-dill-name': "Dill Seedling",
        'kitchen-dill-desc': "Fast growing, for kitchen",
        'kitchen-dill-recipe': "Salad, soup, fish",
        'kitchen-mint-name': "Mint Seedling",
        'kitchen-mint-desc': "Aromatic, ideal for tea",
        'kitchen-mint-recipe': "Tea, lemonade, salad",
        'kitchen-cherry-name': "Cherry Tomatoes",
        'kitchen-cherry-desc': "Small, for kitchen",
        'kitchen-cherry-recipe': "Salad, pizza, pasta",
        'kitchen-recipe-label': "🍝 Recipe:",
        'kitchen-add-cart': "Add to Cart + Recipe",
        'kitchen-title': "🪴 Kitchen Plants",
        'price-currency': "sum",
        'fruit-apple-name': "Apple Tree",
        'fruit-apple-desc': "Fruit tree, high yield",
        'fruit-pear-name': "Pear Tree",
        'fruit-pear-desc': "Sweet fruit tree",
        'fruit-apricot-name': "Apricot Tree",
        'fruit-apricot-desc': "Delicious fruit tree",
        'fruit-cherry-name': "Cherry Tree",
        'fruit-cherry-desc': "Delicious fruit tree",
        'add-to-cart': "Add to Cart",
        'kitchen-set-title': "Kitchen Garden Set",
        'kitchen-set-desc': "All necessary greens in one set! Together with small pots.",
        'kitchen-set-separate': "Separately:",
        'kitchen-set-save': "savings!",
        'kitchen-set-button': "Get the Set",
        'kitchen-set-bonus': "Bonus:",
        'kitchen-set-bonus-text': "10 kitchen recipes in PDF format for free!",
        'kitchen-tips-title': "🌱 Kitchen Garden Tips",
        'kitchen-tip-light': "Light",
        'kitchen-tip-light-desc': "Place near window, needs 4-6 hours of light per day",
        'kitchen-tip-water': "Watering",
        'kitchen-tip-water-desc': "Water when soil is dry, don't overwater",
        'kitchen-tip-harvest': "Harvesting",
        'kitchen-tip-harvest-desc': "Cut from the top, new shoots will grow",
        'sadaqah-title': "Green Savings 🌳💚",
        'sadaqah-subtitle': "Plant a tree for prayer - Sadaqah Jariyah. Plant a tree in the name of your loved ones and share the reward with their souls.",
        'sadaqah-prayer-tree-title': "Prayer Tree",
        'sadaqah-prayer-tree-desc': "Tree for mosque, cemetery or organization",
        'sadaqah-continuous-title': "Sadaqah Jariyah",
        'sadaqah-continuous-subtitle': "Continuous Reward",
        'sadaqah-continuous-desc': "As the tree grows and bears fruit, the reward continues",
        'sadaqah-certificate-title': "Personal Certificate",
        'sadaqah-certificate-desc': "Special certificate with loved one's name and prayer",
        'sadaqah-location-title': "Location Information",
        'sadaqah-location-desc': "Find out where the tree was planted",
        'sadaqah-plant-button': "Plant Prayer Tree",
        'sadaqah-gift-title': "For Life Events",
        'sadaqah-gift-desc': "Gift a tree for birthday, wedding, anniversary",
        'sadaqah-birthday-title': "Birthday",
        'sadaqah-birthday-desc': "A memory that grows every year",
        'sadaqah-wedding-title': "Wedding Gift",
        'sadaqah-wedding-desc': "A tree growing with the family",
        'sadaqah-achievement-title': "Achievement Mark",
        'sadaqah-achievement-desc': "Mark success with a tree",
        'sadaqah-gift-button': "Plant Gift Tree",
        'sadaqah-how-title': "How does it work?",
        'sadaqah-step1-title': "Choose a Tree",
        'sadaqah-step1-desc': "Select fruit or shade tree",
        'sadaqah-step2-title': "Enter Information",
        'sadaqah-step2-desc': "Write loved one's name and prayer text",
        'sadaqah-step3-title': "Tree is Planted",
        'sadaqah-step3-desc': "We plant the tree professionally",
        'sadaqah-step4-title': "Receive Certificate",
        'sadaqah-step4-desc': "Digital certificate with QR code",
        'sadaqah-hadith': "📖\n\"If a Muslim plants a tree or sows a crop, and a person, bird or animal eats from it, it will be charity for him\"\n\n- Hadith Sharif (Bukhari and Muslim)",
        'seasonal-title': "Seasonal Reminder 📅🌱",
        'seasonal-subtitle': "Learn what to do for your garden in each season"
    }
};

// Eski applyTranslations funksiyasini saqlash
if (typeof window.applyTranslations !== 'undefined') {
    window.originalApplyTranslations = window.applyTranslations;
}

// Yangi to'liq applyTranslations funksiyasi
window.applyTranslations = function(lang) {
    const t = translations[lang];
    const at = allTranslations[lang];
    
    if (!t || !at) return;

    // Eski funksiyani chaqirish
    if (typeof window.originalApplyTranslations === 'function') {
        window.originalApplyTranslations(lang);
    }

    // data-translate atributlari bo'yicha tarjima qilish
    document.querySelectorAll('[data-translate]').forEach(el => {
        const key = el.getAttribute('data-translate');
        if (at[key]) {
            el.textContent = at[key];
        }
    });

    // Kitchen Garden - BARCHA matnlarni tarjima qilish
    const kitchenCards = document.querySelectorAll('#kitchen-garden .stat-card');
    kitchenCards.forEach(card => {
        const h4 = card.querySelector('h4');
        const desc = card.querySelector('p.text-sm.text-slate-600');
        const recipeText = card.querySelector('.bg-yellow-50 span:not(.font-bold)');
        const btn = card.querySelector('button');
        
        if (h4) {
            const text = h4.textContent.trim();
            if (text.includes('Rayhon') || text.includes('Базилик') || text.includes('Basil')) {
                h4.textContent = at['kitchen-basil-name'];
                if (desc) desc.textContent = at['kitchen-basil-desc'];
                if (recipeText) recipeText.textContent = at['kitchen-basil-recipe'];
            }
            else if (text.includes('Ukrop') || text.includes('укроп') || text.includes('Dill')) {
                h4.textContent = at['kitchen-dill-name'];
                if (desc) desc.textContent = at['kitchen-dill-desc'];
                if (recipeText) recipeText.textContent = at['kitchen-dill-recipe'];
            }
            else if (text.includes('Yalpiz') || text.includes('мят') || text.includes('Mint')) {
                h4.textContent = at['kitchen-mint-name'];
                if (desc) desc.textContent = at['kitchen-mint-desc'];
                if (recipeText) recipeText.textContent = at['kitchen-mint-recipe'];
            }
            else if (text.includes('Cherry') || text.includes('Черри') || text.includes('pomidor')) {
                h4.textContent = at['kitchen-cherry-name'];
                if (desc) desc.textContent = at['kitchen-cherry-desc'];
                if (recipeText) recipeText.textContent = at['kitchen-cherry-recipe'];
            }
        }
        
        if (btn) {
            btn.textContent = at['kitchen-add-cart'];
        }
    });

    // "Retsept:" labelni tarjima qilish
    document.querySelectorAll('#kitchen-garden .bg-yellow-50 .font-bold').forEach(el => {
        el.textContent = at['kitchen-recipe-label'];
    });

    // Kitchen Garden sarlavhasini tarjima qilish
    const kitchenTitle = document.querySelector('#kitchen-garden h3');
    if (kitchenTitle) {
        kitchenTitle.textContent = at['kitchen-title'];
    }

    // Narxlarni tarjima qilish - barcha narx elementlari
    const priceSelectors = [
        '.text-green-700.font-bold',
        '.text-green-600.font-bold',
        '.text-2xl.font-bold.text-green-600',
        '.text-xl.font-bold.text-green-700',
        '.text-lg.font-bold.text-green-700'
    ];
    
    priceSelectors.forEach(selector => {
        document.querySelectorAll(selector).forEach(el => {
            const text = el.textContent.trim();
            if (text.includes('so\'m') || text.includes('сум') || text.includes('sum')) {
                const price = text.match(/[\d,]+/)?.[0] || '';
                if (price) {
                    el.textContent = `${price} ${at['price-currency']}`;
                }
            }
        });
    });

    // Meva daraxtlari - BARCHA matnlarni tarjima qilish
    const catalogCards = document.querySelectorAll('#catalog .stat-card');
    catalogCards.forEach(card => {
        const h4 = card.querySelector('h4');
        const desc = card.querySelector('p.text-sm.text-slate-600');
        const btn = card.querySelector('button');
        
        if (h4) {
            const text = h4.textContent.trim();
            if (text.includes('Olma') || text.includes('Яблон') || text.includes('Apple')) {
                h4.textContent = at['fruit-apple-name'];
                if (desc) desc.textContent = at['fruit-apple-desc'];
            }
            else if (text.includes('Nok') || text.includes('Груш') || text.includes('Pear')) {
                h4.textContent = at['fruit-pear-name'];
                if (desc) desc.textContent = at['fruit-pear-desc'];
            }
            else if (text.includes('rik') || text.includes('Абрикос') || text.includes('Apricot')) {
                h4.textContent = at['fruit-apricot-name'];
                if (desc) desc.textContent = at['fruit-apricot-desc'];
            }
            else if (text.includes('Gilos') || text.includes('Вишн') || text.includes('Cherry Tree')) {
                h4.textContent = at['fruit-cherry-name'];
                if (desc) desc.textContent = at['fruit-cherry-desc'];
            }
        }
        
        if (btn && !btn.textContent.includes('Retsept') && !btn.textContent.includes('Рецепт') && !btn.textContent.includes('Recipe')) {
            btn.textContent = at['add-to-cart'];
        }
    });

    // Oshxona Bog'i To'plami bo'limini tarjima qilish
    const setTitle = document.querySelector('.bg-gradient-to-r h3');
    if (setTitle && (setTitle.textContent.includes('Oshxona') || setTitle.textContent.includes('Набор') || setTitle.textContent.includes('Kitchen'))) {
        setTitle.textContent = at['kitchen-set-title'];
    }
    
    const setDesc = document.querySelector('.bg-gradient-to-r p.text-slate-700');
    if (setDesc) {
        setDesc.textContent = at['kitchen-set-desc'];
    }
    
    const setButton = document.querySelector('.bg-gradient-to-r button');
    if (setButton) {
        setButton.textContent = at['kitchen-set-button'];
    }
    
    // To'plamdagi o'simlik nomlarini tarjima qilish
    const setPlantNames = document.querySelectorAll('.bg-gradient-to-r .text-center p.text-xs.font-bold');
    setPlantNames.forEach(el => {
        const text = el.textContent.trim();
        if (text.includes('Rayhon') || text.includes('Базилик') || text.includes('Basil')) {
            el.textContent = lang === 'uz' ? 'Rayhon' : (lang === 'ru' ? 'Базилик' : 'Basil');
        }
        else if (text.includes('Ukrop') || text.includes('Укроп') || text.includes('Dill')) {
            el.textContent = lang === 'uz' ? 'Ukrop' : (lang === 'ru' ? 'Укроп' : 'Dill');
        }
        else if (text.includes('Yalpiz') || text.includes('Мята') || text.includes('Mint')) {
            el.textContent = lang === 'uz' ? 'Yalpiz' : (lang === 'ru' ? 'Мята' : 'Mint');
        }
        else if (text.includes('Cherry') || text.includes('Черри') || text.includes('pomidor')) {
            el.textContent = lang === 'uz' ? 'Cherry pomidor' : (lang === 'ru' ? 'Черри помидоры' : 'Cherry Tomatoes');
        }
    });
    
    // Tejash va bonus matnlarini tarjima qilish
    document.querySelectorAll('.bg-gradient-to-r p').forEach(el => {
        const text = el.textContent.trim();
        if (text.includes('tejash') || text.includes('экономия') || text.includes('savings')) {
            el.textContent = `24% ${at['kitchen-set-save']}`;
        }
        else if (text.includes('Bonus') || text.includes('Бонус')) {
            const bonusText = lang === 'uz' ? `${at['kitchen-set-bonus']} ${at['kitchen-set-bonus-text']}` : 
                              lang === 'ru' ? `${at['kitchen-set-bonus']} ${at['kitchen-set-bonus-text']}` : 
                              `${at['kitchen-set-bonus']} ${at['kitchen-set-bonus-text']}`;
            el.innerHTML = `<strong>${at['kitchen-set-bonus']}</strong> ${at['kitchen-set-bonus-text']}`;
        }
        else if (text.includes('Alohida') || text.includes('Отдельно') || text.includes('Separately')) {
            const priceMatch = text.match(/[\d,]+/);
            if (priceMatch) {
                el.textContent = `${at['kitchen-set-separate']} ${priceMatch[0]} ${at['price-currency']}`;
            }
        }
    });
    
    // Maslahatlar bo'limini tarjima qilish
    const tipsTitle = document.querySelector('.bg-white h3');
    if (tipsTitle && (tipsTitle.textContent.includes('maslahatlar') || tipsTitle.textContent.includes('Советы') || tipsTitle.textContent.includes('Tips'))) {
        tipsTitle.textContent = at['kitchen-tips-title'];
    }
    
    const tipCards = document.querySelectorAll('.bg-white .text-center.p-4');
    if (tipCards.length >= 3) {
        const lightH4 = tipCards[0].querySelector('h4');
        const lightP = tipCards[0].querySelector('p');
        if (lightH4) lightH4.textContent = at['kitchen-tip-light'];
        if (lightP) lightP.textContent = at['kitchen-tip-light-desc'];
        
        const waterH4 = tipCards[1].querySelector('h4');
        const waterP = tipCards[1].querySelector('p');
        if (waterH4) waterH4.textContent = at['kitchen-tip-water'];
        if (waterP) waterP.textContent = at['kitchen-tip-water-desc'];
        
        const harvestH4 = tipCards[2].querySelector('h4');
        const harvestP = tipCards[2].querySelector('p');
        if (harvestH4) harvestH4.textContent = at['kitchen-tip-harvest'];
        if (harvestP) harvestP.textContent = at['kitchen-tip-harvest-desc'];
    }

    // Yashil Jamg'arma bo'limini tarjima qilish
    const sadaqahSection = document.querySelector('#sadaqah');
    if (sadaqahSection && at) {
        sadaqahSection.querySelectorAll('h3').forEach(h3 => {
            const text = h3.textContent.trim();
            if (text.includes('Duo uchun daraxt') || text.includes('Дерево для молитвы') || text.includes('Prayer Tree')) {
                h3.textContent = at['sadaqah-prayer-tree-title'];
            } else if (text.includes('Hayot voqealari') || text.includes('жизненных событий') || text.includes('Life Events')) {
                h3.textContent = at['sadaqah-gift-title'];
            }
        });
        
        sadaqahSection.querySelectorAll('strong').forEach(strong => {
            const text = strong.textContent.trim();
            if (text.includes('Sadaqai Joriya') || text.includes('Садака Джария') || text.includes('Sadaqah Jariyah')) {
                strong.textContent = at['sadaqah-continuous-title'];
            } else if (text.includes('Shaxsiy sertifikat') || text.includes('Личный сертификат') || text.includes('Personal Certificate')) {
                strong.textContent = at['sadaqah-certificate-title'];
            } else if (text.includes('Joylashuv') || text.includes('местоположении') || text.includes('Location')) {
                strong.textContent = at['sadaqah-location-title'];
            } else if (text.includes('Tug\'ilgan kun') || text.includes('День рождения') || text.includes('Birthday')) {
                strong.textContent = at['sadaqah-birthday-title'];
            } else if (text.includes('To\'y sovg') || text.includes('Свадебный') || text.includes('Wedding')) {
                strong.textContent = at['sadaqah-wedding-title'];
            } else if (text.includes('Yutuq') || text.includes('достижения') || text.includes('Achievement')) {
                strong.textContent = at['sadaqah-achievement-title'];
            }
        });
        
        sadaqahSection.querySelectorAll('button').forEach(btn => {
            const text = btn.textContent.trim();
            if (text.includes('Duo uchun daraxt ekish') || text.includes('Посадить дерево для молитвы') || text.includes('Plant Prayer Tree')) {
                btn.textContent = at['sadaqah-plant-button'];
            } else if (text.includes('Sovg\'a daraxt') || text.includes('подарочное дерево') || text.includes('Gift Tree')) {
                btn.textContent = at['sadaqah-gift-button'];
            }
        });
        
        sadaqahSection.querySelectorAll('p.text-sm.text-slate-600').forEach(p => {
            const text = p.textContent.trim();
            if (text.includes('Masjid') || text.includes('мечети') || text.includes('mosque')) p.textContent = at['sadaqah-prayer-tree-desc'];
            else if (text.includes('o\'sib, meva') || text.includes('роста дерева') || text.includes('grows and bears')) p.textContent = at['sadaqah-continuous-desc'];
            else if (text.includes('Yaqiningiz nomi') || text.includes('именем близкого') || text.includes('loved one')) p.textContent = at['sadaqah-certificate-desc'];
            else if (text.includes('qayerda ekilganini') || text.includes('где было посажено') || text.includes('where the tree')) p.textContent = at['sadaqah-location-desc'];
            else if (text.includes('Tug\'ilgan kun, to\'y') || text.includes('день рождения, свадьбу') || text.includes('birthday, wedding')) p.textContent = at['sadaqah-gift-desc'];
            else if (text.includes('Har yili') || text.includes('каждый год') || text.includes('grows every year')) p.textContent = at['sadaqah-birthday-desc'];
            else if (text.includes('Oila bilan') || text.includes('вместе с семьей') || text.includes('with the family')) p.textContent = at['sadaqah-wedding-desc'];
            else if (text.includes('Muvaffaqiyatni') || text.includes('успех') || text.includes('success')) p.textContent = at['sadaqah-achievement-desc'];
            else if (text.includes('Mevali yoki soyali') || text.includes('плодовое или тенистое') || text.includes('fruit or shade')) p.textContent = at['sadaqah-step1-desc'];
            else if (text.includes('duo matnini yozing') || text.includes('текст молитвы') || text.includes('prayer text')) p.textContent = at['sadaqah-step2-desc'];
            else if (text.includes('professional ekamiz') || text.includes('профессионально') || text.includes('professionally')) p.textContent = at['sadaqah-step3-desc'];
            else if (text.includes('QR-kodli') || text.includes('QR-кодом') || text.includes('QR code')) p.textContent = at['sadaqah-step4-desc'];
        });
        
        sadaqahSection.querySelectorAll('h4').forEach(h4 => {
            const text = h4.textContent.trim();
            if (text.includes('Qanday ishlaydi') || text.includes('Как это') || text.includes('How does')) h4.textContent = at['sadaqah-how-title'];
            else if (text.includes('Daraxt tanlang') || text.includes('Выберите дерево') || text.includes('Choose a Tree')) h4.textContent = at['sadaqah-step1-title'];
            else if (text.includes('Ma\'lumot kiriting') || text.includes('Введите информацию') || text.includes('Enter Information')) h4.textContent = at['sadaqah-step2-title'];
            else if (text.includes('Daraxt ekiladi') || text.includes('будет посажено') || text.includes('Tree is Planted')) h4.textContent = at['sadaqah-step3-title'];
            else if (text.includes('Sertifikat oling') || text.includes('Получите сертификат') || text.includes('Receive Certificate')) h4.textContent = at['sadaqah-step4-title'];
        });
        
        const hadisContainer = sadaqahSection.querySelector('.bg-green-50.border-l-4');
        if (hadisContainer) {
            console.log('Hadis container topildi');
            hadisContainer.innerHTML = `<p class="italic text-slate-700 whitespace-pre-line">${at['sadaqah-hadith']}</p>`;
        } else {
            console.log('Hadis container topilmadi');
        }
    }

    console.log(`✅ Til o'zgartirildi: ${lang.toUpperCase()}`);
};

// Sahifa yuklanganda
document.addEventListener('DOMContentLoaded', function() {
    const currentLang = localStorage.getItem('selectedLanguage') || 'uz';
    setTimeout(() => {
        if (typeof window.applyTranslations === 'function') {
            window.applyTranslations(currentLang);
        }
    }, 100);
});

console.log('✅ To\'liq tarjimalar yuklandi!');
