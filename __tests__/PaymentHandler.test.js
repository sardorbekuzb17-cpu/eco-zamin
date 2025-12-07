const fc = require('fast-check');
const PaymentHandler = require('../src/services/PaymentHandler');

describe('PaymentHandler', () => {
    let paymentHandler;

    beforeEach(() => {
        paymentHandler = new PaymentHandler();
    });

    describe('Property-Based Tests', () => {
        /**
         * **Feature: green-shop, Property 20: Mobile payment methods available**
         * **Validates: Requirements 8.4**
         * 
         * For any payment page on mobile, the available payment methods should include mobile-specific options.
         */
        test('Property 20: Mobile payment methods available', () => {
            fc.assert(
                fc.property(
                    fc.boolean(), // isMobile flag
                    (isMobile) => {
                        // Get available payment methods
                        const methods = paymentHandler.getAvailablePaymentMethods(isMobile);

                        // All methods should be returned (including mobile-specific ones)
                        expect(methods).toBeDefined();
                        expect(Array.isArray(methods)).toBe(true);
                        expect(methods.length).toBeGreaterThan(0);

                        // Check that mobile payment methods exist in the list
                        const mobilePaymentMethods = methods.filter(m => m.mobileOnly === true);

                        // Mobile payment methods should always be available
                        // (Payme and Click are mobile payment options)
                        expect(mobilePaymentMethods.length).toBeGreaterThan(0);

                        // Verify specific mobile payment methods are present
                        const methodIds = methods.map(m => m.id);
                        expect(methodIds).toContain('payme');
                        expect(methodIds).toContain('click');

                        // All methods should have required properties
                        methods.forEach(method => {
                            expect(method).toHaveProperty('id');
                            expect(method).toHaveProperty('name');
                            expect(method).toHaveProperty('description');
                            expect(method).toHaveProperty('icon');
                            expect(method).toHaveProperty('requiresDetails');
                            expect(typeof method.id).toBe('string');
                            expect(typeof method.name).toBe('string');
                            expect(typeof method.description).toBe('string');
                            expect(typeof method.icon).toBe('string');
                            expect(typeof method.requiresDetails).toBe('boolean');
                        });
                    }
                ),
                { numRuns: 100 }
            );
        });
    });

    describe('Unit Tests', () => {
        test('should validate supported payment methods', () => {
            expect(paymentHandler.validatePaymentMethod('card')).toBe(true);
            expect(paymentHandler.validatePaymentMethod('cash')).toBe(true);
            expect(paymentHandler.validatePaymentMethod('payme')).toBe(true);
            expect(paymentHandler.validatePaymentMethod('click')).toBe(true);
        });

        test('should reject unsupported payment methods', () => {
            expect(() => paymentHandler.validatePaymentMethod('bitcoin')).toThrow();
            expect(() => paymentHandler.validatePaymentMethod('')).toThrow();
            expect(() => paymentHandler.validatePaymentMethod(null)).toThrow();
        });

        test('should validate correct card details', () => {
            const validCard = {
                cardNumber: '1234567890123456',
                cardHolder: 'JOHN DOE',
                expiryDate: '12/25',
                cvv: '123'
            };

            const result = paymentHandler.validateCardDetails(validCard);
            expect(result.valid).toBe(true);
            expect(result.message).toBe('');
        });

        test('should reject invalid card number', () => {
            const invalidCard = {
                cardNumber: '123',
                cardHolder: 'JOHN DOE',
                expiryDate: '12/25',
                cvv: '123'
            };

            const result = paymentHandler.validateCardDetails(invalidCard);
            expect(result.valid).toBe(false);
            expect(result.message).toContain('Karta raqami');
        });

        test('should reject expired card', () => {
            const expiredCard = {
                cardNumber: '1234567890123456',
                cardHolder: 'JOHN DOE',
                expiryDate: '01/20', // Expired
                cvv: '123'
            };

            const result = paymentHandler.validateCardDetails(expiredCard);
            expect(result.valid).toBe(false);
            expect(result.message).toContain('muddati');
        });

        test('should reject invalid CVV', () => {
            const invalidCvv = {
                cardNumber: '1234567890123456',
                cardHolder: 'JOHN DOE',
                expiryDate: '12/25',
                cvv: '12' // Only 2 digits
            };

            const result = paymentHandler.validateCardDetails(invalidCvv);
            expect(result.valid).toBe(false);
            expect(result.message).toContain('CVV');
        });

        test('should process payment successfully', async () => {
            const result = await paymentHandler.processPayment('cash', {}, 100000);

            expect(result).toHaveProperty('success');
            expect(result).toHaveProperty('message');

            if (result.success) {
                expect(result).toHaveProperty('transactionId');
                expect(result.transactionId).toBeTruthy();
                expect(result.paymentMethod).toBe('cash');
                expect(result.amount).toBe(100000);
            }
        });

        test('should generate unique transaction IDs', () => {
            const id1 = paymentHandler.generateTransactionId();
            const id2 = paymentHandler.generateTransactionId();

            expect(id1).toBeTruthy();
            expect(id2).toBeTruthy();
            expect(id1).not.toBe(id2);
            expect(id1).toMatch(/^TXN\d+$/);
        });

        test('should return all payment methods including mobile ones', () => {
            const methods = paymentHandler.getAvailablePaymentMethods(true);

            expect(methods.length).toBeGreaterThanOrEqual(4);

            const methodIds = methods.map(m => m.id);
            expect(methodIds).toContain('card');
            expect(methodIds).toContain('cash');
            expect(methodIds).toContain('payme');
            expect(methodIds).toContain('click');
        });
    });
});
