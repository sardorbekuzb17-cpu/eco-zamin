/**
 * Token Cache Testlari
 * 
 * Bu test fayli token cache mexanizmini tekshiradi.
 * Requirements: 1.3, 1.5
 */

const {
    getAccessToken,
    getOrRefreshToken,
    clearTokenCache,
    isTokenValid,
} = require('../myid_sdk_flow');

// Mock axios
jest.mock('axios');
const axios = require('axios');

describe('Token Cache Mexanizmi', () => {
    beforeEach(() => {
        // Har bir test uchun cache'ni tozalaymiz
        clearTokenCache();
        jest.clearAllMocks();
    });

    describe('Token Saqlash va Olish', () => {
        test('yangi token olinishi va cache\'ga saqlanishi kerak', async () => {
            // Mock response
            axios.post.mockResolvedValue({
                data: {
                    access_token: 'test_token_123',
                    expires_in: 604800, // 7 kun
                    token_type: 'Bearer',
                },
            });

            const result = await getOrRefreshToken();

            expect(result.success).toBe(true);
            expect(result.access_token).toBe('test_token_123');
            expect(result.from_cache).toBe(false);
            expect(axios.post).toHaveBeenCalledTimes(1);
        });

        test('cache\'dan token olinishi kerak (ikkinchi so\'rovda)', async () => {
            // Mock response
            axios.post.mockResolvedValue({
                data: {
                    access_token: 'test_token_123',
                    expires_in: 604800,
                    token_type: 'Bearer',
                },
            });

            // Birinchi so'rov - yangi token
            const result1 = await getOrRefreshToken();
            expect(result1.from_cache).toBe(false);
            expect(axios.post).toHaveBeenCalledTimes(1);

            // Ikkinchi so'rov - cache'dan
            const result2 = await getOrRefreshToken();
            expect(result2.success).toBe(true);
            expect(result2.access_token).toBe('test_token_123');
            expect(result2.from_cache).toBe(true);
            expect(axios.post).toHaveBeenCalledTimes(1); // Hali ham 1 marta
        });

        test('cache\'ga saqlangan token isTokenValid() orqali tekshirilishi kerak', async () => {
            // Mock response
            axios.post.mockResolvedValue({
                data: {
                    access_token: 'test_token_123',
                    expires_in: 604800,
                    token_type: 'Bearer',
                },
            });

            // Boshida token yo'q
            expect(isTokenValid()).toBe(false);

            // Token olamiz
            await getOrRefreshToken();

            // Endi token mavjud va valid
            expect(isTokenValid()).toBe(true);
        });
    });

    describe('Token Muddati Tugashi', () => {
        test('muddati tugagan token avtomatik yangilanishi kerak', async () => {
            // Mock response - birinchi token
            axios.post.mockResolvedValueOnce({
                data: {
                    access_token: 'old_token',
                    expires_in: 1, // 1 sekund (tez tugaydi)
                    token_type: 'Bearer',
                },
            });

            // Birinchi token olamiz
            const result1 = await getOrRefreshToken();
            expect(result1.access_token).toBe('old_token');
            expect(result1.from_cache).toBe(false);

            // 2 sekund kutamiz (token muddati tugadi)
            await new Promise(resolve => setTimeout(resolve, 2000));

            // Mock response - yangi token
            axios.post.mockResolvedValueOnce({
                data: {
                    access_token: 'new_token',
                    expires_in: 604800,
                    token_type: 'Bearer',
                },
            });

            // Yangi token olinishi kerak
            const result2 = await getOrRefreshToken();
            expect(result2.access_token).toBe('new_token');
            expect(result2.from_cache).toBe(false);
            expect(axios.post).toHaveBeenCalledTimes(2);
        });

        test('isTokenValid() muddati tugagan token uchun false qaytarishi kerak', async () => {
            // Mock response - 10 daqiqalik token (buffer vaqtidan ko'proq)
            axios.post.mockResolvedValue({
                data: {
                    access_token: 'test_token',
                    expires_in: 600, // 10 daqiqa
                    token_type: 'Bearer',
                },
            });

            await getOrRefreshToken();
            expect(isTokenValid()).toBe(true);

            // Token cache'ni qo'lda muddati tugagan qilib o'zgartiramiz
            // Bu test uchun internal state'ni manipulyatsiya qilish kerak
            // Lekin bu yaxshi amaliyot emas, shuning uchun testni o'zgartiramiz

            // Mock response - 1 sekundlik token
            axios.post.mockResolvedValue({
                data: {
                    access_token: 'short_token',
                    expires_in: 1, // 1 sekund
                    token_type: 'Bearer',
                },
            });

            // Cache'ni tozalaymiz va yangi qisqa muddatli token olamiz
            clearTokenCache();
            await getOrRefreshToken();

            // 2 sekund kutamiz
            await new Promise(resolve => setTimeout(resolve, 2000));

            expect(isTokenValid()).toBe(false);
        });
    });

    describe('Xato Holatlarini Boshqarish', () => {
        test('token olishda xatolik yuz berganda to\'g\'ri xato qaytarishi kerak', async () => {
            // Mock error
            axios.post.mockRejectedValue({
                response: {
                    data: {
                        error: 'Invalid credentials',
                    },
                },
            });

            const result = await getOrRefreshToken();

            expect(result.success).toBe(false);
            expect(result.error).toBeDefined();
            expect(result.from_cache).toBe(false);
        }, 10000); // 10 soniya timeout (qayta urinish mexanizmi uchun)

        test('tarmoq xatosida to\'g\'ri xato qaytarishi kerak', async () => {
            // Mock network error
            axios.post.mockRejectedValue(new Error('Network Error'));

            const result = await getOrRefreshToken();

            expect(result.success).toBe(false);
            expect(result.error).toBe('Network Error');
        }, 10000); // 10 soniya timeout (qayta urinish mexanizmi uchun)
    });

    describe('Cache Tozalash', () => {
        test('clearTokenCache() cache\'ni to\'liq tozalashi kerak', async () => {
            // Mock response
            axios.post.mockResolvedValue({
                data: {
                    access_token: 'test_token',
                    expires_in: 604800,
                    token_type: 'Bearer',
                },
            });

            // Token olamiz
            await getOrRefreshToken();
            expect(isTokenValid()).toBe(true);

            // Cache'ni tozalaymiz
            clearTokenCache();
            expect(isTokenValid()).toBe(false);

            // Yangi token olinishi kerak
            const result = await getOrRefreshToken();
            expect(result.from_cache).toBe(false);
            expect(axios.post).toHaveBeenCalledTimes(2);
        });
    });
});
