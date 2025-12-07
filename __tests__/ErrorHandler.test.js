/**
 * ErrorHandler Tests
 * Tests for centralized error handling
 */
const ErrorHandler = require('../src/services/ErrorHandler');

describe('ErrorHandler', () => {
    let errorHandler;

    beforeEach(() => {
        errorHandler = new ErrorHandler();
    });

    describe('User-Friendly Messages', () => {
        test('should return Uzbek message for storage errors', () => {
            const error = new Error('Storage quota exceeded');
            const message = errorHandler.getUserFriendlyMessage(error);
            expect(message).toBe('Xotira to\'lgan. Iltimos, eski ma\'lumotlarni tozalang.');
        });

        test('should return Uzbek message for cart errors', () => {
            const error = new Error('Invalid product ID');
            const message = errorHandler.getUserFriendlyMessage(error);
            expect(message).toBe('Mahsulot topilmadi.');
        });

        test('should return Uzbek message for order errors', () => {
            const error = new Error('Order not found');
            const message = errorHandler.getUserFriendlyMessage(error);
            expect(message).toBe('Buyurtma topilmadi.');
        });

        test('should return default message for unknown errors', () => {
            const error = new Error('Some random error');
            const message = errorHandler.getUserFriendlyMessage(error);
            expect(message).toBe('Kutilmagan xatolik yuz berdi. Iltimos, qayta urinib ko\'ring.');
        });
    });

    describe('Error Logging', () => {
        test('should log errors with context', () => {
            const error = new Error('Test error');
            const context = { operation: 'testOp', data: 'testData' };

            errorHandler.logError(error, context);

            const log = errorHandler.getErrorLog();
            expect(log).toHaveLength(1);
            expect(log[0].message).toBe('Test error');
            expect(log[0].context).toEqual(context);
            expect(log[0]).toHaveProperty('timestamp');
        });

        test('should keep only last 50 errors', () => {
            // Log 60 errors
            for (let i = 0; i < 60; i++) {
                errorHandler.logError(new Error(`Error ${i}`));
            }

            const log = errorHandler.getErrorLog();
            expect(log).toHaveLength(50);
            expect(log[0].message).toBe('Error 10'); // First 10 should be removed
        });

        test('should clear error log', () => {
            errorHandler.logError(new Error('Test error'));
            expect(errorHandler.getErrorLog()).toHaveLength(1);

            errorHandler.clearErrorLog();
            expect(errorHandler.getErrorLog()).toHaveLength(0);
        });
    });

    describe('Error Handling', () => {
        test('should handle error and return user-friendly response', () => {
            const error = new Error('Invalid product ID');
            const result = errorHandler.handleError(error, { operation: 'addToCart' });

            expect(result.success).toBe(false);
            expect(result.error).toBe('Mahsulot topilmadi.');
            expect(result.originalError).toBe('Invalid product ID');
        });
    });

    describe('Retry Logic', () => {
        test('should retry operation and succeed', async () => {
            let attempts = 0;
            const operation = async () => {
                attempts++;
                if (attempts < 3) {
                    throw new Error('Temporary failure');
                }
                return 'success';
            };

            const result = await errorHandler.retryOperation(operation, 3);

            expect(result.success).toBe(true);
            expect(result.result).toBe('success');
            expect(result.attempts).toBe(3);
        });

        test('should not retry validation errors', async () => {
            let attempts = 0;
            const operation = async () => {
                attempts++;
                throw new Error('Invalid product ID');
            };

            await expect(errorHandler.retryOperation(operation, 3)).rejects.toThrow('Invalid product ID');
            expect(attempts).toBe(1); // Should not retry
        });

        test('should fail after max retries', async () => {
            const operation = async () => {
                throw new Error('Persistent failure');
            };

            await expect(errorHandler.retryOperation(operation, 3)).rejects.toThrow();
        });

        test('should use exponential backoff', async () => {
            const startTime = Date.now();
            let attempts = 0;

            const operation = async () => {
                attempts++;
                throw new Error('Temporary failure');
            };

            try {
                await errorHandler.retryOperation(operation, 3);
            } catch (error) {
                // Expected to fail
            }

            const duration = Date.now() - startTime;
            // Should take at least 1000 + 2000 = 3000ms (exponential backoff)
            expect(duration).toBeGreaterThanOrEqual(3000);
            expect(attempts).toBe(3);
        });
    });

    describe('Validation Error Detection', () => {
        test('should detect validation errors', () => {
            const validationErrors = [
                new Error('Invalid product ID'),
                new Error('Customer info is required'),
                new Error('Product not found'),
                new Error('Quantity must be positive')
            ];

            validationErrors.forEach(error => {
                expect(errorHandler.isValidationError(error)).toBe(true);
            });
        });

        test('should not detect non-validation errors', () => {
            const nonValidationErrors = [
                new Error('Network error'),
                new Error('Timeout'),
                new Error('Server error')
            ];

            nonValidationErrors.forEach(error => {
                expect(errorHandler.isValidationError(error)).toBe(false);
            });
        });
    });

    describe('Error Boundary', () => {
        test('should wrap operation in error boundary', async () => {
            const operation = async (value) => {
                if (value < 0) {
                    throw new Error('Invalid value');
                }
                return value * 2;
            };

            const wrapped = errorHandler.createErrorBoundary(operation, 0);

            // Should succeed
            const result1 = await wrapped(5);
            expect(result1).toBe(10);

            // Should return fallback on error
            const result2 = await wrapped(-5);
            expect(result2).toBe(0);
        });
    });
});
