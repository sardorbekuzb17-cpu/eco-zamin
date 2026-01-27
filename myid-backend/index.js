const express = require('express');
const axios = require('axios');
const cors = require('cors');
const crypto = require('crypto');
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

// Client hash hisoblash funksiyasi
function calculateClientHash(clientId, clientSecret, externalId = '') {
    const data = `${clientId}${clientSecret}${externalId}`;
    return crypto.createHash('sha256').update(data).digest('hex');
}

// ============================================
// CREATE SESSION ENDPOINT (Flutter app uchun)
// ============================================
app.post('/api/myid/create-session', async (req, res) => {
    try {
        console.log('📤 CREATE SESSION: Session yaratish so\'rovi...');
        console.log(`   CLIENT_ID: ${CLIENT_ID?.substring(0, 20)}...`);
        console.log(`   MYID_HOST: ${MYID_HOST}`);

        // URL variantlarini sinab ko'ramiz
        const urls = [
            `${MYID_HOST}/api/v2/sdk/sessions`,
            `${MYID_HOST}/api/v1/sdk/sessions`,
            `${MYID_HOST}/sdk/sessions`,
        ];

        let sessionResponse;
        let lastError;

        for (const url of urls) {
            try {
                console.log(`   Sinab ko'rilmoqda: ${url}`);

                // Client hash hisoblash
                const externalId = `user_${Date.now()}`;
                const clientHash = calculateClientHash(CLIENT_ID, CLIENT_SECRET, externalId);

                console.log(`   External ID: ${externalId}`);
                console.log(`   Client Hash: ${clientHash.substring(0, 20)}...`);

                sessionResponse = await axios.post(
                    url,
                    {
                        client_id: CLIENT_ID,
                        client_secret: CLIENT_SECRET,
                        client_hash: clientHash,
                        external_id: externalId,
                    },
                    {
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        timeout: 10000,
                    }
                );
                console.log(`   ✅ Muvaffaqiyatli: ${url}`);
                break;
            } catch (error) {
                lastError = error;
                console.log(`   ❌ Xato (${error.response?.status}): ${url}`);
                console.log(`      ${error.response?.data?.error || error.message}`);
            }
        }

        if (!sessionResponse) {
            throw lastError;
        }

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
// HEALTH CHECK
// ============================================
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        myid_host: MYID_HOST,
    });
});

// Vercel serverless environment uchun
module.exports = app;

// Local development uchun
if (process.env.NODE_ENV !== 'production') {
    app.listen(PORT, () => {
        console.log(`Server ${PORT} portda ishlamoqda`);
    });
}
