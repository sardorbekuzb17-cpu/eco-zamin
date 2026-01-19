/**
 * MyID SDK Flow - MyID integratsiyasi uchun asosiy modul
 * 
 * Bu modul MyID API bilan to'g'ridan-to'g'ri integratsiya qiladi va quyidagi funksiyalarni taqdim etadi:
 * - OAuth 2.0 access token olish
 * - Sessiya yaratish (bo'sh yoki pasport ma'lumotlari bilan)
 * - Foydalanuvchi ma'lumotlarini olish
 * - Token cache boshqaruvi
 * - Qayta urinish mexanizmi (retry with exponential backoff)
 * - HTTPS protokoli validatsiyasi
 * 
 * @module myid_sdk_flow
 * @requires axios
 * @see {@link https://myid.uz/api/docs|MyID API Documentation}
 */

const axios = require('axios');

/**
 * MyID client ID - shartnomadan olingan
 * @constant {string}
 * @private
 */
const CLIENT_ID = 'quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v';

/**
 * MyID client secret - shartnomadan olingan
 * @constant {string}
 * @private
 */
const CLIENT_SECRET = 'JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP';

/**
 * MyID API host URL - production muhiti
 * @constant {string}
 * @private
 */
const MYID_HOST = 'https://api.myid.uz';

/**
 * URL HTTPS protokolini tekshirish
 * 
 * Bu funksiya berilgan URL HTTPS protokolidan foydalanishini ta'minlaydi.
 * Xavfsizlik talablariga muvofiq, faqat HTTPS protokoli qo'llab-quvvatlanadi.
 * 
 * @param {string} url - Tekshiriladigan URL
 * @throws {Error} Agar URL HTTPS bilan boshlanmasa yoki noto'g'ri formatda bo'lsa
 * @returns {boolean} URL to'g'ri bo'lsa true qaytaradi
 * @example
 * validateHttpsUrl('https://api.myid.uz'); // true
 * validateHttpsUrl('http://api.myid.uz'); // Error: Faqat HTTPS protokoli qo'llab-quvvatlanadi
 */
function validateHttpsUrl(url) {
    if (!url || typeof url !== 'string') {
        throw new Error('URL noto\'g\'ri formatda');
    }

    if (!url.startsWith('https://')) {
        throw new Error('Faqat HTTPS protokoli qo\'llab-quvvatlanadi. URL https:// bilan boshlanishi kerak');
    }

    return true;
}

// MYID_HOST ni validatsiya qilish
try {
    validateHttpsUrl(MYID_HOST);
    console.log('✅ MYID_HOST HTTPS protokolini ishlatmoqda:', MYID_HOST);
} catch (error) {
    console.error('❌ MYID_HOST xavfsizlik xatosi:', error.message);
    throw error;
}

/**
 * Qayta urinish konfiguratsiyasi
 * 
 * Eksponensial backoff algoritmi uchun standart sozlamalar.
 * Bu sozlamalar tarmoq xatoliklari va timeout holatlarida ishlatiladi.
 * 
 * @constant {Object}
 * @property {number} maxRetries - Maksimal qayta urinishlar soni (3 marta)
 * @property {number} initialDelay - Boshlang'ich kutish vaqti millisoniyalarda (1 soniya)
 * @property {number} maxDelay - Maksimal kutish vaqti millisoniyalarda (8 soniya)
 */
const RETRY_CONFIG = {
    maxRetries: 3,
    initialDelay: 1000, // 1 soniya
    maxDelay: 8000, // 8 soniya
};

