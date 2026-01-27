import axios from 'axios';

export default async function handler(req, res) {
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
        const { code } = req.body;

        if (!code) {
            return res.status(400).json({
                success: false,
                error: 'Kod yuborilmadi',
            });
        }

        console.log('📤 VERIFY USER: Foydalanuvchi ma\'lumotlarini olish sorov...');
        console.log(`   Code: ${code.substring(0, 20)}...`);

        // MyID API'ga so'rov - kodni tekshirish va ma'lumotlarni olish
        const url = `${process.env.MYID_HOST}/v2/sdk/user-data`;
        console.log(`   URL: ${url}`);

        const response = await axios.post(
            url,
            { code },
            {
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                },
                timeout: 30000,
            }
        );

        console.log('✅ VERIFY USER: Ma\'lumotlar olindi');
        console.log(`   Response Status: ${response.status}`);

        const userData = response.data;

        // Foydalanuvchi ma'lumotlarini qaytarish
        res.status(200).json({
            success: true,
            user: {
                full_name: `${userData.name || userData.first_name || ''} ${userData.surname || userData.last_name || ''}`,
                pinfl: userData.pinfl || '',
                passport_series: userData.passport_series || '',
                passport_number: userData.passport_number || '',
                birth_date: userData.birth_date || '',
                gender: userData.gender || '',
                phone_number: userData.phone_number || '',
                email: userData.email || '',
                // Rasm ma'lumotlari (agar mavjud bo'lsa)
                photo: userData.image || userData.base64_image || null,
            },
            reuid: userData.reuid || '',
            comparison_value: userData.comparison_value || 0.95,
        });
    } catch (error) {
        console.error('❌ VERIFY USER XATOSI:');
        console.error(`   Status: ${error.response?.status}`);
        console.error(`   Data: ${JSON.stringify(error.response?.data)}`);
        console.error(`   Message: ${error.message}`);

        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data?.error_description || error.response?.data?.error || error.message,
            message: 'Identifikatsiya ma\'lumotlarini olishda xatolik yuz berdi',
        });
    }
}
