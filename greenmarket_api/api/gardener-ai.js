// Bog'bon AI uchun API
// Bu yerda haqiqiy AI API bilan integratsiya qilish mumkin

// O'simliklar ma'lumotlar bazasi
const plantsDatabase = {
    // Mevali daraxtlar
    apple: {
        name: { uz: "Olma daraxti", ru: "Яблоня", en: "Apple tree" },
        description: {
            uz: "Salqin iqlimga mos, yuqori hosildor mevali daraxt. Bahor gullab, kuzda meva beradi.",
            ru: "Плодовое дерево для прохладного климата. Цветет весной, плодоносит осенью.",
            en: "Fruit tree for cool climate. Blooms in spring, bears fruit in autumn."
        },
        suitableClimates: ["steppe", "mountain"],
        suitableRegions: ["tashkent_city", "tashkent", "fargona", "namangan", "andijon"],
        plantingTime: { uz: "Mart-Aprel yoki Oktyabr-Noyabr", ru: "Март-Апрель или Октябрь-Ноябрь", en: "March-April or October-November" },
        careInstructions: {
            uz: "Haftada 2-3 marta sug'oring. Yiliga 2 marta budang. Qishda sovuqdan himoyalang.",
            ru: "Поливайте 2-3 раза в неделю. Обрезайте 2 раза в год. Защищайте от холода зимой.",
            en: "Water 2-3 times a week. Prune twice a year. Protect from cold in winter."
        },
        soilType: { uz: "Unumli, yaxshi drenajli tuproq", ru: "Плодородная, хорошо дренированная почва", en: "Fertile, well-drained soil" },
        sunlight: { uz: "To'liq quyosh (6-8 soat)", ru: "Полное солнце (6-8 часов)", en: "Full sun (6-8 hours)" },
        waterNeeds: { uz: "O'rtacha", ru: "Умеренный", en: "Moderate" },
        difficulty: "o'rta",
        benefits: ["Vitamin C manbai", "Uzoq saqlash mumkin", "Yuqori hosildorlik"]
    },

    pomegranate: {
        name: { uz: "Anor daraxti", ru: "Гранат", en: "Pomegranate" },
        description: {
            uz: "Issiq va quruq iqlimga mos, dorivor xususiyatli meva. Uzoq umr ko'radi.",
            ru: "Подходит для жаркого и сухого климата, лечебные свойства. Долговечное дерево.",
            en: "Suitable for hot and dry climate, medicinal properties. Long-lived tree."
        },
        suitableClimates: ["desert", "subtropical"],
        suitableRegions: ["qoraqalpogiston", "navoiy", "buxoro", "surxondaryo"],
        plantingTime: { uz: "Mart-Aprel", ru: "Март-Апрель", en: "March-April" },
        careInstructions: {
            uz: "Kam sug'orish kerak. Qurg'oqchilikka chidamli. Yiliga 1 marta budang.",
            ru: "Требует мало полива. Засухоустойчив. Обрезайте раз в год.",
            en: "Requires little watering. Drought resistant. Prune once a year."
        },
        soilType: { uz: "Quruq, sho'rlangan tuproqqa chidamli", ru: "Переносит сухую, засоленную почву", en: "Tolerates dry, saline soil" },
        sunlight: { uz: "To'liq quyosh (8+ soat)", ru: "Полное солнце (8+ часов)", en: "Full sun (8+ hours)" },
        waterNeeds: { uz: "Kam", ru: "Низкий", en: "Low" },
        difficulty: "oson",
        benefits: ["Antioksidant boy", "Qurg'oqchilikka chidamli", "Dorivor xususiyatli"]
    },

    walnut: {
        name: { uz: "Yong'oq daraxti", ru: "Грецкий орех", en: "Walnut tree" },
        description: {
            uz: "Katta o'sadigan, soyali daraxt. Foydali yong'oq beradi. 100 yilgacha yashaydi.",
            ru: "Крупное теневое дерево. Дает полезные орехи. Живет до 100 лет.",
            en: "Large shade tree. Produces healthy nuts. Lives up to 100 years."
        },
        suitableClimates: ["steppe", "mountain"],
        suitableRegions: ["tashkent_city", "tashkent", "fargona", "namangan", "andijon", "samarqand"],
        plantingTime: { uz: "Oktyabr-Noyabr", ru: "Октябрь-Ноябрь", en: "October-November" },
        careInstructions: {
            uz: "Chuqur sug'orish kerak. Keng joy ajrating (10x10m). Dastlabki 3 yil parvarish qiling.",
            ru: "Требует глубокого полива. Выделите широкое место (10x10м). Ухаживайте первые 3 года.",
            en: "Requires deep watering. Allocate wide space (10x10m). Care for the first 3 years."
        },
        soilType: { uz: "Chuqur, unumli tuproq", ru: "Глубокая, плодородная почва", en: "Deep, fertile soil" },
        sunlight: { uz: "To'liq quyosh", ru: "Полное солнце", en: "Full sun" },
        waterNeeds: { uz: "Yuqori", ru: "Высокий", en: "High" },
        difficulty: "qiyin",
        benefits: ["Katta soya", "Foydali yong'oq", "Uzoq umr ko'radi"]
    },

    grape: {
        name: { uz: "Uzum toki", ru: "Виноград", en: "Grape vine" },
        description: {
            uz: "Issiq iqlimga mos, yuqori hosildor tok. Meva va sharbat uchun.",
            ru: "Подходит для жаркого климата, высокоурожайная лоза. Для фруктов и сока.",
            en: "Suitable for hot climate, high-yielding vine. For fruits and juice."
        },
        suitableClimates: ["desert", "steppe", "subtropical"],
        suitableRegions: ["qoraqalpogiston", "navoiy", "buxoro", "samarqand", "qashqadaryo", "surxondaryo"],
        plantingTime: { uz: "Mart-Aprel", ru: "Март-Апрель", en: "March-April" },
        careInstructions: {
            uz: "Muntazam sug'orish. Yozda haftada 2-3 marta. Yiliga 2 marta budang.",
            ru: "Регулярный полив. Летом 2-3 раза в неделю. Обрезайте 2 раза в год.",
            en: "Regular watering. 2-3 times a week in summer. Prune twice a year."
        },
        soilType: { uz: "Yaxshi drenajli, unumli tuproq", ru: "Хорошо дренированная, плодородная почва", en: "Well-drained, fertile soil" },
        sunlight: { uz: "To'liq quyosh", ru: "Полное солнце", en: "Full sun" },
        waterNeeds: { uz: "O'rtacha", ru: "Умеренный", en: "Moderate" },
        difficulty: "o'rta",
        benefits: ["Yuqori hosildorlik", "Turli navlar", "Sharbat va quritish mumkin"]
    },

    apricot: {
        name: { uz: "O'rik daraxti", ru: "Абрикос", en: "Apricot tree" },
        description: {
            uz: "Issiq iqlimga mos, erta pishuvchi meva. Bahorgi sovuqdan ehtiyot bo'ling.",
            ru: "Подходит для жаркого климата, раннеспелый фрукт. Берегите от весенних заморозков.",
            en: "Suitable for hot climate, early ripening fruit. Protect from spring frosts."
        },
        suitableClimates: ["steppe", "subtropical"],
        suitableRegions: ["tashkent_city", "tashkent", "samarqand", "qashqadaryo", "surxondaryo"],
        plantingTime: { uz: "Mart-Aprel", ru: "Март-Апрель", en: "March-April" },
        careInstructions: {
            uz: "Haftada 1-2 marta sug'oring. Bahorgi sovuqdan himoyalang. Yiliga 1 marta budang.",
            ru: "Поливайте 1-2 раза в неделю. Защищайте от весенних заморозков. Обрезайте раз в год.",
            en: "Water 1-2 times a week. Protect from spring frosts. Prune once a year."
        },
        soilType: { uz: "Yaxshi drenajli tuproq", ru: "Хорошо дренированная почва", en: "Well-drained soil" },
        sunlight: { uz: "To'liq quyosh", ru: "Полное солнце", en: "Full sun" },
        waterNeeds: { uz: "O'rtacha", ru: "Умеренный", en: "Moderate" },
        difficulty: "o'rta",
        benefits: ["Erta hosil", "Vitamin A boy", "Quritish mumkin"]
    },

    peach: {
        name: { uz: "Shaftoli daraxti", ru: "Персик", en: "Peach tree" },
        description: {
            uz: "Issiq iqlimga mos, shirin mevali daraxt. Tez o'sadi va hosil beradi.",
            ru: "Подходит для жаркого климата, сладкие плоды. Быстро растет и плодоносит.",
            en: "Suitable for hot climate, sweet fruits. Grows and bears fruit quickly."
        },
        suitableClimates: ["steppe", "subtropical"],
        suitableRegions: ["tashkent_city", "tashkent", "samarqand", "qashqadaryo", "surxondaryo", "fargona"],
        plantingTime: { uz: "Mart-Aprel", ru: "Март-Апрель", en: "March-April" },
        careInstructions: {
            uz: "Haftada 2 marta sug'oring. Kasalliklarga qarshi kurashing. Yiliga 2 marta budang.",
            ru: "Поливайте 2 раза в неделю. Боритесь с болезнями. Обрезайте 2 раза в год.",
            en: "Water twice a week. Fight diseases. Prune twice a year."
        },
        soilType: { uz: "Unumli, yaxshi drenajli tuproq", ru: "Плодородная, хорошо дренированная почва", en: "Fertile, well-drained soil" },
        sunlight: { uz: "To'liq quyosh", ru: "Полное солнце", en: "Full sun" },
        waterNeeds: { uz: "Yuqori", ru: "Высокий", en: "High" },
        difficulty: "o'rta",
        benefits: ["Tez hosil beradi", "Shirin meva", "Vitamin C boy"]
    }
};