/**
 * Eksponensial backoff bilan qayta urinish mexanizmi
 * 
 * Bu funksiya berilgan operatsiyani bajaradi va xatolik yuz berganda
 * eksponensial backoff algoritmi bilan qayta urinadi. Har bir urinishdan
 * keyin kutish vaqti ikki barobar oshadi.
 * 
 * Qayta urinish faqat quyidagi holatlarda amalga oshiriladi:
 * - Tarmoq xatoliklari (ECONNABORTED, ETIMEDOUT, ENOTFOUND)
 * - Timeout xatoliklari
 * - 5xx server xatolari
 * - 429 Too Many Requests
 * - 408 Request Timeout
 * 
 * @param {Function} operation - Bajarilishi kerak bo'lgan asinxron funksiya
 * @param {Object} [options={}] - Qayta urinish sozlamalari
 * @param {number} [options.maxRetries=3] - Maksimal qayta urinishlar soni
 * @param {number} [options.initialDelay=1000] - Boshlang'ich kutish vaqti (ms)
 * @param {number} [options.maxDelay=8000] - Maksimal kutish vaqti (ms)
 * @returns {Promise<*>} Operatsiya natijasi
 * @throws {Error} Barcha urinishlar muvaffaqiyatsiz bo'lsa oxirgi xatoni qaytaradi
 * @example
 * const result = await retryWithBackoff(
 *   async () => axios.get('https://api.myid.uz/endpoint'),
 *   { maxRetries: 3, initialDelay: 1000 }
 * );
 */
async function retryWithBackoff(operation, options = {}) {
    const maxRetries = options.maxRetries || RETRY_CONFIG.maxRetries;
    const initialDelay = options.initialDelay || RETRY_CONFIG.initialDelay;
    const maxDelay = options.maxDelay || RETRY_CONFIG.maxDelay;

    let lastError;

    for (let attempt = 0; attempt <= maxRetries; attempt++) {
        try {
            // Operatsiyani bajarish
            return await operation();
        } catch (error) {
            lastError = error;

            // Qayta urinish kerakmi tekshirish
            const shouldRetry = isRetryableError(error);

            if (!shouldRetry || attempt === maxRetries) {
                // Qayta urinish kerak emas yoki maksimal urinishlar tugadi
                throw error;
            }

            // Eksponensial backoff hisoblash
            const delay = Math.min(initialDelay * Math.pow(2, attempt), maxDelay);

            console.log(`⚠️ Xatolik yuz berdi (urinish ${attempt + 1}/${maxRetries + 1}). ${delay}ms kutilmoqda...`);
            console.log(`   Xato: ${error.message || error.response?.data?.message || 'Noma\'lum xato'}`);

            // Kutish
            await sleep(delay);
        }
    }

    // Agar bu yerga yetib kelsa, barcha urinishlar muvaffaqiyatsiz bo'lgan
    throw lastError;
}

/**
 * Xato qayta urinishga loyiqmi tekshirish
 * 
 * Bu funksiya xato turini tahlil qiladi va qayta urinish kerakligini aniqlaydi.
 * Tarmoq xatoliklari, timeout va 5xx server xatolari uchun qayta urinish tavsiya etiladi.
 * 4xx client xatolari (400, 401, 403, 404) uchun qayta urinish amalga oshirilmaydi.
 * 
 * @param {Error} error - Xato obyekti (axios error yoki oddiy Error)
 * @returns {boolean} Qayta urinish kerak bo'lsa true, aks holda false
 * @example
 * if (isRetryableError(error)) {
 *   // Qayta urinish
 * } else {
 *   // Xatoni qaytarish
 * }
 */
function isRetryableError(error) {
    // Tarmoq xatolari
    if (error.code === 'ECONNABORTED' || error.code === 'ETIMEDOUT' || error.code === 'ENOTFOUND') {
        return true;
    }

    // Timeout xatolari
    if (error.message && error.message.toLowerCase().includes('timeout')) {
        return true;
    }

    // HTTP status kodlari
    if (error.response) {
        const status = error.response.status;

        // 5xx server xatolari - qayta urinish kerak
        if (status >= 500 && status < 600) {
            return true;
        }

        // 429 Too Many Requests - qayta urinish kerak
        if (status === 429) {
            return true;
        }

        // 408 Request Timeout - qayta urinish kerak
        if (status === 408) {
            return true;
        }

        // 4xx client xatolari (401, 403, 404, 400) - qayta urinish kerak emas
        if (status >= 400 && status < 500) {
            return false;
        }
    }

    // Boshqa xatolar uchun qayta urinish
    return true;
}

