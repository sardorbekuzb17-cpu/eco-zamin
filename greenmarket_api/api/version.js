export default function handler(req, res) {
    // CORS headers
    res.setHeader('Access-Control-Allow-Credentials', true);
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
    res.setHeader(
        'Access-Control-Allow-Headers',
        'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
    );

    if (req.method === 'OPTIONS') {
        res.status(200).end();
        return;
    }

    if (req.method === 'GET') {
        // Eng so'nggi versiya ma'lumotlari
        const versionInfo = {
            latestVersion: '1.0.0',
            latestBuildNumber: 1,
            isForceUpdate: true, // Majburiy yangilanish
            updateMessage: {
                uz: 'Yangi versiya mavjud! Ilovani yangilang.',
                ru: 'Доступна новая версия! Обновите приложение.',
                en: 'New version available! Please update the app.',
            },
            downloadUrl: 'https://play.google.com/store/apps/details?id=com.greenmarket.greenmarket_app',
            releaseNotes: {
                uz: [
                    '🌱 Mavsumiy eslatgichlar qo\'shildi',
                    '🤖 Bog\'bon AI yaxshilandi',
                    '🛒 Buyurtma tizimi yangilandi',
                    '🐛 Xatolar tuzatildi',
                ],
                ru: [
                    '🌱 Добавлены сезонные напоминания',
                    '🤖 Улучшен Садовник AI',
                    '🛒 Обновлена система заказов',
                    '🐛 Исправлены ошибки',
                ],
                en: [
                    '🌱 Added seasonal reminders',
                    '🤖 Improved Gardener AI',
                    '🛒 Updated order system',
                    '🐛 Bug fixes',
                ],
            },
        };

        res.status(200).json(versionInfo);
    } else if (req.method === 'POST') {
        // Admin uchun versiyani yangilash (keyinchalik)
        res.status(200).json({ message: 'Version update endpoint' });
    } else {
        res.status(405).json({ error: 'Method not allowed' });
    }
}
