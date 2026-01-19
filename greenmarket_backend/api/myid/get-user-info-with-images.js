const axios = require('axios');
const mongoose = require('mongoose');

const CLIENT_ID = 'quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v';
const CLIENT_SECRET = 'JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP';
const MYID_HOST = 'https://api.devmyid.uz';

const MyIdUserSchema = new mongoose.Schema({
    pinfl: { type: String, required: true, unique: true, index: true },
    myid_code: { type: String, required: true },
    profile: mongoose.Schema.Types.Mixed,
    face_image: String,
    passport_image: String,
    comparison_value: Number,
    auth_method: { type: String, enum: ['sdk_direct', 'simple_authorization', 'empty_session', 'passport_session'], default: 'sdk_direct' },
    status: { type: String, enum: ['active', 'inactive', 'blocked'], default: 'active' },
    registered_at: { type: Date, default: Date.now, index: true },
    last_login: { type: Date, default: Date.now },
    device_info: mongoose.Schema.Types.Mixed,
    metadata: mongoose.Schema.Types.Mixed,
    deleted_at: Date,
});

const MyIdUser = mongoose.model('MyIdUser', MyIdUserSchema);

module.exports = async (req, res) => {
    try {
        const { code, base64_image } = req.body;

        if (!code) {
            return res.status(400).json({
                success: false,
                error: 'code majburiy',
            });
        }

        // MongoDB ulanish
        if (mongoose.connection.readyState === 0) {
            await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/greenmarket');
        }

        console.log('📤 [1/3] Access token olinmoqda...');

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
        console.log('✅ [1/3] Access token olindi');

        console.log('📤 [2/3] Profil ma\'lumotlari olinmoqda...');

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
        console.log('✅ [2/3] Profil ma\'lumotlari olindi');

        console.log('📤 [3/3] Foydalanuvchi saqlanmoqda...');

        const pinfl = userData.pinfl || code;

        let user = await MyIdUser.findOne({ pinfl });

        if (user) {
            user.last_login = new Date();
            user.profile = userData;
            user.face_image = base64_image;
            user.auth_method = 'simple_authorization';
            await user.save();
            console.log('✅ [3/3] Foydalanuvchi yangilandi');
        } else {
            user = new MyIdUser({
                pinfl,
                myid_code: code,
                profile: userData,
                face_image: base64_image,
                auth_method: 'simple_authorization',
                status: 'active',
            });
            await user.save();
            console.log('✅ [3/3] Yangi foydalanuvchi saqlandi');
        }

        res.status(200).json({
            success: true,
            data: {
                user_id: user._id,
                pinfl: user.pinfl,
                profile: userData,
            },
        });
    } catch (error) {
        console.error('❌ Profil olishda xato:', error.response?.data || error.message);
        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data || error.message,
        });
    }
};
