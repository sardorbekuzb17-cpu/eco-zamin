// Maxfiy ma'lumotlarni shifrlash va deshifrlash (AES-256)
const crypto = require('crypto');

// Shifrlash algoritmi
const ALGORITHM = 'aes-256-cbc';

// Shifrlash kaliti (environment variable'dan olinadi)
// Production'da bu kalit xavfsiz joyda saqlanishi kerak (AWS Secrets Manager, Azure Key Vault, va h.k.)
const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY || crypto.randomBytes(32).toString('hex');

// Initialization Vector uzunligi
const IV_LENGTH = 16;

/**
 * Shifrlash kalitini validatsiya qilish
 * @throws {Error} - Agar kalit noto'g'ri formatda bo'lsa
 */
function validateEncryptionKey() {
    if (!ENCRYPTION_KEY) {
        throw new Error('ENCRYPTION_KEY environment variable sozlanmagan');
    }

    // Kalit 64 ta hex belgi (32 byte) bo'lishi kerak
    if (ENCRYPTION_KEY.length !== 64) {
        throw new Error('ENCRYPTION_KEY 64 ta hex belgi (32 byte) bo\'lishi kerak');
    }

    // Kalit faqat hex belgilardan iborat bo'lishi kerak
    if (!/^[0-9a-fA-F]{64}$/.test(ENCRYPTION_KEY)) {
        throw new Error('ENCRYPTION_KEY faqat hex belgilardan iborat bo\'lishi kerak');
    }
}

// Kalitni validatsiya qilish
try {
    validateEncryptionKey();
    console.log('✅ Shifrlash kaliti validatsiya qilindi');
} catch (error) {
    console.error('❌ Shifrlash kaliti xatosi:', error.message);
    console.warn('⚠️ Default kalit ishlatilmoqda (faqat development uchun!)');
}

/**
 * Matnni shifrlash (AES-256-CBC)
 * @param {string} text - Shifrlanishi kerak bo'lgan matn
 * @returns {string} - Shifrlangan matn (iv:encrypted formatida)
 */
function encrypt(text) {
    if (!text || typeof text !== 'string') {
        throw new Error('Shifrlanishi kerak bo\'lgan matn noto\'g\'ri formatda');
    }

    try {
        // Random IV yaratish
        const iv = crypto.randomBytes(IV_LENGTH);

        // Shifrlash kalitini buffer'ga aylantirish
        const key = Buffer.from(ENCRYPTION_KEY, 'hex');

        // Cipher yaratish
        const cipher = crypto.createCipheriv(ALGORITHM, key, iv);

        // Matnni shifrlash
        let encrypted = cipher.update(text, 'utf8', 'hex');
        encrypted += cipher.final('hex');

        // IV va shifrlangan matnni birlashtirish (iv:encrypted)
        return `${iv.toString('hex')}:${encrypted}`;
    } catch (error) {
        console.error('❌ Shifrlash xatosi:', error.message);
        throw new Error('Matnni shifrlashda xatolik yuz berdi');
    }
}

/**
 * Shifrlangan matnni deshifrlash (AES-256-CBC)
 * @param {string} encryptedText - Shifrlangan matn (iv:encrypted formatida)
 * @returns {string} - Deshifrlangan matn
 */
function decrypt(encryptedText) {
    if (!encryptedText || typeof encryptedText !== 'string') {
        throw new Error('Deshifrlash uchun matn noto\'g\'ri formatda');
    }

    try {
        // IV va shifrlangan matnni ajratish
        const parts = encryptedText.split(':');
        if (parts.length !== 2) {
            throw new Error('Shifrlangan matn noto\'g\'ri formatda (iv:encrypted bo\'lishi kerak)');
        }

        const iv = Buffer.from(parts[0], 'hex');
        const encrypted = parts[1];

        // Shifrlash kalitini buffer'ga aylantirish
        const key = Buffer.from(ENCRYPTION_KEY, 'hex');

        // Decipher yaratish
        const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);

        // Matnni deshifrlash
        let decrypted = decipher.update(encrypted, 'hex', 'utf8');
        decrypted += decipher.final('utf8');

        return decrypted;
    } catch (error) {
        console.error('❌ Deshifrlash xatosi:', error.message);
        throw new Error('Matnni deshibrlashda xatolik yuz berdi');
    }
}

