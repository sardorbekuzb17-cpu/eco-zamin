export default async (req, res) => {
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
        const { access_token } = req.body;

        if (!access_token) {
            return res.status(400).json({
                success: false,
                error: 'access_token majburiy',
            });
        }

        console.log('📤 GET SESSION: Session ma\'lumotlarini olish sorov...');

        const response = await axios.post(
            `${process.env.MYID_HOST}/v2/sdk/sessions`,
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

        console.log('✅ GET SESSION: Session ma\'lumotlari olindi');

        res.json({
            success: true,
            session_id: sessionId,
            access_token: newAccessToken,
            expires_in: response.data.expires_in,
            token_type: response.data.token_type,
        });
    } catch (error) {
        console.error('❌ GET SESSION XATOSI:', error.response?.data || error.message);
        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data?.error_description || error.message,
        });
    }
};