// Iqlim zonalari
const climateZones = {
    desert: {
        name: { uz: "Cho'l va yarim cho'l", ru: "Пустыня и полупустыня", en: "Desert and semi-desert" },
        regions: ["qoraqalpogiston", "navoiy", "buxoro"],
        characteristics: {
            uz: "Quruq iqlim, kam yog'ingarchilik (100-200mm/yil), issiq yoz (+45°C), sovuq qish (-15°C)",
            ru: "Сухой климат, мало осадков (100-200мм/год), жаркое лето (+45°C), холодная зима (-15°C)",
            en: "Dry climate, low precipitation (100-200mm/year), hot summer (+45°C), cold winter (-15°C)"
        }
    },
    steppe: {
        name: { uz: "Dasht va tog'oldi", ru: "Степь и предгорье", en: "Steppe and foothill" },
        regions: ["tashkent_city", "tashkent", "sirdaryo", "jizzax", "samarqand", "qashqadaryo"],
        characteristics: {
            uz: "Mo'tadil iqlim, yaxshi yog'ingarchilik (300-600mm/yil), issiq yoz (+35°C), sovuq qish (-10°C)",
            ru: "Умеренный климат, хорошие осадки (300-600мм/год), жаркое лето (+35°C), холодная зима (-10°C)",
            en: "Moderate climate, good precipitation (300-600mm/year), hot summer (+35°C), cold winter (-10°C)"
        }
    },
    mountain: {
        name: { uz: "Tog' va tog'oldi", ru: "Горы и предгорье", en: "Mountains and foothills" },
        regions: ["fargona", "namangan", "andijon"],
        characteristics: {
            uz: "Salqin iqlim, ko'p yog'ingarchilik (400-800mm/yil), salqin yoz (+30°C), sovuq qish (-20°C)",
            ru: "Прохладный климат, много осадков (400-800мм/год), прохладное лето (+30°C), холодная зима (-20°C)",
            en: "Cool climate, high precipitation (400-800mm/year), cool summer (+30°C), cold winter (-20°C)"
        }
    },
    subtropical: {
        name: { uz: "Subtropik", ru: "Субтропики", en: "Subtropical" },
        regions: ["surxondaryo"],
        characteristics: {
            uz: "Issiq nam iqlim, uzun yoz (+40°C), qisqa qish (+5°C), ko'p yog'ingarchilik (500-700mm/yil)",
            ru: "Жаркий влажный климат, долгое лето (+40°C), короткая зима (+5°C), много осадков (500-700мм/год)",
            en: "Hot humid climate, long summer (+40°C), short winter (+5°C), high precipitation (500-700mm/year)"
        }
    }
};