/**
 * Kutish funksiyasi (sleep/delay)
 * 
 * Promise asosida ishlaydi va berilgan vaqt davomida kutadi.
 * Asosan qayta urinish mexanizmida kutish uchun ishlatiladi.
 * 
 * @param {number} ms - Millisoniyalarda kutish vaqti
 * @returns {Promise<void>} Kutish tugagandan keyin resolve bo'ladigan promise
 * @example
 * await sleep(1000); // 1 soniya kutish
 * console.log('1 soniya o\'tdi');
 */
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Token cache mexanizmi
 * 
 * Access token'ni xotirada saqlash va qayta ishlatish uchun ishlatiladi.
 * Token 7 kun amal qiladi, lekin 5 daqiqa oldin avtomatik yangilanadi.
 * 
 * @typedef {Object} TokenCache
 * @property {string|null} access_token - Saqlangan access token
 * @property {number|null} expires_at - Token muddati tugash vaqti (timestamp milliseconds)
 */
let tokenCache = {
    access_token: null,
    expires_at: null, // Timestamp (milliseconds)
};

/**
 * Token cache'ni tozalash
 * 
 * Test va debug maqsadlari uchun cache'ni tozalaydi.
 * Production muhitida odatda ishlatilmaydi.
 * 
 * @returns {void}
 */
function clearTokenCache() {
    tokenCache = {
        access_token: null,
        expires_at: null,
    };
}

/**
 * Token muddatini tekshirish
 * 
 * Cache'dagi token hali amal qiladimi yoki muddati tugaganmi tekshiradi.
 * 5 daqiqalik buffer vaqti qo'shiladi - token muddati tugashidan 5 daqiqa oldin
 * yangi token olish tavsiya etiladi.
 * 
 * @returns {boolean} Token amal qilsa true, aks holda false
 */
function isTokenValid() {
    if (!tokenCache.access_token || !tokenCache.expires_at) {
        return false;
    }

    // 5 daqiqa oldin yangilash (buffer)
    const bufferTime = 5 * 60 * 1000; // 5 daqiqa
    const now = Date.now();

    return now < (tokenCache.expires_at - bufferTime);
}

/**
 * Token'ni cache'ga saqlash
 * 
 * Access token va uning muddatini cache'ga saqlaydi.
 * Muddat timestamp formatida (milliseconds) hisoblanadi.
 * 
 * @param {string} accessToken - Saqlanishi kerak bo'lgan access token
 * @param {number} expiresIn - Token amal qilish muddati (sekundlarda, odatda 604800 = 7 kun)
 * @returns {void}
 */
function saveTokenToCache(accessToken, expiresIn) {
    const now = Date.now();
    tokenCache.access_token = accessToken;
    tokenCache.expires_at = now + (expiresIn * 1000); // expiresIn sekundlarda

    console.log('💾 Token cache\'ga saqlandi. Muddati:', new Date(tokenCache.expires_at).toISOString());
}

/**
 * Cache'dan token olish yoki yangi token olish
 * 
 * Agar cache'dagi token hali amal qilsa, uni qaytaradi.
 * Aks holda, MyID API'dan yangi token oladi va cache'ga saqlaydi.
 * Bu funksiya token boshqaruvini avtomatlashtiradi va har safar yangi token
 * olish zaruratini kamaytiradi.
 * 
 * @async
 * @returns {Promise<Object>} Token natijasi
 * @returns {boolean} returns.success - Operatsiya muvaffaqiyatlimi
 * @returns {string} [returns.access_token] - Access token (muvaffaqiyatli bo'lsa)
 * @returns {boolean} returns.from_cache - Token cache'dan olinganmi
 * @returns {string} [returns.error] - Xato xabari (muvaffaqiyatsiz bo'lsa)
 * @example
 * const result = await getOrRefreshToken();
 * if (result.success) {
 *   console.log('Token:', result.access_token);
 *   console.log('Cache\'dan:', result.from_cache);
 * }
 */
async function getOrRefreshToken() {
    if (isTokenValid()) {
        console.log('✅ Cache\'dan token ishlatilmoqda');
        return {
            success: true,
            access_token: tokenCache.access_token,
            from_cache: true,
        };
    }

    console.log('🔄 Token muddati tugagan yoki mavjud emas, yangi token olinmoqda...');
    const result = await getAccessToken();

    if (result.success) {
        saveTokenToCache(result.access_token, result.expires_in);
    }

    return {
        ...result,
        from_cache: false,
    };
}

