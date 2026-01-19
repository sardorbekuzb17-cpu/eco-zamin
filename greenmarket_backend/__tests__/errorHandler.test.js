/**
 * Xato Handler Middleware Unit Testlari
 * Requirements: 1.4, 2.6, 6.5, 6.6
 */

const {
    errorHandler,
    notFoundHandler,
    getErrorType,
    getStatusCode,
    getUserFriendlyMessage,
    sanitizeRequestBody,
} = require('../middleware/errorHandler');

describe('Error Handler Middleware', () => {
    let req, res, next;

    beforeEach(() => {
        req = {
            method: 'POST',
            originalUrl: '/api/test',
            ip: '127.0.0.1',
            body: {},
            query: {},
            connection: { remoteAddress: '127.0.0.1' },
        };

        res = {
            status: jest.fn().mockReturnThis(),
            json: jest.fn().mockReturnThis(),
            headersSent: false,
        };

        next = jest.fn();

        // console.error'ni mock qilish
        jest.spyOn(console, 'error').mockImplementation(() => { });
    });

    afterEach(() => {
        jest.restoreAllMocks();
    });

    describe('getErrorType', () => {
        test('Axios xatosini aniqlashi kerak', () => {
            const error = new Error('API xatosi');
            error.response = { status: 500 };

            expect(getErrorType(error)).toBe('EXTERNAL_API_ERROR');
        });

        test('Validatsiya xatosini aniqlashi kerak', () => {
            const error = new Error('Validatsiya xatosi');
            error.name = 'ValidationError';

            expect(getErrorType(error)).toBe('VALIDATION_ERROR');
        });

        test('Autentifikatsiya xatosini aniqlashi kerak', () => {
            const error = new Error('Autentifikatsiya xatosi');
            error.name = 'UnauthorizedError';

            expect(getErrorType(error)).toBe('UNAUTHORIZED_ERROR');
        });

        test('Tarmoq xatosini aniqlashi kerak', () => {
            const error = new Error('Tarmoq xatosi');
            error.code = 'ECONNREFUSED';

            expect(getErrorType(error)).toBe('NETWORK_ERROR');
        });

        test('Timeout xatosini aniqlashi kerak', () => {
            const error = new Error('Timeout');
            error.code = 'ETIMEDOUT';

            expect(getErrorType(error)).toBe('NETWORK_ERROR');
        });

        test('Umumiy xatoni aniqlashi kerak', () => {
            const error = new Error('Noma\'lum xato');

            expect(getErrorType(error)).toBe('INTERNAL_ERROR');
        });
    });

    describe('getStatusCode', () => {
        test('Xato obyektidagi statusCode\'ni qaytarishi kerak', () => {
            const error = new Error('Test xatosi');
            error.statusCode = 403;

            expect(getStatusCode(error, 'INTERNAL_ERROR')).toBe(403);
        });

        test('Axios xatosidagi status kodini qaytarishi kerak', () => {
            const error = new Error('API xatosi');
            error.response = { status: 404 };

            expect(getStatusCode(error, 'EXTERNAL_API_ERROR')).toBe(404);
        });

        test('Validatsiya xatosi uchun 400 qaytarishi kerak', () => {
            const error = new Error('Validatsiya xatosi');

            expect(getStatusCode(error, 'VALIDATION_ERROR')).toBe(400);
        });

        test('Autentifikatsiya xatosi uchun 401 qaytarishi kerak', () => {
            const error = new Error('Autentifikatsiya xatosi');

            expect(getStatusCode(error, 'UNAUTHORIZED_ERROR')).toBe(401);
        });

        test('Tarmoq xatosi uchun 503 qaytarishi kerak', () => {
            const error = new Error('Tarmoq xatosi');

            expect(getStatusCode(error, 'NETWORK_ERROR')).toBe(503);
        });

        test('Tashqi API xatosi uchun 502 qaytarishi kerak (agar status yo\'q bo\'lsa)', () => {
            const error = new Error('API xatosi');

            expect(getStatusCode(error, 'EXTERNAL_API_ERROR')).toBe(502);
        });

        test('Umumiy xato uchun 500 qaytarishi kerak', () => {
            const error = new Error('Noma\'lum xato');

            expect(getStatusCode(error, 'INTERNAL_ERROR')).toBe(500);
        });
    });

    describe('getUserFriendlyMessage', () => {
        test('Validatsiya xatosi uchun tushunarli xabar qaytarishi kerak', () => {
            const error = new Error('code majburiy');

            const message = getUserFriendlyMessage(error, 'VALIDATION_ERROR');
            expect(message).toBe('code majburiy');
        });

        test('Autentifikatsiya xatosi uchun tushunarli xabar qaytarishi kerak', () => {
            const error = new Error('Token xato');

            const message = getUserFriendlyMessage(error, 'UNAUTHORIZED_ERROR');
            expect(message).toBe('Autentifikatsiya xatosi. Iltimos, qaytadan kirish qiling');
        });

        test('Tarmoq xatosi uchun tushunarli xabar qaytarishi kerak', () => {
            const error = new Error('ECONNREFUSED');

            const message = getUserFriendlyMessage(error, 'NETWORK_ERROR');
            expect(message).toBe('Tarmoq bilan bog\'lanishda xatolik. Keyinroq qayta urinib ko\'ring');
        });

        test('MyID 401 xatosi uchun tushunarli xabar qaytarishi kerak', () => {
            const error = new Error('Unauthorized');
            error.response = { status: 401 };

            const message = getUserFriendlyMessage(error, 'EXTERNAL_API_ERROR');
            expect(message).toBe('MyID autentifikatsiya xatosi');
        });

        test('MyID 404 xatosi uchun tushunarli xabar qaytarishi kerak', () => {
            const error = new Error('Not Found');
            error.response = { status: 404 };

            const message = getUserFriendlyMessage(error, 'EXTERNAL_API_ERROR');
            expect(message).toBe('So\'ralgan ma\'lumot topilmadi');
        });

        test('MyID 500 xatosi uchun tushunarli xabar qaytarishi kerak', () => {
            const error = new Error('Server Error');
            error.response = { status: 500 };

            const message = getUserFriendlyMessage(error, 'EXTERNAL_API_ERROR');
            expect(message).toBe('MyID serveri vaqtinchalik ishlamayapti. Keyinroq qayta urinib ko\'ring');
        });

        test('Umumiy xato uchun tushunarli xabar qaytarishi kerak', () => {
            const error = new Error('Noma\'lum xato');

            const message = getUserFriendlyMessage(error, 'INTERNAL_ERROR');
            expect(message).toBe('Server xatosi. Keyinroq qayta urinib ko\'ring');
        });
    });

    describe('sanitizeRequestBody', () => {
        test('Maxfiy ma\'lumotlarni [REDACTED] bilan almashtirishi kerak', () => {
            const body = {
                code: '123456',
                client_secret: 'secret123',
                password: 'pass123',
                access_token: 'token123',
                photo_base64: 'base64data',
                pinfl: '12345678901234',
                pass_data: 'AA1234567',
            };

            const sanitized = sanitizeRequestBody(body);

            expect(sanitized.code).toBe('123456');
            expect(sanitized.client_secret).toBe('[REDACTED]');
            expect(sanitized.password).toBe('[REDACTED]');
            expect(sanitized.access_token).toBe('[REDACTED]');
            expect(sanitized.photo_base64).toBe('[REDACTED]');
            expect(sanitized.pinfl).toBe('[REDACTED]');
            expect(sanitized.pass_data).toBe('[REDACTED]');
        });

        test('Bo\'sh body uchun bo\'sh qaytarishi kerak', () => {
            expect(sanitizeRequestBody(null)).toBe(null);
            expect(sanitizeRequestBody(undefined)).toBe(undefined);
        });

        test('Obyekt bo\'lmagan body uchun o\'zini qaytarishi kerak', () => {
            expect(sanitizeRequestBody('string')).toBe('string');
            expect(sanitizeRequestBody(123)).toBe(123);
        });
    });

    describe('errorHandler', () => {
        test('Validatsiya xatosini to\'g\'ri boshqarishi kerak', () => {
            const error = new Error('code majburiy');
            error.name = 'ValidationError';

            errorHandler(error, req, res, next);

            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    success: false,
                    error: 'code majburiy',
                    error_details: expect.objectContaining({
                        type: 'VALIDATION_ERROR',
                        message: 'code majburiy',
                    }),
                })
            );
        });

        test('Axios xatosini to\'g\'ri boshqarishi kerak', () => {
            const error = new Error('API xatosi');
            error.response = {
                status: 500,
                data: { error: 'Server xatosi' },
            };

            errorHandler(error, req, res, next);

            expect(res.status).toHaveBeenCalledWith(500);
            expect(res.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    success: false,
                    error_details: expect.objectContaining({
                        type: 'EXTERNAL_API_ERROR',
                    }),
                })
            );
        });

        test('Tarmoq xatosini to\'g\'ri boshqarishi kerak', () => {
            const error = new Error('ECONNREFUSED');
            error.code = 'ECONNREFUSED';

            errorHandler(error, req, res, next);

            expect(res.status).toHaveBeenCalledWith(503);
            expect(res.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    success: false,
                    error: 'Tarmoq bilan bog\'lanishda xatolik. Keyinroq qayta urinib ko\'ring',
                })
            );
        });

        test('Agar javob allaqachon yuborilgan bo\'lsa, next() chaqirishi kerak', () => {
            const error = new Error('Test xatosi');
            res.headersSent = true;

            errorHandler(error, req, res, next);

            expect(next).toHaveBeenCalledWith(error);
            expect(res.status).not.toHaveBeenCalled();
        });

        test('Xatoni log qilishi kerak', () => {
            const error = new Error('Test xatosi');

            errorHandler(error, req, res, next);

            expect(console.error).toHaveBeenCalled();
        });

        test('Timestamp qo\'shishi kerak', () => {
            const error = new Error('Test xatosi');

            errorHandler(error, req, res, next);

            expect(res.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    timestamp: expect.any(String),
                })
            );
        });

        test('Development muhitida stack trace qo\'shishi kerak', () => {
            const originalEnv = process.env.NODE_ENV;
            process.env.NODE_ENV = 'development';

            const error = new Error('Test xatosi');
            error.stack = 'Error stack trace';

            errorHandler(error, req, res, next);

            expect(res.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    error_details: expect.objectContaining({
                        stack: 'Error stack trace',
                    }),
                })
            );

            process.env.NODE_ENV = originalEnv;
        });
    });

    describe('notFoundHandler', () => {
        test('404 xatosini qaytarishi kerak', () => {
            notFoundHandler(req, res);

            expect(res.status).toHaveBeenCalledWith(404);
            expect(res.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    success: false,
                    error: 'So\'ralgan endpoint topilmadi',
                    error_details: expect.objectContaining({
                        type: 'NOT_FOUND',
                        method: 'POST',
                        url: '/api/test',
                    }),
                })
            );
        });

        test('Timestamp qo\'shishi kerak', () => {
            notFoundHandler(req, res);

            expect(res.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    timestamp: expect.any(String),
                })
            );
        });
    });

    describe('Integratsiya testlari', () => {
        test('To\'liq xato boshqaruv oqimi ishlashi kerak', () => {
            // 1. Xato yaratish
            const error = new Error('code majburiy');
            error.name = 'ValidationError';

            // 2. Xato turini aniqlash
            const errorType = getErrorType(error);
            expect(errorType).toBe('VALIDATION_ERROR');

            // 3. Status kodini aniqlash
            const statusCode = getStatusCode(error, errorType);
            expect(statusCode).toBe(400);

            // 4. Foydalanuvchiga tushunarli xabar yaratish
            const message = getUserFriendlyMessage(error, errorType);
            expect(message).toBe('code majburiy');

            // 5. Xato handler chaqirish
            errorHandler(error, req, res, next);

            // 6. To\'g\'ri javob qaytarilganini tekshirish
            expect(res.status).toHaveBeenCalledWith(400);
            expect(res.json).toHaveBeenCalledWith(
                expect.objectContaining({
                    success: false,
                    error: 'code majburiy',
                })
            );
        });

        test('Maxfiy ma\'lumotlar log\'da ko\'rinmasligi kerak', () => {
            const error = new Error('Test xatosi');
            req.body = {
                code: '123456',
                client_secret: 'secret123',
                pinfl: '12345678901234',
            };

            errorHandler(error, req, res, next);

            // console.error chaqirilganini tekshirish
            expect(console.error).toHaveBeenCalled();

            // console.error argumentlarini olish
            const loggedData = console.error.mock.calls[0][1];

            // Maxfiy ma\'lumotlar [REDACTED] bilan almashtirilganini tekshirish
            expect(loggedData.requestBody.code).toBe('123456');
            expect(loggedData.requestBody.client_secret).toBe('[REDACTED]');
            expect(loggedData.requestBody.pinfl).toBe('[REDACTED]');
        });
    });
});
