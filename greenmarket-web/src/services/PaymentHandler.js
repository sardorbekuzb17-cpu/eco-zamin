const ErrorHandler = require('./ErrorHandler');

/**
 * PaymentHandler
 * Handles payment processing and validation (simulated) with error handling
 */
class PaymentHandler {
    constructor(errorHandler = new ErrorHandler()) {
        this.supportedMethods = ['card', 'cash', 'payme', 'click'];
        this.errorHandler = errorHandler;
    }

    /**
     * Validate payment method
     */
    validatePaymentMethod(method) {
        if (!method || typeof method !== 'string') {
            throw new Error('Payment method is required');
        }

        if (!this.supportedMethods.includes(method)) {
            throw new Error('Unsupported payment method');
        }

        return true;
    }

    /**
     * Validate card details
     */
    validateCardDetails(cardDetails) {
        if (!cardDetails || typeof cardDetails !== 'object') {
            throw new Error('Card details are required');
        }

        const { cardNumber, cardHolder, expiryDate, cvv } = cardDetails;

        // Validate card number (16 digits)
        if (!cardNumber || !/^\d{16}$/.test(cardNumber.replace(/\s/g, ''))) {
            return { valid: false, message: 'Karta raqami noto\'g\'ri formatda (16 ta raqam)' };
        }

        // Validate card holder
        if (!cardHolder || cardHolder.trim().length < 3) {
            return { valid: false, message: 'Karta egasining ismi noto\'g\'ri' };
        }

        // Validate expiry date (MM/YY format)
        if (!expiryDate || !/^(0[1-9]|1[0-2])\/\d{2}$/.test(expiryDate)) {
            return { valid: false, message: 'Amal qilish muddati noto\'g\'ri formatda (MM/YY)' };
        }

        // Check if card is expired
        const [month, year] = expiryDate.split('/').map(Number);
        const currentDate = new Date();
        const currentYear = currentDate.getFullYear() % 100; // Get last 2 digits
        const currentMonth = currentDate.getMonth() + 1;

        if (year < currentYear || (year === currentYear && month < currentMonth)) {
            return { valid: false, message: 'Karta muddati o\'tgan' };
        }

        // Validate CVV (3 digits)
        if (!cvv || !/^\d{3}$/.test(cvv)) {
            return { valid: false, message: 'CVV kodi noto\'g\'ri formatda (3 ta raqam)' };
        }

        return { valid: true, message: '' };
    }

    /**
     * Process payment (simulated) with retry logic
     * Returns a promise that resolves with payment result
     */
    async processPayment(paymentMethod, paymentDetails, amount, retryCount = 0) {
        try {
            if (!this.validatePaymentMethod(paymentMethod)) {
                throw new Error('Invalid payment method');
            }

            if (typeof amount !== 'number' || amount <= 0) {
                throw new Error('Invalid payment amount');
            }

            // Simulate payment processing delay
            await new Promise(resolve => setTimeout(resolve, 2000));

            // Simulate payment success/failure (90% success rate)
            const isSuccess = Math.random() > 0.1;

            if (paymentMethod === 'card') {
                // Validate card details
                const validation = this.validateCardDetails(paymentDetails);
                if (!validation.valid) {
                    this.errorHandler.logError(
                        new Error(validation.message),
                        { operation: 'processPayment', paymentMethod }
                    );
                    return {
                        success: false,
                        message: validation.message,
                        transactionId: null,
                        canRetry: false
                    };
                }
            }

            if (isSuccess) {
                return {
                    success: true,
                    message: 'To\'lov muvaffaqiyatli amalga oshirildi',
                    transactionId: this.generateTransactionId(),
                    paymentMethod: paymentMethod,
                    amount: amount,
                    timestamp: Date.now()
                };
            } else {
                // Payment failed, but can retry
                this.errorHandler.logError(
                    new Error('Payment failed'),
                    { operation: 'processPayment', paymentMethod, retryCount }
                );

                return {
                    success: false,
                    message: 'To\'lov amalga oshmadi. Iltimos, qayta urinib ko\'ring.',
                    transactionId: null,
                    canRetry: true,
                    retryCount: retryCount
                };
            }
        } catch (error) {
            this.errorHandler.logError(error, {
                operation: 'processPayment',
                paymentMethod,
                retryCount
            });
            throw error;
        }
    }

    /**
     * Process payment with automatic retry
     */
    async processPaymentWithRetry(paymentMethod, paymentDetails, amount, maxRetries = 3) {
        let lastResult;

        for (let attempt = 0; attempt < maxRetries; attempt++) {
            lastResult = await this.processPayment(paymentMethod, paymentDetails, amount, attempt);

            if (lastResult.success || !lastResult.canRetry) {
                return lastResult;
            }

            // Wait before retrying
            if (attempt < maxRetries - 1) {
                await new Promise(resolve => setTimeout(resolve, 1000 * (attempt + 1)));
            }
        }

        return lastResult;
    }

    /**
     * Get error handler instance
     */
    getErrorHandler() {
        return this.errorHandler;
    }

    /**
     * Generate unique transaction ID
     */
    generateTransactionId() {
        const timestamp = Date.now();
        const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
        return `TXN${timestamp}${random}`;
    }

    /**
     * Get available payment methods
     * Returns mobile-specific methods if on mobile device
     */
    getAvailablePaymentMethods(isMobile = false) {
        const allMethods = [
            {
                id: 'card',
                name: 'Bank kartasi',
                description: 'Visa, Mastercard, Humo, Uzcard',
                icon: '💳',
                requiresDetails: true
            },
            {
                id: 'cash',
                name: 'Naqd pul',
                description: 'Yetkazib berishda to\'lash',
                icon: '💵',
                requiresDetails: false
            },
            {
                id: 'payme',
                name: 'Payme',
                description: 'Mobil to\'lov',
                icon: '📱',
                requiresDetails: false,
                mobileOnly: true
            },
            {
                id: 'click',
                name: 'Click',
                description: 'Mobil to\'lov',
                icon: '📲',
                requiresDetails: false,
                mobileOnly: true
            }
        ];

        // Return all methods including mobile-specific ones
        return allMethods;
    }
}

// Export for Node.js environment (for testing)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = PaymentHandler;
}
