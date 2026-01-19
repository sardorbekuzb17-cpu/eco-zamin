/**
 * Qayta Urinish Mexanizmi Testlari
 * 
 * Bu test fayli qayta urinish mexanizmini tekshiradi.
 * Requirements: 6.2
 */

const {
    retryWithBackoff,
    isRetryableError,
    sleep,
} = require('../myid_sdk_flow');

describe('Qayta Urinish Mexanizmi', () => {
    describe('retryWithBackoff funksiyasi', () => {
        test('muvaffaqiyatli operatsiya birinchi urinishda ishlashi kerak', async () => {
            const mockOperation = jest.fn().mockResolvedValue('success');

            const result = await retryWithBackoff(mockOperation);

            expect(result).toBe('success');
            expect(mockOperation).toHaveBeenCalledTimes(1);
        });

        test('timeout xatosida maksimal 3 marta qayta urinishi kerak', async () => {
            const mockOperation = jest.fn()
                .mockRejectedValueOnce({ code: 'ETIMEDOUT', message: 'Timeout' })
                .mockRejectedValueOnce({ code: 'ETIMEDOUT', message: 'Timeout' })
                .mockResolvedValueOnce('success');

            const result = await retryWithBackoff(mockOperation, {
                maxRetries: 3,
                initialDelay: 10, // Test uchun qisqa vaqt
            });

            expect(result).toBe('success');
            expect(mockOperation).toHaveBeenCalledTimes(3);
        });

        test('3 marta muvaffaqiyatsiz urinishdan keyin xato qaytarishi kerak', async () => {
            const mockOperation = jest.fn()
                .mockRejectedValue({ code: 'ETIMEDOUT', message: 'Timeout' });

            await expect(
                retryWithBackoff(mockOperation, {
                    maxRetries: 3,
                    initialDelay: 10,
                })
            ).rejects.toEqual({ code: 'ETIMEDOUT', message: 'Timeout' });

            expect(mockOperation).toHaveBeenCalledTimes(4); // 1 + 3 qayta urinish
        });

        test('eksponensial backoff to\'g\'ri ishlashi kerak', async () => {
            const delays = [];
            const mockOperation = jest.fn()
                .mockRejectedValueOnce({ code: 'ETIMEDOUT' })
                .mockRejectedValueOnce({ code: 'ETIMEDOUT' })
                .mockResolvedValueOnce('success');

            const startTime = Date.now();

            await retryWithBackoff(mockOperation, {
                maxRetries: 3,
                initialDelay: 100, // 100ms
                maxDelay: 1000,
            });

            const totalTime = Date.now() - startTime;

            // Kutilgan vaqt: 100ms (1-chi qayta urinish) + 200ms (2-chi qayta urinish) = 300ms
            // Biroz buffer qo'shamiz (±50ms)
            expect(totalTime).toBeGreaterThanOrEqual(250);
            expect(totalTime).toBeLessThan(500);
        });

        test('maxDelay chegarasini oshirmasligi kerak', async () => {
            const mockOperation = jest.fn()
                .mockRejectedValueOnce({ code: 'ETIMEDOUT' })
                .mockRejectedValueOnce({ code: 'ETIMEDOUT' })
                .mockRejectedValueOnce({ code: 'ETIMEDOUT' })
                .mockResolvedValueOnce('success');

            const startTime = Date.now();

            await retryWithBackoff(mockOperation, {
                maxRetries: 3,
                initialDelay: 100,
                maxDelay: 150, // Maksimal 150ms
            });

            const totalTime = Date.now() - startTime;

            // Kutilgan vaqt: 100ms + 150ms (maxDelay) + 150ms (maxDelay) = 400ms
            expect(totalTime).toBeGreaterThanOrEqual(350);
            expect(totalTime).toBeLessThan(600);
        });

        test('qayta urinishga loyiq bo\'lmagan xatoda darhol to\'xtashi kerak', async () => {
            const mockOperation = jest.fn()
                .mockRejectedValue({
                    response: { status: 400 },
                    message: 'Bad Request',
                });

            await expect(
                retryWithBackoff(mockOperation, {
                    maxRetries: 3,
                    initialDelay: 10,
                })
            ).rejects.toEqual({
                response: { status: 400 },
                message: 'Bad Request',
            });

            expect(mockOperation).toHaveBeenCalledTimes(1); // Faqat 1 marta
        });
    });

    describe('isRetryableError funksiyasi', () => {
        test('ETIMEDOUT xatosi uchun true qaytarishi kerak', () => {
            const error = { code: 'ETIMEDOUT', message: 'Timeout' };
            expect(isRetryableError(error)).toBe(true);
        });

        test('ECONNABORTED xatosi uchun true qaytarishi kerak', () => {
            const error = { code: 'ECONNABORTED', message: 'Connection aborted' };
            expect(isRetryableError(error)).toBe(true);
        });

        test('ENOTFOUND xatosi uchun true qaytarishi kerak', () => {
            const error = { code: 'ENOTFOUND', message: 'Not found' };
            expect(isRetryableError(error)).toBe(true);
        });

        test('timeout xabarli xato uchun true qaytarishi kerak', () => {
            const error = { message: 'Request timeout occurred' };
            expect(isRetryableError(error)).toBe(true);
        });

        test('5xx server xatolari uchun true qaytarishi kerak', () => {
            expect(isRetryableError({ response: { status: 500 } })).toBe(true);
            expect(isRetryableError({ response: { status: 502 } })).toBe(true);
            expect(isRetryableError({ response: { status: 503 } })).toBe(true);
            expect(isRetryableError({ response: { status: 504 } })).toBe(true);
        });

        test('429 Too Many Requests uchun true qaytarishi kerak', () => {
            const error = { response: { status: 429 } };
            expect(isRetryableError(error)).toBe(true);
        });

        test('408 Request Timeout uchun true qaytarishi kerak', () => {
            const error = { response: { status: 408 } };
            expect(isRetryableError(error)).toBe(true);
        });

        test('400 Bad Request uchun false qaytarishi kerak', () => {
            const error = { response: { status: 400 } };
            expect(isRetryableError(error)).toBe(false);
        });

        test('401 Unauthorized uchun false qaytarishi kerak', () => {
            const error = { response: { status: 401 } };
            expect(isRetryableError(error)).toBe(false);
        });

        test('403 Forbidden uchun false qaytarishi kerak', () => {
            const error = { response: { status: 403 } };
            expect(isRetryableError(error)).toBe(false);
        });

        test('404 Not Found uchun false qaytarishi kerak', () => {
            const error = { response: { status: 404 } };
            expect(isRetryableError(error)).toBe(false);
        });

        test('noma\'lum xato uchun true qaytarishi kerak (xavfsizlik uchun)', () => {
            const error = { message: 'Unknown error' };
            expect(isRetryableError(error)).toBe(true);
        });
    });

    describe('sleep funksiyasi', () => {
        test('berilgan vaqt davomida kutishi kerak', async () => {
            const startTime = Date.now();
            await sleep(100);
            const endTime = Date.now();

            const elapsed = endTime - startTime;
            expect(elapsed).toBeGreaterThanOrEqual(90); // 10ms buffer
            expect(elapsed).toBeLessThan(150);
        });

        test('0ms uchun darhol qaytishi kerak', async () => {
            const startTime = Date.now();
            await sleep(0);
            const endTime = Date.now();

            const elapsed = endTime - startTime;
            expect(elapsed).toBeLessThan(20); // JavaScript timer'lari aniq emas, 20ms buffer
        });
    });

    describe('Integratsiya testlari', () => {
        test('tarmoq xatosida qayta urinish va muvaffaqiyatli bo\'lish', async () => {
            let attemptCount = 0;
            const mockOperation = jest.fn(async () => {
                attemptCount++;
                if (attemptCount < 3) {
                    throw { code: 'ECONNABORTED', message: 'Connection aborted' };
                }
                return 'success after retries';
            });

            const result = await retryWithBackoff(mockOperation, {
                maxRetries: 3,
                initialDelay: 10,
            });

            expect(result).toBe('success after retries');
            expect(attemptCount).toBe(3);
        });

        test('aralash xatolar bilan ishlash', async () => {
            const mockOperation = jest.fn()
                .mockRejectedValueOnce({ response: { status: 503 } }) // Qayta urinish
                .mockRejectedValueOnce({ code: 'ETIMEDOUT' }) // Qayta urinish
                .mockResolvedValueOnce('success');

            const result = await retryWithBackoff(mockOperation, {
                maxRetries: 3,
                initialDelay: 10,
            });

            expect(result).toBe('success');
            expect(mockOperation).toHaveBeenCalledTimes(3);
        });

        test('maksimal urinishlar soniga yetganda oxirgi xatoni qaytarishi kerak', async () => {
            const errors = [
                { code: 'ETIMEDOUT', message: 'Timeout 1' },
                { code: 'ETIMEDOUT', message: 'Timeout 2' },
                { code: 'ETIMEDOUT', message: 'Timeout 3' },
                { code: 'ETIMEDOUT', message: 'Timeout 4' },
            ];

            let attemptCount = 0;
            const mockOperation = jest.fn(async () => {
                throw errors[attemptCount++];
            });

            await expect(
                retryWithBackoff(mockOperation, {
                    maxRetries: 3,
                    initialDelay: 10,
                })
            ).rejects.toEqual({ code: 'ETIMEDOUT', message: 'Timeout 4' });

            expect(attemptCount).toBe(4); // 1 + 3 qayta urinish
        });
    });
});
