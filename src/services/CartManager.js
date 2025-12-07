const CartItem = require('../models/CartItem');
const StorageService = require('./StorageService');
const ErrorHandler = require('./ErrorHandler');

/**
 * CartManager
 * Manages shopping cart operations with error handling
 */
class CartManager {
    constructor(storageService = new StorageService(), errorHandler = new ErrorHandler()) {
        this.storageService = storageService;
        this.errorHandler = errorHandler;
        this.storageKey = 'cart';
        this.items = this.loadCart();
        this._cachedTotalPrice = null;
        this._cachedItemCount = null;
        this._cacheInvalidated = true;
    }

    /**
     * Load cart from storage with error handling
     */
    loadCart() {
        try {
            const data = this.storageService.load(this.storageKey);
            return data?.items || [];
        } catch (error) {
            this.errorHandler.logError(error, { operation: 'loadCart' });
            // Return empty cart on error
            return [];
        }
    }

    /**
     * Save cart to storage with retry logic
     */
    async saveCart() {
        try {
            const result = this.storageService.save(this.storageKey, {
                items: this.items,
                lastUpdated: Date.now()
            });

            // Show warning if using fallback storage
            if (result && result.usedFallback && typeof window !== 'undefined' && window.showNotification) {
                window.showNotification(
                    result.warning || 'Ma\'lumotlar vaqtinchalik xotirada saqlandi',
                    'warning'
                );
            }

            return result || { success: true, usedFallback: false };
        } catch (error) {
            this.errorHandler.logError(error, { operation: 'saveCart' });
            throw error;
        }
    }

    /**
     * Invalidate cache
     */
    _invalidateCache() {
        this._cachedTotalPrice = null;
        this._cachedItemCount = null;
        this._cacheInvalidated = true;
    }

    /**
     * Add item to cart or increase quantity if exists
     */
    async addItem(productId, quantity = 1) {
        try {
            if (!productId || typeof productId !== 'string') {
                throw new Error('Invalid product ID');
            }
            if (typeof quantity !== 'number' || quantity <= 0) {
                throw new Error('Quantity must be a positive number');
            }

            const existingItem = this.items.find(item => item.productId === productId);

            if (existingItem) {
                existingItem.quantity += quantity;
            } else {
                const newItem = new CartItem({ productId, quantity });
                this.items.push(newItem);
            }

            this._invalidateCache();
            await this.saveCart();
            return this.items;
        } catch (error) {
            this.errorHandler.logError(error, { operation: 'addItem', productId, quantity });
            throw error;
        }
    }

    /**
     * Remove item from cart
     */
    async removeItem(productId) {
        try {
            if (!productId || typeof productId !== 'string') {
                throw new Error('Invalid product ID');
            }

            const initialLength = this.items.length;
            this.items = this.items.filter(item => item.productId !== productId);

            if (this.items.length === initialLength) {
                throw new Error('Product not found in cart');
            }

            this._invalidateCache();
            await this.saveCart();
            return this.items;
        } catch (error) {
            this.errorHandler.logError(error, { operation: 'removeItem', productId });
            throw error;
        }
    }

    /**
     * Update item quantity
     */
    async updateQuantity(productId, quantity) {
        try {
            if (!productId || typeof productId !== 'string') {
                throw new Error('Invalid product ID');
            }
            if (typeof quantity !== 'number' || quantity < 0) {
                throw new Error('Quantity must be a non-negative number');
            }

            const item = this.items.find(item => item.productId === productId);

            if (!item) {
                throw new Error('Product not found in cart');
            }

            if (quantity === 0) {
                return await this.removeItem(productId);
            }

            item.quantity = quantity;
            this._invalidateCache();
            await this.saveCart();
            return this.items;
        } catch (error) {
            this.errorHandler.logError(error, { operation: 'updateQuantity', productId, quantity });
            throw error;
        }
    }

    /**
     * Get all cart items
     */
    getItems() {
        return [...this.items];
    }

    /**
     * Get total price (requires product data) with caching
     */
    getTotalPrice(products) {
        if (!Array.isArray(products)) {
            throw new Error('Products must be an array');
        }

        // Return cached value if available and cache is valid
        if (!this._cacheInvalidated && this._cachedTotalPrice !== null) {
            return this._cachedTotalPrice;
        }

        const totalPrice = this.items.reduce((total, item) => {
            const product = products.find(p => p.id === item.productId);
            if (product) {
                return total + (product.price * item.quantity);
            }
            return total;
        }, 0);

        // Cache the result
        this._cachedTotalPrice = totalPrice;
        this._cacheInvalidated = false;

        return totalPrice;
    }

    /**
     * Get total item count with caching
     */
    getItemCount() {
        // Return cached value if available and cache is valid
        if (!this._cacheInvalidated && this._cachedItemCount !== null) {
            return this._cachedItemCount;
        }

        const itemCount = this.items.reduce((count, item) => count + item.quantity, 0);

        // Cache the result
        this._cachedItemCount = itemCount;

        return itemCount;
    }

    /**
     * Clear cart
     */
    async clear() {
        try {
            this.items = [];
            this._invalidateCache();
            await this.saveCart();
            return this.items;
        } catch (error) {
            this.errorHandler.logError(error, { operation: 'clear' });
            throw error;
        }
    }

    /**
     * Get error handler instance
     */
    getErrorHandler() {
        return this.errorHandler;
    }
}

module.exports = CartManager;
