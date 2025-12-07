/**
 * ProductManager
 * Handles product CRUD operations for admin panel
 */
const StorageService = require('./StorageService');
const Product = require('../models/Product');

class ProductManager {
    constructor() {
        this.storageService = new StorageService('greenmarket');
        this.products = [];
        this.productsCache = null;
        this.cacheTimestamp = null;
        this.CACHE_DURATION = 5 * 60 * 1000; // 5 minutes cache
        this.PAGE_SIZE = 50; // Pagination threshold
        this.loadProducts();
    }

    /**
     * Load products from storage
     */
    loadProducts() {
        try {
            const savedProducts = this.storageService.load('products');
            if (savedProducts && Array.isArray(savedProducts)) {
                this.products = savedProducts.map(p => new Product(p));
            } else {
                // Initialize with default products if none exist
                this.products = this.getDefaultProducts();
                this.saveProducts();
            }
        } catch (error) {
            console.error('Mahsulotlarni yuklashda xato:', error);
            this.products = this.getDefaultProducts();
        }
    }

    /**
     * Save products to storage
     */
    saveProducts() {
        try {
            this.storageService.save('products', this.products);
        } catch (error) {
            throw new Error(`Mahsulotlarni saqlashda xato: ${error.message}`);
        }
    }

    /**
     * Get default products
     */
    getDefaultProducts() {
        return [
            new Product({
                id: 'chinor',
                name: 'Chinordan',
                price: 150000,
                icon: '🌳',
                type: 'daraxt',
                description: 'Ushbu daraxt tez o\'sadi, soyasi qalin va havo tozalashda juda samarali.',
                inStock: true,
                co2Absorption: 20
            }),
            new Product({
                id: 'olma',
                name: 'Olmali daraxt',
                price: 120000,
                icon: '🍏',
                type: 'meva',
                description: 'Meva beruvchi daraxt. Havoni tozalash bilan birga, bog\'ingizga chiroy beradi.',
                inStock: true,
                co2Absorption: 15
            }),
            new Product({
                id: 'atirgul',
                name: 'Atirgul butasi',
                price: 45000,
                icon: '🌸',
                type: 'buta',
                description: 'Bog\' va hovlilarga chiroy beruvchi atirgul butasi, oson parvarish qilinadi.',
                inStock: true,
                co2Absorption: 5
            })
        ];
    }

    /**
     * Get all products with caching
     */
    getAllProducts() {
        // Check if cache is valid
        if (this.productsCache && this.cacheTimestamp) {
            const now = Date.now();
            if (now - this.cacheTimestamp < this.CACHE_DURATION) {
                return [...this.productsCache];
            }
        }

        // Try to load from sessionStorage first
        try {
            const cachedData = sessionStorage.getItem('greenmarket_products_cache');
            const cacheTime = sessionStorage.getItem('greenmarket_products_cache_time');

            if (cachedData && cacheTime) {
                const now = Date.now();
                const timestamp = parseInt(cacheTime, 10);

                if (now - timestamp < this.CACHE_DURATION) {
                    this.productsCache = JSON.parse(cachedData);
                    this.cacheTimestamp = timestamp;
                    return [...this.productsCache];
                }
            }
        } catch (error) {
            console.error('Cache yuklashda xato:', error);
        }

        // Update cache
        this.updateCache();
        return [...this.products];
    }

    /**
     * Update products cache
     */
    updateCache() {
        this.productsCache = [...this.products];
        this.cacheTimestamp = Date.now();

        try {
            sessionStorage.setItem('greenmarket_products_cache', JSON.stringify(this.productsCache));
            sessionStorage.setItem('greenmarket_products_cache_time', this.cacheTimestamp.toString());
        } catch (error) {
            console.error('Cache saqlashda xato:', error);
        }
    }

    /**
     * Clear products cache
     */
    clearCache() {
        this.productsCache = null;
        this.cacheTimestamp = null;

        try {
            sessionStorage.removeItem('greenmarket_products_cache');
            sessionStorage.removeItem('greenmarket_products_cache_time');
        } catch (error) {
            console.error('Cache tozalashda xato:', error);
        }
    }

    /**
     * Get paginated products
     */
    getPaginatedProducts(page = 1, pageSize = null) {
        const size = pageSize || this.PAGE_SIZE;
        const allProducts = this.getAllProducts();

        if (allProducts.length <= size) {
            return {
                products: allProducts,
                currentPage: 1,
                totalPages: 1,
                totalProducts: allProducts.length,
                hasNextPage: false,
                hasPrevPage: false
            };
        }

        const startIndex = (page - 1) * size;
        const endIndex = startIndex + size;
        const paginatedProducts = allProducts.slice(startIndex, endIndex);
        const totalPages = Math.ceil(allProducts.length / size);

        return {
            products: paginatedProducts,
            currentPage: page,
            totalPages: totalPages,
            totalProducts: allProducts.length,
            hasNextPage: page < totalPages,
            hasPrevPage: page > 1
        };
    }

    /**
     * Get product by ID
     */
    getProductById(productId) {
        return this.products.find(p => p.id === productId);
    }

    /**
     * Add new product
     */
    addProduct(productData) {
        // Check if product with same ID already exists
        const existingProduct = this.getProductById(productData.id);
        if (existingProduct) {
            throw new Error('Bu ID bilan mahsulot allaqachon mavjud');
        }

        // Validate product data
        Product.validate(productData);

        // Create new product
        const newProduct = new Product(productData);
        this.products.push(newProduct);
        this.saveProducts();

        // Clear cache when products change
        this.clearCache();

        return newProduct;
    }

    /**
     * Update existing product
     */
    updateProduct(productId, updates) {
        const productIndex = this.products.findIndex(p => p.id === productId);

        if (productIndex === -1) {
            throw new Error('Mahsulot topilmadi');
        }

        // Create updated product data
        const updatedData = {
            ...this.products[productIndex],
            ...updates,
            id: productId // Ensure ID doesn't change
        };

        // Validate updated data
        Product.validate(updatedData);

        // Update product
        this.products[productIndex] = new Product(updatedData);
        this.saveProducts();

        // Clear cache when products change
        this.clearCache();

        return this.products[productIndex];
    }

    /**
     * Delete product
     */
    deleteProduct(productId) {
        const productIndex = this.products.findIndex(p => p.id === productId);

        if (productIndex === -1) {
            throw new Error('Mahsulot topilmadi');
        }

        // Remove product
        const deletedProduct = this.products.splice(productIndex, 1)[0];
        this.saveProducts();

        // Clear cache when products change
        this.clearCache();

        return deletedProduct;
    }

    /**
     * Toggle product stock status
     */
    toggleStock(productId) {
        const product = this.getProductById(productId);

        if (!product) {
            throw new Error('Mahsulot topilmadi');
        }

        product.inStock = !product.inStock;
        this.saveProducts();

        return product;
    }

    /**
     * Update product image
     */
    updateProductImage(productId, imageData) {
        const product = this.getProductById(productId);

        if (!product) {
            throw new Error('Mahsulot topilmadi');
        }

        // In a real application, this would upload to a server
        // For now, we'll store as base64 or URL
        if (!imageData || typeof imageData !== 'string') {
            throw new Error('Noto\'g\'ri rasm ma\'lumoti');
        }

        product.image = imageData;
        this.saveProducts();

        return product;
    }

    /**
     * Check if product can be purchased
     */
    canPurchase(productId) {
        const product = this.getProductById(productId);

        if (!product) {
            return false;
        }

        return product.inStock === true;
    }
}

module.exports = ProductManager;
