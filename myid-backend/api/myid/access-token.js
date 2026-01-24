const axios = require('axios');

module.exports = async (req, res) => {
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    try {
        console.log('📤 1-JADVAL: Access token so\'rovi...');

        const { client_id, client_secret } = req.body;

        if (!client_id || !client_secret) {
            return res.status(400).json({
                success: false,
                error: 'client_id va client_secret majburiy',
            });
        }

        const response = await axios.post(
            `${process.env.MYID_HOST}/oauth/token`,
            {
                client_id,
                client_secret,
                grant_type: 'client_credentials',
            },
            {
                headers: {
                    'Content-Type': 'application/json',
                },
            }
        );

        const accessToken = response.data.access_token;

        if (!accessToken) {
            return res.status(400).json({
                success: false,
                error: 'Access token qaytarilmadi',
            });
        }

        console.log('✅ 1-JADVAL: Access token olindi');

        res.json({
            success: true,
            access_token: accessToken,
            expires_in: response.data.expires_in,
        });
    } catch (error) {
        console.error('❌ 1-JADVAL XATOSI:', error.response?.data || error.message);
        res.status(500).json({
            success: false,
            error: error.response?.data?.error_description || error.message,
        });
    }
};
