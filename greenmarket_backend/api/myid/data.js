const axios = require('axios');

const CLIENT_ID = 'quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v';
const CLIENT_SECRET = 'JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP';
const MYID_HOST = 'https://api.devmyid.uz';

module.exports = async (req, res) => {
    try {
        // URL'dan code parametrini olish
        // /api/myid/data?code=TEST_CODE_12345
        const { code } = req.query;

        if (!code) {
            return res.status(400).json({
                success: false,
                error: 'code majburiy',
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

        console.log('📤 [2/2] Profil ma\'lumotlari olinmoqda...');

        const userResponse = await axios.get(
            `${MYID_HOST}/api/v1/users/me`,
            {
                headers: {
                    'Authorization': `Bearer ${accessToken}`,
                },
                timeout: 10000,
            }
        );

        const userData = userResponse.data;
        console.log('✅ [2/2] Profil ma\'lumotlari olindi');

        res.status(200).json({
            success: true,
            data: userData,
        });
    } catch (error) {
        console.error('❌ Profil olishda xato:', error.response?.data || error.message);
        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data || error.message,
        });
    }
};
