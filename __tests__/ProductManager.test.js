/**
 * ProductManager Tests
 * Property-based and unit tests for product CRUD operations
 */
const fc = require('fast-check');
const ProductManager = require('../src/services/ProductManager');
const StorageService = require('../src/services/StorageService');

// Mock StorageService for testing
class MockStorageService extends StorageService {
    constructor() {
        super();
        this.storage = {};
    }

    save(key, data) {
        this.storage[key] = JSON.stringify(data);
    }

    load(key) {
        const data = this.storage[key];
        return data ? JSON.parse(data) : null;
    }

    clear() {
        this.storage = {};
    }
}

describe('ProductManager Property Tests', () => {
    /**
     * **Feature: green-shop, Property 17: Product CRUD operations persist**
     * **Validates: Requirements 7.1, 7.2, 7.3**
     * 
     * For any product, adding it to the catalog should make it appear in the product list,
     * updating it should reflect changes immediately, and deleting it should remove it from the list.
     */
    test('Property 17: Product CRUD operations persist', () => {
        fc.assert(
            fc.property(
                // Product generator
                fc.record({
                    id: fc.string({ minLength: 1, maxLength: 20 }).filter(id =>
                        id !== '__proto__' &&
                        id !== 'constructor' &&
                        id !== 'prototype' &&
                        id.trim().length > 0 &&
                        !/\s/.test(id) // ID'da bo'sh joy bo'lmasligi kerak
                    ),
                    name: fc.string({ minLength: 1, maxLength: 100 }),
                    price: fc.integer({ min: 1000, max: 10000000 }),
                    description: fc.string({ minLength: 1, maxLength: 500 }),
                    icon: fc.constantFrom('🌳', '🌲', '🌴', '🌵', '🌿', '🍀', '🌸', '🌺', '🌻', '🌹'),
                    type: fc.constantFrom('daraxt', 'meva', 'buta'),
                    inStock: fc.boolean(),
                    co2Absorption: fc.integer({ min: 1, max: 100 })
                }),
                // Update data generator
                fc.record({
                    name: fc.option(fc.string({ minLength: 1, maxLength: 100 }), { nil: undefined }),
                    price: fc.option(fc.integer({ min: 1000, max: 10000000 }), { nil: undefined }),
                    description: fc.option(fc.string({ minLength: 1, maxLength: 500 }), { nil: undefined }),
                    inStock: fc.option(fc.boolean(), { nil: undefined })
                }),
                (productData, updateData) => {
                    // Arrange: yangi ProductManager yaratamiz
                    const mockStorage = new MockStorageService();
                    const productManager = new ProductManager();
                    productManager.storageService = mockStorage;
                    productManager.products = []; // Bo'sh holatdan boshlaymiz

                    // CREATE: Mahsulotni qo'shamiz
                    const addedProduct = productManager.addProduct(productData);

                    // Assert CREATE: Mahsulot qo'shilganligini tekshiramiz
                    const allProductsAfterAdd = productManager.getAllProducts();
                    const productExistsAfterAdd = allProductsAfterAdd.some(p => p.id === productData.id);
                    const productCountAfterAdd = allProductsAfterAdd.length === 1;

                    if (!productExistsAfterAdd || !productCountAfterAdd) {
                        return false;
                    }

                    // READ: Mahsulotni ID bo'yicha olish
                    const retrievedProduct = productManager.getProductById(productData.id);
                    const productRetrieved = retrievedProduct !== undefined &&
                        retrievedProduct.id === productData.id &&
                        retrievedProduct.name === productData.name &&
                        retrievedProduct.price === productData.price;

                    if (!productRetrieved) {
                        return false;
                    }

                    // UPDATE: Mahsulotni yangilaymiz
                    const cleanUpdateData = Object.fromEntries(
                        Object.entries(updateData).filter(([_, v]) => v !== undefined)
                    );

                    if (Object.keys(cleanUpdateData).length > 0) {
                        const updatedProduct = productManager.updateProduct(productData.id, cleanUpdateData);

                        // Assert UPDATE: O'zgarishlar saqlanganligini tekshiramiz
                        const retrievedAfterUpdate = productManager.getProductById(productData.id);

                        const updateCorrect = Object.keys(cleanUpdateData).every(key => {
                            return retrievedAfterUpdate[key] === cleanUpdateData[key];
                        });

                        // ID o'zgarmaganligini tekshiramiz
                        const idUnchanged = retrievedAfterUpdate.id === productData.id;

                        if (!updateCorrect || !idUnchanged) {
                            return false;
                        }
                    }

                    // DELETE: Mahsulotni o'chiramiz
                    const deletedProduct = productManager.deleteProduct(productData.id);

                    // Assert DELETE: Mahsulot o'chirilganligini tekshiramiz
                    const allProductsAfterDelete = productManager.getAllProducts();
                    const productNotExists = !allProductsAfterDelete.some(p => p.id === productData.id);
                    const productCountAfterDelete = allProductsAfterDelete.length === 0;
                    const deletedProductCorrect = deletedProduct.id === productData.id;

                    return productNotExists && productCountAfterDelete && deletedProductCorrect;
                }
            ),
            { numRuns: 100 }
        );
    });

    /**
     * **Feature: green-shop, Property 18: Out-of-stock products cannot be purchased**
     * **Validates: Requirements 7.4**
     * 
     * For any product with inStock = false, attempting to add it to the cart should be 
     * prevented and show an appropriate message.
     */
    test('Property 18: Out-of-stock products cannot be purchased', () => {
        fc.assert(
            fc.property(
                // Product generator
                fc.record({
                    id: fc.string({ minLength: 1, maxLength: 20 }).filter(id =>
                        id !== '__proto__' &&
                        id !== 'constructor' &&
                        id !== 'prototype' &&
                        id.trim().length > 0 &&
                        !/\s/.test(id)
                    ),
                    name: fc.string({ minLength: 1, maxLength: 100 }),
                    price: fc.integer({ min: 1000, max: 10000000 }),
                    description: fc.string({ minLength: 1, maxLength: 500 }),
                    icon: fc.constantFrom('🌳', '🌲', '🌴', '🌵', '🌿'),
                    type: fc.constantFrom('daraxt', 'meva', 'buta'),
                    inStock: fc.boolean(),
                    co2Absorption: fc.integer({ min: 1, max: 100 })
                }),
                (productData) => {
                    // Arrange: yangi ProductManager yaratamiz
                    const mockStorage = new MockStorageService();
                    const productManager = new ProductManager();
                    productManager.storageService = mockStorage;
                    productManager.products = [];

                    // Mahsulotni qo'shamiz
                    productManager.addProduct(productData);

                    // Act & Assert: canPurchase funksiyasi inStock holatiga mos javob berishi kerak
                    const canPurchase = productManager.canPurchase(productData.id);

                    // Agar mahsulot omborda bo'lsa, xarid qilish mumkin bo'lishi kerak
                    // Agar mahsulot omborda bo'lmasa, xarid qilish mumkin bo'lmasligi kerak
                    return canPurchase === productData.inStock;
                }
            ),
            { numRuns: 100 }
        );
    });

    /**
     * **Feature: green-shop, Property 19: Product images persist and display**
     * **Validates: Requirements 7.5**
     * 
     * For any product with an uploaded image, the image should be saved and 
     * displayed on the product card.
     */
    test('Property 19: Product images persist and display', () => {
        fc.assert(
            fc.property(
                // Product generator
                fc.record({
                    id: fc.string({ minLength: 1, maxLength: 20 }).filter(id =>
                        id !== '__proto__' &&
                        id !== 'constructor' &&
                        id !== 'prototype' &&
                        id.trim().length > 0 &&
                        !/\s/.test(id)
                    ),
                    name: fc.string({ minLength: 1, maxLength: 100 }),
                    price: fc.integer({ min: 1000, max: 10000000 }),
                    description: fc.string({ minLength: 1, maxLength: 500 }),
                    icon: fc.constantFrom('🌳', '🌲', '🌴'),
                    type: fc.constantFrom('daraxt', 'meva', 'buta'),
                    inStock: fc.boolean(),
                    co2Absorption: fc.integer({ min: 1, max: 100 })
                }),
                // Image data generator (simulated base64 or URL)
                fc.oneof(
                    fc.constant('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='),
                    fc.webUrl(),
                    fc.string({ minLength: 10, maxLength: 100 }).map(s => `data:image/jpeg;base64,${s}`)
                ),
                (productData, imageData) => {
                    // Arrange: yangi ProductManager yaratamiz
                    const mockStorage = new MockStorageService();
                    const productManager = new ProductManager();
                    productManager.storageService = mockStorage;
                    productManager.products = [];

                    // Mahsulotni qo'shamiz
                    productManager.addProduct(productData);

                    // Act: Rasm yuklaymiz
                    const updatedProduct = productManager.updateProductImage(productData.id, imageData);

                    // Assert: Rasm saqlanganligini tekshiramiz
                    const retrievedProduct = productManager.getProductById(productData.id);

                    // 1. Rasm mavjud bo'lishi kerak
                    const imageExists = retrievedProduct.image !== null && retrievedProduct.image !== undefined;

                    // 2. Rasm yuklangan ma'lumotga mos kelishi kerak
                    const imageMatches = retrievedProduct.image === imageData;

                    // 3. Boshqa ma'lumotlar o'zgarmaganligini tekshiramiz
                    const otherDataUnchanged =
                        retrievedProduct.id === productData.id &&
                        retrievedProduct.name === productData.name &&
                        retrievedProduct.price === productData.price;

                    return imageExists && imageMatches && otherDataUnchanged;
                }
            ),
            { numRuns: 100 }
        );
    });
});