/**
 * MyID'dan OAuth 2.0 access token olish
 * 
 * Bu funksiya MyID API'dan client credentials grant type orqali access token oladi.
 * Token 7 kun (604800 soniya) amal qiladi va barcha MyID API so'rovlari uchun
 * zarur. Xatolik yuz berganda qayta urinish mexanizmi avtomatik ishga tushadi.
 * 
 * @async
 * @returns {Promise<Object>} Token natijasi
 * @returns {boolean} returns.success - Operatsiya muvaffaqiyatlimi
 * @returns {string} [returns.access_token] - JWT access token (512+ belgi)
 * @returns {number} [returns.expires_in] - Token amal qilish muddati (sekundlarda, 604800 = 7 kun)
 * @returns {string} [returns.error] - Xato xabari yoki xato obyekti
 * @throws {Error} Barcha qayta urinishlar muvaffaqiyatsiz bo'lsa
 * @example
 * const result = await getAccessToken();
 * if (result.success) {
 *   console.log('Token olindi:', result.access_token);
 *   console.log('Muddat:', result.expires_in, 'soniya');
 * }
 */
async function getAccessToken() {
    try {
        console.log('📤 [1/4] Access token olinmoqda...');

        // HTTPS protokolini tekshirish
        const apiUrl = `${MYID_HOST}/api/v1/auth/clients/access-token`;
        validateHttpsUrl(apiUrl);

        const response = await retryWithBackoff(async () => {
            return await axios.post(
                apiUrl,
                {
                    client_id: CLIENT_ID,
                    client_secret: CLIENT_SECRET,
                },
                {
                    headers: { 'Content-Type': 'application/json' },
                    timeout: 10000, // 10 soniya timeout
                }
            );
        });

        console.log('✅ [1/4] Access token olindi');
        return {
            success: true,
            access_token: response.data.access_token,
            expires_in: response.data.expires_in,
        };
    } catch (error) {
        console.error('❌ Access token xatosi:', error.response?.data || error.message);
        return {
            success: false,
            error: error.response?.data || error.message,
        };
    }
}

/**
 * MyID sessiyasi yaratish
 * 
 * Bu funksiya MyID SDK uchun sessiya yaratadi. Sessiya bo'sh (pasport ma'lumotlarisiz)
 * yoki pasport ma'lumotlari bilan yaratilishi mumkin.
 * 
 * Bo'sh sessiya: SDK o'zi foydalanuvchidan pasport ma'lumotlarini so'raydi
 * Pasport bilan sessiya: SDK foydalanuvchidan faqat yuz rasmini oladi
 * 
 * @async
 * @param {string} accessToken - MyID access token (getAccessToken'dan olingan)
 * @param {Object} [passportData={}] - Pasport ma'lumotlari (ixtiyoriy)
 * @param {string} [passportData.pass_data] - Pasport seriyasi va raqami (masalan: "AA1234567")
 * @param {string} [passportData.pinfl] - PINFL (14 raqam)
 * @param {string} [passportData.birth_date] - Tug'ilgan sana (YYYY-MM-DD)
 * @param {string} [passportData.phone_number] - Telefon raqami (+998901234567)
 * @param {boolean} [passportData.is_resident] - Rezidentmi (standart: true)
 * @param {number} [passportData.threshold] - Yuz tanish aniqlik darajasi (0.5 - 0.99)
 * @returns {Promise<Object>} Sessiya natijasi
 * @returns {boolean} returns.success - Operatsiya muvaffaqiyatlimi
 * @returns {string} [returns.session_id] - Sessiya ID (SDK uchun zarur)
 * @returns {number} [returns.expires_in] - Sessiya amal qilish muddati (sekundlarda, odatda 3600 = 1 soat)
 * @returns {string} [returns.error] - Xato xabari
 * @example
 * // Bo'sh sessiya
 * const result = await createSession(accessToken);
 * 
 * // Pasport bilan sessiya
 * const result = await createSession(accessToken, {
 *   pass_data: 'AA1234567',
 *   birth_date: '1990-01-01'
 * });
 */
