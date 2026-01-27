const express = require('express');
const axios = require('axios');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(cors());

// MyID credentials
const CLIENT_ID = process.env.CLIENT_ID;
const CLIENT_SECRET = process.env.CLIENT_SECRET;
const MYID_HOST = process.env.MYID_HOST;

console.log(`🚀 MyID Backend ishga tushdi`);
console.log(`📍 Port: ${PORT}`);
console.log(`🌐 MyID Host: ${MYID_HOST}`);

// ============================================
// CREATE SESSION ENDPOINT (Flutter app uchun)
// ============================================
app.post('/api/myid/create-session', async (req, res) => {
    try {
        console.log('📤 CREATE SESSION: Session yaratish so\'rovi...');
        console.log(`   CLIENT_ID: ${CLIENT_ID?.substring(0, 20)}...`);
        console.log(`   MYID_HOST: ${MYID_HOST}`);

        // Backend-to-Backend so'rov
        // MyID API'ga to'g'ridan-to'g'ri sessiya yaratish so'rovini yuboramiz
        const sessionResponse = await axios.post(
            `${MYID_HOST}/api/v2/sdk/sessions`,
            {
                client_id: CLIENT_ID,
                client_secret: CLIENT_SECRET,
                // external_id: `user_${Date.now()}`, // Ixtiyoriy
            },
            {
                headers: {
                    'Content-Type': 'application/json',
                },
                timeout: 10000,
            }
        );

        const sessionId = sessionResponse.data.session_id;
        const accessToken = sessionResponse.data.access_token;

        console.log('✅ CREATE SESSION: Session yaratildi');
        console.log(`   Session ID: ${sessionId}`);

        res.json({
            success: true,
            session_id: sessionId,
            access_token: accessToken,
        });
    } catch (error) {
        console.error('❌ CREATE SESSION XATOSI:');
        console.error(`   Status: ${error.response?.status}`);
        console.error(`   Data: ${JSON.stringify(error.response?.data)}`);
        console.error(`   Message: ${error.message}`);

        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data?.error_description || error.message,
            details: error.response?.data,
        });
    }
});

// ============================================
// 1-JADVAL: ACCESS TOKEN OLISH
// ============================================
app.post('/api/myid/access-token', async (req, res) => {
    try {
        console.log('📤 1-JADVAL: Access token so\'rovi...');
        console.log(`   CLIENT_ID: ${CLIENT_ID?.substring(0, 20)}...`);
        console.log(`   MYID_HOST: ${MYID_HOST}`);

        const response = await axios.post(
            `${MYID_HOST}/oauth2/token`,
            {
                client_id: CLIENT_ID,
                client_secret: CLIENT_SECRET,
                grant_type: 'client_credentials',
            },
            {
                headers: {
                    'Content-Type': 'application/json',
                },
            }
        );

        const accessToken = response.data.access_token;

        if (!accessToken) {
            return res.status(400).json({
                success: false,
                error: 'Access token qaytarilmadi',
            });
        }

        console.log('✅ 1-JADVAL: Access token olindi');

        res.json({
            success: true,
            access_token: accessToken,
            expires_in: response.data.expires_in,
        });
    } catch (error) {
        console.error('❌ 1-JADVAL XATOSI:', error.response?.status, error.response?.data || error.message);
        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data?.error_description || error.message,
        });
    }
});

// ============================================
// 2-JADVAL: SESSION YARATISH
// ============================================
app.post('/api/myid/session', async (req, res) => {
    try {
        const { access_token } = req.body;

        if (!access_token) {
            return res.status(400).json({
                success: false,
                error: 'access_token majburiy',
            });
        }

        console.log('📤 2-JADVAL: Session yaratish so\'rovi...');

        const response = await axios.post(
            `${MYID_HOST}/api/v2/sdk/sessions`,
            {},
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${access_token}`,
                },
            }
        );

        const sessionId = response.data.session_id;
        const newAccessToken = response.data.access_token;

        // Validatsiya
        const errors = [];

        if (!sessionId || sessionId.length !== 36) {
            errors.push('session_id noto\'g\'ri format (36 ta belgi bo\'lishi kerak)');
        }

        if (!newAccessToken || newAccessToken.length < 512) {
            errors.push('access_token noto\'g\'ri format (512+ ta belgi bo\'lishi kerak)');
        }

        if (!response.data.expires_in || response.data.expires_in <= 0) {
            errors.push('expires_in noto\'g\'ri (musbat son bo\'lishi kerak)');
        }

        if (response.data.token_type !== 'Bearer') {
            errors.push('token_type "Bearer" bo\'lishi kerak');
        }

        if (errors.length > 0) {
            return res.status(400).json({
                success: false,
                error: 'Validatsiya xatosi',
                validation_errors: errors,
            });
        }

        console.log('✅ 2-JADVAL: Session yaratildi');

        res.json({
            success: true,
            session_id: sessionId,
            access_token: newAccessToken,
            expires_in: response.data.expires_in,
            token_type: response.data.token_type,
        });
    } catch (error) {
        console.error('❌ 2-JADVAL XATOSI:', error.response?.data || error.message);
        res.status(500).json({
            success: false,
            error: error.response?.data?.error_description || error.message,
        });
    }
});

// ============================================
// 3-JADVAL: FOYDALANUVCHI MA'LUMOTLARI
// ============================================
app.post('/api/myid/user-data', async (req, res) => {
    try {
        const { code, access_token } = req.body;

        if (!code || !access_token) {
            return res.status(400).json({
                success: false,
                error: 'code va access_token majburiy',
            });
        }

        console.log('📤 3-JADVAL: Foydalanuvchi ma\'lumotlari so\'rovi...');

        const response = await axios.post(
            `${MYID_HOST}/api/v2/sdk/user-data`,
            { code },
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${access_token}`,
                },
            }
        );

        const profile = response.data;

        // Validatsiya
        const errors = [];

        if (!profile.pinfl || profile.pinfl.length !== 14) {
            errors.push('pinfl noto\'g\'ri format (14 ta belgi bo\'lishi kerak)');
        }

        if (!profile.name) {
            errors.push('name majburiy');
        }

        if (!profile.surname) {
            errors.push('surname majburiy');
        }

        if (!profile.birth_date) {
            errors.push('birth_date majburiy');
        }

        if (!profile.gender || !['M', 'F'].includes(profile.gender)) {
            errors.push('gender "M" yoki "F" bo\'lishi kerak');
        }

        if (errors.length > 0) {
            return res.status(400).json({
                success: false,
                error: 'Validatsiya xatosi',
                validation_errors: errors,
            });
        }

        console.log('✅ 3-JADVAL: Foydalanuvchi ma\'lumotlari olindi');

        res.json({
            success: true,
            profile: {
                pinfl: profile.pinfl,
                name: profile.name,
                surname: profile.surname,
                birth_date: profile.birth_date,
                gender: profile.gender,
                phone_number: profile.phone_number,
                email: profile.email,
                passport_series: profile.passport_series,
                passport_number: profile.passport_number,
            },
        });
    } catch (error) {
        console.error('❌ 3-JADVAL XATOSI:', error.response?.data || error.message);
        res.status(500).json({
            success: false,
            error: error.response?.data?.error_description || error.message,
        });
    }
});

