/**
 * Xato Handler Middleware
 * 
 * Barcha xatolarni ushlaydi, log qiladi va tushunarli xato xabarlarini qaytaradi.
 * Requirements: 1.4, 2.6, 6.5, 6.6
 */

/**
 * Xato turini aniqlash
 * @param {Error} error - Xato obyekti
 * @returns {string} - Xato turi
 */
function getErrorType(error) {
    if (error.response) {
        // Axios xatosi (tashqi API xatosi)
        return 'EXTERNAL_API_ERROR';
    } else if (error.name === 'ValidationError') {
        return 'VALIDATION_ERROR';
    } else if (error.name === 'UnauthorizedError') {
        return 'UNAUTHORIZED_ERROR';
    } else if (error.code === 'ECONNREFUSED' || error.code === 'ETIMEDOUT') {
        return 'NETWORK_ERROR';
    } else {
        return 'INTERNAL_ERROR';
    }
}

/**
 * HTTP status kodini aniqlash
 * @param {Error} error - Xato obyekti
 * @param {string} errorType - Xato turi
 * @returns {number} - HTTP status kodi
 */
function getStatusCode(error, errorType) {
    // Agar xato obyektida status mavjud bo'lsa
    if (error.statusCode) {
        return error.statusCode;
    }

    // Axios xatosi uchun
    if (error.response && error.response.status) {
        return error.response.status;
    }

    // Xato turiga qarab
    switch (errorType) {
        case 'VALIDATION_ERROR':
            return 400;
        case 'UNAUTHORIZED_ERROR':
            return 401;
        case 'NETWORK_ERROR':
            return 503; // Service Unavailable
        case 'EXTERNAL_API_ERROR':
            return error.response?.status || 502; // Bad Gateway
        default:
            return 500;
    }
}

/**
 * Foydalanuvchiga tushunarli xato xabarini yaratish
 * @param {Error} error - Xato obyekti
 * @param {string} errorType - Xato turi
 * @returns {string} - Tushunarli xato xabari
 */
function getUserFriendlyMessage(error, errorType) {
    switch (errorType) {
        case 'VALIDATION_ERROR':
            return error.message || 'Kiritilgan ma\'lumotlar noto\'g\'ri';
        case 'UNAUTHORIZED_ERROR':
            return 'Autentifikatsiya xatosi. Iltimos, qaytadan kirish qiling';
        case 'NETWORK_ERROR':
            return 'Tarmoq bilan bog\'lanishda xatolik. Keyinroq qayta urinib ko\'ring';
        case 'EXTERNAL_API_ERROR':
            if (error.response?.status === 401) {
                return 'MyID autentifikatsiya xatosi';
            } else if (error.response?.status === 404) {
                return 'So\'ralgan ma\'lumot topilmadi';
            } else if (error.response?.status >= 500) {
                return 'MyID serveri vaqtinchalik ishlamayapti. Keyinroq qayta urinib ko\'ring';
            }
            return 'Tashqi xizmat bilan bog\'lanishda xatolik';
        default:
            return 'Server xatosi. Keyinroq qayta urinib ko\'ring';
    }
}

/**
 * Xato tafsilotlarini log qilish
 * @param {Error} error - Xato obyekti
 * @param {Object} req - Express request obyekti
 * @param {string} errorType - Xato turi
 */
function logError(error, req, errorType) {
    const timestamp = new Date().toISOString();
    const method = req.method;
    const url = req.originalUrl;
    const ip = req.ip || req.connection.remoteAddress;

    console.error('❌ XATO:', {
        timestamp,
        errorType,
        method,
        url,
        ip,
        message: error.message,
        stack: error.stack,
        // Axios xatosi uchun qo'shimcha ma'lumotlar
        externalApiStatus: error.response?.status,
        externalApiData: error.response?.data,
        // Request ma'lumotlari (maxfiy ma'lumotlarni chiqarib)
        requestBody: sanitizeRequestBody(req.body),
        requestQuery: req.query,
    });
}

/**
 * Request body'dan maxfiy ma'lumotlarni olib tashlash
 * @param {Object} body - Request body
 * @returns {Object} - Tozalangan body
 */
function sanitizeRequestBody(body) {
    if (!body || typeof body !== 'object') {
        return body;
    }

    const sanitized = { ...body };
    const sensitiveFields = [
        'client_secret',
        'password',
        'access_token',
        'photo_base64',
        'pinfl',
        'pass_data',
    ];

    sensitiveFields.forEach(field => {
        if (sanitized[field]) {
            sanitized[field] = '[REDACTED]';
        }
    });

    return sanitized;
}

/**
 * Xato handler middleware
 * @param {Error} err - Xato obyekti
 * @param {Object} req - Express request obyekti
 * @param {Object} res - Express response obyekti
 * @param {Function} next - Express next funksiyasi
 */
function errorHandler(err, req, res, next) {
    // Agar javob allaqachon yuborilgan bo'lsa, Express'ning default xato handlerini chaqirish
    if (res.headersSent) {
        return next(err);
    }

    // Xato turini aniqlash
    const errorType = getErrorType(err);

    // Xatoni log qilish
    logError(err, req, errorType);

    // HTTP status kodini aniqlash
    const statusCode = getStatusCode(err, errorType);

    // Foydalanuvchiga tushunarli xato xabarini yaratish
    const userMessage = getUserFriendlyMessage(err, errorType);

    // Xato javobini qaytarish
    res.status(statusCode).json({
        success: false,
        error: userMessage,
        error_details: {
            type: errorType,
            message: err.message,
            // Development muhitida qo'shimcha ma'lumotlar
            ...(process.env.NODE_ENV === 'development' && {
                stack: err.stack,
                externalApiData: err.response?.data,
            }),
        },
        timestamp: new Date().toISOString(),
    });
}

/**
 * 404 xatosi uchun middleware
 * @param {Object} req - Express request obyekti
 * @param {Object} res - Express response obyekti
 */
function notFoundHandler(req, res) {
    res.status(404).json({
        success: false,
        error: 'So\'ralgan endpoint topilmadi',
        error_details: {
            type: 'NOT_FOUND',
            method: req.method,
            url: req.originalUrl,
        },
        timestamp: new Date().toISOString(),
    });
}

module.exports = {
    errorHandler,
    notFoundHandler,
    getErrorType,
    getStatusCode,
    getUserFriendlyMessage,
    sanitizeRequestBody,
};
