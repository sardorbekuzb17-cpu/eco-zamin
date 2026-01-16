const express = require('express');
const axios = require('axios');
const cors = require('cors');
const app = express();

app.use(express.json());
app.use(cors());

// MyID credentials (shartnomadan)
const CLIENT_ID = 'quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v';
const CLIENT_SECRET = 'JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP';
const MYID_HOST = 'https://devapi.devmyid.uz'; // Test muhiti - yangi flow

let bearerToken = null;
let tokenExpiry = null;

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

        // BO'SH session yaratish - pasport ma'lumotlari MyID SDK'da kiritiladi
        const sessionData = {};

        console.log('📤 MyID ga yuborilmoqda: {} (bo\'sh session)');

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

        console.log('✅ Bo\'sh session yaratildi:', response.data);

        // Faqat session_id ni qaytarish (to'liq javob emas)
        res.json({
            success: true,
            data: {
                session_id: response.data.session_id,
            },
        });
    } catch (error) {
        console.error('❌ Session xatolik:', {
            status: error.response?.status,
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

// Root
app.get('/', (req, res) => {
    res.json({
        name: 'GreenMarket MyID Backend',
        version: '2.0.0',
        myid_host: MYID_HOST,
        endpoints: {
            health: 'GET /health',
            create_session: 'POST /api/myid/create-session',
            verify_passport: 'POST /api/myid/verify-passport',
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
