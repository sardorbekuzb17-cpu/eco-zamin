const express = require('express');
const axios = require('axios');
const cors = require('cors');
const mongoose = require('mongoose');
require('dotenv').config();

const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');
const { apiLimiter } = require('./middleware/rateLimiter');

// MyID User Model
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

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors());

// MongoDB ulanish
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/greenmarket')
    .then(() => console.log('✅ MongoDB ga ulandi'))
    .catch(err => console.error('❌ MongoDB xatosi:', err));

// Rate limiting
app.use('/api/', apiLimiter);

// MyID credentials
const CLIENT_ID = 'quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v';
const CLIENT_SECRET = 'JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP';
const MYID_HOST = 'https://api.devmyid.uz'; // DEV muhiti

// ============================================
// 1. ACCESS TOKEN OLISH
// ============================================
app.post('/api/myid/get-access-token', async (req, res, next) => {
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

        res.json({
            success: true,
            data: {
                access_token,
                expires_in,
                token_type,
            },
        });
    } catch (error) {
        console.error('❌ Access token olishda xato:', error.response?.data || error.message);
        next(error);
    }
});

// ============================================
// 2. SESSION YARATISH (BO'SH)
// ============================================
app.post('/api/myid/create-session', async (req, res, next) => {
    try {
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

        console.log('📤 [2/2] Session yaratilmoqda...');

        const sessionResponse = await axios.post(
            `${MYID_HOST}/api/v2/sdk/sessions`,
            {},
            {
                headers: {
                    'Authorization': `Bearer ${accessToken}`,
                    'Content-Type': 'application/json',
                },
                timeout: 10000,
            }
        );

        console.log('✅ [2/2] Session yaratildi:', sessionResponse.data.session_id);

        res.json({
            success: true,
            data: {
                session_id: sessionResponse.data.session_id,
                expires_in: sessionResponse.data.expires_in,
            },
        });
    } catch (error) {
        console.error('❌ Session yaratishda xato:', error.response?.data || error.message);
        next(error);
    }
});

