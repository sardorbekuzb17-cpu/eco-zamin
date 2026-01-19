const axios = require('axios');

const CLIENT_ID = process.env.MYID_CLIENT_ID;
const CLIENT_SECRET = process.env.MYID_CLIENT_SECRET;
const MYID_HOST = process.env.MYID_HOST || 'https://api.devmyid.uz';

if (!CLIENT_ID || !CLIENT_SECRET) {
    console.error('❌ MYID_CLIENT_ID yoki MYID_CLIENT_SECRET qo\'shilmagan!');
}

module.exports = async (req, res) => {
    try {
        console.log('📤 [1/1] Access token olinmoqda...');

        const response = await axios.post(
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

        const { access_token, expires_in, token_type } = response.data;

        if (!access_token || !expires_in || !token_type) {
            throw new Error('Access token javobida majburiy maydonlar yo\'q');
        }

        console.log('✅ [1/1] Access token olindi:', {
            token_length: access_token.length,
            expires_in,
            token_type,
        });

        res.status(200).json({
            success: true,
            data: {
                access_token,
                expires_in,
                token_type,
            },
        });
    } catch (error) {
        console.error('❌ Access token olishda xato:', error.response?.data || error.message);
        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data || error.message,
        });
    }
};
