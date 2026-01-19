// HTTPS Protokoli Validatsiya Testlari
// Requirements: 5.1

const { validateHttpsUrl } = require('../myid_sdk_flow');

describe('HTTPS Protokoli Validatsiyasi', () => {
    describe('validateHttpsUrl funksiyasi', () => {
        test('HTTPS URL ni qabul qilishi kerak', () => {
            expect(() => validateHttpsUrl('https://api.myid.uz')).not.toThrow();
            expect(() => validateHttpsUrl('https://example.com/api/v1/test')).not.toThrow();
            expect(() => validateHttpsUrl('https://localhost:3000')).not.toThrow();
        });

        test('HTTP URL ni rad etishi kerak', () => {
            expect(() => validateHttpsUrl('http://api.myid.uz')).toThrow('Faqat HTTPS protokoli qo\'llab-quvvatlanadi');
            expect(() => validateHttpsUrl('http://example.com')).toThrow('Faqat HTTPS protokoli qo\'llab-quvvatlanadi');
        });

        test('Bo\'sh URL ni rad etishi kerak', () => {
            expect(() => validateHttpsUrl('')).toThrow('URL noto\'g\'ri formatda');
            expect(() => validateHttpsUrl(null)).toThrow('URL noto\'g\'ri formatda');
            expect(() => validateHttpsUrl(undefined)).toThrow('URL noto\'g\'ri formatda');
        });

        test('Noto\'g\'ri formatdagi URL ni rad etishi kerak', () => {
            expect(() => validateHttpsUrl(123)).toThrow('URL noto\'g\'ri formatda');
            expect(() => validateHttpsUrl({})).toThrow('URL noto\'g\'ri formatda');
            expect(() => validateHttpsUrl([])).toThrow('URL noto\'g\'ri formatda');
        });

        test('Protokolsiz URL ni rad etishi kerak', () => {
            expect(() => validateHttpsUrl('api.myid.uz')).toThrow('Faqat HTTPS protokoli qo\'llab-quvvatlanadi');
            expect(() => validateHttpsUrl('www.example.com')).toThrow('Faqat HTTPS protokoli qo\'llab-quvvatlanadi');
        });

        test('Boshqa protokollarni rad etishi kerak', () => {
            expect(() => validateHttpsUrl('ftp://example.com')).toThrow('Faqat HTTPS protokoli qo\'llab-quvvatlanadi');
            expect(() => validateHttpsUrl('ws://example.com')).toThrow('Faqat HTTPS protokoli qo\'llab-quvvatlanadi');
            expect(() => validateHttpsUrl('file:///path/to/file')).toThrow('Faqat HTTPS protokoli qo\'llab-quvvatlanadi');
        });
    });

    describe('MyID API URL lari', () => {
        test('MYID_HOST HTTPS protokolini ishlatishi kerak', () => {
            const MYID_HOST = 'https://api.myid.uz';
            expect(() => validateHttpsUrl(MYID_HOST)).not.toThrow();
            expect(MYID_HOST.startsWith('https://')).toBe(true);
        });

        test('Barcha API endpoint URL lari HTTPS bo\'lishi kerak', () => {
            const MYID_HOST = 'https://api.myid.uz';
            const endpoints = [
                `${MYID_HOST}/api/v1/auth/clients/access-token`,
                `${MYID_HOST}/api/v2/sdk/sessions`,
                `${MYID_HOST}/api/v1/sdk/data?code=test123`,
            ];

            endpoints.forEach(url => {
                expect(() => validateHttpsUrl(url)).not.toThrow();
                expect(url.startsWith('https://')).toBe(true);
            });
        });
    });

    describe('Edge Cases', () => {
        test('HTTPS bilan boshlanuvchi lekin noto\'g\'ri URL', () => {
            // Bu URL lar HTTPS bilan boshlangani uchun validatsiyadan o'tadi
            // Lekin real so'rovda xatolik beradi (bu axios ning ishi)
            expect(() => validateHttpsUrl('https://')).not.toThrow();
            expect(() => validateHttpsUrl('https:///')).not.toThrow();
        });

        test('HTTPS katta harflar bilan', () => {
            // JavaScript'da startsWith case-sensitive
            expect(() => validateHttpsUrl('HTTPS://api.myid.uz')).toThrow('Faqat HTTPS protokoli qo\'llab-quvvatlanadi');
            expect(() => validateHttpsUrl('Https://api.myid.uz')).toThrow('Faqat HTTPS protokoli qo\'llab-quvvatlanadi');
        });

        test('Bo\'sh joy bilan URL', () => {
            expect(() => validateHttpsUrl(' https://api.myid.uz')).toThrow('Faqat HTTPS protokoli qo\'llab-quvvatlanadi');
            expect(() => validateHttpsUrl('https://api.myid.uz ')).not.toThrow(); // Oxirida bo'sh joy - qabul qilinadi
        });
    });
});
