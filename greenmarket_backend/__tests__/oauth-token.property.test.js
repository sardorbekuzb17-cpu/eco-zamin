/**
 * OAuth Token Property-Based Testlari
 * 
 * Feature: myid-integration-v2
 * Property 1: OAuth Token Olish va Saqlash
 * 
 * Har qanday to'g'ri client_id va client_secret bilan, backend access token olishi,
 * uni xavfsiz saqlashi va 7 kun davomida qayta ishlatishi kerak.
 * Token muddati tugaganda avtomatik yangilanishi kerak.
 * 
 * Validates: Requirements 1.1, 1.2, 1.3, 1.5
 */

const fc = require('fast-check');
const {
    getAccessToken,
    getOrRefreshToken,
    clearTokenCache,
    isTokenValid,
} = require('../myid_sdk_flow');

// Mock axios
jest.mock('axios');
const axios = require('axios');

describe('Property-Based Tests: OAuth Token', () => {
    beforeEach(() => {
        clearTokenCache();
        jest.clearAllMocks();
        // Axios mock'ni reset qilish
        axios.post.mockReset();
    });

    afterEach(() => {
        clearTokenCache();
        jest.clearAllMocks();
    });

    describe('Property 1: OAuth Token Olish va Saqlash', () => {
        /**
         * Property: Token olish va saqlash
         * 
         * Har qanday muvaffaqiyatli token olish so'rovida:
         * 1. Backend access_token olishi kerak
         * 2. Token expires_in bilan qaytishi kerak
         * 3. Token cache'ga saqlanishi kerak
         * 4. Keyingi so'rovda cache'dan token ishlatilishi kerak
         */
        test('har qanday muvaffaqiyatli token olishda token cache\'ga saqlanishi va qayta ishlatilishi kerak', async () => {
            await fc.assert(
                fc.asyncProperty(
                    // Token ma'lumotlarini generate qilamiz (base64 string)
                    fc.record({
                        access_token: fc.base64String({ minLength: 20, maxLength: 100 }),
                        expires_in: fc.integer({ min: 3600, max: 604800 }), // 1 soatdan 7 kungacha (60 sekund juda qisqa)
                        token_type: fc.constant('Bearer'),
                    }),
                    async (tokenData) => {
                        // Har bir iteratsiya uchun cache'ni tozalash
                        clearTokenCache();
                        jest.clearAllMocks();
                        axios.post.mockReset();

                        // Mock response - har safar bir xil tokenni qaytarish
                        axios.post.mockResolvedValue({
                            data: tokenData,
                        });

                        // 1. Token olish
                        const result1 = await getOrRefreshToken();

                        // Tekshirish: Token muvaffaqiyatli olingan
                        expect(result1.success).toBe(true);
                        expect(result1.access_token).toBe(tokenData.access_token);
                        expect(result1.from_cache).toBe(false);

                        // Tekshirish: Token cache'ga saqlangan
                        expect(isTokenValid()).toBe(true);

                        // 2. Ikkinchi so'rov - cache'dan olish
                        const result2 = await getOrRefreshToken();

                        // Tekshirish: Token cache'dan olingan
                        expect(result2.success).toBe(true);
                        expect(result2.access_token).toBe(tokenData.access_token);
                        expect(result2.from_cache).toBe(true);

                        // Tekshirish: Faqat 1 marta API chaqirilgan
                        expect(axios.post).toHaveBeenCalledTimes(1);
                    }
                ),
                { numRuns: 100 } // 100 iteratsiya
            );
        });

        /**
         * Property: Token muddati tugashi va avtomatik yangilanish
         * 
         * Har qanday muddati tugagan token uchun:
         * 1. isTokenValid() false qaytarishi kerak
         * 2. getOrRefreshToken() yangi token olishi kerak
         * 3. Yangi token cache'ga saqlanishi kerak
         */
        test('muddati tugagan token avtomatik yangilanishi kerak', async () => {
            await fc.assert(
                fc.asyncProperty(
                    // Eski va yangi token ma'lumotlarini generate qilamiz
                    fc.tuple(
                        fc.record({
                            access_token: fc.base64String({ minLength: 20, maxLength: 50 }),
                            expires_in: fc.constant(1), // 1 sekund (tez tugaydi)
                            token_type: fc.constant('Bearer'),
                        }),
                        fc.record({
                            access_token: fc.base64String({ minLength: 20, maxLength: 50 }),
                            expires_in: fc.integer({ min: 3600, max: 604800 }),
                            token_type: fc.constant('Bearer'),
                        })
                    ),
                    async ([oldToken, newToken]) => {
                        // Har bir iteratsiya uchun cache'ni tozalash
                        clearTokenCache();
                        jest.clearAllMocks();

                        // Eski va yangi tokenlar farqli bo'lishi kerak
                        fc.pre(oldToken.access_token !== newToken.access_token);

                        // Mock response - eski token
                        axios.post.mockResolvedValueOnce({
                            data: oldToken,
                        });

                        // 1. Eski token olish
                        const result1 = await getOrRefreshToken();
                        expect(result1.access_token).toBe(oldToken.access_token);
                        expect(result1.from_cache).toBe(false);

                        // 2 sekund kutish (token muddati tugadi)
                        await new Promise(resolve => setTimeout(resolve, 2000));

                        // Tekshirish: Token muddati tugagan
                        expect(isTokenValid()).toBe(false);

                        // Mock response - yangi token
                        axios.post.mockResolvedValueOnce({
                            data: newToken,
                        });

                        // 2. Yangi token olish
                        const result2 = await getOrRefreshToken();

                        // Tekshirish: Yangi token olingan
                        expect(result2.access_token).toBe(newToken.access_token);
                        expect(result2.from_cache).toBe(false);

                        // Tekshirish: 2 marta API chaqirilgan
                        expect(axios.post).toHaveBeenCalledTimes(2);

                        // Tekshirish: Yangi token cache'ga saqlangan
                        expect(isTokenValid()).toBe(true);
                    }
                ),
                { numRuns: 50 } // 50 iteratsiya (timeout tufayli kamroq)
            );
        }, 120000); // 2 daqiqa timeout

        /**
         * Property: Token xavfsiz saqlash
         * 
         * Har qanday token olishda:
         * 1. Token cache'da saqlanishi kerak
         * 2. Token muddati (expires_at) to'g'ri hisoblanishi kerak
         * 3. Cache'ni tozalash token'ni o'chirishi kerak
         */
        test('token xavfsiz cache\'da saqlanishi va tozalanishi kerak', async () => {
            await fc.assert(
                fc.asyncProperty(
                    fc.record({
                        access_token: fc.base64String({ minLength: 20, maxLength: 100 }),
                        expires_in: fc.integer({ min: 3600, max: 604800 }),
                        token_type: fc.constant('Bearer'),
                    }),
                    async (tokenData) => {
                        // Har bir iteratsiya uchun tozalash
                        clearTokenCache();
                        jest.clearAllMocks();
                        axios.post.mockReset();

                        // Mock response
                        axios.post.mockResolvedValue({
                            data: tokenData,
                        });

                        // 1. Token olish
                        await getOrRefreshToken();

                        // Tekshirish: Token cache'da
                        expect(isTokenValid()).toBe(true);

                        // 2. Cache'ni tozalash
                        clearTokenCache();

                        // Tekshirish: Token o'chirilgan
                        expect(isTokenValid()).toBe(false);

                        // 3. Yangi token olish
                        const result = await getOrRefreshToken();

                        // Tekshirish: Yangi token olingan (cache'dan emas)
                        expect(result.from_cache).toBe(false);
                        expect(axios.post).toHaveBeenCalledTimes(2);
                    }
                ),
                { numRuns: 100 }
            );
        });

        /**
         * Property: Token 7 kun amal qilishi
         * 
         * Har qanday token uchun:
         * 1. expires_in 604800 sekund (7 kun) bo'lishi kerak
         * 2. Token 7 kun davomida valid bo'lishi kerak
         */
        test('token 7 kun davomida amal qilishi kerak', async () => {
            await fc.assert(
                fc.asyncProperty(
                    fc.record({
                        access_token: fc.base64String({ minLength: 20, maxLength: 100 }),
                        expires_in: fc.constant(604800), // 7 kun
                        token_type: fc.constant('Bearer'),
                    }),
                    async (tokenData) => {
                        // Har bir iteratsiya uchun tozalash
                        clearTokenCache();
                        jest.clearAllMocks();
                        axios.post.mockReset();

                        // Mock response
                        axios.post.mockResolvedValue({
                            data: tokenData,
                        });

                        // Token olish
                        const result = await getOrRefreshToken();

                        // Tekshirish: Token 7 kun amal qiladi
                        expect(result.success).toBe(true);
                        expect(result.access_token).toBe(tokenData.access_token);
                        expect(result.expires_in).toBe(604800);

                        // Tekshirish: Token hozir valid
                        expect(isTokenValid()).toBe(true);

                        // Tekshirish: Token cache'dan qayta ishlatiladi
                        const result2 = await getOrRefreshToken();
                        expect(result2.from_cache).toBe(true);
                        expect(result2.access_token).toBe(tokenData.access_token);
                        expect(axios.post).toHaveBeenCalledTimes(1);
                    }
                ),
                { numRuns: 100 }
            );
        });

        /**
         * Property: Xato holatlarini boshqarish
         * 
         * Har qanday xato holatida:
         * 1. success: false qaytarishi kerak
         * 2. error ma'lumoti bo'lishi kerak
         * 3. Token cache'ga saqlanmasligi kerak
         */
        test('xato holatlarida token cache\'ga saqlanmasligi kerak', async () => {
            await fc.assert(
                fc.asyncProperty(
                    fc.record({
                        error: fc.base64String({ minLength: 10, maxLength: 50 }),
                        error_description: fc.base64String({ minLength: 20, maxLength: 100 }),
                    }),
                    async (errorData) => {
                        // Har bir iteratsiya uchun tozalash
                        clearTokenCache();
                        jest.clearAllMocks();
                        axios.post.mockReset();

                        // Mock error response - qayta urinishlarni kamaytirish uchun
                        axios.post.mockRejectedValue({
                            response: {
                                data: errorData,
                            },
                        });

                        // Token olishga urinish
                        const result = await getOrRefreshToken();

                        // Tekshirish: Xato qaytarilgan
                        expect(result.success).toBe(false);
                        expect(result.error).toBeDefined();
                        expect(result.from_cache).toBe(false);

                        // Tekshirish: Token cache'ga saqlanmagan
                        expect(isTokenValid()).toBe(false);

                        // Tekshirish: Qayta urinish mexanizmi ishlagan (1 asl + 3 retry = 4)
                        expect(axios.post).toHaveBeenCalledTimes(4);
                    }
                ),
                { numRuns: 20 } // Kamroq iteratsiya (timeout oldini olish uchun)
            );
        }, 180000); // 3 daqiqa timeout (qayta urinish mexanizmi uchun)
    });
});
