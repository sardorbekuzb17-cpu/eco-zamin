/**
 * MyID Konfiguratsiya Fayli
 * 
 * Bu fayl MyID integratsiyasi uchun barcha konfiguratsiyalarni o'z ichiga oladi.
 * Environment variables orqali sozlanadi.
 */

require('dotenv').config();

const config = {
    // MyID Credentials
    clientId: process.env.CLIENT_ID || 'quyosh_24_sdk-OYD9rRoHYRjJkpQ2LQNV0EG6KSXtKruUMkOCdY1v',
    clientSecret: process.env.CLIENT_SECRET || 'JRgNV6Av8DlocKJIAozwUrx4uCOU9mDLy5D9SKsEF6EvG2VlD7FU8nup5AYlU3biDfNwOEB0S54Sgup3CB3aJNJuk2wIkG3AIOlP',

    // MyID API Host
    myidHost: process.env.MYID_HOST || 'https://api.myid.uz',

    // Server Configuration
    port: parseInt(process.env.PORT) || 3000,
    nodeEnv: process.env.NODE_ENV || 'development',

    // API Endpoints
    endpoints: {
        accessToken: '/api/v1/auth/clients/access-token',
        createSession: '/api/v2/sdk/sessions',
        getUserData: '/api/v1/sdk/data',
        sessionResult: '/api/v2/sdk/sessions',
    },

    // Token Configuration
    token: {
        expiresIn: 604800, // 7 kun (sekundlarda)
    },

    // Rate Limiting
    rateLimit: {
        windowMs: 60 * 1000, // 1 daqiqa
        maxRequests: 10, // Maksimal 10 so'rov
    },
};

module.exports = config;
