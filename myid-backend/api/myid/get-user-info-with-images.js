import axios from 'axios';

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

        console.log('📤 GET USER INFO: Foydalanuvchi ma\'lumotlari sorov...');
        console.log(`   Session ID: ${session_id}`);
        console.log(`   Code: ${code?.substring(0, 20)}...`);

        // MyID API'ga so'rov
        const response = await axios.post(
            `${process.env.MYID_HOST}/v2/sdk/user-data`,
            { code },
            {
                headers: {
                    'Content-Type': 'application/json',
                },
                timeout: 30000,
            }
        );

        console.log('✅ GET USER INFO: Ma\'lumotlar olindi');

        const userData = response.data;

        res.status(200).json({
            success: true,
            session_id: session_id,
            profile: {
                first_name: userData.name || userData.first_name,
                last_name: userData.surname || userData.last_name,
                pinfl: userData.pinfl,
                birth_date: userData.birth_date,
                gender: userData.gender,
                phone_number: userData.phone_number,
                email: userData.email,
                passport_series: userData.passport_series,
                passport_number: userData.passport_number,
            },
            reuid: userData.reuid || session_id,
            comparison_value: userData.comparison_value || 0.95,
            data: userData,
        });
    } catch (error) {
        console.error('❌ GET USER INFO XATOSI:');
        console.error(`   Status: ${error.response?.status}`);
        console.error(`   Data: ${JSON.stringify(error.response?.data)}`);
        console.error(`   Message: ${error.message}`);

        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data?.error_description || error.response?.data?.error || error.message,
            details: error.response?.data,
        });
    }
}
