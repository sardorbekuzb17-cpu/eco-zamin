const axios = require('axios');

const MYID_HOST = process.env.MYID_HOST || 'https://api.devmyid.uz';
const CLIENT_ID = process.env.CLIENT_ID || 'quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v';
const CLIENT_SECRET = process.env.CLIENT_SECRET || 'JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP';

module.exports = async (req, res) => {
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    try {
        console.log('📤 COMPLETE FLOW: Barcha jadvallarni bajarish...');

        // 1-JADVAL: Access Token olish
        console.log('📤 1-JADVAL: Access token olinmoqda...');
        const token1Response = await axios.post(
            `${MYID_HOST}/oauth/token`,
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

        const accessToken1 = token1Response.data.access_token;
        if (!accessToken1) {
            return res.status(400).json({
                success: false,
                error: 'Access token qaytarilmadi',
            });
        }
        console.log('✅ 1-JADVAL: Access token olindi');

        // 2-JADVAL: Session yaratish
        console.log('📤 2-JADVAL: Session yaratilmoqda...');
        const sessionResponse = await axios.post(
            `${MYID_HOST}/api/v2/sdk/sessions`,
            {},
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${accessToken1}`,
                },
            }
        );

        const sessionId = sessionResponse.data.session_id;
        const accessToken2 = sessionResponse.data.access_token;

        if (!sessionId || sessionId.length !== 36) {
            return res.status(400).json({
                success: false,
                error: 'Session ID noto\'g\'ri format',
            });
        }

        if (!accessToken2 || accessToken2.length < 512) {
            return res.status(400).json({
                success: false,
                error: 'Access token noto\'g\'ri format',
            });
        }

        console.log('✅ 2-JADVAL: Session yaratildi');
        console.log(`   Session ID: ${sessionId}`);

        // Session ma'lumotlarini qaytarish
        res.json({
            success: true,
            session_id: sessionId,
            access_token: accessToken2,
            expires_in: sessionResponse.data.expires_in,
            token_type: sessionResponse.data.token_type,
        });
    } catch (error) {
        console.error('❌ COMPLETE FLOW XATOSI:', error.response?.data || error.message);
        res.status(500).json({
            success: false,
            error: error.response?.data?.error_description || error.message,
        });
    }
};
