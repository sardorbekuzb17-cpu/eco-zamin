/**
 * ErrorHandler
 * Centralized error handling with user-friendly messages and retry logic
 */
class ErrorHandler {
    constructor() {
        this.errorLog = [];
        this.maxRetries = 3;
        this.retryDelay = 1000; // 1 second
    }

    /**
     * Get user-friendly error message in Uzbek
     */
    getUserFriendlyMessage(error) {
        const errorMessages = {
            // Storage errors
            'Storage quota exceeded': 'Xotira to\'lgan. Iltimos, eski ma\'lumotlarni tozalang.',
            'Failed to save data': 'Ma\'lumotni saqlashda xatolik yuz berdi.',
            'Failed to load data': 'Ma\'lumotni yuklashda xatolik yuz berdi.',

            // Cart errors
            'Invalid product ID': 'Mahsulot topilmadi.',
            'Quantity must be a positive number': 'Miqdor musbat son bo\'lishi kerak.',
            'Product not found in cart': 'Mahsulot savatda topilmadi.',

            // Order errors
            'Customer info is required': 'Mijoz ma\'lumotlari to\'ldirilishi shart.',
            'Cart items are required': 'Savat bo\'sh bo\'lishi mumkin emas.',
            'Order not found': 'Buyurtma topilmadi.',

            // Payment errors
            'Payment method is required': 'To\'lov usulini tanlang.',
            'Unsupported payment method': 'Bu to\'lov usuli qo\'llab-quvvatlanmaydi.',
            'Invalid payment amount': 'To\'lov summasi noto\'g\'ri.',

            // Search errors
            'Search query must be a string': 'Qidiruv so\'zi matn bo\'lishi kerak.',
            'Min price cannot be greater than max price': 'Minimal narx maksimal narxdan katta bo\'lishi mumkin emas.',

            // Network errors
            'Network error': 'Internet aloqasi yo\'q. Iltimos, ulanishni tekshiring.',
            'Timeout': 'So\'rov vaqti tugadi. Iltimos, qayta urinib ko\'ring.'
        };

        const errorMessage = error.message || error.toString();

        // Check for exact matches
        for (const [key, value] of Object.entries(errorMessages)) {
            if (errorMessage.includes(key)) {
                return value;
            }
        }

        // Default message
        return 'Kutilmagan xatolik yuz berdi. Iltimos, qayta urinib ko\'ring.';
    }

    /**
     * Log error for debugging
     */
    logError(error, context = {}) {
        const errorEntry = {
            message: error.message || error.toString(),
            stack: error.stack,
            context,
            timestamp: Date.now()
        };

        this.errorLog.push(errorEntry);

        // Keep only last 50 errors
        if (this.errorLog.length > 50) {
            this.errorLog.shift();
        }

        // Log to console in development
        if (typeof process !== 'undefined' && process.env.NODE_ENV !== 'production') {
            console.error('Error logged:', errorEntry);
        }
    }

    /**
     * Handle error with user notification
     */
    handleError(error, context = {}) {
        this.logError(error, context);
        const userMessage = this.getUserFriendlyMessage(error);

        return {
            success: false,
            error: userMessage,
            originalError: error.message
        };
    }

    /**
     * Retry operation with exponential backoff
     */
    async retryOperation(operation, maxRetries = this.maxRetries) {
        let lastError;

        for (let attempt = 0; attempt < maxRetries; attempt++) {
            try {
                const result = await operation();
                return { success: true, result, attempts: attempt + 1 };
            } catch (error) {
                lastError = error;
                this.logError(error, { attempt: attempt + 1, maxRetries });

                // Don't retry on validation errors
                if (this.isValidationError(error)) {
                    throw error;
                }

                // Wait before retrying (exponential backoff)
                if (attempt < maxRetries - 1) {
                    const delay = this.retryDelay * Math.pow(2, attempt);
                    await this.sleep(delay);
                }
            }
        }

        // All retries failed
        throw new Error(`Operatsiya ${maxRetries} marta urinildi, lekin muvaffaqiyatsiz bo'ldi: ${lastError.message}`);
    }

    /**
     * Check if error is a validation error (should not retry)
     */
    isValidationError(error) {
        const validationKeywords = [
            'Invalid',
            'required',
            'must be',
            'cannot be',
            'not found',
            'noto\'g\'ri',
            'topilmadi'
        ];

        const errorMessage = error.message || error.toString();
        return validationKeywords.some(keyword =>
            errorMessage.toLowerCase().includes(keyword.toLowerCase())
        );
    }

    /**
     * Sleep utility for retry delays
     */
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    /**
     * Get error log
     */
    getErrorLog() {
        return [...this.errorLog];
    }

    /**
     * Clear error log
     */
    clearErrorLog() {
        this.errorLog = [];
    }

    /**
     * Create error boundary wrapper for UI operations
     */
    createErrorBoundary(operation, fallbackValue = null) {
        return async (...args) => {
            try {
                return await operation(...args);
            } catch (error) {
                const handled = this.handleError(error, {
                    operation: operation.name,
                    args
                });

                // Show user notification if in browser
                if (typeof window !== 'undefined' && window.showNotification) {
                    window.showNotification(handled.error, 'error');
                }

                return fallbackValue;
            }
        };
    }
}

// Export for Node.js environment (for testing)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ErrorHandler;
}
