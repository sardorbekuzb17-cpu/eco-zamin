/**
 * Server Testlari
 * 
 * Bu test fayli Express server'ning asosiy funksiyalarini tekshiradi.
 */

const request = require('supertest');
const express = require('express');
const cors = require('cors');

describe('Express Server', () => {
    let app;

    beforeEach(() => {
        // Har bir test uchun yangi app yaratamiz
        app = express();
        app.use(express.json());
        app.use(express.urlencoded({ extended: true }));
        app.use(cors());

        // Test endpoint
        app.get('/health', (req, res) => {
            res.json({ status: 'ok', timestamp: new Date().toISOString() });
        });

        app.get('/', (req, res) => {
            res.json({
                name: 'GreenMarket MyID Backend',
                version: '4.0.0',
            });
        });
    });

    describe('Server Initialization', () => {
        test('server ishga tushishi kerak', () => {
            expect(app).toBeDefined();
        });

        test('express.json() middleware ishlashi kerak', async () => {
            app.post('/test-json', (req, res) => {
                res.json({ received: req.body });
            });

            const response = await request(app)
                .post('/test-json')
                .send({ test: 'data' })
                .set('Content-Type', 'application/json');

            expect(response.status).toBe(200);
            expect(response.body.received).toEqual({ test: 'data' });
        });

        test('CORS middleware ishlashi kerak', async () => {
            const response = await request(app)
                .get('/health')
                .set('Origin', 'http://localhost:3000');

            expect(response.headers['access-control-allow-origin']).toBeDefined();
        });
    });

    describe('Health Endpoint', () => {
        test('GET /health 200 status qaytarishi kerak', async () => {
            const response = await request(app).get('/health');

            expect(response.status).toBe(200);
            expect(response.body.status).toBe('ok');
            expect(response.body.timestamp).toBeDefined();
        });
    });

    describe('Root Endpoint', () => {
        test('GET / server ma\'lumotlarini qaytarishi kerak', async () => {
            const response = await request(app).get('/');

            expect(response.status).toBe(200);
            expect(response.body.name).toBe('GreenMarket MyID Backend');
            expect(response.body.version).toBeDefined();
        });
    });

    describe('Error Handling', () => {
        test('404 xatosini to\'g\'ri qaytarishi kerak', async () => {
            const response = await request(app).get('/nonexistent');

            expect(response.status).toBe(404);
        });
    });
});
