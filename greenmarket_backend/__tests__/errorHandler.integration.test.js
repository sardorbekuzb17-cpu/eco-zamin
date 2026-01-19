/**
 * Xato Handler Middleware Integratsiya Testlari
 * Express endpoint'lar bilan ishlashini tekshirish
 * Requirements: 1.4, 2.6, 6.5, 6.6
 */

const request = require('supertest');
const express = require('express');
const { errorHandler, notFoundHandler } = require('../middleware/errorHandler');

describe('Error Handler Integration Tests', () => {
    let app;

    beforeEach(() => {
        app = express();
        app.use(express.json());

        // console.error'ni mock qilish
        jest.spyOn(console, 'error').mockImplementation(() => { });
    });

    afterEach(() => {
        jest.restoreAllMocks();
    });

    describe('Validatsiya xatolari', () => {
        test('400 status kodi bilan validatsiya xatosini qaytarishi kerak', async () => {
            app.post('/test', (req, res, next) => {
                const error = new Error('code majburiy');
                error.name = 'ValidationError';
                next(error);
            });

            app.use(errorHandler);

            const response = await request(app)
                .post('/test')
                .send({});

            expect(response.status).toBe(400);
            expect(response.body).toMatchObject({
                success: false,
                error: 'code majburiy',
                error_details: {
                    type: 'VALIDATION_ERROR',
                    message: 'code majburiy',
                },
            });
            expect(response.body.timestamp).toBeDefined();
        });

        test('Bir nechta validatsiya xatolarini boshqarishi kerak', async () => {
            app.post('/test', (req, res, next) => {
                const error = new Error('pass_data yoki pinfl majburiy');
                error.name = 'ValidationError';
                next(error);
            });

            app.use(errorHandler);

            const response = await request(app)
                .post('/test')
                .send({});

            expect(response.status).toBe(400);
            expect(response.body.error).toBe('pass_data yoki pinfl majburiy');
        });
    });

    describe('Autentifikatsiya xatolari', () => {
        test('401 status kodi bilan autentifikatsiya xatosini qaytarishi kerak', async () => {
            app.get('/protected', (req, res, next) => {
                const error = new Error('Token xato');
                error.name = 'UnauthorizedError';
                next(error);
            });

            app.use(errorHandler);

            const response = await request(app).get('/protected');

            expect(response.status).toBe(401);
            expect(response.body).toMatchObject({
                success: false,
                error: 'Autentifikatsiya xatosi. Iltimos, qaytadan kirish qiling',
                error_details: {
                    type: 'UNAUTHORIZED_ERROR',
                },
            });
        });
    });

    describe('Tashqi API xatolari', () => {
        test('MyID API 401 xatosini to\'g\'ri boshqarishi kerak', async () => {
            app.post('/myid', (req, res, next) => {
                const error = new Error('Unauthorized');
                error.response = {
                    status: 401,
                    data: { error: 'Invalid token' },
                };
                next(error);
            });

            app.use(errorHandler);

            const response = await request(app)
                .post('/myid')
                .send({});

            expect(response.status).toBe(401);
            expect(response.body.error).toBe('MyID autentifikatsiya xatosi');
        });

        test('MyID API 404 xatosini to\'g\'ri boshqarishi kerak', async () => {
            app.get('/myid/user/:id', (req, res, next) => {
                const error = new Error('Not Found');
                error.response = {
                    status: 404,
                    data: { error: 'User not found' },
                };
                next(error);
            });

            app.use(errorHandler);

            const response = await request(app).get('/myid/user/123');

            expect(response.status).toBe(404);
            expect(response.body.error).toBe('So\'ralgan ma\'lumot topilmadi');
        });

        test('MyID API 500 xatosini to\'g\'ri boshqarishi kerak', async () => {
            app.post('/myid', (req, res, next) => {
                const error = new Error('Server Error');
                error.response = {
                    status: 500,
                    data: { error: 'Internal server error' },
                };
                next(error);
            });

            app.use(errorHandler);

            const response = await request(app)
                .post('/myid')
                .send({});

            expect(response.status).toBe(500);
            expect(response.body.error).toBe('MyID serveri vaqtinchalik ishlamayapti. Keyinroq qayta urinib ko\'ring');
        });
    });

    describe('Tarmoq xatolari', () => {
        test('ECONNREFUSED xatosini to\'g\'ri boshqarishi kerak', async () => {
            app.get('/external', (req, res, next) => {
                const error = new Error('connect ECONNREFUSED');
                error.code = 'ECONNREFUSED';
                next(error);
            });

            app.use(errorHandler);

            const response = await request(app).get('/external');

            expect(response.status).toBe(503);
            expect(response.body.error).toBe('Tarmoq bilan bog\'lanishda xatolik. Keyinroq qayta urinib ko\'ring');
        });

        test('ETIMEDOUT xatosini to\'g\'ri boshqarishi kerak', async () => {
            app.get('/external', (req, res, next) => {
                const error = new Error('Timeout');
                error.code = 'ETIMEDOUT';
                next(error);
            });

            app.use(errorHandler);

            const response = await request(app).get('/external');

            expect(response.status).toBe(503);
            expect(response.body.error).toBe('Tarmoq bilan bog\'lanishda xatolik. Keyinroq qayta urinib ko\'ring');
        });
    });

    describe('Umumiy xatolar', () => {
        test('500 status kodi bilan umumiy xatoni qaytarishi kerak', async () => {
            app.get('/error', (req, res, next) => {
                const error = new Error('Noma\'lum xato');
                next(error);
            });

            app.use(errorHandler);

            const response = await request(app).get('/error');

            expect(response.status).toBe(500);
            expect(response.body).toMatchObject({
                success: false,
                error: 'Server xatosi. Keyinroq qayta urinib ko\'ring',
                error_details: {
                    type: 'INTERNAL_ERROR',
                    message: 'Noma\'lum xato',
                },
            });
        });

        test('Custom status code\'ni qo\'llab-quvvatlashi kerak', async () => {
            app.get('/custom', (req, res, next) => {
                const error = new Error('Custom xato');
                error.statusCode = 403;
                next(error);
            });

            app.use(errorHandler);

            const response = await request(app).get('/custom');

            expect(response.status).toBe(403);
        });
    });

    describe('404 Not Found', () => {
        test('Mavjud bo\'lmagan endpoint uchun 404 qaytarishi kerak', async () => {
            app.use(notFoundHandler);

            const response = await request(app).get('/mavjud-emas');

            expect(response.status).toBe(404);
            expect(response.body).toMatchObject({
                success: false,
                error: 'So\'ralgan endpoint topilmadi',
                error_details: {
                    type: 'NOT_FOUND',
                    method: 'GET',
                    url: '/mavjud-emas',
                },
            });
        });

        test('POST so\'rov uchun ham 404 qaytarishi kerak', async () => {
            app.use(notFoundHandler);

            const response = await request(app)
                .post('/mavjud-emas')
                .send({ test: 'data' });

            expect(response.status).toBe(404);
            expect(response.body.error_details.method).toBe('POST');
        });
    });

    describe('Maxfiy ma\'lumotlarni himoya qilish', () => {
        test('client_secret log\'da ko\'rinmasligi kerak', async () => {
            app.post('/test', (req, res, next) => {
                const error = new Error('Test xatosi');
                next(error);
            });

            app.use(errorHandler);

            await request(app)
                .post('/test')
                .send({
                    code: '123456',
                    client_secret: 'secret123',
                });

            // console.error chaqirilganini tekshirish
            expect(console.error).toHaveBeenCalled();

            // Log'dagi ma'lumotlarni tekshirish
            const loggedData = console.error.mock.calls[0][1];
            expect(loggedData.requestBody.code).toBe('123456');
            expect(loggedData.requestBody.client_secret).toBe('[REDACTED]');
        });

        test('Bir nechta maxfiy maydonlar log\'da ko\'rinmasligi kerak', async () => {
            app.post('/test', (req, res, next) => {
                const error = new Error('Test xatosi');
                next(error);
            });

            app.use(errorHandler);

            await request(app)
                .post('/test')
                .send({
                    code: '123456',
                    client_secret: 'secret123',
                    password: 'pass123',
                    access_token: 'token123',
                    photo_base64: 'base64data',
                    pinfl: '12345678901234',
                    pass_data: 'AA1234567',
                });

            const loggedData = console.error.mock.calls[0][1];
            expect(loggedData.requestBody.code).toBe('123456');
            expect(loggedData.requestBody.client_secret).toBe('[REDACTED]');
            expect(loggedData.requestBody.password).toBe('[REDACTED]');
            expect(loggedData.requestBody.access_token).toBe('[REDACTED]');
            expect(loggedData.requestBody.photo_base64).toBe('[REDACTED]');
            expect(loggedData.requestBody.pinfl).toBe('[REDACTED]');
            expect(loggedData.requestBody.pass_data).toBe('[REDACTED]');
        });
    });

    describe('Bir nechta endpoint\'lar bilan', () => {
        test('Har xil endpoint\'larda xatolarni to\'g\'ri boshqarishi kerak', async () => {
            // Endpoint 1: Validatsiya xatosi
            app.post('/api/users', (req, res, next) => {
                const error = new Error('name majburiy');
                error.name = 'ValidationError';
                next(error);
            });

            // Endpoint 2: Muvaffaqiyatli
            app.get('/api/users', (req, res) => {
                res.json({ success: true, users: [] });
            });

            // Endpoint 3: Server xatosi
            app.delete('/api/users/:id', (req, res, next) => {
                const error = new Error('Ma\'lumotlar bazasi xatosi');
                next(error);
            });

            app.use(notFoundHandler);
            app.use(errorHandler);

            // Test 1: Validatsiya xatosi
            const response1 = await request(app)
                .post('/api/users')
                .send({});
            expect(response1.status).toBe(400);

            // Test 2: Muvaffaqiyatli
            const response2 = await request(app).get('/api/users');
            expect(response2.status).toBe(200);
            expect(response2.body.success).toBe(true);

            // Test 3: Server xatosi
            const response3 = await request(app).delete('/api/users/1');
            expect(response3.status).toBe(500);

            // Test 4: 404
            const response4 = await request(app).get('/api/mavjud-emas');
            expect(response4.status).toBe(404);
        });
    });

    describe('Xato boshqaruv ketma-ketligi', () => {
        test('Middleware ketma-ketligi to\'g\'ri ishlashi kerak', async () => {
            let middlewareOrder = [];

            // Middleware 1
            app.use((req, res, next) => {
                middlewareOrder.push('middleware1');
                next();
            });

            // Endpoint
            app.get('/test', (req, res, next) => {
                middlewareOrder.push('endpoint');
                const error = new Error('Test xatosi');
                next(error);
            });

            // Middleware 2 (xato handler'dan oldin)
            app.use((req, res, next) => {
                middlewareOrder.push('middleware2');
                next();
            });

            // Xato handler
            app.use((err, req, res, next) => {
                middlewareOrder.push('errorHandler');
                errorHandler(err, req, res, next);
            });

            await request(app).get('/test');

            expect(middlewareOrder).toEqual([
                'middleware1',
                'endpoint',
                'errorHandler',
            ]);
        });
    });

    describe('HTTP metodlari', () => {
        test('GET so\'rov uchun xatoni boshqarishi kerak', async () => {
            app.get('/test', (req, res, next) => {
                const error = new Error('GET xatosi');
                next(error);
            });

            app.use(errorHandler);

            const response = await request(app).get('/test');
            expect(response.status).toBe(500);
        });

        test('POST so\'rov uchun xatoni boshqarishi kerak', async () => {
            app.post('/test', (req, res, next) => {
                const error = new Error('POST xatosi');
                next(error);
            });

            app.use(errorHandler);

            const response = await request(app).post('/test').send({});
            expect(response.status).toBe(500);
        });

        test('PUT so\'rov uchun xatoni boshqarishi kerak', async () => {
            app.put('/test', (req, res, next) => {
                const error = new Error('PUT xatosi');
                next(error);
            });

            app.use(errorHandler);

            const response = await request(app).put('/test').send({});
            expect(response.status).toBe(500);
        });

        test('DELETE so\'rov uchun xatoni boshqarishi kerak', async () => {
            app.delete('/test', (req, res, next) => {
                const error = new Error('DELETE xatosi');
                next(error);
            });

            app.use(errorHandler);

            const response = await request(app).delete('/test');
            expect(response.status).toBe(500);
        });
    });
});
