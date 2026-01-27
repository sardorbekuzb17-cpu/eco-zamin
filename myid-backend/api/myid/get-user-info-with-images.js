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
            `${MYID_HOST}/api/v1/sdk/user-data`,
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

        res.status(200).json({
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
}
