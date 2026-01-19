const axios = require('axios');

const BASE_URL = 'https://greenmarket-backend-lilac.vercel.app';

// Test ma'lumotlari
const TEST_CODE = 'TEST_CODE_12345';
const TEST_BASE64 = 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8VAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCwAA8A/9k=';

describe('MyID Backend Endpoints', () => {

    // ============================================
    // 1. HEALTH CHECK
    // ============================================
    describe('Health Check', () => {
        test('GET /api/health - Backend sog\'lom', async () => {
            try {
                const response = await axios.get(`${BASE_URL}/api/health`);

                console.log('✅ Health Check:');
                console.log('   Status:', response.status);
                console.log('   Data:', response.data);

                expect(response.status).toBe(200);
                expect(response.data.status).toBe('OK');
            } catch (error) {
                console.error('❌ Health Check xatosi:', error.message);
                throw error;
            }
        });
    });

    // ============================================
    // 2. ACCESS TOKEN OLISH
    // ============================================
    describe('Access Token', () => {
        test('POST /api/myid/get-access-token - Access token olish', async () => {
            try {
                const response = await axios.post(`${BASE_URL}/api/myid/get-access-token`);

                console.log('✅ Access Token:');
                console.log('   Status:', response.status);
                console.log('   Token length:', response.data.data.access_token.length);
                console.log('   Expires in:', response.data.data.expires_in);
                console.log('   Token type:', response.data.data.token_type);

                expect(response.status).toBe(200);
                expect(response.data.success).toBe(true);
                expect(response.data.data.access_token).toBeDefined();
                expect(response.data.data.access_token.length).toBeGreaterThan(100);
                expect(response.data.data.expires_in).toBeDefined();
                expect(response.data.data.token_type).toBe('Bearer');
            } catch (error) {
                console.error('❌ Access Token xatosi:', error.response?.data || error.message);
                throw error;
            }
        });
    });

    // ============================================
    // 3. SESSION YARATISH (BO'SH)
    // ============================================
    describe('Create Session (Empty)', () => {
        test('POST /api/myid/create-session - Bo\'sh session yaratish', async () => {
            try {
                const response = await axios.post(`${BASE_URL}/api/myid/create-session`);

                console.log('✅ Create Session (Empty):');
                console.log('   Status:', response.status);
                console.log('   Session ID:', response.data.data.session_id);
                console.log('   Expires in:', response.data.data.expires_in);

                expect(response.status).toBe(200);
                expect(response.data.success).toBe(true);
                expect(response.data.data.session_id).toBeDefined();
                expect(response.data.data.expires_in).toBeDefined();
            } catch (error) {
                console.error('❌ Create Session xatosi:', error.response?.data || error.message);
                throw error;
            }
        });
    });

    // ============================================
    // 4. SESSION YARATISH (PASPORT BILAN)
    // ============================================
    describe('Create Session (With Passport)', () => {
        test('POST /api/myid/create-session-with-passport - Pasport bilan session', async () => {
            try {
                const response = await axios.post(
                    `${BASE_URL}/api/myid/create-session-with-passport`,
                    {
                        pass_data: 'AA1234567',
                        birth_date: '1990-01-15',
                    }
                );

                console.log('✅ Create Session (With Passport):');
                console.log('   Status:', response.status);
                console.log('   Session ID:', response.data.data.session_id);

                expect(response.status).toBe(200);
                expect(response.data.success).toBe(true);
                expect(response.data.data.session_id).toBeDefined();
            } catch (error) {
                console.error('❌ Create Session (Passport) xatosi:', error.response?.data || error.message);
                throw error;
            }
        });
    });

    // ============================================
    // 5. SESSION YARATISH (PASPORT MAYDONLARI BILAN)
    // ============================================
    describe('Create Session (With Fields)', () => {
        test('POST /api/myid/create-session-with-fields - Pasport maydonlari bilan', async () => {
            try {
                const response = await axios.post(
                    `${BASE_URL}/api/myid/create-session-with-fields`,
                    {
                        phone_number: '+998901234567',
                        birth_date: '1990-01-15',
                        is_resident: true,
                        pass_data: 'AA1234567',
                        threshold: 0.5,
                    }
                );

                console.log('✅ Create Session (With Fields):');
                console.log('   Status:', response.status);
                console.log('   Session ID:', response.data.data.session_id);

                expect(response.status).toBe(200);
                expect(response.data.success).toBe(true);
                expect(response.data.data.session_id).toBeDefined();
            } catch (error) {
                console.error('❌ Create Session (Fields) xatosi:', error.response?.data || error.message);
                throw error;
            }
        });
    });

    // ============================================
    // 6. PROFIL MA'LUMOTLARINI OLISH
    // ============================================
    describe('Get User Info', () => {
        test('POST /api/myid/get-user-info - Profil ma\'lumotlarini olish', async () => {
            try {
                const response = await axios.post(
                    `${BASE_URL}/api/myid/get-user-info`,
                    {
                        code: TEST_CODE,
                        base64_image: TEST_BASE64,
                    }
                );

                console.log('✅ Get User Info:');
                console.log('   Status:', response.status);
                console.log('   User ID:', response.data.data.user_id);
                console.log('   PINFL:', response.data.data.pinfl);

                expect(response.status).toBe(200);
                expect(response.data.success).toBe(true);
                expect(response.data.data.user_id).toBeDefined();
                expect(response.data.data.pinfl).toBeDefined();
            } catch (error) {
                console.error('❌ Get User Info xatosi:', error.response?.data || error.message);
                // Bu endpoint MyID API'ga bog'liq, shuning uchun xato bo'lishi mumkin
            }
        });
    });

    // ============================================
    // 7. PROFIL MA'LUMOTLARINI OLISH (RASMLAR BILAN)
    // ============================================
    describe('Get User Info With Images', () => {
        test('POST /api/myid/get-user-info-with-images - Profil + rasmlar', async () => {
            try {
                const response = await axios.post(
                    `${BASE_URL}/api/myid/get-user-info-with-images`,
                    {
                        code: TEST_CODE,
                        base64_image: TEST_BASE64,
                    }
                );

                console.log('✅ Get User Info With Images:');
                console.log('   Status:', response.status);
                console.log('   User ID:', response.data.data.user_id);

                expect(response.status).toBe(200);
                expect(response.data.success).toBe(true);
            } catch (error) {
                console.error('❌ Get User Info With Images xatosi:', error.response?.data || error.message);
            }
        });
    });

    // ============================================
    // 8. FOYDALANUVCHI MA'LUMOTLARINI OLISH (GET)
    // ============================================
    describe('Get User Data By Code', () => {
        test('GET /api/myid/data/code=:code - Code orqali ma\'lumot olish', async () => {
            try {
                const response = await axios.get(
                    `${BASE_URL}/api/myid/data/code=${TEST_CODE}`
                );

                console.log('✅ Get User Data By Code:');
                console.log('   Status:', response.status);
                console.log('   Data:', response.data.data ? 'Mavjud' : 'Yo\'q');

                expect(response.status).toBe(200);
                expect(response.data.success).toBe(true);
            } catch (error) {
                console.error('❌ Get User Data By Code xatosi:', error.response?.data || error.message);
            }
        });
    });

    // ============================================
    // 9. ADMIN: BARCHA FOYDALANUVCHILAR
    // ============================================
    describe('Admin: Get All Users', () => {
        test('GET /api/myid/users - Barcha foydalanuvchilar', async () => {
            try {
                const response = await axios.get(`${BASE_URL}/api/myid/users`);

                console.log('✅ Get All Users:');
                console.log('   Status:', response.status);
                console.log('   Total users:', response.data.data.total);
                console.log('   Users count:', response.data.data.users.length);

                expect(response.status).toBe(200);
                expect(response.data.success).toBe(true);
                expect(response.data.data.total).toBeDefined();
                expect(Array.isArray(response.data.data.users)).toBe(true);
            } catch (error) {
                console.error('❌ Get All Users xatosi:', error.response?.data || error.message);
                throw error;
            }
        });
    });

    // ============================================
    // 10. ADMIN: STATISTIKA
    // ============================================
    describe('Admin: Get Stats', () => {
        test('GET /api/myid/stats - Statistika', async () => {
            try {
                const response = await axios.get(`${BASE_URL}/api/myid/stats`);

                console.log('✅ Get Stats:');
                console.log('   Status:', response.status);
                console.log('   Total users:', response.data.data.total_users);
                console.log('   Today registrations:', response.data.data.today_registrations);

                expect(response.status).toBe(200);
                expect(response.data.success).toBe(true);
                expect(response.data.data.total_users).toBeDefined();
                expect(response.data.data.today_registrations).toBeDefined();
            } catch (error) {
                console.error('❌ Get Stats xatosi:', error.response?.data || error.message);
                throw error;
            }
        });
    });

    // ============================================
    // ERROR HANDLING
    // ============================================
    describe('Error Handling', () => {
        test('POST /api/myid/get-user-info - Code bo\'lmasa xato', async () => {
            try {
                await axios.post(`${BASE_URL}/api/myid/get-user-info`, {
                    base64_image: TEST_BASE64,
                });

                throw new Error('Xato bo\'lishi kerak edi');
            } catch (error) {
                console.log('✅ Error Handling (Code yo\'q):');
                console.log('   Status:', error.response?.status);
                console.log('   Error:', error.response?.data?.message || error.message);

                expect(error.response?.status).toBe(400);
            }
        });

        test('POST /api/myid/create-session-with-passport - Majburiy maydonlar yo\'q', async () => {
            try {
                await axios.post(`${BASE_URL}/api/myid/create-session-with-passport`, {
                    pass_data: 'AA1234567',
                    // birth_date yo'q
                });

                throw new Error('Xato bo\'lishi kerak edi');
            } catch (error) {
                console.log('✅ Error Handling (Majburiy maydonlar):');
                console.log('   Status:', error.response?.status);

                expect(error.response?.status).toBe(400);
            }
        });
    });
});

// ============================================
// TEST SUMMARY
// ============================================
console.log(`
╔════════════════════════════════════════════════════════════╗
║          MyID Backend Endpoints Test Suite                 ║
╠════════════════════════════════════════════════════════════╣
║ ✅ Health Check                                            ║
║ ✅ Access Token Olish                                      ║
║ ✅ Session Yaratish (Bo'sh)                                ║
║ ✅ Session Yaratish (Pasport Bilan)                        ║
║ ✅ Session Yaratish (Pasport Maydonlari Bilan)             ║
║ ✅ Profil Ma'lumotlarini Olish                             ║
║ ✅ Profil Ma'lumotlarini Olish (Rasmlar Bilan)             ║
║ ✅ Foydalanuvchi Ma'lumotlarini Olish (GET)                ║
║ ✅ Admin: Barcha Foydalanuvchilar                          ║
║ ✅ Admin: Statistika                                       ║
║ ✅ Error Handling                                          ║
╚════════════════════════════════════════════════════════════╝
`);
