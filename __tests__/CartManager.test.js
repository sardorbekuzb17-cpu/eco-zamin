/**
 * CartManager Tests
 * Property-based and unit tests for cart operations
 */
const fc = require('fast-check');
const CartManager = require('../src/services/CartManager');
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

describe('CartManager Property Tests', () => {
    /**
     * **Feature: green-shop, Property 1: Adding products increases cart count**
     * **Validates: Requirements 1.1**
     * 
     * For any product and cart state, adding a product to the cart should 
     * increase the cart item count and the product should appear in the cart items list.
     */
    test('Property 1: Adding products increases cart count', () => {
        fc.assert(
            fc.property(
                fc.string({ minLength: 1 }), // productId
                fc.integer({ min: 1, max: 100 }), // quantity
                (productId, quantity) => {
                    // Arrange: yangi cart yaratamiz
                    const mockStorage = new MockStorageService();
                    const cart = new CartManager(mockStorage);

                    // Boshlang'ich holatni saqlaymiz
                    const initialCount = cart.getItemCount();
                    const initialItems = cart.getItems();
                    const initialLength = initialItems.length;

                    // Act: mahsulotni qo'shamiz
                    cart.addItem(productId, quantity);

                    // Assert: cart count oshgan bo'lishi kerak
                    const newCount = cart.getItemCount();
                    const newItems = cart.getItems();

                    // 1. Item count oshgan bo'lishi kerak
                    const countIncreased = newCount === initialCount + quantity;

                    // 2. Mahsulot items ro'yxatida bo'lishi kerak
                    const productExists = newItems.some(item => item.productId === productId);

                    // 3. Agar mahsulot yangi bo'lsa, items length oshgan bo'lishi kerak
                    const wasExisting = initialItems.some(item => item.productId === productId);
                    const lengthCorrect = wasExisting ?
                        newItems.length === initialLength :
                        newItems.length === initialLength + 1;

                    return countIncreased && productExists && lengthCorrect;
                }
            ),
            { numRuns: 100 }
        );
    });

    /**
     * **Feature: green-shop, Property 2: Adding same product increases quantity**
     * **Validates: Requirements 1.2**
     * 
     * For any product, adding it to the cart multiple times should increase 
     * its quantity in the cart rather than creating duplicate entries.
     */
    test('Property 2: Adding same product increases quantity', () => {
        fc.assert(
            fc.property(
                fc.string({ minLength: 1 }), // productId
                fc.integer({ min: 1, max: 50 }), // firstQuantity
                fc.integer({ min: 1, max: 50 }), // secondQuantity
                (productId, firstQuantity, secondQuantity) => {
                    // Arrange: yangi cart yaratamiz
                    const mockStorage = new MockStorageService();
                    const cart = new CartManager(mockStorage);

                    // Act: bir xil mahsulotni ikki marta qo'shamiz
                    cart.addItem(productId, firstQuantity);
                    const itemsAfterFirst = cart.getItems();
                    const lengthAfterFirst = itemsAfterFirst.length;

                    cart.addItem(productId, secondQuantity);
                    const itemsAfterSecond = cart.getItems();

                    // Assert: 
                    // 1. Items ro'yxati uzunligi o'zgarmagan bo'lishi kerak (duplicate yaratilmagan)
                    const noDuplicateCreated = itemsAfterSecond.length === lengthAfterFirst;

                    // 2. Mahsulot miqdori ikkala qo'shilgan miqdorning yig'indisiga teng bo'lishi kerak
                    const item = itemsAfterSecond.find(i => i.productId === productId);
                    const quantityCorrect = item && item.quantity === firstQuantity + secondQuantity;

                    // 3. Faqat bitta item bo'lishi kerak
                    const onlyOneItem = itemsAfterSecond.filter(i => i.productId === productId).length === 1;

                    return noDuplicateCreated && quantityCorrect && onlyOneItem;
                }
            ),
            { numRuns: 100 }
        );
    });

    /**
     * **Feature: green-shop, Property 4: Quantity changes update total price correctly**
     * **Validates: Requirements 1.5, 2.1**
     * 
     * For any cart item, changing its quantity should result in the total price 
     * being recalculated as the sum of (quantity × price) for all items in the cart.
     */
    test('Property 4: Quantity changes update total price correctly', () => {
        fc.assert(
            fc.property(
                // Mahsulotlar ro'yxatini yaratamiz
                fc.array(
                    fc.record({
                        id: fc.string({ minLength: 1 }).filter(id =>
                            // Maxsus JavaScript property nomlarini chiqarib tashlaymiz
                            id !== '__proto__' &&
                            id !== 'constructor' &&
                            id !== 'prototype' &&
                            id.trim().length > 0
                        ),
                        price: fc.integer({ min: 1000, max: 1000000 }) // narx so'mda
                    }),
                    { minLength: 1, maxLength: 10 }
                ),
                // Qaysi mahsulotni yangilashni tanlaymiz (index)
                fc.nat(),
                // Yangi miqdor
                fc.integer({ min: 1, max: 100 }),
                (products, updateIndex, newQuantity) => {
                    // Arrange: yangi cart yaratamiz
                    const mockStorage = new MockStorageService();
                    const cart = new CartManager(mockStorage);

                    // Unique product IDs yaratamiz va bo'sh ID larni chiqarib tashlaymiz
                    const uniqueProducts = products.filter((p, i, arr) =>
                        p.id.trim().length > 0 && arr.findIndex(x => x.id === p.id) === i
                    );

                    if (uniqueProducts.length === 0) return true; // bo'sh array uchun skip

                    // Barcha mahsulotlarni savatga qo'shamiz
                    const initialQuantities = {};
                    uniqueProducts.forEach(product => {
                        const qty = Math.floor(Math.random() * 10) + 1;
                        cart.addItem(product.id, qty);
                        initialQuantities[product.id] = qty;
                    });

                    // Yangilanadigan mahsulotni tanlaymiz
                    const productToUpdate = uniqueProducts[updateIndex % uniqueProducts.length];

                    // Act: miqdorni yangilaymiz
                    cart.updateQuantity(productToUpdate.id, newQuantity);

                    // Assert: umumiy narx to'g'ri hisoblanganligini tekshiramiz
                    const expectedTotal = uniqueProducts.reduce((total, product) => {
                        const quantity = product.id === productToUpdate.id
                            ? newQuantity
                            : initialQuantities[product.id];
                        return total + (product.price * quantity);
                    }, 0);

                    const actualTotal = cart.getTotalPrice(uniqueProducts);

                    return actualTotal === expectedTotal;
                }
            ),
            { numRuns: 100 }
        );
    });

    /**
     * **Feature: green-shop, Property 3: Cart displays all added items**
     * **Validates: Requirements 1.3**
     * 
     * For any cart state with items, opening the cart modal should display 
     * all items that exist in the cart state.
     */
    test('Property 3: Cart displays all added items', () => {
        fc.assert(
            fc.property(
                // Mahsulotlar ro'yxatini yaratamiz
                fc.array(
                    fc.record({
                        id: fc.string({ minLength: 1 }),
                        quantity: fc.integer({ min: 1, max: 100 })
                    }),
                    { minLength: 1, maxLength: 20 }
                ),
                (productsToAdd) => {
                    // Arrange: yangi cart yaratamiz
                    const mockStorage = new MockStorageService();
                    const cart = new CartManager(mockStorage);

                    // Unique product IDs yaratamiz
                    const uniqueProducts = productsToAdd.filter((p, i, arr) =>
                        arr.findIndex(x => x.id === p.id) === i
                    );

                    if (uniqueProducts.length === 0) return true; // bo'sh array uchun skip

                    // Act: barcha mahsulotlarni savatga qo'shamiz
                    uniqueProducts.forEach(product => {
                        cart.addItem(product.id, product.quantity);
                    });

                    // Assert: getItems() barcha qo'shilgan mahsulotlarni qaytarishi kerak
                    const cartItems = cart.getItems();

                    // 1. Cart items soni qo'shilgan unique mahsulotlar soniga teng bo'lishi kerak
                    const correctLength = cartItems.length === uniqueProducts.length;

                    // 2. Har bir qo'shilgan mahsulot cart items'da bo'lishi kerak
                    const allProductsPresent = uniqueProducts.every(product => {
                        const cartItem = cartItems.find(item => item.productId === product.id);
                        return cartItem !== undefined;
                    });

                    // 3. Har bir cart item'ning miqdori to'g'ri bo'lishi kerak
                    const allQuantitiesCorrect = uniqueProducts.every(product => {
                        const cartItem = cartItems.find(item => item.productId === product.id);
                        return cartItem && cartItem.quantity === product.quantity;
                    });

                    // 4. Cart items'da ortiqcha mahsulotlar bo'lmasligi kerak
                    const noExtraProducts = cartItems.every(cartItem => {
                        return uniqueProducts.some(product => product.id === cartItem.productId);
                    });

                    return correctLength && allProductsPresent && allQuantitiesCorrect && noExtraProducts;
                }
            ),
            { numRuns: 100 }
        );
    });

    /**
     * **Feature: green-shop, Property 5: Removing items from cart**
     * **Validates: Requirements 2.3**
     * 
     * For any product in the cart, removing it should result in the product 
     * no longer appearing in the cart items list and the cart count decreasing.
     */
    test('Property 5: Removing items from cart', () => {
        fc.assert(
            fc.property(
                // Mahsulotlar ro'yxatini yaratamiz
                fc.array(
                    fc.string({ minLength: 1 }),
                    { minLength: 1, maxLength: 20 }
                ),
                // Har bir mahsulot uchun miqdor
                fc.array(
                    fc.integer({ min: 1, max: 50 }),
                    { minLength: 1, maxLength: 20 }
                ),
                // Qaysi mahsulotni o'chirishni tanlaymiz (index)
                fc.nat(),
                (productIds, quantities, removeIndex) => {
                    // Arrange: yangi cart yaratamiz
                    const mockStorage = new MockStorageService();
                    const cart = new CartManager(mockStorage);

                    // Unique product IDs yaratamiz
                    const uniqueProductIds = [...new Set(productIds)];
                    if (uniqueProductIds.length === 0) return true; // bo'sh array uchun skip

                    // Barcha mahsulotlarni savatga qo'shamiz
                    uniqueProductIds.forEach((productId, index) => {
                        const qty = quantities[index % quantities.length];
                        cart.addItem(productId, qty);
                    });

                    // Boshlang'ich holatni saqlaymiz
                    const initialCount = cart.getItemCount();
                    const initialItems = cart.getItems();
                    const initialLength = initialItems.length;

                    // O'chiriladigan mahsulotni tanlaymiz
                    const productToRemove = uniqueProductIds[removeIndex % uniqueProductIds.length];
                    const removedItem = initialItems.find(item => item.productId === productToRemove);
                    const removedQuantity = removedItem ? removedItem.quantity : 0;

                    // Act: mahsulotni o'chiramiz
                    cart.removeItem(productToRemove);

                    // Assert:
                    const newItems = cart.getItems();
                    const newCount = cart.getItemCount();

                    // 1. Mahsulot items ro'yxatida bo'lmasligi kerak
                    const productNotExists = !newItems.some(item => item.productId === productToRemove);

                    // 2. Items ro'yxati uzunligi 1 ga kamaygan bo'lishi kerak
                    const lengthDecreased = newItems.length === initialLength - 1;

                    // 3. Cart count o'chirilgan mahsulot miqdoriga kamaygan bo'lishi kerak
                    const countDecreased = newCount === initialCount - removedQuantity;

                    return productNotExists && lengthDecreased && countDecreased;
                }
            ),
            { numRuns: 100 }
        );
    });
});