async function createSession(accessToken, passportData = {}) {
    try {
        console.log('📤 [2/4] Session yaratilmoqda (Empty Session)...');

        // HTTPS protokolini tekshirish
        const apiUrl = `${MYID_HOST}/api/v2/sdk/sessions`;
        validateHttpsUrl(apiUrl);

        // BO'SH SESSIYA - SDK o'zi pasport ekranini ko'rsatadi
        const requestBody = {};

        // Faqat berilgan parametrlarni qo'shamiz (ixtiyoriy)
        if (passportData.pass_data) requestBody.pass_data = passportData.pass_data;
        if (passportData.pinfl) requestBody.pinfl = passportData.pinfl;
        if (passportData.birth_date) requestBody.birth_date = passportData.birth_date;
        if (passportData.phone_number) requestBody.phone_number = passportData.phone_number;
        if (passportData.is_resident !== undefined) requestBody.is_resident = passportData.is_resident;
        if (passportData.threshold) requestBody.threshold = passportData.threshold;

        console.log('📤 Request body:', Object.keys(requestBody).length === 0 ? 'BO\'SH {}' : requestBody);

        const response = await retryWithBackoff(async () => {
            return await axios.post(
                apiUrl,
                requestBody,
                {
                    headers: {
                        'Authorization': `Bearer ${accessToken}`,
                        'Content-Type': 'application/json',
                    },
                    timeout: 10000, // 10 soniya timeout
                }
            );
        });

        console.log('✅ [2/4] Session yaratildi:', response.data.data.session_id);
        return {
            success: true,
            session_id: response.data.data.session_id,
            expires_in: response.data.data.expires_in,
        };
    } catch (error) {
        console.error('❌ Session yaratish xatosi:', error.response?.data || error.message);
        return {
            success: false,
            error: error.response?.data || error.message,
        };
    }
}

/**
 * Foydalanuvchi ma'lumotlarini olish
 * 
 * MyID SDK'dan olingan code yordamida foydalanuvchi shaxsiy ma'lumotlarini oladi.
 * Bu funksiya SDK yuz tanish jarayonidan keyin chaqiriladi.
 * 
 * @async
 * @param {string} accessToken - MyID access token
 * @param {string} code - MyID SDK'dan olingan natija kodi
 * @returns {Promise<Object>} Foydalanuvchi ma'lumotlari natijasi
 * @returns {boolean} returns.success - Operatsiya muvaffaqiyatlimi
 * @returns {Object} [returns.data] - Foydalanuvchi ma'lumotlari
 * @returns {Object} [returns.data.profile] - Foydalanuvchi profili
 * @returns {string} [returns.data.profile.first_name] - Ism
 * @returns {string} [returns.data.profile.last_name] - Familiya
 * @returns {string} [returns.data.profile.middle_name] - Otasining ismi
 * @returns {string} [returns.data.profile.birth_date] - Tug'ilgan sana
 * @returns {string} [returns.data.profile.pinfl] - PINFL
 * @returns {string} [returns.data.profile.pass_data] - Pasport ma'lumotlari
 * @returns {number} [returns.data.comparison_value] - Yuz tanish aniqlik darajasi (0.0 - 1.0)
 * @returns {string} [returns.error] - Xato xabari
 * @example
 * const result = await retrieveUserData(accessToken, 'xyz789...');
 * if (result.success) {
 *   console.log('Ism:', result.data.profile.first_name);
 *   console.log('Aniqlik:', result.data.comparison_value);
 * }
 */
async function retrieveUserData(accessToken, code) {
    try {
        console.log('📤 [4/4] Foydalanuvchi ma\'lumotlari olinmoqda...');

        // HTTPS protokolini tekshirish
        const apiUrl = `${MYID_HOST}/api/v1/sdk/data?code=${code}`;
        validateHttpsUrl(apiUrl);

        const response = await retryWithBackoff(async () => {
            return await axios.get(
                apiUrl,
                {
                    headers: {
                        'Authorization': `Bearer ${accessToken}`,
                        'Content-Type': 'application/json',
                    },
                    timeout: 10000, // 10 soniya timeout
                }
            );
        });

        console.log('✅ [4/4] Foydalanuvchi ma\'lumotlari olindi');
        return {
            success: true,
            data: response.data.data,
        };
    } catch (error) {
        console.error('❌ Foydalanuvchi ma\'lumotlari xatosi:', error.response?.data || error.message);
        return {
            success: false,
            error: error.response?.data || error.message,
        };
    }
}

