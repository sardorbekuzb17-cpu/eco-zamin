/**
 * Order data model
 * Represents a customer order
 */
class Order {
    constructor({
        orderId,
        orderNumber,
        items,
        customerInfo,
        totalPrice,
        status = 'pending',
        createdAt = Date.now(),
        qrCode = null,
        certificate = null
    }) {
        this.orderId = orderId;
        this.orderNumber = orderNumber;
        this.items = items;
        this.customerInfo = customerInfo;
        this.totalPrice = totalPrice;
        this.status = status;
        this.createdAt = createdAt;
        this.qrCode = qrCode;
        this.certificate = certificate;
    }

    /**
     * Validate order data
     */
    static validate(order) {
        if (!order.orderId || typeof order.orderId !== 'string') {
            throw new Error('Order ID is required and must be a string');
        }
        if (!order.orderNumber || typeof order.orderNumber !== 'string') {
            throw new Error('Order number is required and must be a string');
        }
        if (!Array.isArray(order.items) || order.items.length === 0) {
            throw new Error('Order must have at least one item');
        }
        if (!order.customerInfo || typeof order.customerInfo !== 'object') {
            throw new Error('Customer info is required');
        }
        if (typeof order.totalPrice !== 'number' || order.totalPrice < 0) {
            throw new Error('Total price must be a non-negative number');
        }
        return true;
    }
}

module.exports = Order;