describe('CartManager Unit Tests - Edge Cases', () => {
    let mockStorage;
    let cart;

    beforeEach(() => {
        mockStorage = new MockStorageService();
        cart = new CartManager(mockStorage);
    });

    describe('Empty cart behavior', () => {
        test('should return empty array for getItems on empty cart', () => {
            const items = cart.getItems();
            expect(items).toEqual([]);
            expect(items.length).toBe(0);
        });

        test('should return 0 for getItemCount on empty cart', () => {
            const count = cart.getItemCount();
            expect(count).toBe(0);
        });

        test('should return 0 for getTotalPrice on empty cart', () => {
            const products = [
                { id: 'prod1', price: 10000 },
                { id: 'prod2', price: 20000 }
            ];
            const total = cart.getTotalPrice(products);
            expect(total).toBe(0);
        });

        test('should throw error when removing from empty cart', () => {
            expect(() => {
                cart.removeItem('nonexistent');
            }).toThrow('Product not found in cart');
        });

        test('should throw error when updating quantity in empty cart', () => {
            expect(() => {
                cart.updateQuantity('nonexistent', 5);
            }).toThrow('Product not found in cart');
        });
    });

    describe('Invalid product ID handling', () => {
        test('should throw error when adding item with empty string ID', () => {
            expect(() => {
                cart.addItem('', 1);
            }).toThrow('Invalid product ID');
        });

        test('should throw error when adding item with null ID', () => {
            expect(() => {
                cart.addItem(null, 1);
            }).toThrow('Invalid product ID');
        });

        test('should throw error when adding item with undefined ID', () => {
            expect(() => {
                cart.addItem(undefined, 1);
            }).toThrow('Invalid product ID');
        });

        test('should throw error when adding item with number ID', () => {
            expect(() => {
                cart.addItem(123, 1);
            }).toThrow('Invalid product ID');
        });

        test('should throw error when removing item with invalid ID', () => {
            expect(() => {
                cart.removeItem(null);
            }).toThrow('Invalid product ID');
        });

        test('should throw error when updating quantity with invalid ID', () => {
            expect(() => {
                cart.updateQuantity(null, 5);
            }).toThrow('Invalid product ID');
        });

        test('should throw error when removing non-existent product', () => {
            cart.addItem('prod1', 2);
            expect(() => {
                cart.removeItem('nonexistent');
            }).toThrow('Product not found in cart');
        });

        test('should throw error when updating non-existent product', () => {
            cart.addItem('prod1', 2);
            expect(() => {
                cart.updateQuantity('nonexistent', 5);
            }).toThrow('Product not found in cart');
        });
    });

    describe('Negative quantity handling', () => {
        test('should throw error when adding item with negative quantity', () => {
            expect(() => {
                cart.addItem('prod1', -5);
            }).toThrow('Quantity must be a positive number');
        });

        test('should throw error when adding item with zero quantity', () => {
            expect(() => {
                cart.addItem('prod1', 0);
            }).toThrow('Quantity must be a positive number');
        });

        test('should throw error when updating to negative quantity', () => {
            cart.addItem('prod1', 5);
            expect(() => {
                cart.updateQuantity('prod1', -3);
            }).toThrow('Quantity must be a non-negative number');
        });

        test('should throw error when adding with non-number quantity', () => {
            expect(() => {
                cart.addItem('prod1', 'five');
            }).toThrow('Quantity must be a positive number');
        });

        test('should throw error when updating with non-number quantity', () => {
            cart.addItem('prod1', 5);
            expect(() => {
                cart.updateQuantity('prod1', 'ten');
            }).toThrow('Quantity must be a non-negative number');
        });
    });

    describe('Zero quantity removal', () => {
        test('should remove item when quantity updated to 0', () => {
            // Mahsulotni qo'shamiz
            cart.addItem('prod1', 5);
            expect(cart.getItems().length).toBe(1);
            expect(cart.getItemCount()).toBe(5);

            // Miqdorni 0 ga o'zgartiramiz
            cart.updateQuantity('prod1', 0);

            // Mahsulot o'chirilgan bo'lishi kerak
            expect(cart.getItems().length).toBe(0);
            expect(cart.getItemCount()).toBe(0);
            expect(cart.getItems().find(item => item.productId === 'prod1')).toBeUndefined();
        });

        test('should remove correct item when multiple items exist and one updated to 0', () => {
            // Bir nechta mahsulot qo'shamiz
            cart.addItem('prod1', 3);
            cart.addItem('prod2', 5);
            cart.addItem('prod3', 2);

            expect(cart.getItems().length).toBe(3);
            expect(cart.getItemCount()).toBe(10);

            // Bitta mahsulotni 0 ga o'zgartiramiz
            cart.updateQuantity('prod2', 0);

            // Faqat prod2 o'chirilgan bo'lishi kerak
            const items = cart.getItems();
            expect(items.length).toBe(2);
            expect(items.find(item => item.productId === 'prod1')).toBeDefined();
            expect(items.find(item => item.productId === 'prod2')).toBeUndefined();
            expect(items.find(item => item.productId === 'prod3')).toBeDefined();
            expect(cart.getItemCount()).toBe(5); // 3 + 2
        });

        test('should handle updating to 0 and then adding same product again', () => {
            // Mahsulotni qo'shamiz
            cart.addItem('prod1', 5);
            expect(cart.getItemCount()).toBe(5);

            // 0 ga o'zgartiramiz (o'chiriladi)
            cart.updateQuantity('prod1', 0);
            expect(cart.getItemCount()).toBe(0);

            // Qaytadan qo'shamiz
            cart.addItem('prod1', 3);
            expect(cart.getItemCount()).toBe(3);
            expect(cart.getItems().length).toBe(1);
            expect(cart.getItems()[0].quantity).toBe(3);
        });
    });
});
