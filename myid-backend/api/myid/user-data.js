const axios = require('axios');

const MYID_HOST = process.env.MYID_HOST || 'https://api.devmyid.uz';

module.exports = async (req, res) => {
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

        console.log('📤 3-JADVAL: Foydalanuvchi ma\'lumotlari so\'rovi...');

        const response = await axios.post(
            `${MYID_HOST}/api/v2/sdk/user-data`,
            { code },
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${access_token}`,
                },
            }
        );

        const profile = response.data;

        const errors = [];

        if (!profile.pinfl || profile.pinfl.length !== 14) {
            errors.push('pinfl noto\'g\'ri format (14 ta belgi bo\'lishi kerak)');
        }

        if (!profile.name) {
            errors.push('name majburiy');
        }

        if (!profile.surname) {
            errors.push('surname majburiy');
        }

        if (!profile.birth_date) {
            errors.push('birth_date majburiy');
        }

        if (!profile.gender || !['M', 'F'].includes(profile.gender)) {
            errors.push('gender "M" yoki "F" bo\'lishi kerak');
        }

        if (errors.length > 0) {
            return res.status(400).json({
                success: false,
                error: 'Validatsiya xatosi',
                validation_errors: errors,
            });
        }

        console.log('✅ 3-JADVAL: Foydalanuvchi ma\'lumotlari olindi');

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
        console.error('❌ 3-JADVAL XATOSI:', error.response?.data || error.message);
        res.status(500).json({
            success: false,
            error: error.response?.data?.error_description || error.message,
        });
    }
};
