const axios = require('axios');

const CLIENT_ID = process.env.CLIENT_ID;
const CLIENT_SECRET = process.env.CLIENT_SECRET;
const MYID_HOST = process.env.MYID_HOST;

export default async function handler(req, res) {
    // CORS sozlamalari
    res.setHeader('Access-Control-Allow-Credentials', 'true');
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

    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

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
                sessionResponse = await axios.post(
                    url,
                    {
                        client_id: CLIENT_ID,
                        client_secret: CLIENT_SECRET,
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

        res.status(200).json({
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
}