/**
 * Foydalanuvchi maxfiy ma'lumotlarini shifrlash
 * @param {Object} profileData - Foydalanuvchi profil ma'lumotlari
 * @returns {Object} - Shifrlangan profil ma'lumotlari
 */
function encryptSensitiveData(profileData) {
    if (!profileData || typeof profileData !== 'object') {
        throw new Error('Profil ma\'lumotlari noto\'g\'ri formatda');
    }

    const encryptedProfile = { ...profileData };

    // Pasport raqamini shifrlash
    if (profileData.pass_data) {
        encryptedProfile.pass_data = encrypt(profileData.pass_data);
    }

    // PINFL'ni shifrlash
    if (profileData.pinfl) {
        encryptedProfile.pinfl = encrypt(profileData.pinfl);
    }

    return encryptedProfile;
}

/**
 * Foydalanuvchi maxfiy ma'lumotlarini deshifrlash
 * @param {Object} encryptedProfile - Shifrlangan profil ma'lumotlari
 * @returns {Object} - Deshifrlangan profil ma'lumotlari
 */
function decryptSensitiveData(encryptedProfile) {
    if (!encryptedProfile || typeof encryptedProfile !== 'object') {
        throw new Error('Shifrlangan profil ma\'lumotlari noto\'g\'ri formatda');
    }

    const decryptedProfile = { ...encryptedProfile };

    // Pasport raqamini deshifrlash
    if (encryptedProfile.pass_data && encryptedProfile.pass_data.includes(':')) {
        try {
            decryptedProfile.pass_data = decrypt(encryptedProfile.pass_data);
        } catch (error) {
            console.error('❌ Pasport raqamini deshibrlashda xatolik:', error.message);
            // Xato bo'lsa, shifrlangan qiymatni qaytaramiz
        }
    }

    // PINFL'ni deshifrlash
    if (encryptedProfile.pinfl && encryptedProfile.pinfl.includes(':')) {
        try {
            decryptedProfile.pinfl = decrypt(encryptedProfile.pinfl);
        } catch (error) {
            console.error('❌ PINFL\'ni deshibrlashda xatolik:', error.message);
            // Xato bo'lsa, shifrlangan qiymatni qaytaramiz
        }
    }

    return decryptedProfile;
}

/**
 * Maxfiy ma'lumotlarni API javobidan olib tashlash
 * @param {Object} data - API javobi
 * @returns {Object} - Tozalangan API javobi (client_secret'siz)
 */
function sanitizeApiResponse(data) {
    if (!data || typeof data !== 'object') {
        return data;
    }

    const sanitized = { ...data };

    // client_secret'ni olib tashlash
    if (sanitized.client_secret) {
        delete sanitized.client_secret;
        console.log('🔒 client_secret API javobidan olib tashlandi');
    }

    // Nested obyektlar uchun rekursiv tozalash
    for (const key in sanitized) {
        if (typeof sanitized[key] === 'object' && sanitized[key] !== null) {
            sanitized[key] = sanitizeApiResponse(sanitized[key]);
        }
    }

    return sanitized;
}

/**
 * Yangi shifrlash kaliti yaratish (faqat development uchun)
 * @returns {string} - Yangi 32 byte hex kalit
 */
function generateEncryptionKey() {
    return crypto.randomBytes(32).toString('hex');
}

module.exports = {
    encrypt,
    decrypt,
    encryptSensitiveData,
    decryptSensitiveData,
    sanitizeApiResponse,
    generateEncryptionKey,
    validateEncryptionKey,
};
