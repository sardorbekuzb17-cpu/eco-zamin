const axios = require('axios');

const CLIENT_ID = 'quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v';
const CLIENT_SECRET = 'JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP';
const MYID_HOST = 'https://api.devmyid.uz';

module.exports = async (req, res) => {
    try {
        const { pass_data, birth_date } = req.body;

        if (!pass_data || !birth_date) {
            return res.status(400).json({
                success: false,
                error: 'pass_data va birth_date majburiy',
            });
        }

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

        console.log('📤 [2/2] Session yaratilmoqda (pasport bilan)...');

        const sessionResponse = await axios.post(
            `${MYID_HOST}/api/v2/sdk/sessions`,
            {
                pass_data,
                birth_date,
            },
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
