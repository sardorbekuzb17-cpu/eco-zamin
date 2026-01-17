const express = require('express');
const axios = require('axios');
const cors = require('cors');
const app = express();

app.use(express.json());
app.use(cors());

// MyID credentials (shartnomadan)
const CLIENT_ID = 'quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v';
const CLIENT_SECRET = 'JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP';
const MYID_HOST = 'https://myid.uz'; // Production muhiti

let bearerToken = null;
let tokenExpiry = null;

// Foydalanuvchilar bazasi (xotirada saqlash - test uchun)
// Production'da MongoDB, PostgreSQL yoki boshqa DB ishlatish kerak
const users = [];

// Foydalanuvchi statistikasi
const stats = {
    totalUsers: 0,
    todayRegistrations: 0,
    lastRegistrationDate: null,
};

// 1. Kirish tokenini olish
async function getBearerToken() {
    if (bearerToken && tokenExpiry && Date.now() < tokenExpiry) {
        console.log('✅ Mavjud token ishlatilmoqda');
        return bearerToken;
    }

    try {
        console.log('📤 Yangi token so\'ralmoqda...');
        const response = await axios.post(
            `${MYID_HOST}/api/v1/auth/clients/access-token`,
            {
                client_id: CLIENT_ID,
                client_secret: CLIENT_SECRET,
            },
            {
                headers: { 'Content-Type': 'application/json' },
            }
        );

        bearerToken = response.data.access_token;
        tokenExpiry = Date.now() + (response.data.expires_in || 3600) * 1000;

        console.log('✅ Token olindi:', {
            token: bearerToken.substring(0, 20) + '...',
            expires_in: response.data.expires_in,
        });

        return bearerToken;
    } catch (error) {
        console.error('❌ Token xatolik:', {
            status: error.response?.status,
            data: error.response?.data,
            message: error.message,
        });
        throw error;
    }
}

// 2. BO'SH Session yaratish (SDK uchun) - pasport ma'lumotlari SDK'da kiritiladi
app.post('/api/myid/create-session', async (req, res) => {
    try {
        console.log('📞 Bo\'sh session yaratish so\'rovi');

        // Token olish
        const token = await getBearerToken();

        // Создаёт пустую сессию.
        // Паспортные данные будут введены вручную позже.
        // BO'SH session yaratish - pasport ma'lumotlari MyID SDK'da kiritiladi
        const sessionData = {};

        console.log('📤 MyID ga yuborilmoqda: {} (bo\'sh session)');
        console.log('🔗 Endpoint:', `${MYID_HOST}/api/v2/sdk/sessions`);

        // MyID API ga so'rov - test muhiti (v2 endpoint - to'g'ri)
        const response = await axios.post(
            `${MYID_HOST}/api/v2/sdk/sessions`,
            sessionData,
            {
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json',
                },
            }
        );

        console.log('✅ Bo\'sh session yaratildi:', JSON.stringify(response.data, null, 2));

        // Session ma'lumotlarini tekshirish
        if (!response.data || !response.data.session_id) {
            throw new Error('MyID API session_id qaytarmadi: ' + JSON.stringify(response.data));
        }

        // Faqat session_id ni qaytarish (to'liq javob emas)
        res.json({
            success: true,
            data: {
                session_id: response.data.session_id,
                expires_in: response.data.expires_in || 'unknown',
                created_at: new Date().toISOString(),
            },
        });
    } catch (error) {
        console.error('❌ Session xatolik:', {
            status: error.response?.status,
            statusText: error.response?.statusText,
            data: error.response?.data,
            message: error.message,
            url: error.config?.url,
        });

        // Agar 404 bo'lsa, endpoint noto'g'ri
        if (error.response?.status === 404) {
            return res.status(404).json({
                success: false,
                error: 'MyID API endpoint topilmadi (404)',
                error_details: {
                    message: 'Endpoint noto\'g\'ri yoki mavjud emas',
                    url: `${MYID_HOST}/api/v2/sdk/sessions`,
                    status: 404,
                    suggestion: 'MyID support bilan bog\'laning: @myid_support',
                },
            });
        }

        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data || error.message,
            error_details: {
                message: error.message,
                status: error.response?.status,
                data: error.response?.data,
                url: error.config?.url,
            },
        });
    }
});

