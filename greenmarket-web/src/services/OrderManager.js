const Order = require('../models/Order');
const StorageService = require('./StorageService');
const ErrorHandler = require('./ErrorHandler');

/**
 * OrderManager
 * Manages order creation and retrieval with error handling
 */
class OrderManager {
    constructor(storageService = new StorageService(), errorHandler = new ErrorHandler()) {
        this.storageService = storageService;
        this.errorHandler = errorHandler;
        this.storageKey = 'orders';
    }

    /**
     * Generate unique order number
     */
    generateOrderNumber() {
        const timestamp = Date.now();
        const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
        return `GM${timestamp}${random}`;
    }

    /**
     * Create new order with retry logic
     */
    async createOrder(customerInfo, cartItems, totalPrice) {
        try {
            if (!customerInfo || typeof customerInfo !== 'object') {
                throw new Error('Customer info is required');
            }
            if (!Array.isArray(cartItems) || cartItems.length === 0) {
                throw new Error('Cart items are required');
            }
            if (typeof totalPrice !== 'number' || totalPrice < 0) {
                throw new Error('Total price must be a non-negative number');
            }

            const orderId = `order_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
            const orderNumber = this.generateOrderNumber();

            const order = new Order({
                orderId,
                orderNumber,
                items: cartItems,
                customerInfo,
                totalPrice,
                status: 'pending',
                createdAt: Date.now()
            });

            // Use retry logic for saving
            const result = await this.errorHandler.retryOperation(async () => {
                const orders = this.getOrders();
                orders.push(order);
                this.storageService.save(this.storageKey, orders);
                return order;
            }, 3);

            return result.result;
        } catch (error) {
            this.errorHandler.logError(error, { operation: 'createOrder' });
            throw error;
        }
    }

    /**
     * Get all orders with error handling
     */
    getOrders() {
        try {
            const orders = this.storageService.load(this.storageKey);
            return orders || [];
        } catch (error) {
            this.errorHandler.logError(error, { operation: 'getOrders' });
            return [];
        }
    }

    /**
     * Get order by ID with error handling
     */
    getOrderById(orderId) {
        try {
            if (!orderId || typeof orderId !== 'string') {
                throw new Error('Invalid order ID');
            }

            const orders = this.getOrders();
            const order = orders.find(o => o.orderId === orderId);

            if (!order) {
                throw new Error('Order not found');
            }

            return order;
        } catch (error) {
            this.errorHandler.logError(error, { operation: 'getOrderById', orderId });
            throw error;
        }
    }

    /**
     * Update order status with retry logic
     */
    async updateOrderStatus(orderId, status) {
        try {
            if (!orderId || typeof orderId !== 'string') {
                throw new Error('Invalid order ID');
            }
            if (!status || typeof status !== 'string') {
                throw new Error('Invalid status');
            }

            // Use retry logic for updating
            const result = await this.errorHandler.retryOperation(async () => {
                const orders = this.getOrders();
                const order = orders.find(o => o.orderId === orderId);

                if (!order) {
                    throw new Error('Order not found');
                }

                order.status = status;

                // Add QR code and certificate for delivered orders
                if (status === 'delivered') {
                    order.qrCode = `QR_${orderId}`;
                    order.certificate = `CERT_${orderId}`;
                }

                this.storageService.save(this.storageKey, orders);
                return order;
            }, 3);

            return result.result;
        } catch (error) {
            this.errorHandler.logError(error, { operation: 'updateOrderStatus', orderId, status });
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

module.exports = OrderManager;
