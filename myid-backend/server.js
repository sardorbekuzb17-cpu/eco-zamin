const express = require('express');
const axios = require('axios');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();
app.use(bodyParser.json());

// MyID Credentials
const CONFIG = {
    CLIENT_ID: process.env.CLIENT_ID,
    CLIENT_SECRET: process.env.CLIENT_SECRET,
    BASE_URL: process.env.MYID_HOST,
};

console.log('🚀 MyID Backend Server Ishga Tushdi');
console.log(`📍 Client ID: ${CONFIG.CLIENT_ID?.substring(0, 20)}...`);
console.log(`🌐 MyID Host: ${CONFIG.BASE_URL}`);

// Flutter'dan kelgan 'code'ni qabul qilib, ma'lumotlarni qaytaruvchi endpoint
app.post('/api/verify-user', async (req, res) => {
    const { code } = req.body;

    if (!code) {
        return res.status(400).json({
            success: false,
            error: 'Kod yuborilmadi',
        });
    }

    try {
        console.log('📤 VERIFY USER: Foydalanuvchi ma\'lumotlarini olish sorov...');
        console.log(`   Code: ${code.substring(0, 20)}...`);

        // MyID API'ga so'rov - kodni tekshirish va ma'lumotlarni olish
        const url = `${CONFIG.BASE_URL}/v2/sdk/user-data`;
        console.log(`   URL: ${url}`);

        const response = await axios.post(
            url,
            { code },
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                },
                timeout: 30000,
            }
        );

        console.log('✅ VERIFY USER: Ma\'lumotlar olindi');
        console.log(`   Response Status: ${response.status}`);

        const userData = response.data;

        // Foydalanuvchi ma'lumotlarini qaytarish
        res.json({
            success: true,
            user: {
                full_name: `${userData.name || userData.first_name || ''} ${userData.surname || userData.last_name || ''}`,
                pinfl: userData.pinfl || '',
                passport_series: userData.passport_series || '',
                passport_number: userData.passport_number || '',
                birth_date: userData.birth_date || '',
                gender: userData.gender || '',
                phone_number: userData.phone_number || '',
                email: userData.email || '',
                // Rasm ma'lumotlari (agar mavjud bo'lsa)
                photo: userData.image || userData.base64_image || null,
            },
            reuid: userData.reuid || '',
            comparison_value: userData.comparison_value || 0.95,
        });
    } catch (error) {
        console.error('❌ VERIFY USER XATOSI:');
        console.error(`   Status: ${error.response?.status}`);
        console.error(`   Data: ${JSON.stringify(error.response?.data)}`);
        console.error(`   Message: ${error.message}`);

        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data?.error_description || error.response?.data?.error || error.message,
            message: 'Identifikatsiya ma\'lumotlarini olishda xatolik yuz berdi',
        });
    }
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        myid_host: CONFIG.BASE_URL,
    });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`✅ Backend server http://localhost:${PORT} portida ishlamoqda`);
    console.log(`📍 Endpoint: POST http://localhost:${PORT}/api/verify-user`);
});