// 2.1. PASPORT bilan Session yaratish (Flutter'dan pasport ma'lumotlari bilan)
app.post('/api/myid/create-session-with-passport', async (req, res) => {
    try {
        const { passport_series, passport_number, birth_date } = req.body;

        if (!passport_series || !passport_number || !birth_date) {
            return res.status(400).json({
                success: false,
                error: 'Barcha maydonlar kerak: passport_series, passport_number, birth_date',
            });
        }

        console.log('📞 Pasport bilan session yaratish:', { passport_series, passport_number, birth_date });

        // Token olish
        const token = await getBearerToken();

        // Pasport ma'lumotlari bilan session yaratish
        const sessionData = {
            passport_series: passport_series.toUpperCase(),
            passport_number: passport_number,
            birth_date: birth_date, // YYYY-MM-DD formatida
        };

        console.log('📤 MyID ga yuborilmoqda:', sessionData);
        console.log('🔗 Endpoint:', `${MYID_HOST}/api/v2/sdk/sessions`);

        // MyID API ga so'rov
        const response = await axios.post(
            `${MYID_HOST}/api/v2/sdk/sessions`,
            sessionData,
            {
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json',
                },
            }
        );

        console.log('✅ Pasport bilan session yaratildi:', JSON.stringify(response.data, null, 2));

        // Session ma'lumotlarini tekshirish
        if (!response.data || !response.data.session_id) {
            throw new Error('MyID API session_id qaytarmadi: ' + JSON.stringify(response.data));
        }

        // Session ID ni qaytarish
        res.json({
            success: true,
            data: {
                session_id: response.data.session_id,
                expires_in: response.data.expires_in || 'unknown',
                created_at: new Date().toISOString(),
            },
        });
    } catch (error) {
        console.error('❌ Pasport session xatolik:', {
            status: error.response?.status,
            statusText: error.response?.statusText,
            data: error.response?.data,
            message: error.message,
        });

        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data || error.message,
            error_details: {
                message: error.message,
                status: error.response?.status,
                data: error.response?.data,
            },
        });
    }
});

// 3. Pasport tekshirish
app.post('/api/myid/verify-passport', async (req, res) => {
    try {
        const { passport_series, passport_number, birth_date } = req.body;

        if (!passport_series || !passport_number || !birth_date) {
            return res.status(400).json({
                success: false,
                error: 'Barcha maydonlar kerak: passport_series, passport_number, birth_date',
            });
        }

        console.log('📝 Pasport tekshirish:', { passport_series, passport_number, birth_date });

        const token = await getBearerToken();

        const response = await axios.post(
            `${MYID_HOST}/api/v1/identification/passport`,
            {
                passport_series: passport_series.toUpperCase(),
                passport_number: passport_number,
                birth_date: birth_date,
            },
            {
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json',
                },
            }
        );

        console.log('✅ Pasport tasdiqlandi');

        res.json({ success: true, data: response.data });
    } catch (error) {
        console.error('❌ Pasport xatolik:', {
            status: error.response?.status,
            data: error.response?.data,
        });

        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data || error.message,
        });
    }
});

// Health check
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        token_status: bearerToken ? 'active' : 'not_initialized',
        myid_host: MYID_HOST,
    });
});

