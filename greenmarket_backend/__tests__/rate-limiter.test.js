const request = require('supertest');
const express = require('express');
const rateLimit = require('express-rate-limit');

describe('Rate Limiter Middleware', () => {
    /**
     * Test 1: Normal so'rovlar o'tishi kerak
     * Requirements: 5.8
     */
    test('should allow requests within rate limit', async () => {
        const app = express();
        app.use(express.json());

        // Rate limiter qo'shish
        const limiter = rateLimit({
            windowMs: 60 * 1000,
            max: 10,
            standardHeaders: true,
            legacyHeaders: false,
        });
        app.use('/api/', limiter);

        // Test endpoint
        app.get('/api/test', (req, res) => {
            res.json({ success: true, message: 'Test endpoint' });
        });

        // 5 ta so'rov yuborish (limit 10)
        for (let i = 0; i < 5; i++) {
            const response = await request(app)
                .get('/api/test')
                .expect(200);

            expect(response.body.success).toBe(true);
        }
    });

    /**
     * Test 2: 10 tadan ortiq so'rov 429 qaytarishi kerak
     * Requirements: 5.8
     */
    test('should return 429 after exceeding rate limit', async () => {
        const app = express();
        app.use(express.json());

        const limiter = rateLimit({
            windowMs: 60 * 1000,
            max: 10,
            standardHeaders: true,
            legacyHeaders: false,
            handler: (req, res) => {
                res.status(429).json({
                    success: false,
                    error: 'Juda ko\'p so\'rovlar yuborildi',
                    error_code: 'RATE_LIMIT_EXCEEDED',
                    retry_after: 60,
                });
            },
        });
        app.use('/api/', limiter);

        app.get('/api/test', (req, res) => {
            res.json({ success: true, message: 'Test endpoint' });
        });

        // 10 ta so'rov yuborish (limit)
        for (let i = 0; i < 10; i++) {
            await request(app)
                .get('/api/test')
                .expect(200);
        }

        // 11-chi so'rov 429 qaytarishi kerak
        const response = await request(app)
            .get('/api/test')
            .expect(429);

        expect(response.body.success).toBe(false);
        expect(response.body.error_code).toBe('RATE_LIMIT_EXCEEDED');
        expect(response.body.retry_after).toBe(60);
    });

    /**
     * Test 3: Xato xabari to'g'ri formatda bo'lishi kerak
     * Requirements: 5.8
     */
    test('should return correct error message format', async () => {
        const app = express();
        app.use(express.json());

        const limiter = rateLimit({
            windowMs: 60 * 1000,
            max: 10,
            standardHeaders: true,
            legacyHeaders: false,
            handler: (req, res) => {
                res.status(429).json({
                    success: false,
                    error: 'Juda ko\'p so\'rovlar yuborildi',
                    error_code: 'RATE_LIMIT_EXCEEDED',
                    retry_after: 60,
                });
            },
        });
        app.use('/api/', limiter);

        app.get('/api/test', (req, res) => {
            res.json({ success: true });
        });

        // 10 ta so'rov yuborish
        for (let i = 0; i < 10; i++) {
            await request(app).get('/api/test');
        }

        // 11-chi so'rov
        const response = await request(app)
            .get('/api/test')
            .expect(429);

        expect(response.body).toHaveProperty('success', false);
        expect(response.body).toHaveProperty('error');
        expect(response.body).toHaveProperty('error_code', 'RATE_LIMIT_EXCEEDED');
        expect(response.body).toHaveProperty('retry_after', 60);
        expect(typeof response.body.error).toBe('string');
    });

    /**
     * Test 4: RateLimit headerlar qaytarilishi kerak
     * Requirements: 5.8
     */
    test('should include RateLimit headers', async () => {
        const app = express();
        app.use(express.json());

        const limiter = rateLimit({
            windowMs: 60 * 1000,
            max: 10,
            standardHeaders: true,
            legacyHeaders: false,
        });
        app.use('/api/', limiter);

        app.get('/api/test', (req, res) => {
            res.json({ success: true });
        });

        const response = await request(app)
            .get('/api/test')
            .expect(200);

        // RateLimit-* headerlar mavjud bo'lishi kerak
        expect(response.headers).toHaveProperty('ratelimit-limit');
        expect(response.headers).toHaveProperty('ratelimit-remaining');
        expect(response.headers).toHaveProperty('ratelimit-reset');
    });

    /**
     * Test 5: Turli endpointlar bir xil limitga ega bo'lishi kerak
     * Requirements: 5.8
     */
    test('should apply same limit to all API endpoints', async () => {
        const app = express();
        app.use(express.json());

        const limiter = rateLimit({
            windowMs: 60 * 1000,
            max: 10,
            standardHeaders: true,
            legacyHeaders: false,
            handler: (req, res) => {
                res.status(429).json({
                    success: false,
                    error_code: 'RATE_LIMIT_EXCEEDED',
                });
            },
        });
        app.use('/api/', limiter);

        app.get('/api/test', (req, res) => {
            res.json({ success: true });
        });

        app.get('/api/another', (req, res) => {
            res.json({ success: true, message: 'Another endpoint' });
        });

        // 5 ta /api/test so'rovi
        for (let i = 0; i < 5; i++) {
            await request(app).get('/api/test').expect(200);
        }

        // 5 ta /api/another so'rovi
        for (let i = 0; i < 5; i++) {
            await request(app).get('/api/another').expect(200);
        }

        // 11-chi so'rov (har qanday endpoint) 429 qaytarishi kerak
        const response = await request(app)
            .get('/api/test')
            .expect(429);

        expect(response.body.error_code).toBe('RATE_LIMIT_EXCEEDED');
    });

    /**
     * Test 6: Root endpoint rate limit'dan tashqarida bo'lishi kerak
     * Requirements: 5.8
     */
    test('should not apply rate limit to root endpoint', async () => {
        const app = express();
        app.use(express.json());

        const limiter = rateLimit({
            windowMs: 60 * 1000,
            max: 10,
            standardHeaders: true,
            legacyHeaders: false,
        });
        app.use('/api/', limiter);

        app.get('/', (req, res) => {
            res.json({ success: true, message: 'Root endpoint' });
        });

        // 15 ta so'rov yuborish (limit 10 dan ko'p)
        for (let i = 0; i < 15; i++) {
            const response = await request(app)
                .get('/')
                .expect(200);

            expect(response.body.success).toBe(true);
        }
    });
});
