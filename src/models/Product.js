/**
 * Product data model
 * Represents a tree or plant available for purchase
 */
class Product {
    constructor({ id, name, price, description, icon, type, inStock = true, co2Absorption, image = null }) {
        this.id = id;
        this.name = name;
        this.price = price;
        this.description = description;
        this.icon = icon;
        this.type = type;
        this.inStock = inStock;
        this.co2Absorption = co2Absorption;
        this.image = image;
    }

    /**
     * Validate product data
     */
    static validate(product) {
        if (!product.id || typeof product.id !== 'string') {
            throw new Error('Product ID is required and must be a string');
        }
        if (!product.name || typeof product.name !== 'string') {
            throw new Error('Product name is required and must be a string');
        }
        if (typeof product.price !== 'number' || product.price < 0) {
            throw new Error('Product price must be a non-negative number');
        }
        if (typeof product.inStock !== 'boolean') {
            throw new Error('Product inStock must be a boolean');
        }
        return true;
    }
}

module.exports = Product;