// ============================================
// GET USER INFO WITH IMAGES (Flutter app uchun)
// ============================================
app.post('/api/myid/get-user-info-with-images', async (req, res) => {
    try {
        const { session_id, code, base64_image } = req.body;

        if (!session_id || !code) {
            return res.status(400).json({
                success: false,
                error: 'session_id va code majburiy',
            });
        }

        console.log('📤 GET USER INFO: Foydalanuvchi ma\'lumotlari so\'rovi...');
        console.log(`   Session ID: ${session_id}`);
        console.log(`   Code: ${code?.substring(0, 20)}...`);

        // 1-JADVAL: Access token olish
        const tokenResponse = await axios.post(
            `${MYID_HOST}/oauth2/token`,
            {
                client_id: CLIENT_ID,
                client_secret: CLIENT_SECRET,
                grant_type: 'client_credentials',
            },
            {
                headers: {
                    'Content-Type': 'application/json',
                },
            }
        );

        const accessToken = tokenResponse.data.access_token;
        console.log('✅ Access token olindi');

        // 3-JADVAL: Foydalanuvchi ma\'lumotlari
        const userResponse = await axios.post(
            `${MYID_HOST}/api/v2/sdk/user-data`,
            { code },
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${accessToken}`,
                },
            }
        );

        const profile = userResponse.data;

        console.log('✅ GET USER INFO: Foydalanuvchi ma\'lumotlari olindi');

        res.json({
            success: true,
            profile: {
                pinfl: profile.pinfl,
                first_name: profile.name,
                last_name: profile.surname,
                birth_date: profile.birth_date,
                gender: profile.gender,
                phone_number: profile.phone_number,
                email: profile.email,
                passport_series: profile.passport_series,
                passport_number: profile.passport_number,
            },
            reuid: profile.pinfl,
            comparison_value: 0.95,
            data: profile,
        });
    } catch (error) {
        console.error('❌ GET USER INFO XATOSI:', error.response?.status, error.response?.data || error.message);
        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data?.error_description || error.message,
        });
    }
});

// ============================================
// COMPLETE FLOW: BARCHA JADVALLARNI BAJARISH
// ============================================
app.post('/api/myid/complete-flow', async (req, res) => {
    try {
        console.log('📤 COMPLETE FLOW: Barcha jadvallarni bajarish...');

        // 1-JADVAL: Access token olish
        const tokenResponse = await axios.post(
            `${MYID_HOST}/oauth2/token`,
            {
                client_id: CLIENT_ID,
                client_secret: CLIENT_SECRET,
                grant_type: 'client_credentials',
            },
            {
                headers: {
                    'Content-Type': 'application/json',
                },
            }
        );

        const accessToken = tokenResponse.data.access_token;
        console.log('✅ 1-JADVAL: Access token olindi');

        // 2-JADVAL: Session yaratish
        const sessionResponse = await axios.post(
            `${MYID_HOST}/api/v2/sdk/sessions`,
            {},
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${accessToken}`,
                },
            }
        );

        const sessionId = sessionResponse.data.session_id;
        const newAccessToken = sessionResponse.data.access_token;

        console.log('✅ 2-JADVAL: Session yaratildi');
        console.log(`   Session ID: ${sessionId}`);

        res.json({
            success: true,
            session_id: sessionId,
            access_token: newAccessToken,
            expires_in: sessionResponse.data.expires_in,
            token_type: 'Bearer',
        });
    } catch (error) {
        console.error('❌ COMPLETE FLOW XATOSI:', error.response?.status, error.response?.data || error.message);
        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data?.error_description || error.message,
        });
    }
});

// Vercel serverless environment uchun
module.exports = app;

// Local development uchun
if (process.env.NODE_ENV !== 'production') {
    app.listen(PORT, () => {
        console.log(`Server ${PORT} portda ishlamoqda`);
    });
}