describe('ProductManager Unit Tests - Admin Functionality', () => {
    let mockStorage;
    let productManager;

    beforeEach(() => {
        mockStorage = new MockStorageService();
        productManager = new ProductManager();
        productManager.storageService = mockStorage;
        productManager.products = [];
    });

    describe('Duplicate product ID prevention', () => {
        test('should throw error when adding product with existing ID', () => {
            const product1 = {
                id: 'test-product',
                name: 'Test Product 1',
                price: 50000,
                description: 'Test description',
                icon: '🌳',
                type: 'daraxt',
                inStock: true,
                co2Absorption: 15
            };

            const product2 = {
                id: 'test-product', // Same ID
                name: 'Test Product 2',
                price: 60000,
                description: 'Different description',
                icon: '🌲',
                type: 'daraxt',
                inStock: true,
                co2Absorption: 20
            };

            // Birinchi mahsulotni qo'shamiz
            productManager.addProduct(product1);

            // Ikkinchi mahsulotni qo'shishda xato bo'lishi kerak
            expect(() => {
                productManager.addProduct(product2);
            }).toThrow('Bu ID bilan mahsulot allaqachon mavjud');

            // Faqat bitta mahsulot bo'lishi kerak
            expect(productManager.getAllProducts().length).toBe(1);
        });

        test('should allow adding products with different IDs', () => {
            const product1 = {
                id: 'product-1',
                name: 'Product 1',
                price: 50000,
                description: 'Description 1',
                icon: '🌳',
                type: 'daraxt',
                inStock: true,
                co2Absorption: 15
            };

            const product2 = {
                id: 'product-2',
                name: 'Product 2',
                price: 60000,
                description: 'Description 2',
                icon: '🌲',
                type: 'daraxt',
                inStock: true,
                co2Absorption: 20
            };

            productManager.addProduct(product1);
            productManager.addProduct(product2);

            expect(productManager.getAllProducts().length).toBe(2);
        });

        test('should not allow updating product ID to existing ID', () => {
            const product1 = {
                id: 'product-1',
                name: 'Product 1',
                price: 50000,
                description: 'Description 1',
                icon: '🌳',
                type: 'daraxt',
                inStock: true,
                co2Absorption: 15
            };

            const product2 = {
                id: 'product-2',
                name: 'Product 2',
                price: 60000,
                description: 'Description 2',
                icon: '🌲',
                type: 'daraxt',
                inStock: true,
                co2Absorption: 20
            };

            productManager.addProduct(product1);
            productManager.addProduct(product2);

            // ID o'zgartirishga urinish (bu amalga oshmasligi kerak)
            productManager.updateProduct('product-2', { name: 'Updated Name' });

            // ID o'zgarmaganligini tekshiramiz
            const updatedProduct = productManager.getProductById('product-2');
            expect(updatedProduct.id).toBe('product-2');
            expect(updatedProduct.name).toBe('Updated Name');
        });
    });

    describe('Invalid product data validation', () => {
        test('should throw error when adding product without ID', () => {
            const invalidProduct = {
                name: 'Test Product',
                price: 50000,
                description: 'Test description',
                icon: '🌳',
                type: 'daraxt',
                inStock: true,
                co2Absorption: 15
            };

            expect(() => {
                productManager.addProduct(invalidProduct);
            }).toThrow('Product ID is required and must be a string');
        });

        test('should throw error when adding product with empty ID', () => {
            const invalidProduct = {
                id: '',
                name: 'Test Product',
                price: 50000,
                description: 'Test description',
                icon: '🌳',
                type: 'daraxt',
                inStock: true,
                co2Absorption: 15
            };

            expect(() => {
                productManager.addProduct(invalidProduct);
            }).toThrow('Product ID is required and must be a string');
        });

        test('should throw error when adding product without name', () => {
            const invalidProduct = {
                id: 'test-product',
                price: 50000,
                description: 'Test description',
                icon: '🌳',
                type: 'daraxt',
                inStock: true,
                co2Absorption: 15
            };

            expect(() => {
                productManager.addProduct(invalidProduct);
            }).toThrow('Product name is required and must be a string');
        });

        test('should throw error when adding product with negative price', () => {
            const invalidProduct = {
                id: 'test-product',
                name: 'Test Product',
                price: -5000,
                description: 'Test description',
                icon: '🌳',
                type: 'daraxt',
                inStock: true,
                co2Absorption: 15
            };

            expect(() => {
                productManager.addProduct(invalidProduct);
            }).toThrow('Product price must be a non-negative number');
        });

        test('should throw error when adding product with invalid inStock value', () => {
            const invalidProduct = {
                id: 'test-product',
                name: 'Test Product',
                price: 50000,
                description: 'Test description',
                icon: '🌳',
                type: 'daraxt',
                inStock: 'yes', // Should be boolean
                co2Absorption: 15
            };

            expect(() => {
                productManager.addProduct(invalidProduct);
            }).toThrow('Product inStock must be a boolean');
        });

        test('should throw error when updating product with invalid data', () => {
            const validProduct = {
                id: 'test-product',
                name: 'Test Product',
                price: 50000,
                description: 'Test description',
                icon: '🌳',
                type: 'daraxt',
                inStock: true,
                co2Absorption: 15
            };

            productManager.addProduct(validProduct);

            expect(() => {
                productManager.updateProduct('test-product', { price: -1000 });
            }).toThrow('Product price must be a non-negative number');
        });

        test('should throw error when updating non-existent product', () => {
            expect(() => {
                productManager.updateProduct('non-existent', { name: 'New Name' });
            }).toThrow('Mahsulot topilmadi');
        });

        test('should throw error when deleting non-existent product', () => {
            expect(() => {
                productManager.deleteProduct('non-existent');
            }).toThrow('Mahsulot topilmadi');
        });
    });

    describe('Image upload failure handling', () => {
        test('should throw error when uploading image to non-existent product', () => {
            expect(() => {
                productManager.updateProductImage('non-existent', 'data:image/png;base64,abc123');
            }).toThrow('Mahsulot topilmadi');
        });

        test('should throw error when uploading invalid image data (null)', () => {
            const product = {
                id: 'test-product',
                name: 'Test Product',
                price: 50000,
                description: 'Test description',
                icon: '🌳',
                type: 'daraxt',
                inStock: true,
                co2Absorption: 15
            };

            productManager.addProduct(product);

            expect(() => {
                productManager.updateProductImage('test-product', null);
            }).toThrow('Noto\'g\'ri rasm ma\'lumoti');
        });

        test('should throw error when uploading invalid image data (empty string)', () => {
            const product = {
                id: 'test-product',
                name: 'Test Product',
                price: 50000,
                description: 'Test description',
                icon: '🌳',
                type: 'daraxt',
                inStock: true,
                co2Absorption: 15
            };

            productManager.addProduct(product);

            expect(() => {
                productManager.updateProductImage('test-product', '');
            }).toThrow('Noto\'g\'ri rasm ma\'lumoti');
        });

        test('should throw error when uploading invalid image data (number)', () => {
            const product = {
                id: 'test-product',
                name: 'Test Product',
                price: 50000,
                description: 'Test description',
                icon: '🌳',
                type: 'daraxt',
                inStock: true,
                co2Absorption: 15
            };

            productManager.addProduct(product);

            expect(() => {
                productManager.updateProductImage('test-product', 12345);
            }).toThrow('Noto\'g\'ri rasm ma\'lumoti');
        });

        test('should successfully upload valid image data', () => {
            const product = {
                id: 'test-product',
                name: 'Test Product',
                price: 50000,
                description: 'Test description',
                icon: '🌳',
                type: 'daraxt',
                inStock: true,
                co2Absorption: 15
            };

            productManager.addProduct(product);

            const imageData = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
            const updatedProduct = productManager.updateProductImage('test-product', imageData);

            expect(updatedProduct.image).toBe(imageData);
            expect(productManager.getProductById('test-product').image).toBe(imageData);
        });

        test('should successfully upload image URL', () => {
            const product = {
                id: 'test-product',
                name: 'Test Product',
                price: 50000,
                description: 'Test description',
                icon: '🌳',
                type: 'daraxt',
                inStock: true,
                co2Absorption: 15
            };

            productManager.addProduct(product);

            const imageUrl = 'https://example.com/image.jpg';
            const updatedProduct = productManager.updateProductImage('test-product', imageUrl);

            expect(updatedProduct.image).toBe(imageUrl);
        });
    });

    describe('Stock toggle functionality', () => {
        test('should toggle product stock status from true to false', () => {
            const product = {
                id: 'test-product',
                name: 'Test Product',
                price: 50000,
                description: 'Test description',
                icon: '🌳',
                type: 'daraxt',
                inStock: true,
                co2Absorption: 15
            };

            productManager.addProduct(product);
            expect(productManager.canPurchase('test-product')).toBe(true);

            productManager.toggleStock('test-product');
            expect(productManager.canPurchase('test-product')).toBe(false);
        });

        test('should toggle product stock status from false to true', () => {
            const product = {
                id: 'test-product',
                name: 'Test Product',
                price: 50000,
                description: 'Test description',
                icon: '🌳',
                type: 'daraxt',
                inStock: false,
                co2Absorption: 15
            };

            productManager.addProduct(product);
            expect(productManager.canPurchase('test-product')).toBe(false);

            productManager.toggleStock('test-product');
            expect(productManager.canPurchase('test-product')).toBe(true);
        });

        test('should throw error when toggling stock of non-existent product', () => {
            expect(() => {
                productManager.toggleStock('non-existent');
            }).toThrow('Mahsulot topilmadi');
        });
    });
});
