/**
 * Konfiguratsiya Testlari
 * 
 * Bu test fayli backend konfiguratsiyasini tekshiradi.
 */

const config = require('../config/myid.config');

describe('MyID Configuration', () => {
    describe('Environment Variables', () => {
        test('clientId mavjud bo\'lishi kerak', () => {
            expect(config.clientId).toBeDefined();
            expect(typeof config.clientId).toBe('string');
            expect(config.clientId.length).toBeGreaterThan(0);
        });

        test('clientSecret mavjud bo\'lishi kerak', () => {
            expect(config.clientSecret).toBeDefined();
            expect(typeof config.clientSecret).toBe('string');
            expect(config.clientSecret.length).toBeGreaterThan(0);
        });

        test('myidHost to\'g\'ri formatda bo\'lishi kerak', () => {
            expect(config.myidHost).toBeDefined();
            expect(config.myidHost).toMatch(/^https:\/\//);
        });

        test('port raqam bo\'lishi kerak', () => {
            expect(config.port).toBeDefined();
            expect(typeof config.port).toBe('number');
            expect(config.port).toBeGreaterThan(0);
        });
    });

    describe('API Endpoints', () => {
        test('barcha endpoint\'lar mavjud bo\'lishi kerak', () => {
            expect(config.endpoints).toBeDefined();
            expect(config.endpoints.accessToken).toBeDefined();
            expect(config.endpoints.createSession).toBeDefined();
            expect(config.endpoints.getUserData).toBeDefined();
            expect(config.endpoints.sessionResult).toBeDefined();
        });

        test('endpoint\'lar / bilan boshlanishi kerak', () => {
            Object.values(config.endpoints).forEach(endpoint => {
                expect(endpoint).toMatch(/^\//);
            });
        });
    });

    describe('Token Configuration', () => {
        test('token expiresIn 7 kun bo\'lishi kerak', () => {
            expect(config.token.expiresIn).toBe(604800); // 7 kun sekundlarda
        });
    });

    describe('Rate Limiting', () => {
        test('rate limit sozlamalari to\'g\'ri bo\'lishi kerak', () => {
            expect(config.rateLimit.windowMs).toBe(60000); // 1 daqiqa
            expect(config.rateLimit.maxRequests).toBe(10); // 10 so\'rov
        });
    });
});