// ============================================
// 2B. SESSION YARATISH (PASPORT BILAN)
// ============================================
app.post('/api/myid/create-session-with-passport', async (req, res, next) => {
    try {
        const { pass_data, birth_date } = req.body;

        if (!pass_data || !birth_date) {
            const error = new Error('pass_data va birth_date majburiy');
            error.statusCode = 400;
            return next(error);
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

        console.log('📤 [2/2] Session yaratilmoqda (pasport bilan)...');

        const sessionResponse = await axios.post(
            `${MYID_HOST}/api/v2/sdk/sessions`,
            {
                pass_data,
                birth_date,
            },
            {
                headers: {
                    'Authorization': `Bearer ${accessToken}`,
                    'Content-Type': 'application/json',
                },
                timeout: 10000,
            }
        );

        console.log('✅ [2/2] Session yaratildi:', sessionResponse.data.session_id);

        res.json({
            success: true,
            data: {
                session_id: sessionResponse.data.session_id,
                expires_in: sessionResponse.data.expires_in,
            },
        });
    } catch (error) {
        console.error('❌ Session yaratishda xato:', error.response?.data || error.message);
        next(error);
    }
});

// ============================================
// 2C. SESSION YARATISH (PASPORT MAYDONLARI BILAN)
// ============================================
app.post('/api/myid/create-session-with-fields', async (req, res, next) => {
    try {
        const { phone_number, birth_date, is_resident, pass_data, threshold } = req.body;

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

        console.log('📤 [2/2] Session yaratilmoqda (pasport maydonlari bilan)...');

        const sessionBody = {};
        if (phone_number) sessionBody.phone_number = phone_number;
        if (birth_date) sessionBody.birth_date = birth_date;
        if (is_resident !== undefined) sessionBody.is_resident = is_resident;
        if (pass_data) sessionBody.pass_data = pass_data;
        if (threshold !== undefined) sessionBody.threshold = threshold;

        const sessionResponse = await axios.post(
            `${MYID_HOST}/api/v2/sdk/sessions`,
            sessionBody,
            {
                headers: {
                    'Authorization': `Bearer ${accessToken}`,
                    'Content-Type': 'application/json',
                },
                timeout: 10000,
            }
        );

        console.log('✅ [2/2] Session yaratildi:', sessionResponse.data.session_id);

        res.json({
            success: true,
            data: {
                session_id: sessionResponse.data.session_id,
                expires_in: sessionResponse.data.expires_in,
            },
        });
    } catch (error) {
        console.error('❌ Session yaratishda xato:', error.response?.data || error.message);
        next(error);
    }
});

// ============================================
// 3. PROFIL MA'LUMOTLARINI OLISH
// ============================================
app.post('/api/myid/get-user-info', async (req, res, next) => {
    try {
        const { code, base64_image } = req.body;

        if (!code) {
            const error = new Error('code majburiy');
            error.statusCode = 400;
            return next(error);
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
            user.auth_method = 'sdk_direct';
            await user.save();
            console.log('✅ [3/3] Foydalanuvchi yangilandi');
        } else {
            user = new MyIdUser({
                pinfl,
                myid_code: code,
                profile: userData,
                face_image: base64_image,
                auth_method: 'sdk_direct',
                status: 'active',
            });
            await user.save();
            console.log('✅ [3/3] Yangi foydalanuvchi saqlandi');
        }

        res.json({
            success: true,
            data: {
                user_id: user._id,
                pinfl: user.pinfl,
                profile: userData,
            },
        });
    } catch (error) {
        console.error('❌ Profil olishda xato:', error.response?.data || error.message);
        next(error);
    }
});

// ============================================
// 3B. PROFIL MA'LUMOTLARINI OLISH (RASMLAR BILAN)
// ============================================
app.post('/api/myid/get-user-info-with-images', async (req, res, next) => {
    try {
        const { code, base64_image } = req.body;

        if (!code) {
            const error = new Error('code majburiy');
            error.statusCode = 400;
            return next(error);
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

        res.json({
            success: true,
            data: {
                user_id: user._id,
                pinfl: user.pinfl,
                profile: userData,
            },
        });
    } catch (error) {
        console.error('❌ Profil olishda xato:', error.response?.data || error.message);
        next(error);
    }
});

// ============================================
// 4. FOYDALANUVCHI MA'LUMOTLARINI OLISH (GET)
// ============================================
app.get('/api/myid/data/code=:code', async (req, res, next) => {
    try {
        const { code } = req.params;

        if (!code) {
            const error = new Error('code majburiy');
            error.statusCode = 400;
            return next(error);
        }

        console.log('📤 [1/2] Access token olinmoqda...');

        // Access token olish
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

        // Profil ma'lumotlarini olish
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

        res.json({
            success: true,
            data: userData,
        });
    } catch (error) {
        console.error('❌ Profil olishda xato:', error.response?.data || error.message);
        next(error);
    }
});

// ============================================
// ADMIN ENDPOINT'LAR
// ============================================

// Barcha foydalanuvchilar
app.get('/api/myid/users', async (req, res) => {
    try {
        const users = await MyIdUser.find({ deleted_at: null })
            .select('-face_image -passport_image')
            .sort({ registered_at: -1 });

        res.json({
            success: true,
            data: {
                total: users.length,
                users,
            },
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// Statistika
app.get('/api/myid/stats', async (req, res) => {
    try {
        const totalUsers = await MyIdUser.countDocuments({ deleted_at: null });

        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const todayUsers = await MyIdUser.countDocuments({
            registered_at: { $gte: today },
            deleted_at: null,
        });

        res.json({
            success: true,
            data: {
                total_users: totalUsers,
                today_registrations: todayUsers,
                last_updated: new Date(),
            },
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', message: 'Backend ishlayapti!' });
});

const PORT = process.env.PORT || 3000;

app.use(notFoundHandler);
app.use(errorHandler);

app.listen(PORT, () => {
    console.log(`🚀 Server ${PORT} portda ishlamoqda`);
    console.log(`🔗 MyID Host: ${MYID_HOST}`);
});
