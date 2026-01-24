const axios = require('axios');

const MYID_HOST = process.env.MYID_HOST || 'https://api.devmyid.uz';

module.exports = async (req, res) => {
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    try {
        const { access_token } = req.body;

        if (!access_token) {
            return res.status(400).json({
                success: false,
                error: 'access_token majburiy',
            });
        }

        console.log('📤 2-JADVAL: Session yaratish so\'rovi...');

        const response = await axios.post(
            `${MYID_HOST}/api/v2/sdk/sessions`,
            {},
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${access_token}`,
                },
            }
        );

        const sessionId = response.data.session_id;
        const newAccessToken = response.data.access_token;

        const errors = [];

        if (!sessionId || sessionId.length !== 36) {
            errors.push('session_id noto\'g\'ri format (36 ta belgi bo\'lishi kerak)');
        }

        if (!newAccessToken || newAccessToken.length < 512) {
            errors.push('access_token noto\'g\'ri format (512+ ta belgi bo\'lishi kerak)');
        }

        if (!response.data.expires_in || response.data.expires_in <= 0) {
            errors.push('expires_in noto\'g\'ri (musbat son bo\'lishi kerak)');
        }

        if (response.data.token_type !== 'Bearer') {
            errors.push('token_type "Bearer" bo\'lishi kerak');
        }

        if (errors.length > 0) {
            return res.status(400).json({
                success: false,
                error: 'Validatsiya xatosi',
                validation_errors: errors,
            });
        }

        console.log('✅ 2-JADVAL: Session yaratildi');

        res.json({
            success: true,
            session_id: sessionId,
            access_token: newAccessToken,
            expires_in: response.data.expires_in,
            token_type: response.data.token_type,
        });
    } catch (error) {
        console.error('❌ 2-JADVAL XATOSI:', error.response?.data || error.message);
        res.status(500).json({
            success: false,
            error: error.response?.data?.error_description || error.message,
        });
    }
};