// 4. Foydalanuvchini saqlash (MyID'dan ma'lumot kelgandan keyin)
app.post('/api/users/register', async (req, res) => {
    try {
        const { session_id, profile_data, passport_data } = req.body;

        if (!session_id) {
            return res.status(400).json({
                success: false,
                error: 'session_id majburiy',
            });
        }

        // Foydalanuvchi allaqachon mavjudmi tekshirish
        const existingUser = users.find(u => u.session_id === session_id);
        if (existingUser) {
            return res.json({
                success: true,
                message: 'Foydalanuvchi allaqachon ro\'yxatdan o\'tgan',
                user: existingUser,
            });
        }

        // Yangi foydalanuvchi
        const newUser = {
            id: users.length + 1,
            session_id: session_id,
            profile_data: profile_data || null,
            passport_data: passport_data || null,
            registered_at: new Date().toISOString(),
            last_login: new Date().toISOString(),
            status: 'active',
        };

        users.push(newUser);

        // Statistikani yangilash
        stats.totalUsers = users.length;
        stats.todayRegistrations++;
        stats.lastRegistrationDate = new Date().toISOString();

        console.log('✅ Yangi foydalanuvchi ro\'yxatdan o\'tdi:', {
            id: newUser.id,
            session_id: session_id,
            total_users: stats.totalUsers,
        });

        res.json({
            success: true,
            message: 'Foydalanuvchi muvaffaqiyatli ro\'yxatdan o\'tdi',
            user: newUser,
        });
    } catch (error) {
        console.error('❌ Foydalanuvchini saqlashda xatolik:', error);
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// 5. Barcha foydalanuvchilarni ko'rish
app.get('/api/users', (req, res) => {
    try {
        const { page = 1, limit = 10, status } = req.query;

        let filteredUsers = users;

        // Status bo'yicha filter
        if (status) {
            filteredUsers = users.filter(u => u.status === status);
        }

        // Pagination
        const startIndex = (page - 1) * limit;
        const endIndex = page * limit;
        const paginatedUsers = filteredUsers.slice(startIndex, endIndex);

        res.json({
            success: true,
            data: {
                users: paginatedUsers,
                pagination: {
                    total: filteredUsers.length,
                    page: parseInt(page),
                    limit: parseInt(limit),
                    totalPages: Math.ceil(filteredUsers.length / limit),
                },
                stats: stats,
            },
        });
    } catch (error) {
        console.error('❌ Foydalanuvchilarni olishda xatolik:', error);
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// 6. Bitta foydalanuvchini ko'rish
app.get('/api/users/:id', (req, res) => {
    try {
        const userId = parseInt(req.params.id);
        const user = users.find(u => u.id === userId);

        if (!user) {
            return res.status(404).json({
                success: false,
                error: 'Foydalanuvchi topilmadi',
            });
        }

        res.json({
            success: true,
            user: user,
        });
    } catch (error) {
        console.error('❌ Foydalanuvchini olishda xatolik:', error);
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// 7. Foydalanuvchi statistikasi
app.get('/api/users/stats/summary', (req, res) => {
    try {
        const today = new Date().toISOString().split('T')[0];
        const todayUsers = users.filter(u =>
            u.registered_at.startsWith(today)
        ).length;

        const activeUsers = users.filter(u => u.status === 'active').length;
        const inactiveUsers = users.filter(u => u.status === 'inactive').length;

        res.json({
            success: true,
            stats: {
                total_users: users.length,
                today_registrations: todayUsers,
                active_users: activeUsers,
                inactive_users: inactiveUsers,
                last_registration: stats.lastRegistrationDate,
            },
        });
    } catch (error) {
        console.error('❌ Statistikani olishda xatolik:', error);
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// 8. Foydalanuvchini o'chirish
app.delete('/api/users/:id', (req, res) => {
    try {
        const userId = parseInt(req.params.id);
        const userIndex = users.findIndex(u => u.id === userId);

        if (userIndex === -1) {
            return res.status(404).json({
                success: false,
                error: 'Foydalanuvchi topilmadi',
            });
        }

        const deletedUser = users.splice(userIndex, 1)[0];
        stats.totalUsers = users.length;

        console.log('🗑️ Foydalanuvchi o\'chirildi:', deletedUser.id);

        res.json({
            success: true,
            message: 'Foydalanuvchi o\'chirildi',
            user: deletedUser,
        });
    } catch (error) {
        console.error('❌ Foydalanuvchini o\'chirishda xatolik:', error);
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// Root
app.get('/', (req, res) => {
    res.json({
        name: 'GreenMarket MyID Backend',
        version: '4.0.0', // Foydalanuvchilar bazasi qo'shildi
        myid_host: MYID_HOST,
        total_users: users.length,
        endpoints: {
            health: 'GET /health',
            create_session: 'POST /api/myid/create-session',
            create_session_with_passport: 'POST /api/myid/create-session-with-passport',
            verify_passport: 'POST /api/myid/verify-passport',
            register_user: 'POST /api/users/register',
            get_users: 'GET /api/users',
            get_user: 'GET /api/users/:id',
            get_stats: 'GET /api/users/stats/summary',
            delete_user: 'DELETE /api/users/:id',
        },
    });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Server ${PORT} portda ishlamoqda`);
    console.log(`🔗 MyID Host: ${MYID_HOST}`);
    console.log(`📊 Health: http://localhost:${PORT}/health`);
});

module.exports = app;
