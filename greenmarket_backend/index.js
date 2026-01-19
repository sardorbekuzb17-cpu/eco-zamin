const express = require('express');
const axios = require('axios');
const cors = require('cors');
const mongoose = require('mongoose');
require('dotenv').config();
const myidSdkFlow = require('./myid_sdk_flow');
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');
const { retryWithBackoff } = require('./myid_sdk_flow');
const { encryptSensitiveData, decryptSensitiveData, sanitizeApiResponse } = require('./security/encryption');
const { apiLimiter } = require('./middleware/rateLimiter');

// MyID User Model
const MyIdUserSchema = new mongoose.Schema({
    pinfl: { type: String, required: true, unique: true, index: true },
    myid_code: { type: String, required: true },
    profile: mongoose.Schema.Types.Mixed,
    face_image: String,
    passport_image: String,
    comparison_value: Number,
    auth_method: { type: String, enum: ['sdk_direct', 'simple_authorization', 'empty_session'], default: 'sdk_direct' },
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
app.use(express.urlencoded({ extended: true })); // x-www-form-urlencoded uchun
app.use(cors());

// MongoDB ulanish
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/greenmarket')
    .then(() => console.log('✅ MongoDB ga ulandi'))
    .catch(err => console.error('❌ MongoDB xatosi:', err));

// Rate limiting - barcha API endpointlariga qo'llash
// 1 daqiqada maksimal 10 so'rov (Requirements: 5.8)
app.use('/api/', apiLimiter);

// MyID credentials (shartnomadan)
const CLIENT_ID = 'quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v';
const CLIENT_SECRET = 'JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP';
const USERNAME = 'quyosh_24_sdk'; // API uchun username
const PASSWORD = 'JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP'; // API uchun password
const MYID_HOST = 'https://api.devmyid.uz'; // DEV muhiti

// Foydalanuvchilar bazasi (xotirada saqlash - test uchun)
const users = [];

// Foydalanuvchi statistikasi
const stats = {
    totalUsers: 0,
    todayRegistrations: 0,
    lastRegistrationDate: null,
};

// 0. Simple Authorization - To'liq oqim (access token + session bitta so'rovda)
app.post('/api/myid/create-simple-session-complete', async (req, res, next) => {
    try {
        const { pass_data, birth_date } = req.body;

        if (!pass_data || !birth_date) {
            const error = new Error('pass_data va birth_date majburiy');
            error.statusCode = 400;
            error.name = 'ValidationError';
            return next(error);
        }

        console.log('📤 [1/2] Access token olinmoqda (client credentials)...');

        // 1. Access token olish
        const tokenResponse = await retryWithBackoff(async () => {
            return await axios.post(
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
        });

        const accessToken = tokenResponse.data.access_token;
        const expiresIn = tokenResponse.data.expires_in;
        const tokenType = tokenResponse.data.token_type;

        if (!accessToken || !expiresIn || !tokenType) {
            throw new Error('Access token javobida majburiy maydonlar yo\'q');
        }

        console.log('✅ Access token olindi:', {
            token_length: accessToken.length,
            expires_in: expiresIn,
            token_type: tokenType,
        });
        console.log('✅ [1/2] Access token olindi');

        // 2. Simple session yaratish
        console.log('📤 [2/2] Simple session yaratilmoqda...');
        console.log('   Pasport:', pass_data);
        console.log('   Tug\'ilgan sana:', birth_date);

        const sessionResponse = await retryWithBackoff(async () => {
            return await axios.post(
                `${MYID_HOST}/api/v1/oauth2/session`,
                {
                    grant_type: 'simple_authorization',
                    scope: 'address,contacts,doc_data,common_data,doc_files',
                    pass_data: pass_data,
                    birth_date: birth_date,
                },
                {
                    headers: {
                        'Authorization': `Bearer ${accessToken}`,
                        'Content-Type': 'application/json',
                    },
                    timeout: 10000,
                }
            );
        });

        console.log('✅ [2/2] Simple session yaratildi');

        res.json({
            success: true,
            data: sessionResponse.data,
        });
    } catch (error) {
        console.error('❌ Simple session yaratishda xato:', error.response?.data || error.message);
        next(error);
    }
});

// 1. SDK'dan CODE va RASMLAR olish va ACCESS_TOKEN olish
app.post('/api/myid/get-user-info-with-images', async (req, res, next) => {
    try {
        const { code, base64_image } = req.body;

        if (!code) {
            const error = new Error('code majburiy');
            error.statusCode = 400;
            error.name = 'ValidationError';
            return next(error);
        }

        console.log('📞 SDK\'dan code va rasm olindi:');
        console.log('   - code:', code);
        console.log('   - base64_image:', base64_image ? `${base64_image.length} bytes` : 'yo\'q');

        // 1. Access token olish (qayta urinish mexanizmi bilan)
        console.log('📤 Access token so\'ralmoqda...');
        const tokenResponse = await retryWithBackoff(async () => {
            return await axios.post(
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
        });

        const accessToken = tokenResponse.data.access_token;
        const expiresIn = tokenResponse.data.expires_in;
        const tokenType = tokenResponse.data.token_type;

        if (!accessToken || !expiresIn || !tokenType) {
            throw new Error('Access token javobida majburiy maydonlar yo\'q');
        }

        console.log('✅ Access token olindi:', {
            token_length: accessToken.length,
            expires_in: expiresIn,
            token_type: tokenType,
        });

        // 2. Foydalanuvchi ma'lumotlarini olish (qayta urinish mexanizmi bilan)
        console.log('📤 Foydalanuvchi ma\'lumotlari so\'ralmoqda...');
        const userInfoResponse = await retryWithBackoff(async () => {
            return await axios.get(
                `${MYID_HOST}/api/v1/users/me`,
                {
                    headers: {
                        'Authorization': `Bearer ${accessToken}`,
                    },
                    timeout: 10000,
                }
            );
        });

        console.log('✅ Foydalanuvchi ma\'lumotlari olindi');

        // 3. Foydalanuvchini saqlash (rasmlar bilan)
        const userData = userInfoResponse.data;

        // PINFL ni olish (profil ma'lumotlaridan)
        const pinfl = userData.pinfl || code;

        // Mavjud foydalanuvchini tekshirish
        let existingUser = await MyIdUser.findOne({ pinfl: pinfl });

        if (existingUser) {
            // Mavjud foydalanuvchini yangilash
            console.log('📝 Mavjud foydalanuvchi yangilanmoqda:', pinfl);
            existingUser.last_login = new Date();
            existingUser.profile = userData;
            existingUser.face_image = base64_image;
            await existingUser.save();
            console.log('✅ Foydalanuvchi yangilandi');
        } else {
            // Yangi foydalanuvchi yaratish
            console.log('🆕 Yangi foydalanuvchi yaratilmoqda:', pinfl);
            const newUser = new MyIdUser({
                pinfl: pinfl,
                myid_code: code,
                profile: userData,
                face_image: base64_image,
                auth_method: 'simple_authorization',
                status: 'active',
                registered_at: new Date(),
                last_login: new Date(),
            });

            await newUser.save();
            existingUser = newUser;
            console.log('✅ Yangi foydalanuvchi saqlandi:', newUser._id);
        }

        // Xotirada ham saqlash (test uchun)
        const newUser = {
            id: users.length + 1,
            myid_code: code,
            pinfl: pinfl,
            profile_data: userData,
            base64_image: base64_image,
            registered_at: new Date().toISOString(),
            last_login: new Date().toISOString(),
            status: 'active',
            auth_method: 'simple_authorization',
        };

        users.push(newUser);

        // Statistikani yangilash
        stats.totalUsers = users.length;
        stats.todayRegistrations++;
        stats.lastRegistrationDate = new Date().toISOString();

        console.log('✅ Foydalanuvchi saqlandi (xotirada):', newUser.id);
        console.log('   - MongoDB ID:', existingUser._id);
        console.log('   - Rasm saqlandi:', base64_image ? 'ha' : 'yo\'q');

        // API javobini tozalash (client_secret'ni olib tashlash)
        const sanitizedResponse = sanitizeApiResponse({
            success: true,
            message: 'Foydalanuvchi muvaffaqiyatli ro\'yxatdan o\'tdi',
            user: {
                id: existingUser._id,
                pinfl: existingUser.pinfl,
                myid_code: existingUser.myid_code,
                registered_at: existingUser.registered_at,
                status: existingUser.status,
                auth_method: existingUser.auth_method,
            },
            profile: userData,
        });

        res.json(sanitizedResponse);
    } catch (error) {
        next(error);
    }
});

// 1.1. Session natijasini olish (SDK tugagandan keyin)
app.post('/api/myid/get-session-result', async (req, res) => {
    try {
        const { session_id } = req.body;

        if (!session_id) {
            return res.status(400).json({
                success: false,
                error: 'session_id majburiy',
            });
        }

        console.log('📞 Session natijasi so\'ralmoqda:', session_id);

        // 1. Access token olish (qayta urinish mexanizmi bilan)
        const tokenResponse = await retryWithBackoff(async () => {
            return await axios.post(
                `${MYID_HOST}/api/v1/auth/clients/access-token`,
                {
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
        });

        const accessToken = tokenResponse.data.access_token;
        console.log('✅ Access token olindi');

        // 2. Session natijasini olish (qayta urinish mexanizmi bilan)
        console.log('📤 Session natijasi olinmoqda...');
        const sessionResultResponse = await retryWithBackoff(async () => {
            return await axios.get(
                `${MYID_HOST}/api/v2/sdk/sessions/${session_id}`,
                {
                    headers: {
                        'Authorization': `Bearer ${accessToken}`,
                        'Content-Type': 'application/json',
                    },
                    timeout: 10000,
                }
            );
        });

        console.log('✅ Session natijasi olindi:', sessionResultResponse.data);

        // 3. Foydalanuvchini saqlash
        const sessionData = sessionResultResponse.data;

        // Maxfiy ma'lumotlarni shifrlash
        const encryptedProfileData = encryptSensitiveData(sessionData);

        const newUser = {
            id: users.length + 1,
            session_id: session_id,
            profile_data: encryptedProfileData,
            registered_at: new Date().toISOString(),
            last_login: new Date().toISOString(),
            status: 'active',
        };

        users.push(newUser);

        // Statistikani yangilash
        stats.totalUsers = users.length;
        stats.todayRegistrations++;
        stats.lastRegistrationDate = new Date().toISOString();

        console.log('✅ Foydalanuvchi saqlandi:', newUser.id);

        // API javobini tozalash
        const sanitizedResponse = sanitizeApiResponse({
            success: true,
            message: 'Foydalanuvchi muvaffaqiyatli ro\'yxatdan o\'tdi',
            user: {
                ...newUser,
                profile_data: sessionData, // Deshifrlangan ma'lumotlarni qaytarish
            },
            profile: sessionData,
        });

        res.json(sanitizedResponse);
    } catch (error) {
        console.error('❌ Session natijasini olishda xatolik:', {
            status: error.response?.status,
            data: error.response?.data,
            message: error.message,
        });

        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data || error.message,
            error_details: {
                message: error.message,
                status: error.response?.status,
                data: error.response?.data,
            },
        });
    }
});

// 2. Bo'sh sessiya yaratish (pasport ma'lumotlari siz)
app.post('/api/myid/create-session', async (req, res, next) => {
    try {
        console.log('📤 Bo\'sh sessiya yaratilmoqda...');

        // 1. Access token olish (client credentials - OAuth2)
        const tokenResponse = await retryWithBackoff(async () => {
            return await axios.post(
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
        });

        const accessToken = tokenResponse.data.access_token;
        const expiresIn = tokenResponse.data.expires_in;
        const tokenType = tokenResponse.data.token_type;

        if (!accessToken || !expiresIn || !tokenType) {
            throw new Error('Access token javobida majburiy maydonlar yo\'q');
        }

        console.log('✅ Access token olindi:', {
            token_length: accessToken.length,
            expires_in: expiresIn,
            token_type: tokenType,
        });

        // 2. Bo'sh sessiya yaratish (YANGI API v2) (qayta urinish mexanizmi bilan)
        const sessionResponse = await retryWithBackoff(async () => {
            return await axios.post(
                `${MYID_HOST}/api/v2/sdk/sessions`,
                {}, // Bo'sh body - pasport ma'lumotlari siz
                {
                    headers: {
                        'Authorization': `Bearer ${accessToken}`,
                        'Content-Type': 'application/json',
                    },
                    timeout: 10000,
                }
            );
        });

        console.log('✅ Sessiya yaratildi:', sessionResponse.data);

        // MyID API javobini to'g'ri formatda qaytarish
        // MyID API v2: {session_id: "...", expires_in: 3600}
        // Lekin biz uni {data: {session_id: ...}} formatida qaytaramiz
        res.json({
            success: true,
            session_id: sessionResponse.data.session_id,
            data: sessionResponse.data
        });
    } catch (error) {
        next(error);
    }
});

// ============================================
// SDK FLOW - DIAGRAMMAGA MUVOFIQ (YANGI!)
// ============================================

// 1+2. Access token olish va Session yaratish
app.post('/api/myid/sdk/create-session', async (req, res) => {
    try {
        const { pass_data, pinfl, birth_date, phone_number, is_resident, threshold } = req.body;

        const passportData = {
            pass_data,
            pinfl,
            birth_date,
            phone_number,
            is_resident,
            threshold,
        };

        const result = await myidSdkFlow.completeSdkFlow(passportData);

        if (result.success) {
            res.json(result);
        } else {
            res.status(400).json(result);
        }
    } catch (error) {
        console.error('❌ SDK create-session xatosi:', error);
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// 3. SDK'dan code olish va foydalanuvchi ma'lumotlarini olish
app.post('/api/myid/sdk/get-user-data', async (req, res, next) => {
    try {
        const { code } = req.body;

        if (!code) {
            const error = new Error('code majburiy');
            error.statusCode = 400;
            error.name = 'ValidationError';
            return next(error);
        }

        // Access token olish
        const tokenResult = await myidSdkFlow.getAccessToken();
        if (!tokenResult.success) {
            const error = new Error(tokenResult.error || 'Access token olishda xatolik');
            error.statusCode = 400;
            return next(error);
        }

        // Foydalanuvchi ma'lumotlarini olish
        const userDataResult = await myidSdkFlow.retrieveUserData(tokenResult.access_token, code);

        if (userDataResult.success) {
            // Maxfiy ma'lumotlarni shifrlash
            const encryptedProfileData = encryptSensitiveData(userDataResult.data.profile);

            // Foydalanuvchini saqlash
            const newUser = {
                id: users.length + 1,
                code: code,
                profile_data: encryptedProfileData,
                comparison_value: userDataResult.data.comparison_value,
                registered_at: new Date().toISOString(),
                last_login: new Date().toISOString(),
                status: 'active',
                method: 'sdk_flow',
            };

            users.push(newUser);
            stats.totalUsers = users.length;
            stats.todayRegistrations++;
            stats.lastRegistrationDate = new Date().toISOString();

            console.log('✅ Foydalanuvchi saqlandi:', newUser.id);

            // API javobini tozalash
            const sanitizedResponse = sanitizeApiResponse(userDataResult);
            res.json(sanitizedResponse);
        } else {
            const error = new Error(userDataResult.error || 'Foydalanuvchi ma\'lumotlarini olishda xatolik');
            error.statusCode = 400;
            next(error);
        }
    } catch (error) {
        next(error);
    }
});

// ============================================
// SDK FLOW - RASMIY USUL (client_id/client_secret)
// ============================================

// 1-QADAM: Access token olish (client credentials bilan)
app.post('/api/myid/get-access-token', async (req, res) => {
    try {
        console.log('📤 [SDK FLOW] Access token olinmoqda...');

        const tokenResponse = await retryWithBackoff(async () => {
            return await axios.post(
                `${MYID_HOST}/api/v1/auth/clients/access-token`,
                {
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
        });

        console.log('✅ [SDK FLOW] Access token olindi:', {
            expires_in: tokenResponse.data.expires_in,
        });

        res.json({
            success: true,
            data: tokenResponse.data,
        });
    } catch (error) {
        console.error('❌ [SDK FLOW] Access token olishda xatolik:', {
            status: error.response?.status,
            data: error.response?.data,
            message: error.message,
        });

        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data || error.message,
        });
    }
});

// 2-QADAM: Pasport + selfie yuborish va job_id olish
app.post('/api/myid/submit-verification', async (req, res) => {
    try {
        const {
            access_token,
            pass_data,
            pinfl,
            birth_date,
            photo_base64,
            agreed_on_terms,
            device,
            threshold,
            external_id,
            is_resident,
        } = req.body;

        if (!access_token) {
            return res.status(400).json({
                success: false,
                error: 'access_token majburiy',
            });
        }

        if (!pass_data && !pinfl) {
            return res.status(400).json({
                success: false,
                error: 'pass_data yoki pinfl majburiy',
            });
        }

        if (!birth_date || !photo_base64) {
            return res.status(400).json({
                success: false,
                error: 'birth_date va photo_base64 majburiy',
            });
        }

        console.log('📤 [SDK FLOW] Verifikatsiya so\'rovi yuborilmoqda...', {
            pass_data,
            pinfl,
            birth_date,
            photo_length: photo_base64?.length,
            is_resident,
        });

        const requestBody = {
            birth_date,
            photo_from_camera: {
                front: photo_base64,
            },
            agreed_on_terms: agreed_on_terms !== false,
            client_id: CLIENT_ID,
        };

        if (pass_data) requestBody.pass_data = pass_data;
        if (pinfl) requestBody.pinfl = pinfl;
        if (device) requestBody.device = device;
        if (threshold) requestBody.threshold = threshold;
        if (external_id) requestBody.external_id = external_id;
        if (is_resident !== undefined) requestBody.is_resident = is_resident;

        const response = await retryWithBackoff(async () => {
            return await axios.post(
                `${MYID_HOST}/api/v1/authentication/simple-inplace-authentication-request-task`,
                requestBody,
                {
                    headers: {
                        'Authorization': `Bearer ${access_token}`,
                        'Content-Type': 'application/json',
                    },
                    timeout: 10000,
                }
            );
        });

        console.log('✅ [SDK FLOW] job_id olindi:', response.data.job_id);

        res.json({
            success: true,
            data: response.data,
        });
    } catch (error) {
        console.error('❌ [SDK FLOW] Verifikatsiya so\'rovida xatolik:', {
            status: error.response?.status,
            data: error.response?.data,
            message: error.message,
        });

        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data || error.message,
            error_details: {
                message: error.message,
                status: error.response?.status,
                data: error.response?.data,
            },
        });
    }
});

// 3-QADAM: job_id bilan natija olish
app.post('/api/myid/get-result', async (req, res) => {
    try {
        const { access_token, job_id } = req.body;

        if (!access_token || !job_id) {
            return res.status(400).json({
                success: false,
                error: 'access_token va job_id majburiy',
            });
        }

        console.log('📤 [SDK FLOW] Natija olinmoqda, job_id:', job_id);

        await new Promise(resolve => setTimeout(resolve, 500));

        const response = await retryWithBackoff(async () => {
            return await axios.post(
                `${MYID_HOST}/api/v1/authentication/simple-inplace-authentication-request-status?job_id=${job_id}`,
                {},
                {
                    headers: {
                        'Authorization': `Bearer ${access_token}`,
                        'Content-Type': 'application/json',
                    },
                    timeout: 10000,
                }
            );
        });

        console.log('✅ [SDK FLOW] Natija olindi:', {
            result_code: response.data.result_code,
            result_note: response.data.result_note,
        });

        if (response.data.result_code === 1) {
            // Maxfiy ma'lumotlarni shifrlash
            const encryptedProfileData = encryptSensitiveData(response.data.profile);

            const newUser = {
                id: users.length + 1,
                job_id: job_id,
                profile_data: encryptedProfileData,
                comparison_value: response.data.comparison_value,
                registered_at: new Date().toISOString(),
                last_login: new Date().toISOString(),
                status: 'active',
                method: 'sdk_flow',
            };

            users.push(newUser);
            stats.totalUsers = users.length;
            stats.todayRegistrations++;
            stats.lastRegistrationDate = new Date().toISOString();

            console.log('✅ [SDK FLOW] Foydalanuvchi saqlandi:', newUser.id);
        }

        // API javobini tozalash
        const sanitizedResponse = sanitizeApiResponse({
            success: true,
            data: response.data,
        });

        res.json(sanitizedResponse);
    } catch (error) {
        console.error('❌ [SDK FLOW] Natija olishda xatolik:', {
            status: error.response?.status,
            data: error.response?.data,
            message: error.message,
        });

        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data || error.message,
            error_details: {
                message: error.message,
                status: error.response?.status,
                data: error.response?.data,
            },
        });
    }
});

// TO'LIQ SDK FLOW - Barcha qadamlarni bitta so'rovda
app.post('/api/myid/complete', async (req, res) => {
    try {
        const {
            pass_data,
            pinfl,
            birth_date,
            photo_base64,
            agreed_on_terms,
            device,
            threshold,
            external_id,
            is_resident,
        } = req.body;

        console.log('🚀 [SDK FLOW COMPLETE] Boshlandi...');

        // 1. Access token olish
        console.log('📤 [1/3] Access token olinmoqda...');
        const tokenResponse = await retryWithBackoff(async () => {
            return await axios.post(
                `${MYID_HOST}/api/v1/auth/clients/access-token`,
                {
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
        });

        const accessToken = tokenResponse.data.access_token;
        console.log('✅ [1/3] Access token olindi');

        // 2. Verifikatsiya so'rovi yuborish
        console.log('📤 [2/3] Verifikatsiya so\'rovi yuborilmoqda...');
        const requestBody = {
            birth_date,
            photo_from_camera: {
                front: photo_base64,
            },
            agreed_on_terms: agreed_on_terms !== false,
            client_id: CLIENT_ID,
        };

        if (pass_data) requestBody.pass_data = pass_data;
        if (pinfl) requestBody.pinfl = pinfl;
        if (device) requestBody.device = device;
        if (threshold) requestBody.threshold = threshold;
        if (external_id) requestBody.external_id = external_id;
        if (is_resident !== undefined) requestBody.is_resident = is_resident;

        const verifyResponse = await retryWithBackoff(async () => {
            return await axios.post(
                `${MYID_HOST}/api/v1/authentication/simple-inplace-authentication-request-task`,
                requestBody,
                {
                    headers: {
                        'Authorization': `Bearer ${accessToken}`,
                        'Content-Type': 'application/json',
                    },
                    timeout: 10000,
                }
            );
        });

        const jobId = verifyResponse.data.job_id;
        console.log('✅ [2/3] job_id olindi:', jobId);

        // 3. Natija olish (0.5 soniya kutish)
        console.log('⏳ [3/3] 0.5 soniya kutilmoqda...');
        await new Promise(resolve => setTimeout(resolve, 500));

        console.log('📤 [3/3] Natija olinmoqda...');
        const resultResponse = await retryWithBackoff(async () => {
            return await axios.post(
                `${MYID_HOST}/api/v1/authentication/simple-inplace-authentication-request-status?job_id=${jobId}`,
                {},
                {
                    headers: {
                        'Authorization': `Bearer ${accessToken}`,
                        'Content-Type': 'application/json',
                    },
                    timeout: 10000,
                }
            );
        });

        console.log('✅ [3/3] Natija olindi:', {
            result_code: resultResponse.data.result_code,
            result_note: resultResponse.data.result_note,
        });

        if (resultResponse.data.result_code === 1) {
            // Maxfiy ma'lumotlarni shifrlash
            const encryptedProfileData = encryptSensitiveData(resultResponse.data.profile);

            const newUser = {
                id: users.length + 1,
                job_id: jobId,
                profile_data: encryptedProfileData,
                comparison_value: resultResponse.data.comparison_value,
                registered_at: new Date().toISOString(),
                last_login: new Date().toISOString(),
                status: 'active',
                method: 'sdk_flow_complete',
            };

            users.push(newUser);
            stats.totalUsers = users.length;
            stats.todayRegistrations++;
            stats.lastRegistrationDate = new Date().toISOString();

            console.log('✅ Foydalanuvchi saqlandi:', newUser.id);
        }

        // API javobini tozalash
        const sanitizedResponse = sanitizeApiResponse({
            success: true,
            message: 'SDK Flow muvaffaqiyatli yakunlandi',
            data: resultResponse.data,
            job_id: jobId,
        });

        res.json(sanitizedResponse);
    } catch (error) {
        console.error('❌ [SDK FLOW COMPLETE] Xatolik:', {
            status: error.response?.status,
            data: error.response?.data,
            message: error.message,
        });

        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data || error.message,
            error_details: {
                message: error.message,
                status: error.response?.status,
                data: error.response?.data,
            },
        });
    }
});

// ============================================
// ESKI USULLAR (SDK bilan sessiya yaratish)
// ============================================

// 3. Pasport ma'lumotlari bilan sessiya yaratish
app.post('/api/myid/create-session-with-passport', async (req, res) => {
    try {
        const { phone_number, birth_date, is_resident, pass_data, pinfl, threshold } = req.body;

        console.log('📤 Pasport bilan sessiya yaratilmoqda...', {
            phone_number,
            birth_date,
            is_resident,
            pass_data,
            pinfl,
            threshold,
        });

        // 1. Access token olish (qayta urinish mexanizmi bilan)
        const tokenResponse = await retryWithBackoff(async () => {
            return await axios.post(
                `${MYID_HOST}/api/v1/auth/clients/access-token`,
                {
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
        });

        const accessToken = tokenResponse.data.access_token;
        console.log('✅ Access token olindi');

        // 2. Pasport bilan sessiya yaratish (YANGI API v2) (qayta urinish mexanizmi bilan)
        const sessionData = {};
        if (phone_number) sessionData.phone_number = phone_number;
        if (birth_date) sessionData.birth_date = birth_date;
        if (is_resident !== undefined) sessionData.is_resident = is_resident;
        if (pass_data) sessionData.pass_data = pass_data;
        if (pinfl) sessionData.pinfl = pinfl;
        if (threshold) sessionData.threshold = threshold;

        const sessionResponse = await retryWithBackoff(async () => {
            return await axios.post(
                `${MYID_HOST}/api/v2/sdk/sessions`,
                sessionData,
                {
                    headers: {
                        'Authorization': `Bearer ${accessToken}`,
                        'Content-Type': 'application/json',
                    },
                    timeout: 10000,
                }
            );
        });

        console.log('✅ Sessiya yaratildi:', sessionResponse.data);

        res.json({
            success: true,
            data: sessionResponse.data,
        });
    } catch (error) {
        console.error('❌ Sessiya yaratishda xatolik:', {
            status: error.response?.status,
            data: error.response?.data,
            message: error.message,
        });

        res.status(error.response?.status || 500).json({
            success: false,
            error: error.response?.data || error.message,
        });
    }
});

// 5. Barcha foydalanuvchilarni ko'rish
app.get('/api/users', (req, res, next) => {
    try {
        const { page = 1, limit = 10, status } = req.query;

        let filteredUsers = users;

        // Status bo'yicha filter
        if (status) {
            filteredUsers = users.filter(u => u.status === status);
        }

        // Pagination
        const startIndex = (page - 1) * limit;
        const endIndex = page * limit;
        const paginatedUsers = filteredUsers.slice(startIndex, endIndex);

        // Maxfiy ma'lumotlarni deshifrlash (faqat ko'rsatish uchun)
        const decryptedUsers = paginatedUsers.map(user => ({
            ...user,
            profile_data: decryptSensitiveData(user.profile_data),
        }));

        // API javobini tozalash
        const sanitizedResponse = sanitizeApiResponse({
            success: true,
            data: {
                users: decryptedUsers,
                pagination: {
                    total: filteredUsers.length,
                    page: parseInt(page),
                    limit: parseInt(limit),
                    totalPages: Math.ceil(filteredUsers.length / limit),
                },
                stats: stats,
            },
        });

        res.json(sanitizedResponse);
    } catch (error) {
        next(error);
    }
});

// 6. Bitta foydalanuvchini ko'rish
app.get('/api/users/:id', (req, res, next) => {
    try {
        const userId = parseInt(req.params.id);
        const user = users.find(u => u.id === userId);

        if (!user) {
            const error = new Error('Foydalanuvchi topilmadi');
            error.statusCode = 404;
            return next(error);
        }

        // Maxfiy ma'lumotlarni deshifrlash
        const decryptedUser = {
            ...user,
            profile_data: decryptSensitiveData(user.profile_data),
        };

        // API javobini tozalash
        const sanitizedResponse = sanitizeApiResponse({
            success: true,
            user: decryptedUser,
        });

        res.json(sanitizedResponse);
    } catch (error) {
        next(error);
    }
});

// 7. Foydalanuvchi statistikasi
app.get('/api/users/stats/summary', (req, res, next) => {
    try {
        const today = new Date().toISOString().split('T')[0];
        const todayUsers = users.filter(u =>
            u.registered_at.startsWith(today)
        ).length;

        const activeUsers = users.filter(u => u.status === 'active').length;
        const inactiveUsers = users.filter(u => u.status === 'inactive').length;

        res.json({
            success: true,
            stats: {
                total_users: users.length,
                today_registrations: todayUsers,
                active_users: activeUsers,
                inactive_users: inactiveUsers,
                last_registration: stats.lastRegistrationDate,
            },
        });
    } catch (error) {
        next(error);
    }
});

// 8. Foydalanuvchini o'chirish
app.delete('/api/users/:id', (req, res, next) => {
    try {
        const userId = parseInt(req.params.id);
        const userIndex = users.findIndex(u => u.id === userId);

        if (userIndex === -1) {
            const error = new Error('Foydalanuvchi topilmadi');
            error.statusCode = 404;
            return next(error);
        }

        const deletedUser = users.splice(userIndex, 1)[0];
        stats.totalUsers = users.length;

        console.log('🗑️ Foydalanuvchi o\'chirildi:', deletedUser.id);

        res.json({
            success: true,
            message: 'Foydalanuvchi o\'chirildi',
            user: deletedUser,
        });
    } catch (error) {
        next(error);
    }
});

// Root
app.get('/', (req, res) => {
    res.json({
        name: 'GreenMarket MyID Backend',
        version: '4.0.0', // Foydalanuvchilar bazasi qo'shildi
        myid_host: MYID_HOST,
        total_users: users.length,
        endpoints: {
            health: 'GET /health',
            create_session: 'POST /api/myid/create-session',
            create_session_with_passport: 'POST /api/myid/create-session-with-passport',
            verify_passport: 'POST /api/myid/verify-passport',
            register_user: 'POST /api/users/register',
            get_users: 'GET /api/users',
            get_user: 'GET /api/users/:id',
            get_stats: 'GET /api/users/stats/summary',
            delete_user: 'DELETE /api/users/:id',
        },
    });
});

// ============================================
// ADMIN ENDPOINT'LAR
// ============================================

// Barcha ro'yxatdan o'tgan foydalanuvchilarni ko'rish
app.get('/api/myid/users', async (req, res) => {
    try {
        console.log('📊 Barcha foydalanuvchilar so\'ralmoqda...');

        const users = await MyIdUser.find({ deleted_at: null })
            .select('-face_image -passport_image') // Rasmlarni qaytarmaylik
            .sort({ registered_at: -1 });

        const totalCount = users.length;
        const todayCount = users.filter(u => {
            const today = new Date();
            const userDate = new Date(u.registered_at);
            return userDate.toDateString() === today.toDateString();
        }).length;

        console.log(`✅ ${totalCount} ta foydalanuvchi topildi (bugun: ${todayCount})`);

        res.json({
            success: true,
            data: {
                total: totalCount,
                today: todayCount,
                users: users,
            },
        });
    } catch (error) {
        console.error('❌ Foydalanuvchilarni olishda xato:', error);
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// Bitta foydalanuvchini ko'rish
app.get('/api/myid/users/:pinfl', async (req, res) => {
    try {
        const { pinfl } = req.params;

        console.log('📊 Foydalanuvchi so\'ralmoqda:', pinfl);

        const user = await MyIdUser.findOne({ pinfl: pinfl, deleted_at: null });

        if (!user) {
            return res.status(404).json({
                success: false,
                error: 'Foydalanuvchi topilmadi',
            });
        }

        console.log('✅ Foydalanuvchi topildi:', user._id);

        res.json({
            success: true,
            data: user,
        });
    } catch (error) {
        console.error('❌ Foydalanuvchini olishda xato:', error);
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// Statistika
app.get('/api/myid/stats', async (req, res) => {
    try {
        console.log('📊 Statistika so\'ralmoqda...');

        const totalUsers = await MyIdUser.countDocuments({ deleted_at: null });

        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const todayUsers = await MyIdUser.countDocuments({
            registered_at: { $gte: today },
            deleted_at: null,
        });

        const authMethods = await MyIdUser.aggregate([
            { $match: { deleted_at: null } },
            { $group: { _id: '$auth_method', count: { $sum: 1 } } },
        ]);

        console.log('✅ Statistika:', { totalUsers, todayUsers });

        res.json({
            success: true,
            data: {
                total_users: totalUsers,
                today_registrations: todayUsers,
                auth_methods: authMethods,
                last_updated: new Date(),
            },
        });
    } catch (error) {
        console.error('❌ Statistikani olishda xato:', error);
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

const PORT = process.env.PORT || 3000;

// 404 xatosi uchun middleware (barcha route'lardan keyin)
app.use(notFoundHandler);

// Xato handler middleware (eng oxirida)
app.use(errorHandler);

app.listen(PORT, () => {
    console.log(`🚀 Server ${PORT} portda ishlamoqda`);
    console.log(`🔗 MyID Host: ${MYID_HOST}`);
    console.log(`📊 Health: http://localhost:${PORT}/health`);
});

module.exports = app;
