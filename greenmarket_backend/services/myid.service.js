/**
 * MyID Service
 * 
 * MyID API bilan integratsiya uchun asosiy servis.
 * Token boshqaruvi, sessiya yaratish va foydalanuvchi ma'lumotlarini olish.
 */

const axios = require('axios');
const config = require('../config/myid.config');

// Token cache (in-memory)
let tokenCache = {
    access_token: null,
    expires_at: null,
};

/**
 * Access token olish
 * MyID API'ga POST so'rov yuboradi va access token oladi
 * 
 * @returns {Promise<{success: boolean, access_token?: string, expires_in?: number, error?: string}>}
 */
async function getAccessToken() {
    try {
        // Agar token cache'da mavjud va muddati tugamagan bo'lsa, uni qaytarish
        if (tokenCache.access_token && tokenCache.expires_at > Date.now()) {
            const remainingTime = Math.floor((tokenCache.expires_at - Date.now()) / 1000);
            console.log(`✅ Token cache'dan olindi (${remainingTime}s qoldi)`);

            return {
                success: true,
                access_token: tokenCache.access_token,
                expires_in: remainingTime,
            };
        }

        console.log('📤 Access token so\'ralmoqda...');

        // MyID API'ga so'rov yuborish
        const response = await axios.post(
            `${config.myidHost}${config.endpoints.accessToken}`,
            {
                client_id: config.clientId,
                client_secret: config.clientSecret,
            },
            {
                headers: {
                    'Content-Type': 'application/json',
                },
            }
        );

        const { access_token, expires_in, token_type } = response.data;

        // Token'ni cache'ga saqlash
        tokenCache = {
            access_token,
            expires_at: Date.now() + (expires_in * 1000),
        };

        console.log(`✅ Access token olindi (${expires_in}s amal qiladi)`);

        return {
            success: true,
            access_token,
            expires_in,
            token_type,
        };
    } catch (error) {
        console.error('❌ Access token olishda xatolik:', {
            status: error.response?.status,
            data: error.response?.data,
            message: error.message,
        });

        return {
            success: false,
            error: error.response?.data || error.message,
        };
    }
}

/**
 * Token cache'ni tozalash
 * Test va debug uchun
 */
function clearTokenCache() {
    tokenCache = {
        access_token: null,
        expires_at: null,
    };
    console.log('🗑️ Token cache tozalandi');
}

/**
 * Token cache holatini olish
 * Test va debug uchun
 */
function getTokenCacheStatus() {
    if (!tokenCache.access_token) {
        return {
            cached: false,
            message: 'Token cache bo\'sh',
        };
    }

    const remainingTime = Math.floor((tokenCache.expires_at - Date.now()) / 1000);
    const isValid = tokenCache.expires_at > Date.now();

    return {
        cached: true,
        valid: isValid,
        expires_in: remainingTime,
        expires_at: new Date(tokenCache.expires_at).toISOString(),
    };
}

module.exports = {
    getAccessToken,
    clearTokenCache,
    getTokenCacheStatus,
};
