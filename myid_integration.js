// MyID Integration for GreenMarket
// https://id.egov.uz/

class MyIDAuth {
    constructor(config) {
        this.clientId = config.clientId;
        this.redirectUri = config.redirectUri;
        this.scope = config.scope || 'address,contacts,doc_data,common_data';
        this.baseUrl = 'https://sso.egov.uz';
    }

    // MyID orqali kirish
    login() {
        const authUrl = `${this.baseUrl}/sso/oauth/Authorization.do?` +
            `response_type=one_code&` +
            `client_id=${this.clientId}&` +
            `redirect_uri=${encodeURIComponent(this.redirectUri)}&` +
            `scope=${this.scope}&` +
            `state=${this.generateState()}`;

        window.location.href = authUrl;
    }

    // State generatsiya qilish (CSRF himoyasi)
    generateState() {
        const state = Math.random().toString(36).substring(7);
        sessionStorage.setItem('myid_state', state);
        return state;
    }

    // Callback'dan token olish
    async handleCallback(code, state) {
        // State tekshirish
        const savedState = sessionStorage.getItem('myid_state');
        if (state !== savedState) {
            throw new Error('Invalid state parameter');
        }

        try {
            // Token olish
            const tokenResponse = await fetch(`${this.baseUrl}/sso/oauth/Authorization.do`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: new URLSearchParams({
                    grant_type: 'one_authorization_code',
                    code: code,
                    client_id: this.clientId,
                    redirect_uri: this.redirectUri
                })
            });

            const tokenData = await tokenResponse.json();

            if (tokenData.access_token) {
                // Token'ni saqlash
                localStorage.setItem('myid_access_token', tokenData.access_token);
                localStorage.setItem('myid_refresh_token', tokenData.refresh_token);

                // Foydalanuvchi ma'lumotlarini olish
                const userData = await this.getUserData(tokenData.access_token);
                return userData;
            } else {
                throw new Error('Token olishda xatolik');
            }
        } catch (error) {
            console.error('MyID callback xatolik:', error);
            throw error;
        }
    }

    // Foydalanuvchi ma'lumotlarini olish
    async getUserData(accessToken) {
        try {
            const response = await fetch(`${this.baseUrl}/sso/oauth/Authorization.do`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: new URLSearchParams({
                    grant_type: 'access_token',
                    access_token: accessToken
                })
            });

            const data = await response.json();

            // Ma'lumotlarni formatlash
            const userData = {
                pin: data.pin,
                fullName: `${data.sur_name} ${data.first_name} ${data.middle_name}`,
                firstName: data.first_name,
                lastName: data.sur_name,
                middleName: data.middle_name,
                birthDate: data.birth_date,
                citizenship: data.citizenship,
                nationality: data.nationality,
                gender: data.sex,
                // Passport ma'lumotlari
                passportSerial: data.doc_data?.pass_data,
                passportNumber: data.doc_data?.pass_data,
                passportIssueDate: data.doc_data?.issued_date,
                passportExpireDate: data.doc_data?.expiry_date,
                // Manzil
                address: {
                    region: data.address?.region,
                    district: data.address?.district,
                    address: data.address?.address,
                    cadastre: data.address?.cadastre
                },
                // Kontakt
                phone: data.contacts?.phone,
                email: data.contacts?.email
            };

            // Foydalanuvchi ma'lumotlarini saqlash
            localStorage.setItem('user_data', JSON.stringify(userData));

            return userData;
        } catch (error) {
            console.error('Foydalanuvchi ma\'lumotlarini olishda xatolik:', error);
            throw error;
        }
    }

    // Refresh token bilan yangi access token olish
    async refreshToken() {
        const refreshToken = localStorage.getItem('myid_refresh_token');

        if (!refreshToken) {
            throw new Error('Refresh token topilmadi');
        }

        try {
            const response = await fetch(`${this.baseUrl}/sso/oauth/Authorization.do`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: new URLSearchParams({
                    grant_type: 'refresh_token',
                    refresh_token: refreshToken,
                    client_id: this.clientId
                })
            });

            const data = await response.json();

            if (data.access_token) {
                localStorage.setItem('myid_access_token', data.access_token);
                return data.access_token;
            } else {
                throw new Error('Token yangilashda xatolik');
            }
        } catch (error) {
            console.error('Token yangilash xatolik:', error);
            throw error;
        }
    }

    // Chiqish
    logout() {
        localStorage.removeItem('myid_access_token');
        localStorage.removeItem('myid_refresh_token');
        localStorage.removeItem('user_data');
        sessionStorage.removeItem('myid_state');
    }

    // Foydalanuvchi tizimga kirganmi?
    isAuthenticated() {
        return !!localStorage.getItem('myid_access_token');
    }

    // Saqlangan foydalanuvchi ma'lumotlarini olish
    getCurrentUser() {
        const userData = localStorage.getItem('user_data');
        return userData ? JSON.parse(userData) : null;
    }
}

// Export
if (typeof module !== 'undefined' && module.exports) {
    module.exports = MyIDAuth;
}
