// Shifrlash moduli uchun unit testlar
const {
    encrypt,
    decrypt,
    encryptSensitiveData,
    decryptSensitiveData,
    sanitizeApiResponse,
    generateEncryptionKey,
} = require('../security/encryption');

describe('Encryption Module', () => {
    describe('encrypt va decrypt', () => {
        it('matnni to\'g\'ri shifrlashi va deshifrlashi kerak', () => {
            const originalText = 'AA1234567';
            const encrypted = encrypt(originalText);
            const decrypted = decrypt(encrypted);

            expect(decrypted).toBe(originalText);
        });

        it('shifrlangan matn iv:encrypted formatida bo\'lishi kerak', () => {
            const text = 'test123';
            const encrypted = encrypt(text);

            expect(encrypted).toMatch(/^[0-9a-f]+:[0-9a-f]+$/);
            expect(encrypted.split(':').length).toBe(2);
        });

        it('har safar boshqa shifrlangan matn qaytarishi kerak (random IV)', () => {
            const text = 'test123';
            const encrypted1 = encrypt(text);
            const encrypted2 = encrypt(text);

            expect(encrypted1).not.toBe(encrypted2);
        });

        it('bo\'sh matn uchun xato qaytarishi kerak', () => {
            expect(() => encrypt('')).toThrow();
            expect(() => encrypt(null)).toThrow();
            expect(() => encrypt(undefined)).toThrow();
        });

        it('noto\'g\'ri formatdagi shifrlangan matn uchun xato qaytarishi kerak', () => {
            expect(() => decrypt('invalid')).toThrow();
            expect(() => decrypt('invalid:format:extra')).toThrow();
        });
    });

    describe('encryptSensitiveData', () => {
        it('pasport va PINFL\'ni shifrlashi kerak', () => {
            const profileData = {
                first_name: 'Sardor',
                last_name: 'Aliyev',
                pass_data: 'AA1234567',
                pinfl: '12345678901234',
                birth_date: '1990-01-01',
            };

            const encrypted = encryptSensitiveData(profileData);

            // Pasport va PINFL shifrlangan bo'lishi kerak
            expect(encrypted.pass_data).not.toBe(profileData.pass_data);
            expect(encrypted.pinfl).not.toBe(profileData.pinfl);
            expect(encrypted.pass_data).toMatch(/^[0-9a-f]+:[0-9a-f]+$/);
            expect(encrypted.pinfl).toMatch(/^[0-9a-f]+:[0-9a-f]+$/);

            // Boshqa maydonlar o'zgarmasligi kerak
            expect(encrypted.first_name).toBe(profileData.first_name);
            expect(encrypted.last_name).toBe(profileData.last_name);
            expect(encrypted.birth_date).toBe(profileData.birth_date);
        });

        it('pasport yoki PINFL bo\'lmasa, boshqa maydonlarni o\'zgartirmasligi kerak', () => {
            const profileData = {
                first_name: 'Sardor',
                last_name: 'Aliyev',
                birth_date: '1990-01-01',
            };

            const encrypted = encryptSensitiveData(profileData);

            expect(encrypted).toEqual(profileData);
        });

        it('noto\'g\'ri formatdagi ma\'lumot uchun xato qaytarishi kerak', () => {
            expect(() => encryptSensitiveData(null)).toThrow();
            expect(() => encryptSensitiveData('string')).toThrow();
        });
    });

    describe('decryptSensitiveData', () => {
        it('shifrlangan pasport va PINFL\'ni deshifrlashi kerak', () => {
            const originalData = {
                first_name: 'Sardor',
                pass_data: 'AA1234567',
                pinfl: '12345678901234',
            };

            const encrypted = encryptSensitiveData(originalData);
            const decrypted = decryptSensitiveData(encrypted);

            expect(decrypted.pass_data).toBe(originalData.pass_data);
            expect(decrypted.pinfl).toBe(originalData.pinfl);
            expect(decrypted.first_name).toBe(originalData.first_name);
        });

        it('shifrlangan ma\'lumot bo\'lmasa, o\'zgartirmasligi kerak', () => {
            const data = {
                first_name: 'Sardor',
                pass_data: 'AA1234567', // Shifrlangan emas
            };

            const decrypted = decryptSensitiveData(data);

            expect(decrypted.pass_data).toBe(data.pass_data);
        });
    });

    describe('sanitizeApiResponse', () => {
        it('client_secret\'ni olib tashlashi kerak', () => {
            const response = {
                success: true,
                client_id: 'test_client',
                client_secret: 'secret_key_123',
                data: {
                    token: 'abc123',
                },
            };

            const sanitized = sanitizeApiResponse(response);

            expect(sanitized.client_secret).toBeUndefined();
            expect(sanitized.client_id).toBe(response.client_id);
            expect(sanitized.data).toEqual(response.data);
        });

        it('nested obyektlardagi client_secret\'ni ham olib tashlashi kerak', () => {
            const response = {
                success: true,
                data: {
                    credentials: {
                        client_id: 'test',
                        client_secret: 'secret',
                    },
                },
            };

            const sanitized = sanitizeApiResponse(response);

            expect(sanitized.data.credentials.client_secret).toBeUndefined();
            expect(sanitized.data.credentials.client_id).toBe('test');
        });

        it('client_secret bo\'lmasa, o\'zgartirmasligi kerak', () => {
            const response = {
                success: true,
                data: { token: 'abc' },
            };

            const sanitized = sanitizeApiResponse(response);

            expect(sanitized).toEqual(response);
        });
    });

    describe('generateEncryptionKey', () => {
        it('64 ta hex belgidan iborat kalit yaratishi kerak', () => {
            const key = generateEncryptionKey();

            expect(key).toHaveLength(64);
            expect(key).toMatch(/^[0-9a-f]{64}$/);
        });

        it('har safar boshqa kalit yaratishi kerak', () => {
            const key1 = generateEncryptionKey();
            const key2 = generateEncryptionKey();

            expect(key1).not.toBe(key2);
        });
    });

    describe('To\'liq shifrlash va deshifrlash oqimi', () => {
        it('foydalanuvchi ma\'lumotlarini to\'liq shifrlash va deshifrlash', () => {
            const userData = {
                id: 1,
                first_name: 'Sardor',
                last_name: 'Aliyev',
                middle_name: 'Akbarovich',
                birth_date: '1990-01-01',
                pass_data: 'AA1234567',
                pinfl: '12345678901234',
                nationality: 'UZB',
            };

            // Shifrlash
            const encrypted = encryptSensitiveData(userData);

            // Shifrlangan ma'lumotlar original'dan farq qilishi kerak
            expect(encrypted.pass_data).not.toBe(userData.pass_data);
            expect(encrypted.pinfl).not.toBe(userData.pinfl);

            // Deshifrlash
            const decrypted = decryptSensitiveData(encrypted);

            // Deshifrlangan ma'lumotlar original bilan bir xil bo'lishi kerak
            expect(decrypted.pass_data).toBe(userData.pass_data);
            expect(decrypted.pinfl).toBe(userData.pinfl);
            expect(decrypted.first_name).toBe(userData.first_name);
            expect(decrypted.last_name).toBe(userData.last_name);
        });
    });
});
