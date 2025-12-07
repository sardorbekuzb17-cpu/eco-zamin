/**
 * CheckoutForm
 * Represents checkout form data and validation
 */
class CheckoutForm {
    constructor(data = {}) {
        this.name = data.name || '';
        this.phone = data.phone || '';
        this.address = data.address || '';
        this.email = data.email || '';
    }

    /**
     * Validate name field
     */
    validateName() {
        if (!this.name || this.name.trim() === '') {
            return { valid: false, message: 'Ism va familiya kiritilishi shart' };
        }
        if (this.name.trim().length < 2) {
            return { valid: false, message: 'Ism kamida 2 ta belgidan iborat bo\'lishi kerak' };
        }
        return { valid: true, message: '' };
    }

    /**
     * Validate phone field (Uzbekistan format)
     */
    validatePhone() {
        if (!this.phone || this.phone.trim() === '') {
            return { valid: false, message: 'Telefon raqami kiritilishi shart' };
        }

        const cleanPhone = this.phone.trim();

        // Check if phone contains only valid characters (digits, +, spaces, hyphens)
        if (!/^[\d\s+\-]+$/.test(cleanPhone)) {
            return { valid: false, message: 'Telefon raqami noto\'g\'ri formatda. Misol: +998 20 000 00 00' };
        }

        // O'zbekiston telefon raqami formati: +998 XX XXX XX XX yoki 998XXXXXXXXX yoki +998XXXXXXXXX
        // Must start with +998 or 998, followed by 9 digits
        const phoneRegex = /^(\+998|998)[\s-]?(\d{2})[\s-]?(\d{3})[\s-]?(\d{2})[\s-]?(\d{2})$/;

        if (!phoneRegex.test(cleanPhone)) {
            return { valid: false, message: 'Telefon raqami noto\'g\'ri formatda. Misol: +998 20 000 00 00' };
        }

        return { valid: true, message: '' };
    }

    /**
     * Validate address field
     */
    validateAddress() {
        if (!this.address || this.address.trim() === '') {
            return { valid: false, message: 'Manzil kiritilishi shart' };
        }
        if (this.address.trim().length < 10) {
            return { valid: false, message: 'Iltimos, to\'liq manzilni kiriting (kamida 10 ta belgi)' };
        }
        return { valid: true, message: '' };
    }

    /**
     * Validate email field
     */
    validateEmail() {
        if (!this.email || this.email.trim() === '') {
            return { valid: false, message: 'Email kiritilishi shart' };
        }

        // Email format validation
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!emailRegex.test(this.email.trim())) {
            return { valid: false, message: 'Email noto\'g\'ri formatda. Misol: email@example.com' };
        }

        return { valid: true, message: '' };
    }

    /**
     * Validate all fields
     */
    validateAll() {
        const nameValidation = this.validateName();
        const phoneValidation = this.validatePhone();
        const addressValidation = this.validateAddress();
        const emailValidation = this.validateEmail();

        const isValid = nameValidation.valid &&
            phoneValidation.valid &&
            addressValidation.valid &&
            emailValidation.valid;

        return {
            valid: isValid,
            errors: {
                name: nameValidation.valid ? null : nameValidation.message,
                phone: phoneValidation.valid ? null : phoneValidation.message,
                address: addressValidation.valid ? null : addressValidation.message,
                email: emailValidation.valid ? null : emailValidation.message
            }
        };
    }

    /**
     * Get form data as plain object
     */
    toJSON() {
        return {
            name: this.name.trim(),
            phone: this.phone.trim(),
            address: this.address.trim(),
            email: this.email.trim()
        };
    }
}

module.exports = CheckoutForm;
