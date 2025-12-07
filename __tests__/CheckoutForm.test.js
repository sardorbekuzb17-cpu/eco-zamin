const fc = require('fast-check');
const CheckoutForm = require('../src/models/CheckoutForm');

describe('CheckoutForm', () => {
    describe('Unit Tests', () => {
        describe('Name Validation', () => {
            test('should reject empty name', () => {
                const form = new CheckoutForm({ name: '' });
                const result = form.validateName();
                expect(result.valid).toBe(false);
                expect(result.message).toContain('kiritilishi shart');
            });

            test('should reject name with only whitespace', () => {
                const form = new CheckoutForm({ name: '   ' });
                const result = form.validateName();
                expect(result.valid).toBe(false);
            });

            test('should reject name shorter than 2 characters', () => {
                const form = new CheckoutForm({ name: 'A' });
                const result = form.validateName();
                expect(result.valid).toBe(false);
                expect(result.message).toContain('kamida 2 ta belgidan');
            });

            test('should accept valid name', () => {
                const form = new CheckoutForm({ name: 'Ali Valiyev' });
                const result = form.validateName();
                expect(result.valid).toBe(true);
            });
        });

        describe('Phone Validation', () => {
            test('should reject empty phone', () => {
                const form = new CheckoutForm({ phone: '' });
                const result = form.validatePhone();
                expect(result.valid).toBe(false);
                expect(result.message).toContain('kiritilishi shart');
            });

            test('should accept valid Uzbekistan phone formats', () => {
                const validPhones = [
                    '+998 20 000 00 00',
                    '+998200000000',
                    '998 20 000 00 00',
                    '998200000000',
                    '+998-20-000-00-00'
                ];

                validPhones.forEach(phone => {
                    const form = new CheckoutForm({ phone });
                    const result = form.validatePhone();
                    expect(result.valid).toBe(true);
                });
            });

            test('should reject invalid phone formats', () => {
                const invalidPhones = [
                    '123456789',
                    '+1234567890',
                    'abcdefghij',
                    '+998 1234567',
                    '998 12 345 67 8' // 8 ta raqam (kam)
                ];

                invalidPhones.forEach(phone => {
                    const form = new CheckoutForm({ phone });
                    const result = form.validatePhone();
                    expect(result.valid).toBe(false);
                });
            });
        });

        describe('Address Validation', () => {
            test('should reject empty address', () => {
                const form = new CheckoutForm({ address: '' });
                const result = form.validateAddress();
                expect(result.valid).toBe(false);
                expect(result.message).toContain('kiritilishi shart');
            });

            test('should reject address shorter than 10 characters', () => {
                const form = new CheckoutForm({ address: 'Short' });
                const result = form.validateAddress();
                expect(result.valid).toBe(false);
                expect(result.message).toContain('to\'liq manzilni');
            });

            test('should accept valid address', () => {
                const form = new CheckoutForm({ address: 'Toshkent shahar, Yunusobod tumani, Amir Temur ko\'chasi 123' });
                const result = form.validateAddress();
                expect(result.valid).toBe(true);
            });
        });

        describe('Email Validation', () => {
            test('should reject empty email', () => {
                const form = new CheckoutForm({ email: '' });
                const result = form.validateEmail();
                expect(result.valid).toBe(false);
                expect(result.message).toContain('kiritilishi shart');
            });

            test('should accept valid email formats', () => {
                const validEmails = [
                    'test@example.com',
                    'user.name@domain.co.uz',
                    'user+tag@example.org'
                ];

                validEmails.forEach(email => {
                    const form = new CheckoutForm({ email });
                    const result = form.validateEmail();
                    expect(result.valid).toBe(true);
                });
            });

            test('should reject invalid email formats', () => {
                const invalidEmails = [
                    'notanemail',
                    '@example.com',
                    'user@',
                    'user @example.com',
                    'user@example'
                ];

                invalidEmails.forEach(email => {
                    const form = new CheckoutForm({ email });
                    const result = form.validateEmail();
                    expect(result.valid).toBe(false);
                });
            });
        });
    });

    describe('Property-Based Tests', () => {
        /**
         * Feature: green-shop, Property 7: Form validation rejects invalid inputs
         * Validates: Requirements 3.2, 3.3, 3.4, 4.3
         * 
         * For any form field with validation rules, submitting invalid data 
         * (empty fields, invalid phone numbers, invalid email) should result 
         * in an error message and prevent form submission.
         */
        test('Property 7: Form validation rejects invalid inputs', () => {
            fc.assert(
                fc.property(
                    // Generate invalid form data
                    fc.record({
                        // Empty or whitespace-only names
                        emptyName: fc.constantFrom('', '   ', '\t', '\n'),
                        // Short names (less than 2 chars)
                        shortName: fc.string({ minLength: 0, maxLength: 1 }),
                        // Invalid phone numbers
                        invalidPhone: fc.oneof(
                            fc.constantFrom('', '   ', '123', 'abc', '+1234567890'),
                            fc.string({ minLength: 0, maxLength: 5 }),
                            fc.integer().map(n => n.toString())
                        ),
                        // Short addresses (less than 10 chars)
                        shortAddress: fc.string({ minLength: 0, maxLength: 9 }),
                        // Invalid emails
                        invalidEmail: fc.oneof(
                            fc.constantFrom('', 'notanemail', '@example.com', 'user@', 'user @example.com'),
                            fc.string({ minLength: 0, maxLength: 5 })
                        )
                    }),
                    (invalidData) => {
                        // Test empty/whitespace name
                        const formWithEmptyName = new CheckoutForm({
                            name: invalidData.emptyName,
                            phone: '+998 20 000 00 00',
                            address: 'Toshkent shahar, Yunusobod tumani',
                            email: 'test@example.com'
                        });
                        expect(formWithEmptyName.validateName().valid).toBe(false);
                        expect(formWithEmptyName.validateAll().valid).toBe(false);

                        // Test short name
                        const formWithShortName = new CheckoutForm({
                            name: invalidData.shortName,
                            phone: '+998 20 000 00 00',
                            address: 'Toshkent shahar, Yunusobod tumani',
                            email: 'test@example.com'
                        });
                        expect(formWithShortName.validateName().valid).toBe(false);
                        expect(formWithShortName.validateAll().valid).toBe(false);

                        // Test invalid phone
                        const formWithInvalidPhone = new CheckoutForm({
                            name: 'Ali Valiyev',
                            phone: invalidData.invalidPhone,
                            address: 'Toshkent shahar, Yunusobod tumani',
                            email: 'test@example.com'
                        });
                        expect(formWithInvalidPhone.validatePhone().valid).toBe(false);
                        expect(formWithInvalidPhone.validateAll().valid).toBe(false);

                        // Test short address
                        const formWithShortAddress = new CheckoutForm({
                            name: 'Ali Valiyev',
                            phone: '+998 20 000 00 00',
                            address: invalidData.shortAddress,
                            email: 'test@example.com'
                        });
                        expect(formWithShortAddress.validateAddress().valid).toBe(false);
                        expect(formWithShortAddress.validateAll().valid).toBe(false);

                        // Test invalid email
                        const formWithInvalidEmail = new CheckoutForm({
                            name: 'Ali Valiyev',
                            phone: '+998 20 000 00 00',
                            address: 'Toshkent shahar, Yunusobod tumani',
                            email: invalidData.invalidEmail
                        });
                        expect(formWithInvalidEmail.validateEmail().valid).toBe(false);
                        expect(formWithInvalidEmail.validateAll().valid).toBe(false);
                    }
                ),
                { numRuns: 100 }
            );
        });

        /**
         * Feature: green-shop, Property 8: Valid form submission proceeds to next step
         * Validates: Requirements 3.5
         * 
         * For any checkout form with all valid data, submitting the form should 
         * proceed to the payment page without errors.
         */
        test('Property 8: Valid form submission proceeds to next step', () => {
            // Custom arbitraries for valid data
            const validNameArb = fc.string({ minLength: 2, maxLength: 50 })
                .filter(s => s.trim().length >= 2);

            const validPhoneArb = fc.oneof(
                fc.constantFrom(
                    '+998 20 000 00 00',
                    '+998 91 234 56 78',
                    '+998 93 345 67 89',
                    '998 20 000 00 00',
                    '998200000000',
                    '+998-20-000-00-00'
                ),
                fc.record({
                    prefix: fc.constantFrom('+998', '998'),
                    code: fc.constantFrom('90', '91', '93', '94', '95', '97', '98', '99'),
                    part1: fc.integer({ min: 100, max: 999 }),
                    part2: fc.integer({ min: 10, max: 99 }),
                    part3: fc.integer({ min: 10, max: 99 })
                }).map(({ prefix, code, part1, part2, part3 }) =>
                    `${prefix} ${code} ${part1} ${part2} ${part3}`
                )
            );

            const validAddressArb = fc.string({ minLength: 10, maxLength: 200 })
                .filter(s => s.trim().length >= 10);

            const validEmailArb = fc.oneof(
                fc.constantFrom(
                    'test@example.com',
                    'user@domain.uz',
                    'admin@greenmarket.uz'
                ),
                fc.record({
                    username: fc.stringOf(fc.constantFrom(...'abcdefghijklmnopqrstuvwxyz0123456789'.split('')), { minLength: 3, maxLength: 10 }),
                    domain: fc.constantFrom('example.com', 'test.uz', 'domain.org')
                }).map(({ username, domain }) => `${username}@${domain}`)
            );

            fc.assert(
                fc.property(
                    fc.record({
                        name: validNameArb,
                        phone: validPhoneArb,
                        address: validAddressArb,
                        email: validEmailArb
                    }),
                    (validData) => {
                        const form = new CheckoutForm(validData);

                        // All individual validations should pass
                        expect(form.validateName().valid).toBe(true);
                        expect(form.validatePhone().valid).toBe(true);
                        expect(form.validateAddress().valid).toBe(true);
                        expect(form.validateEmail().valid).toBe(true);

                        // Overall validation should pass
                        const result = form.validateAll();
                        expect(result.valid).toBe(true);
                        expect(result.errors.name).toBeNull();
                        expect(result.errors.phone).toBeNull();
                        expect(result.errors.address).toBeNull();
                        expect(result.errors.email).toBeNull();

                        // Form should be able to convert to JSON
                        const json = form.toJSON();
                        expect(json).toHaveProperty('name');
                        expect(json).toHaveProperty('phone');
                        expect(json).toHaveProperty('address');
                        expect(json).toHaveProperty('email');
                        expect(json.name.trim().length).toBeGreaterThanOrEqual(2);
                        expect(json.address.trim().length).toBeGreaterThanOrEqual(10);
                    }
                ),
                { numRuns: 100 }
            );
        });
    });
});