/**
 * To'liq MyID SDK oqimi
 * 
 * Bu funksiya to'liq MyID autentifikatsiya jarayonini amalga oshiradi:
 * 1. Access token olish (cache'dan yoki yangi)
 * 2. Sessiya yaratish (bo'sh yoki pasport bilan)
 * 3. SDK ishga tushadi (mobile'da) - bu qadamni mobile app bajaradi
 * 4. Code bilan foydalanuvchi ma'lumotlarini olish (agar code berilgan bo'lsa)
 * 
 * @async
 * @param {Object} [passportData={}] - Pasport ma'lumotlari (ixtiyoriy)
 * @param {string} [passportData.pass_data] - Pasport seriyasi va raqami
 * @param {string} [passportData.pinfl] - PINFL
 * @param {string} [passportData.birth_date] - Tug'ilgan sana
 * @param {string} [passportData.phone_number] - Telefon raqami
 * @param {boolean} [passportData.is_resident] - Rezidentmi
 * @param {number} [passportData.threshold] - Yuz tanish aniqlik darajasi
 * @param {string} [code] - MyID SDK'dan olingan code (ixtiyoriy, SDK tugagandan keyin)
 * @returns {Promise<Object>} To'liq oqim natijasi
 * @returns {boolean} returns.success - Operatsiya muvaffaqiyatlimi
 * @returns {string} [returns.session_id] - Sessiya ID
 * @returns {Object} [returns.user_data] - Foydalanuvchi ma'lumotlari (agar code berilgan bo'lsa)
 * @returns {string} [returns.message] - Holat xabari
 * @returns {string} [returns.error] - Xato xabari
 * @example
 * // Bo'sh sessiya yaratish
 * const result = await completeSdkFlow();
 * console.log('Session ID:', result.session_id);
 * 
 * // Code bilan to'liq oqim
 * const result = await completeSdkFlow({}, 'code_from_sdk');
 * console.log('Foydalanuvchi:', result.user_data.profile.first_name);
 */
async function completeSdkFlow(passportData = {}, code) {
    try {
        console.log('🚀 SDK Flow boshlandi (Empty Session)...');

        // 1. Access token olish (cache'dan yoki yangi)
        const tokenResult = await getOrRefreshToken();
        if (!tokenResult.success) {
            return { success: false, error: 'Access token olishda xatolik', details: tokenResult };
        }

        const accessToken = tokenResult.access_token;

        // 2. BO'SH Session yaratish (SDK o'zi pasport so'raydi)
        const sessionResult = await createSession(accessToken, passportData);
        if (!sessionResult.success) {
            return { success: false, error: 'Session yaratishda xatolik', details: sessionResult };
        }

        const sessionId = sessionResult.session_id;

        // 3. SDK ishga tushadi (mobile'da) va code qaytaradi
        console.log('⏳ [3/4] SDK ishga tushmoqda (mobile\'da)...');
        console.log('📱 Session ID mobile\'ga yuborildi:', sessionId);
        console.log('📱 SDK o\'zi pasport ekranini ko\'rsatadi');

        // 4. Code bilan foydalanuvchi ma'lumotlarini olish
        if (code) {
            const userDataResult = await retrieveUserData(accessToken, code);
            if (!userDataResult.success) {
                return { success: false, error: 'Foydalanuvchi ma\'lumotlarini olishda xatolik', details: userDataResult };
            }

            console.log('✅ SDK Flow muvaffaqiyatli yakunlandi!');
            return {
                success: true,
                session_id: sessionId,
                user_data: userDataResult.data,
            };
        }

        // Agar code yo'q bo'lsa, faqat session_id qaytaramiz
        return {
            success: true,
            session_id: sessionId,
            message: 'BO\'SH session yaratildi, SDK o\'zi pasport so\'raydi',
        };
    } catch (error) {
        console.error('❌ SDK Flow xatosi:', error);
        return {
            success: false,
            error: error.message,
        };
    }
}

module.exports = {
    getAccessToken,
    createSession,
    retrieveUserData,
    completeSdkFlow,
    getOrRefreshToken,
    clearTokenCache,
    isTokenValid,
    retryWithBackoff,
    isRetryableError,
    sleep,
    validateHttpsUrl,
};
