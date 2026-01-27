/**
 * CartItem data model
 * Represents an item in the shopping cart
 */
class CartItem {
    constructor({ productId, quantity, addedAt = Date.now() }) {
        this.productId = productId;
        this.quantity = quantity;
        this.addedAt = addedAt;
    }

    /**
     * Validate cart item data
     */
    static validate(cartItem) {
        if (!cartItem.productId || typeof cartItem.productId !== 'string') {
            throw new Error('Product ID is required and must be a string');
        }
        if (typeof cartItem.quantity !== 'number' || cartItem.quantity <= 0) {
            throw new Error('Quantity must be a positive number');
        }
        return true;
    }
}

module.exports = CartItem;
