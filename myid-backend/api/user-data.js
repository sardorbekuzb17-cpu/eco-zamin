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
        const { code, access_token } = req.body;

        if (!code || !access_token) {
            return res.status(400).json({
                success: false,
                error: 'code va access_token majburiy',
            });
        }

        console.log('📤 USER DATA: Foydalanuvchi ma\'lumotlari so\'rovi...');

        const response = await axios.post(
            `${process.env.MYID_HOST}/v2/sdk/user-data`,
            { code },
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${access_token}`,
                },
            }
        );

        const profile = response.data;

        console.log('✅ USER DATA: Foydalanuvchi ma\'lumotlari olindi');

        res.json({
            success: true,
            profile: {
                pinfl: profile.pinfl,
                name: profile.name,
                surname: profile.surname,
                birth_date: profile.birth_date,
                gender: profile.gender,
                phone_number: profile.phone_number,
                email: profile.email,
                passport_series: profile.passport_series,
                passport_number: profile.passport_number,
            },
        });
    } catch (error) {
        console.error('❌ USER DATA XATOSI:', error.response?.data || error.message);
        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data?.error_description || error.message,
        });
    }
};
