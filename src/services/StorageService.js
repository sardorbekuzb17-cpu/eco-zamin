/**
 * StorageService
 * Handles localStorage operations with error handling and graceful degradation
 */
class StorageService {
    constructor(storagePrefix = 'greenmarket') {
        this.storagePrefix = storagePrefix;
        this.isAvailable = this.checkStorageAvailability();
        this.fallbackStorage = {}; // In-memory fallback
    }

    /**
     * Check if localStorage is available
     */
    checkStorageAvailability() {
        try {
            const testKey = '__storage_test__';
            localStorage.setItem(testKey, 'test');
            localStorage.removeItem(testKey);
            return true;
        } catch (error) {
            console.warn('localStorage mavjud emas, xotira rejimida ishlayapti');
            return false;
        }
    }

    /**
     * Get full key with prefix
     */
    getKey(key) {
        return `${this.storagePrefix}_${key}`;
    }

    /**
     * Save data to localStorage with fallback
     */
    save(key, data) {
        const fullKey = this.getKey(key);

        try {
            const serialized = JSON.stringify(data);

            if (this.isAvailable) {
                try {
                    localStorage.setItem(fullKey, serialized);
                    return { success: true, usedFallback: false };
                } catch (error) {
                    if (error.name === 'QuotaExceededError') {
                        // Try to clear old data
                        const cleared = this.clearOldData();
                        if (cleared) {
                            // Retry after clearing
                            try {
                                localStorage.setItem(fullKey, serialized);
                                return { success: true, usedFallback: false, clearedOldData: true };
                            } catch (retryError) {
                                // Still failed, use fallback
                                this.fallbackStorage[fullKey] = serialized;
                                return {
                                    success: true,
                                    usedFallback: true,
                                    warning: 'localStorage to\'lgan, xotira rejimida saqlandi'
                                };
                            }
                        } else {
                            // Use fallback
                            this.fallbackStorage[fullKey] = serialized;
                            return {
                                success: true,
                                usedFallback: true,
                                warning: 'localStorage to\'lgan, xotira rejimida saqlandi'
                            };
                        }
                    }
                    throw error;
                }
            } else {
                // Use fallback storage
                this.fallbackStorage[fullKey] = serialized;
                return { success: true, usedFallback: true };
            }
        } catch (error) {
            throw new Error(`Ma'lumotni saqlashda xatolik: ${error.message}`);
        }
    }

    /**
     * Load data from localStorage with fallback
     */
    load(key) {
        const fullKey = this.getKey(key);

        try {
            let serialized = null;

            if (this.isAvailable) {
                serialized = localStorage.getItem(fullKey);
            }

            // If not found in localStorage, check fallback
            if (serialized === null && this.fallbackStorage[fullKey]) {
                serialized = this.fallbackStorage[fullKey];
            }

            if (serialized === null) {
                return null;
            }

            return JSON.parse(serialized);
        } catch (error) {
            console.error(`Ma'lumotni yuklashda xatolik: ${error.message}`);
            return null;
        }
    }

    /**
     * Remove data from localStorage
     */
    remove(key) {
        const fullKey = this.getKey(key);

        try {
            if (this.isAvailable) {
                localStorage.removeItem(fullKey);
            }
            delete this.fallbackStorage[fullKey];
            return true;
        } catch (error) {
            throw new Error(`Ma'lumotni o'chirishda xatolik: ${error.message}`);
        }
    }

    /**
     * Clear all data with prefix
     */
    clear() {
        try {
            if (this.isAvailable) {
                const keys = Object.keys(localStorage);
                keys.forEach(key => {
                    if (key.startsWith(this.storagePrefix)) {
                        localStorage.removeItem(key);
                    }
                });
            }

            // Clear fallback storage
            Object.keys(this.fallbackStorage).forEach(key => {
                if (key.startsWith(this.storagePrefix)) {
                    delete this.fallbackStorage[key];
                }
            });

            return true;
        } catch (error) {
            throw new Error(`Ma'lumotlarni tozalashda xatolik: ${error.message}`);
        }
    }

    /**
     * Clear old data to free up space
     * Removes oldest cart and order data
     */
    clearOldData() {
        try {
            if (!this.isAvailable) return false;

            const keys = Object.keys(localStorage);
            const greenmarketKeys = keys.filter(key => key.startsWith(this.storagePrefix));

            // Try to remove old cart data first
            const cartKey = this.getKey('cart');
            if (greenmarketKeys.includes(cartKey)) {
                localStorage.removeItem(cartKey);
                return true;
            }

            // If no cart, try to remove oldest orders
            const ordersKey = this.getKey('orders');
            const orders = this.load('orders');
            if (orders && orders.length > 0) {
                // Keep only last 5 orders
                const recentOrders = orders.slice(-5);
                this.save('orders', recentOrders);
                return true;
            }

            return false;
        } catch (error) {
            console.error('Eski ma\'lumotlarni tozalashda xatolik:', error);
            return false;
        }
    }

    /**
     * Get storage status
     */
    getStorageStatus() {
        return {
            available: this.isAvailable,
            usingFallback: !this.isAvailable || Object.keys(this.fallbackStorage).length > 0,
            fallbackItemCount: Object.keys(this.fallbackStorage).length
        };
    }
}

module.exports = StorageService;
