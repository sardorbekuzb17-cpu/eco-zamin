const axios = require('axios');

const CLIENT_ID = process.env.MYID_CLIENT_ID;
const CLIENT_SECRET = process.env.MYID_CLIENT_SECRET;
const MYID_HOST = process.env.MYID_HOST || 'https://api.devmyid.uz';

if (!CLIENT_ID || !CLIENT_SECRET) {
    console.error('❌ MYID_CLIENT_ID yoki MYID_CLIENT_SECRET qo\'shilmagan!');
}

module.exports = async (req, res) => {
    try {
        const { phone_number, birth_date, is_resident, pass_data, threshold } = req.body;

        console.log('📤 [1/2] Access token olinmoqda...');

        const tokenResponse = await axios.post(
            `${MYID_HOST}/api/v1/auth/clients/access-token`,
            {
                grant_type: 'client_credentials',
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

        const accessToken = tokenResponse.data.access_token;
        console.log('✅ [1/2] Access token olindi');

        console.log('📤 [2/2] Session yaratilmoqda (pasport maydonlari bilan)...');

        const sessionBody = {};
        if (phone_number) sessionBody.phone_number = phone_number;
        if (birth_date) sessionBody.birth_date = birth_date;
        if (is_resident !== undefined) sessionBody.is_resident = is_resident;
        if (pass_data) sessionBody.pass_data = pass_data;
        if (threshold !== undefined) sessionBody.threshold = threshold;

        const sessionResponse = await axios.post(
            `${MYID_HOST}/api/v2/sdk/sessions`,
            sessionBody,
            {
                headers: {
                    'Authorization': `Bearer ${accessToken}`,
                    'Content-Type': 'application/json',
                },
                timeout: 10000,
            }
        );

        console.log('✅ [2/2] Session yaratildi:', sessionResponse.data.session_id);

        res.status(200).json({
            success: true,
            data: {
                session_id: sessionResponse.data.session_id,
                expires_in: sessionResponse.data.expires_in,
            },
        });
    } catch (error) {
        console.error('❌ Session yaratishda xato:', error.response?.data || error.message);
        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data || error.message,
        });
    }
};
