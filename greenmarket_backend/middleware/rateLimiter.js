const rateLimit = require('express-rate-limit');

/**
 * Rate limiting middleware
 * 1 daqiqada maksimal 10 so'rov
 * Requirements: 5.8
 */
const apiLimiter = rateLimit({
    windowMs: 60 * 1000, // 1 daqiqa
    max: 10, // Maksimal 10 so'rov
    message: {
        success: false,
        error: 'Juda ko\'p so\'rovlar yuborildi. Iltimos, 1 daqiqadan keyin qayta urinib ko\'ring.',
        error_code: 'RATE_LIMIT_EXCEEDED',
    },
    statusCode: 429, // Too Many Requests
    standardHeaders: true, // RateLimit-* headerlarini qaytarish
    legacyHeaders: false, // X-RateLimit-* headerlarini o'chirish
    // Xato handler
    handler: (req, res) => {
        console.warn(`⚠️ Rate limit oshdi: ${req.ip} - ${req.method} ${req.path}`);
        res.status(429).json({
            success: false,
            error: 'Juda ko\'p so\'rovlar yuborildi. Iltimos, 1 daqiqadan keyin qayta urinib ko\'ring.',
            error_code: 'RATE_LIMIT_EXCEEDED',
            retry_after: 60, // soniyalarda
        });
    },
});

module.exports = { apiLimiter };