export default async function handler(req, res) {
    // CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }

    try {
        if (req.method === 'POST') {
            const { action, region, district, symptoms, season, language = 'uz' } = req.body || {};

            // 1. Hudud bo'yicha tavsiyalar
            if (action === 'recommendations') {
                if (!region) {
                    return res.status(400).json({ error: 'region majburiy' });
                }

                // Iqlim zonasini aniqlash
                let climateZone = null;
                for (const [key, zone] of Object.entries(climateZones)) {
                    if (zone.regions.includes(region)) {
                        climateZone = { id: key, ...zone };
                        break;
                    }
                }

                if (!climateZone) {
                    return res.status(404).json({ error: 'Iqlim zonasi topilmadi' });
                }

                // Mos o'simliklarni topish
                const suitablePlants = Object.entries(plantsDatabase)
                    .filter(([_, plant]) => plant.suitableRegions.includes(region))
                    .map(([id, plant]) => ({
                        id,
                        name: plant.name[language],
                        description: plant.description[language],
                        plantingTime: plant.plantingTime[language],
                        careInstructions: plant.careInstructions[language],
                        soilType: plant.soilType[language],
                        sunlight: plant.sunlight[language],
                        waterNeeds: plant.waterNeeds[language],
                        difficulty: plant.difficulty,
                        benefits: plant.benefits
                    }));

                return res.status(200).json({
                    success: true,
                    climate: {
                        name: climateZone.name[language],
                        characteristics: climateZone.characteristics[language]
                    },
                    plants: suitablePlants,
                    tips: [
                        language === 'uz' ? `${climateZone.name.uz} iqlim zonasi uchun ${suitablePlants.length} ta mos o'simlik topildi` :
                            language === 'ru' ? `Найдено ${suitablePlants.length} подходящих растений для зоны ${climateZone.name.ru}` :
                                `Found ${suitablePlants.length} suitable plants for ${climateZone.name.en} zone`
                    ]
                });
            }

            // 2. Kasallik tashxisi
            if (action === 'diagnose') {
                if (!symptoms || symptoms.length === 0) {
                    return res.status(400).json({ error: 'symptoms majburiy' });
                }

                // Oddiy tashxis (keyinchalik AI bilan almashtirish mumkin)
                const diagnosis = {
                    disease: language === 'uz' ? 'Shiralar' : language === 'ru' ? 'Тля' : 'Aphids',
                    description: language === 'uz' ?
                        'Kichik yashil yoki qora hasharotlar barglarni so\'radi' :
                        language === 'ru' ?
                            'Мелкие зеленые или черные насекомые высасывают листья' :
                            'Small green or black insects suck leaves',
                    treatment: language === 'uz' ? [
                        'Sovun eritmasi bilan purkash',
                        'Neem yog\'i ishlatish',
                        'Zarar ko\'rgan qismlarni kesish'
                    ] : language === 'ru' ? [
                        'Опрыскивание мыльным раствором',
                        'Использование масла нима',
                        'Удаление поврежденных частей'
                    ] : [
                        'Spray with soap solution',
                        'Use neem oil',
                        'Remove damaged parts'
                    ],
                    prevention: language === 'uz' ? [
                        'Muntazam tekshirish',
                        'Havo almashinuvini yaxshilash',
                        'Foydali hasharotlarni himoyalash'
                    ] : language === 'ru' ? [
                        'Регулярный осмотр',
                        'Улучшение вентиляции',
                        'Защита полезных насекомых'
                    ] : [
                        'Regular inspection',
                        'Improve ventilation',
                        'Protect beneficial insects'
                    ]
                };

                return res.status(200).json({
                    success: true,
                    diagnosis
                });
            }

            // 3. Mavsumiy maslahatlar
            if (action === 'seasonal') {
                if (!season) {
                    return res.status(400).json({ error: 'season majburiy' });
                }

                const seasonalTips = {
                    bahor: {
                        uz: [
                            'Tuproqni tayyorlang va o\'g\'itlang',
                            'Urug\' va ko\'chatlarni eking',
                            'Zararkunandalarga qarshi choralar ko\'ring',
                            'Sug\'orish tizimini tekshiring'
                        ],
                        ru: [
                            'Подготовьте и удобрите почву',
                            'Посадите семена и саженцы',
                            'Примите меры против вредителей',
                            'Проверьте систему полива'
                        ],
                        en: [
                            'Prepare and fertilize soil',
                            'Plant seeds and seedlings',
                            'Take measures against pests',
                            'Check irrigation system'
                        ]
                    },
                    yoz: {
                        uz: [
                            'Muntazam sug\'orish rejimini saqlang',
                            'Begona o\'tlarni tozalang',
                            'Soyali joylar yarating',
                            'Kasalliklarni kuzatib boring'
                        ],
                        ru: [
                            'Поддерживайте регулярный режим полива',
                            'Удаляйте сорняки',
                            'Создайте тенистые места',
                            'Следите за болезнями'
                        ],
                        en: [
                            'Maintain regular watering schedule',
                            'Remove weeds',
                            'Create shaded areas',
                            'Monitor diseases'
                        ]
                    },
                    kuz: {
                        uz: [
                            'Hosil yig\'ing va saqlang',
                            'Qish uchun tayyorgarlik ko\'ring',
                            'Daraxtlarni budang',
                            'Tuproqni qish uchun tayyorlang'
                        ],
                        ru: [
                            'Соберите и сохраните урожай',
                            'Подготовьтесь к зиме',
                            'Обрежьте деревья',
                            'Подготовьте почву к зиме'
                        ],
                        en: [
                            'Harvest and store crops',
                            'Prepare for winter',
                            'Prune trees',
                            'Prepare soil for winter'
                        ]
                    },
                    qish: {
                        uz: [
                            'O\'simliklarni sovuqdan himoyalang',
                            'Qor ostida saqlanishini ta\'minlang',
                            'Keyingi yil uchun reja tuzing',
                            'Asboblarni ta\'mirlang'
                        ],
                        ru: [
                            'Защитите растения от холода',
                            'Обеспечьте хранение под снегом',
                            'Планируйте следующий год',
                            'Отремонтируйте инструменты'
                        ],
                        en: [
                            'Protect plants from cold',
                            'Ensure storage under snow',
                            'Plan for next year',
                            'Repair tools'
                        ]
                    }
                };

                return res.status(200).json({
                    success: true,
                    season: season,
                    tips: seasonalTips[season]?.[language] || []
                });
            }

            return res.status(400).json({ error: 'Noto\'g\'ri action' });
        }

        return res.status(405).json({ error: 'Method not allowed' });
    } catch (error) {
        console.error('Error:', error);
        return res.status(500).json({
            error: 'Server xatosi',
            details: error.message
        });
    }
}
