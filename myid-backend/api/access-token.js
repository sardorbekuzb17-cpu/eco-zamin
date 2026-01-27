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
        console.log('📤 ACCESS TOKEN: Token so\'rovi...');

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

        console.log('✅ ACCESS TOKEN: Token olindi');

        res.json({
            success: true,
            access_token: accessToken,
            expires_in: response.data.expires_in,
        });
    } catch (error) {
        console.error('❌ ACCESS TOKEN XATOSI:', error.response?.data || error.message);
        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data?.error_description || error.message,
        });
    }
};
