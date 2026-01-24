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
const CLIENT_ID = process.env.MYID_CLIENT_ID || process.env.CLIENT_ID || 'quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v';
const CLIENT_SECRET = process.env.MYID_CLIENT_SECRET || process.env.CLIENT_SECRET || 'JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP';
const MYID_HOST = process.env.MYID_HOST || 'https://api.devmyid.uz'; // DEV muhiti

// ============================================
// 1. ACCESS TOKEN OLISH
// ============================================
// 1. ACCESS TOKEN OLISH (1-JADVAL)
// ============================================
// So'rov: client_id va client_secret bilan
// Javob: access_token
app.post('/api/myid/get-access-token', async (req, res, next) => {
    try {
        const { client_id, client_secret } = req.body;

        // Parametrlarni tekshirish
        if (!client_id || !client_secret) {
            return res.status(400).json({
                success: false,
                error: 'client_id va client_secret majburiy',
            });
        }

        console.log('📤 [1-JADVAL] Access token olinmoqda...');
        console.log('   client_id:', client_id.substring(0, 10) + '...');

        const response = await axios.post(
            `${MYID_HOST}/api/v1/auth/clients/access-token`,
            {
                grant_type: 'client_credentials',
                client_id: client_id,
                client_secret: client_secret,
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

        console.log('✅ [1-JADVAL] Access token olindi:', {
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
// 2. SESSION YARATISH (BO'SH) - 2-JADVAL
// ============================================
// So'rov: access_token (Authorization header'da, 1-jadvaldan)
// Javob: session_id, expires_in, token_type, access_token (MAJBURIY)
// 
// Spesifikatsiya:
// - Usul: POST
// - Yakuniy nuqta: {myid_host}/api/v2/sdk/sessions
// - Kontent turi: application/json
// - Avtorizatsiya: Bearer {access_token} (1-so'rovdan)
app.post('/api/myid/create-session', async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;

        // Authorization header'ni tekshirish
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            const error = new Error('Authorization header majburiy (Bearer token)');
            error.statusCode = 401;
            return next(error);
        }

        const accessToken = authHeader.substring(7); // "Bearer " ni olib tashlash

        console.log('📤 [2-JADVAL] Session yaratilmoqda...');
        console.log('   URL:', `${MYID_HOST}/api/v2/sdk/sessions`);
        console.log('   Token:', accessToken.substring(0, 50) + '...');

        // MyID API'ga session yaratish so'rovi
        const sessionResponse = await axios.post(
            `${MYID_HOST}/api/v2/sdk/sessions`,
            {},
            {
                headers: {
                    'Authorization': `Bearer ${accessToken}`,
                    'Content-Type': 'application/json',
                },
                timeout: 15000,
            }
        );

        console.log('✅ [2-JADVAL] MyID API dan javob olindi');

        // MAJBURIY MAYDONLARNI TEKSHIRISH
        const sessionData = sessionResponse.data;
        const validationErrors = [];

        // 1. session_id tekshirish (UUID, 36 belgi)
        if (!sessionData.session_id || typeof sessionData.session_id !== 'string') {
            validationErrors.push('session_id majburiy va string bo\'lishi kerak');
        } else if (sessionData.session_id.length !== 36) {
            validationErrors.push(`session_id uzunligi 36 belgi bo\'lishi kerak (hozir: ${sessionData.session_id.length})`);
        }

        // 2. expires_in tekshirish (soniya)
        if (sessionData.expires_in === null || sessionData.expires_in === undefined) {
            validationErrors.push('expires_in majburiy');
        } else if (typeof sessionData.expires_in !== 'number') {
            validationErrors.push('expires_in raqam bo\'lishi kerak');
        } else if (sessionData.expires_in <= 0) {
            validationErrors.push('expires_in musbat raqam bo\'lishi kerak');
        }

        // 3. token_type tekshirish (Bearer, 50 belgi max)
        if (!sessionData.token_type || typeof sessionData.token_type !== 'string') {
            validationErrors.push('token_type majburiy va string bo\'lishi kerak');
        } else if (sessionData.token_type.length > 50) {
            validationErrors.push(`token_type 50 belgidan ko\'p bo\'lmasligi kerak (hozir: ${sessionData.token_type.length})`);
        } else if (sessionData.token_type !== 'Bearer') {
            validationErrors.push(`token_type "Bearer" bo\'lishi kerak (hozir: ${sessionData.token_type})`);
        }

        // 4. access_token tekshirish (JWT, 512+ belgi)
        if (!sessionData.access_token || typeof sessionData.access_token !== 'string') {
            validationErrors.push('access_token majburiy va string bo\'lishi kerak');
        } else if (sessionData.access_token.length < 512) {
            validationErrors.push(`access_token 512 belgidan ko\'p bo\'lishi kerak (hozir: ${sessionData.access_token.length})`);
        } else if (!sessionData.access_token.includes('.')) {
            validationErrors.push('access_token JWT format bo\'lishi kerak (3 ta nuqta bo\'lishi kerak)');
        }

        // Agar validatsiya xatosi bo'lsa
        if (validationErrors.length > 0) {
            console.error('❌ [2-JADVAL] Validatsiya xatosi:');
            validationErrors.forEach(err => console.error('   - ' + err));
            return res.status(400).json({
                success: false,
                error: 'Session javobida validatsiya xatosi',
                validation_errors: validationErrors,
            });
        }

        console.log('✅ [2-JADVAL] Validatsiya o\'tdi');
        console.log('   Session ID:', sessionData.session_id);
        console.log('   Amal qilish muddati:', sessionData.expires_in, 'soniya');
        console.log('   Token turi:', sessionData.token_type);
        console.log('   Access token uzunligi:', sessionData.access_token.length);

        res.json({
            success: true,
            data: {
                session_id: sessionData.session_id,
                expires_in: sessionData.expires_in,
                token_type: sessionData.token_type,
                access_token: sessionData.access_token,
            },
        });
    } catch (error) {
        console.error('❌ Session yaratishda xato:');
        console.error('   Status:', error.response?.status);
        console.error('   Data:', error.response?.data);
        console.error('   Message:', error.message);
        next(error);
    }
});

// ============================================
// 2B. SESSION YARATISH (PASPORT BILAN) - 2-JADVAL
// ============================================
// So'rov: access_token (Authorization header'da) + pass_data + birth_date
// Javob: session_id, expires_in, token_type, access_token
app.post('/api/myid/create-session-with-passport', async (req, res, next) => {
    try {
        const { pass_data, birth_date } = req.body;
        const authHeader = req.headers.authorization;

        if (!pass_data || !birth_date) {
            const error = new Error('pass_data va birth_date majburiy');
            error.statusCode = 400;
            return next(error);
        }

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            const error = new Error('Authorization header majburiy (Bearer token)');
            error.statusCode = 401;
            return next(error);
        }

        const accessToken = authHeader.substring(7);

        console.log('📤 [2B-JADVAL] Session yaratilmoqda (pasport bilan)...');

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

        console.log('✅ [2B-JADVAL] Session yaratildi:', sessionResponse.data.session_id);

        res.json({
            success: true,
            data: {
                session_id: sessionResponse.data.session_id,
                expires_in: sessionResponse.data.expires_in,
                token_type: sessionResponse.data.token_type,
                access_token: sessionResponse.data.access_token,
            },
        });
    } catch (error) {
        console.error('❌ Session yaratishda xato:', error.response?.data || error.message);
        next(error);
    }
});

// ============================================
// 2C. SESSION YARATISH (PASPORT MAYDONLARI BILAN) - 2-JADVAL
// ============================================
// So'rov: access_token (Authorization header'da) + optional fields
// Javob: session_id, expires_in, token_type, access_token
app.post('/api/myid/create-session-with-fields', async (req, res, next) => {
    try {
        const { phone_number, birth_date, is_resident, pass_data, threshold } = req.body;
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            const error = new Error('Authorization header majburiy (Bearer token)');
            error.statusCode = 401;
            return next(error);
        }

        const accessToken = authHeader.substring(7);

        console.log('📤 [2C-JADVAL] Session yaratilmoqda (pasport maydonlari bilan)...');

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

        console.log('✅ [2C-JADVAL] Session yaratildi:', sessionResponse.data.session_id);

        res.json({
            success: true,
            data: {
                session_id: sessionResponse.data.session_id,
                expires_in: sessionResponse.data.expires_in,
                token_type: sessionResponse.data.token_type,
                access_token: sessionResponse.data.access_token,
            },
        });
    } catch (error) {
        console.error('❌ Session yaratishda xato:', error.response?.data || error.message);
        next(error);
    }
});

// ============================================
// 3. PROFIL MA'LUMOTLARINI OLISH (3-JADVAL)
// ============================================
// So'rov: code + Authorization header'da access_token
// Javob: user profile
app.post('/api/myid/get-user-info', async (req, res, next) => {
    try {
        const { code, base64_image } = req.body;
        const authHeader = req.headers.authorization;

        if (!code) {
            const error = new Error('code majburiy');
            error.statusCode = 400;
            return next(error);
        }

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            const error = new Error('Authorization header majburiy (Bearer token)');
            error.statusCode = 401;
            return next(error);
        }

        const accessToken = authHeader.substring(7); // "Bearer " ni olib tashlash

        console.log('📤 [3-JADVAL] Profil ma\'lumotlari olinmoqda...');
        console.log('   Code:', code.substring(0, 10) + '...');
        console.log('   Token:', accessToken.substring(0, 50) + '...');

        // Access token bilan profil ma'lumotlarini olish
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
        console.log('✅ [3-JADVAL] Profil ma\'lumotlari olindi');

        // MAJBURIY MAYDONLARNI TEKSHIRISH
        const validationErrors = [];

        // 1. pinfl tekshirish (14 belgi)
        if (!userData.pinfl || typeof userData.pinfl !== 'string') {
            validationErrors.push('pinfl majburiy va string bo\'lishi kerak');
        } else if (userData.pinfl.length !== 14) {
            validationErrors.push(`pinfl uzunligi 14 belgi bo\'lishi kerak (hozir: ${userData.pinfl.length})`);
        }

        // 2. name tekshirish
        if (!userData.name || typeof userData.name !== 'string') {
            validationErrors.push('name majburiy va string bo\'lishi kerak');
        }

        // 3. surname tekshirish
        if (!userData.surname || typeof userData.surname !== 'string') {
            validationErrors.push('surname majburiy va string bo\'lishi kerak');
        }

        // 4. birth_date tekshirish
        if (!userData.birth_date || typeof userData.birth_date !== 'string') {
            validationErrors.push('birth_date majburiy va string bo\'lishi kerak');
        }

        // 5. gender tekshirish (M yoki F)
        if (!userData.gender || typeof userData.gender !== 'string') {
            validationErrors.push('gender majburiy va string bo\'lishi kerak');
        } else if (userData.gender !== 'M' && userData.gender !== 'F') {
            validationErrors.push(`gender "M" yoki "F" bo\'lishi kerak (hozir: ${userData.gender})`);
        }

        // Agar validatsiya xatosi bo'lsa
        if (validationErrors.length > 0) {
            console.error('❌ [3-JADVAL] Validatsiya xatosi:');
            validationErrors.forEach(err => console.error('   - ' + err));
            return res.status(400).json({
                success: false,
                error: 'Foydalanuvchi ma\'lumotlarida validatsiya xatosi',
                validation_errors: validationErrors,
            });
        }

        console.log('✅ [3-JADVAL] Validatsiya o\'tdi');
        console.log('   PINFL:', userData.pinfl);
        console.log('   Ism:', userData.name);
        console.log('   Familiya:', userData.surname);

        const pinfl = userData.pinfl || code;

        let user = await MyIdUser.findOne({ pinfl });

        if (user) {
            user.last_login = new Date();
            user.profile = userData;
            user.face_image = base64_image;
            user.auth_method = 'sdk_direct';
            await user.save();
            console.log('✅ [3-JADVAL] Foydalanuvchi yangilandi');
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
            console.log('✅ [3-JADVAL] Yangi foydalanuvchi saqlandi');
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
        const authHeader = req.headers.authorization;

        if (!code) {
            const error = new Error('code majburiy');
            error.statusCode = 400;
            return next(error);
        }

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            const error = new Error('Authorization header majburiy (Bearer token)');
            error.statusCode = 401;
            return next(error);
        }

        const accessToken = authHeader.substring(7);

        console.log('📤 [3B-JADVAL] Profil ma\'lumotlari (rasmlar bilan) olinmoqda...');

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
        console.log('✅ [3B-JADVAL] Profil ma\'lumotlari olindi');

        const pinfl = userData.pinfl || code;

        let user = await MyIdUser.findOne({ pinfl });

        if (user) {
            user.last_login = new Date();
            user.profile = userData;
            user.face_image = base64_image;
            user.auth_method = 'simple_authorization';
            await user.save();
            console.log('✅ [3B-JADVAL] Foydalanuvchi yangilandi');
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
            console.log('✅ [3B-JADVAL] Yangi foydalanuvchi saqlandi');
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
        const authHeader = req.headers.authorization;

        if (!code) {
            const error = new Error('code majburiy');
            error.statusCode = 400;
            return next(error);
        }

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            const error = new Error('Authorization header majburiy (Bearer token)');
            error.statusCode = 401;
            return next(error);
        }

        const accessToken = authHeader.substring(7);

        console.log('📤 [GET] Profil ma\'lumotlari olinmoqda...');
        console.log('   Code:', code.substring(0, 10) + '...');
        console.log('   Token:', accessToken.substring(0, 50) + '...');

        // Profil ma'lumotlarini olish
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
        console.log('✅ [GET] Profil ma\'lumotlari olindi');

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
