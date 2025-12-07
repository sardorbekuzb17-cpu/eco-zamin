/**
 * OrderManager Tests
 * Tests for order creation and management
 */
const fc = require('fast-check');
const OrderManager = require('../src/services/OrderManager');
const StorageService = require('../src/services/StorageService');

describe('OrderManager', () => {
    let orderManager;
    let storageService;

    beforeEach(() => {
        // Create fresh instances for each test
        storageService = new StorageService();
        orderManager = new OrderManager(storageService);
        // Clear storage before each test
        storageService.clear();
    });

    /**
     * **Feature: green-shop, Property 9: Successful payment creates order**
     * **Validates: Requirements 4.4**
     * 
     * For any valid payment, completing the payment should create an order 
     * with a unique order number, save it to storage, and display a confirmation page.
     */
    describe('Property 9: Successful payment creates order', () => {
        test('should create order with unique order number and save to storage', async () => {
            await fc.assert(
                fc.asyncProperty(
                    // Generator for customer info
                    fc.record({
                        name: fc.hexaString({ minLength: 1, maxLength: 50 }),
                        phone: fc.hexaString({ minLength: 9, maxLength: 15 }),
                        address: fc.hexaString({ minLength: 5, maxLength: 100 }),
                        email: fc.emailAddress()
                    }),
                    // Generator for cart items (1-10 items)
                    fc.array(
                        fc.record({
                            productId: fc.hexaString({ minLength: 1, maxLength: 20 }),
                            quantity: fc.integer({ min: 1, max: 100 }),
                            addedAt: fc.integer({ min: 1000000000000, max: Date.now() })
                        }),
                        { minLength: 1, maxLength: 10 }
                    ),
                    // Generator for total price
                    fc.float({ min: Math.fround(0.01), max: Math.fround(1000000), noNaN: true }),
                    async (customerInfo, cartItems, totalPrice) => {
                        // Get initial order count
                        const initialOrders = orderManager.getOrders();
                        const initialCount = initialOrders.length;

                        // Create order (simulating successful payment)
                        const order = await orderManager.createOrder(customerInfo, cartItems, totalPrice);

                        // Verify order was created with required properties
                        expect(order).toBeDefined();
                        expect(order.orderId).toBeDefined();
                        expect(typeof order.orderId).toBe('string');
                        expect(order.orderNumber).toBeDefined();
                        expect(typeof order.orderNumber).toBe('string');
                        expect(order.orderNumber).toMatch(/^GM\d+$/); // Format: GM followed by numbers

                        // Verify order contains correct data
                        expect(order.customerInfo).toEqual(customerInfo);
                        expect(order.items).toEqual(cartItems);
                        expect(order.totalPrice).toBe(totalPrice);
                        expect(order.status).toBe('pending');
                        expect(order.createdAt).toBeDefined();

                        // Verify order was saved to storage
                        const ordersAfterCreation = orderManager.getOrders();
                        expect(ordersAfterCreation.length).toBe(initialCount + 1);

                        // Verify the created order exists in storage
                        const savedOrder = ordersAfterCreation.find(o => o.orderId === order.orderId);
                        expect(savedOrder).toBeDefined();
                        expect(savedOrder.orderNumber).toBe(order.orderNumber);
                        expect(savedOrder.totalPrice).toBe(totalPrice);

                        return true;
                    }
                ),
                { numRuns: 100 }
            );
        });

        test('should create orders with unique order numbers', async () => {
            await fc.assert(
                fc.asyncProperty(
                    // Generate multiple orders
                    fc.array(
                        fc.record({
                            customerInfo: fc.record({
                                name: fc.hexaString({ minLength: 1, maxLength: 50 }),
                                phone: fc.hexaString({ minLength: 9, maxLength: 15 }),
                                address: fc.hexaString({ minLength: 5, maxLength: 100 }),
                                email: fc.emailAddress()
                            }),
                            cartItems: fc.array(
                                fc.record({
                                    productId: fc.hexaString({ minLength: 1, maxLength: 20 }),
                                    quantity: fc.integer({ min: 1, max: 100 }),
                                    addedAt: fc.integer({ min: 1000000000000, max: Date.now() })
                                }),
                                { minLength: 1, maxLength: 5 }
                            ),
                            totalPrice: fc.float({ min: Math.fround(0.01), max: Math.fround(100000), noNaN: true })
                        }),
                        { minLength: 2, maxLength: 10 }
                    ),
                    async (orderDataArray) => {
                        const createdOrders = [];

                        // Create all orders
                        for (const orderData of orderDataArray) {
                            const order = await orderManager.createOrder(
                                orderData.customerInfo,
                                orderData.cartItems,
                                orderData.totalPrice
                            );
                            createdOrders.push(order);
                        }

                        // Verify all order numbers are unique
                        const orderNumbers = createdOrders.map(o => o.orderNumber);
                        const uniqueOrderNumbers = new Set(orderNumbers);
                        expect(uniqueOrderNumbers.size).toBe(orderNumbers.length);

                        // Verify all order IDs are unique
                        const orderIds = createdOrders.map(o => o.orderId);
                        const uniqueOrderIds = new Set(orderIds);
                        expect(uniqueOrderIds.size).toBe(orderIds.length);

                        return true;
                    }
                ),
                { numRuns: 100 }
            );
        });
    });

    /**
     * **Feature: green-shop, Property 11: Order details contain complete information**
     * **Validates: Requirements 5.3, 5.4**
     * 
     * For any order, viewing its details should display all required information 
     * including product list, total price, delivery address, and customer information.
     */
    describe('Property 11: Order details contain complete information', () => {
        test('should contain all required information when retrieving order by ID', () => {
            fc.assert(
                fc.property(
                    // Generator for customer info
                    fc.record({
                        name: fc.string({ minLength: 1, maxLength: 50 }),
                        phone: fc.string({ minLength: 9, maxLength: 15 }),
                        address: fc.string({ minLength: 5, maxLength: 100 }),
                        email: fc.emailAddress()
                    }),
                    // Generator for cart items (1-10 items)
                    fc.array(
                        fc.record({
                            productId: fc.string({ minLength: 1, maxLength: 20 }),
                            quantity: fc.integer({ min: 1, max: 100 }),
                            addedAt: fc.integer({ min: 1000000000000, max: Date.now() })
                        }),
                        { minLength: 1, maxLength: 10 }
                    ),
                    // Generator for total price
                    fc.float({ min: Math.fround(0.01), max: Math.fround(1000000), noNaN: true }),
                    (customerInfo, cartItems, totalPrice) => {
                        // Create an order
                        const order = orderManager.createOrder(customerInfo, cartItems, totalPrice);

                        // Retrieve order details by ID (simulating what the UI would do)
                        const orderDetails = orderManager.getOrderById(order.orderId);

                        // Verify all required information is present
                        expect(orderDetails).toBeDefined();

                        // Verify order identification
                        expect(orderDetails.orderId).toBeDefined();
                        expect(typeof orderDetails.orderId).toBe('string');
                        expect(orderDetails.orderNumber).toBeDefined();
                        expect(typeof orderDetails.orderNumber).toBe('string');

                        // Verify product list (items) is complete
                        expect(orderDetails.items).toBeDefined();
                        expect(Array.isArray(orderDetails.items)).toBe(true);
                        expect(orderDetails.items.length).toBe(cartItems.length);
                        expect(orderDetails.items).toEqual(cartItems);

                        // Verify total price is present
                        expect(orderDetails.totalPrice).toBeDefined();
                        expect(typeof orderDetails.totalPrice).toBe('number');
                        expect(orderDetails.totalPrice).toBe(totalPrice);

                        // Verify customer information is complete
                        expect(orderDetails.customerInfo).toBeDefined();
                        expect(typeof orderDetails.customerInfo).toBe('object');
                        expect(orderDetails.customerInfo.name).toBe(customerInfo.name);
                        expect(orderDetails.customerInfo.phone).toBe(customerInfo.phone);
                        expect(orderDetails.customerInfo.address).toBe(customerInfo.address);
                        expect(orderDetails.customerInfo.email).toBe(customerInfo.email);

                        // Verify delivery address (part of customer info) is present
                        expect(orderDetails.customerInfo.address).toBeDefined();
                        expect(typeof orderDetails.customerInfo.address).toBe('string');
                        expect(orderDetails.customerInfo.address.length).toBeGreaterThan(0);

                        // Verify order status is present
                        expect(orderDetails.status).toBeDefined();
                        expect(typeof orderDetails.status).toBe('string');

                        // Verify creation timestamp is present
                        expect(orderDetails.createdAt).toBeDefined();
                        expect(typeof orderDetails.createdAt).toBe('number');

                        return true;
                    }
                ),
                { numRuns: 100 }
            );
        });

        test('should contain complete information for multiple orders', () => {
            fc.assert(
                fc.property(
                    // Generate multiple orders
                    fc.array(
                        fc.record({
                            customerInfo: fc.record({
                                name: fc.string({ minLength: 1, maxLength: 50 }),
                                phone: fc.string({ minLength: 9, maxLength: 15 }),
                                address: fc.string({ minLength: 5, maxLength: 100 }),
                                email: fc.emailAddress()
                            }),
                            cartItems: fc.array(
                                fc.record({
                                    productId: fc.string({ minLength: 1, maxLength: 20 }),
                                    quantity: fc.integer({ min: 1, max: 100 }),
                                    addedAt: fc.integer({ min: 1000000000000, max: Date.now() })
                                }),
                                { minLength: 1, maxLength: 5 }
                            ),
                            totalPrice: fc.float({ min: Math.fround(0.01), max: Math.fround(100000), noNaN: true })
                        }),
                        { minLength: 1, maxLength: 10 }
                    ),
                    (orderDataArray) => {
                        const createdOrders = [];

                        // Create all orders
                        for (const orderData of orderDataArray) {
                            const order = orderManager.createOrder(
                                orderData.customerInfo,
                                orderData.cartItems,
                                orderData.totalPrice
                            );
                            createdOrders.push({
                                order,
                                originalData: orderData
                            });
                        }

                        // Verify each order contains complete information
                        for (const { order, originalData } of createdOrders) {
                            const orderDetails = orderManager.getOrderById(order.orderId);

                            // Verify all required fields are present and correct
                            expect(orderDetails.orderId).toBe(order.orderId);
                            expect(orderDetails.orderNumber).toBe(order.orderNumber);
                            expect(orderDetails.items).toEqual(originalData.cartItems);
                            expect(orderDetails.totalPrice).toBe(originalData.totalPrice);
                            expect(orderDetails.customerInfo).toEqual(originalData.customerInfo);
                            expect(orderDetails.customerInfo.address).toBe(originalData.customerInfo.address);
                            expect(orderDetails.status).toBeDefined();
                            expect(orderDetails.createdAt).toBeDefined();
                        }

                        return true;
                    }
                ),
                { numRuns: 100 }
            );
        });

        test('should throw error when order ID is invalid', () => {
            fc.assert(
                fc.property(
                    fc.oneof(
                        fc.constant(null),
                        fc.constant(undefined),
                        fc.constant(''),
                        fc.integer(),
                        fc.constant({})
                    ),
                    (invalidId) => {
                        expect(() => {
                            orderManager.getOrderById(invalidId);
                        }).toThrow();
                        return true;
                    }
                ),
                { numRuns: 50 }
            );
        });

        test('should throw error when order does not exist', () => {
            fc.assert(
                fc.property(
                    fc.string({ minLength: 1, maxLength: 50 }),
                    (nonExistentId) => {
                        // Make sure this ID doesn't exist
                        const orders = orderManager.getOrders();
                        const exists = orders.some(o => o.orderId === nonExistentId);

                        if (!exists) {
                            expect(() => {
                                orderManager.getOrderById(nonExistentId);
                            }).toThrow('Order not found');
                        }
                        return true;
                    }
                ),
                { numRuns: 50 }
            );
        });
    });

    /**
     * **Feature: green-shop, Property 12: Delivered orders have QR code and certificate**
     * **Validates: Requirements 5.5**
     * 
     * For any order with status "delivered", the order details should include 
     * a QR code and digital certificate.
     */
    describe('Property 12: Delivered orders have QR code and certificate', () => {
        test('should have QR code and certificate when order status is delivered', async () => {
            await fc.assert(
                fc.asyncProperty(
                    // Generator for customer info
                    fc.record({
                        name: fc.string({ minLength: 1, maxLength: 50 }),
                        phone: fc.string({ minLength: 9, maxLength: 15 }),
                        address: fc.string({ minLength: 5, maxLength: 100 }),
                        email: fc.emailAddress()
                    }),
                    // Generator for cart items (1-10 items)
                    fc.array(
                        fc.record({
                            productId: fc.string({ minLength: 1, maxLength: 20 }),
                            quantity: fc.integer({ min: 1, max: 100 }),
                            addedAt: fc.integer({ min: 1000000000000, max: Date.now() })
                        }),
                        { minLength: 1, maxLength: 10 }
                    ),
                    // Generator for total price
                    fc.float({ min: Math.fround(0.01), max: Math.fround(1000000), noNaN: true }),
                    async (customerInfo, cartItems, totalPrice) => {
                        // Create an order
                        const order = orderManager.createOrder(customerInfo, cartItems, totalPrice);

                        // Initially, order should not have QR code or certificate (status is 'pending')
                        expect(order.qrCode).toBeNull();
                        expect(order.certificate).toBeNull();

                        // Update order status to 'delivered'
                        const updatedOrder = await orderManager.updateOrderStatus(order.orderId, 'delivered');

                        // Verify order status is 'delivered'
                        expect(updatedOrder.status).toBe('delivered');

                        // Verify QR code is present
                        expect(updatedOrder.qrCode).toBeDefined();
                        expect(typeof updatedOrder.qrCode).toBe('string');
                        expect(updatedOrder.qrCode.length).toBeGreaterThan(0);

                        // Verify certificate is present
                        expect(updatedOrder.certificate).toBeDefined();
                        expect(typeof updatedOrder.certificate).toBe('string');
                        expect(updatedOrder.certificate.length).toBeGreaterThan(0);

                        // Verify the order can be retrieved with QR code and certificate
                        const retrievedOrder = orderManager.getOrderById(order.orderId);
                        expect(retrievedOrder.status).toBe('delivered');
                        expect(retrievedOrder.qrCode).toBe(updatedOrder.qrCode);
                        expect(retrievedOrder.certificate).toBe(updatedOrder.certificate);

                        return true;
                    }
                ),
                { numRuns: 100 }
            );
        });

        test('should not have QR code and certificate when order status is not delivered', async () => {
            await fc.assert(
                fc.asyncProperty(
                    // Generator for customer info
                    fc.record({
                        name: fc.string({ minLength: 1, maxLength: 50 }),
                        phone: fc.string({ minLength: 9, maxLength: 15 }),
                        address: fc.string({ minLength: 5, maxLength: 100 }),
                        email: fc.emailAddress()
                    }),
                    // Generator for cart items
                    fc.array(
                        fc.record({
                            productId: fc.string({ minLength: 1, maxLength: 20 }),
                            quantity: fc.integer({ min: 1, max: 100 }),
                            addedAt: fc.integer({ min: 1000000000000, max: Date.now() })
                        }),
                        { minLength: 1, maxLength: 10 }
                    ),
                    // Generator for total price
                    fc.float({ min: Math.fround(0.01), max: Math.fround(1000000), noNaN: true }),
                    // Generator for non-delivered status
                    fc.constantFrom('pending', 'confirmed', 'processing', 'shipped'),
                    async (customerInfo, cartItems, totalPrice, status) => {
                        // Create an order
                        const order = orderManager.createOrder(customerInfo, cartItems, totalPrice);

                        // Update order status to non-delivered status
                        const updatedOrder = await orderManager.updateOrderStatus(order.orderId, status);

                        // Verify order status is the non-delivered status
                        expect(updatedOrder.status).toBe(status);

                        // Verify QR code and certificate are NOT present
                        expect(updatedOrder.qrCode).toBeNull();
                        expect(updatedOrder.certificate).toBeNull();

                        return true;
                    }
                ),
                { numRuns: 100 }
            );
        });

        test('should persist QR code and certificate across manager instances', async () => {
            await fc.assert(
                fc.asyncProperty(
                    // Generator for customer info
                    fc.record({
                        name: fc.string({ minLength: 1, maxLength: 50 }),
                        phone: fc.string({ minLength: 9, maxLength: 15 }),
                        address: fc.string({ minLength: 5, maxLength: 100 }),
                        email: fc.emailAddress()
                    }),
                    // Generator for cart items
                    fc.array(
                        fc.record({
                            productId: fc.string({ minLength: 1, maxLength: 20 }),
                            quantity: fc.integer({ min: 1, max: 100 }),
                            addedAt: fc.integer({ min: 1000000000000, max: Date.now() })
                        }),
                        { minLength: 1, maxLength: 5 }
                    ),
                    // Generator for total price
                    fc.float({ min: Math.fround(0.01), max: Math.fround(100000), noNaN: true }),
                    async (customerInfo, cartItems, totalPrice) => {
                        // Create an order and mark as delivered
                        const order = orderManager.createOrder(customerInfo, cartItems, totalPrice);
                        const deliveredOrder = await orderManager.updateOrderStatus(order.orderId, 'delivered');

                        // Store the QR code and certificate
                        const originalQrCode = deliveredOrder.qrCode;
                        const originalCertificate = deliveredOrder.certificate;

                        // Create new manager instance (simulating page reload)
                        const newOrderManager = new OrderManager(storageService);

                        // Retrieve the order with new manager instance
                        const retrievedOrder = newOrderManager.getOrderById(order.orderId);

                        // Verify QR code and certificate are still present
                        expect(retrievedOrder.status).toBe('delivered');
                        expect(retrievedOrder.qrCode).toBe(originalQrCode);
                        expect(retrievedOrder.certificate).toBe(originalCertificate);

                        return true;
                    }
                ),
                { numRuns: 100 }
            );
        });

        test('should have unique QR codes and certificates for different orders', async () => {
            await fc.assert(
                fc.asyncProperty(
                    // Generate multiple orders
                    fc.array(
                        fc.record({
                            customerInfo: fc.record({
                                name: fc.string({ minLength: 1, maxLength: 50 }),
                                phone: fc.string({ minLength: 9, maxLength: 15 }),
                                address: fc.string({ minLength: 5, maxLength: 100 }),
                                email: fc.emailAddress()
                            }),
                            cartItems: fc.array(
                                fc.record({
                                    productId: fc.string({ minLength: 1, maxLength: 20 }),
                                    quantity: fc.integer({ min: 1, max: 100 }),
                                    addedAt: fc.integer({ min: 1000000000000, max: Date.now() })
                                }),
                                { minLength: 1, maxLength: 5 }
                            ),
                            totalPrice: fc.float({ min: Math.fround(0.01), max: Math.fround(100000), noNaN: true })
                        }),
                        { minLength: 2, maxLength: 10 }
                    ),
                    async (orderDataArray) => {
                        const deliveredOrders = [];

                        // Create all orders and mark them as delivered
                        for (const orderData of orderDataArray) {
                            const order = orderManager.createOrder(
                                orderData.customerInfo,
                                orderData.cartItems,
                                orderData.totalPrice
                            );
                            const deliveredOrder = await orderManager.updateOrderStatus(order.orderId, 'delivered');
                            deliveredOrders.push(deliveredOrder);
                        }

                        // Verify all QR codes are unique
                        const qrCodes = deliveredOrders.map(o => o.qrCode);
                        const uniqueQrCodes = new Set(qrCodes);
                        expect(uniqueQrCodes.size).toBe(qrCodes.length);

                        // Verify all certificates are unique
                        const certificates = deliveredOrders.map(o => o.certificate);
                        const uniqueCertificates = new Set(certificates);
                        expect(uniqueCertificates.size).toBe(certificates.length);

                        return true;
                    }
                ),
                { numRuns: 100 }
            );
        });
    });

    /**
     * **Feature: green-shop, Property 10: Order history displays all orders**
     * **Validates: Requirements 5.1**
     * 
     * For any set of created orders, the order history page should display 
     * all orders that exist in storage.
     */
    describe('Property 10: Order history displays all orders', () => {
        test('should display all orders that exist in storage', () => {
            fc.assert(
                fc.property(
                    // Generate array of orders (0-20 orders)
                    fc.array(
                        fc.record({
                            customerInfo: fc.record({
                                name: fc.string({ minLength: 1, maxLength: 50 }),
                                phone: fc.string({ minLength: 9, maxLength: 15 }),
                                address: fc.string({ minLength: 5, maxLength: 100 }),
                                email: fc.emailAddress()
                            }),
                            cartItems: fc.array(
                                fc.record({
                                    productId: fc.string({ minLength: 1, maxLength: 20 }),
                                    quantity: fc.integer({ min: 1, max: 100 }),
                                    addedAt: fc.integer({ min: 1000000000000, max: Date.now() })
                                }),
                                { minLength: 1, maxLength: 5 }
                            ),
                            totalPrice: fc.float({ min: Math.fround(0.01), max: Math.fround(100000), noNaN: true })
                        }),
                        { minLength: 0, maxLength: 20 }
                    ),
                    (orderDataArray) => {
                        // Clear storage to start fresh
                        storageService.clear();
                        orderManager = new OrderManager(storageService);

                        const createdOrders = [];

                        // Create all orders
                        for (const orderData of orderDataArray) {
                            const order = orderManager.createOrder(
                                orderData.customerInfo,
                                orderData.cartItems,
                                orderData.totalPrice
                            );
                            createdOrders.push(order);
                        }

                        // Get orders from order history (simulating what the UI would do)
                        const displayedOrders = orderManager.getOrders();

                        // Verify the count matches
                        expect(displayedOrders.length).toBe(createdOrders.length);

                        // Verify all created orders are in the displayed orders
                        for (const createdOrder of createdOrders) {
                            const foundOrder = displayedOrders.find(
                                o => o.orderId === createdOrder.orderId
                            );
                            expect(foundOrder).toBeDefined();
                            expect(foundOrder.orderNumber).toBe(createdOrder.orderNumber);
                            expect(foundOrder.totalPrice).toBe(createdOrder.totalPrice);
                            expect(foundOrder.status).toBe(createdOrder.status);
                            expect(foundOrder.customerInfo).toEqual(createdOrder.customerInfo);
                            expect(foundOrder.items).toEqual(createdOrder.items);
                        }

                        // Verify no extra orders are displayed
                        for (const displayedOrder of displayedOrders) {
                            const foundOrder = createdOrders.find(
                                o => o.orderId === displayedOrder.orderId
                            );
                            expect(foundOrder).toBeDefined();
                        }

                        return true;
                    }
                ),
                { numRuns: 100 }
            );
        });

        test('should return empty array when no orders exist', () => {
            // Clear storage
            storageService.clear();
            orderManager = new OrderManager(storageService);

            // Get orders when storage is empty
            const orders = orderManager.getOrders();

            // Verify empty array is returned
            expect(Array.isArray(orders)).toBe(true);
            expect(orders.length).toBe(0);
        });

        test('should persist orders across manager instances', () => {
            fc.assert(
                fc.property(
                    // Generate some orders
                    fc.array(
                        fc.record({
                            customerInfo: fc.record({
                                name: fc.string({ minLength: 1, maxLength: 50 }),
                                phone: fc.string({ minLength: 9, maxLength: 15 }),
                                address: fc.string({ minLength: 5, maxLength: 100 }),
                                email: fc.emailAddress()
                            }),
                            cartItems: fc.array(
                                fc.record({
                                    productId: fc.string({ minLength: 1, maxLength: 20 }),
                                    quantity: fc.integer({ min: 1, max: 100 }),
                                    addedAt: fc.integer({ min: 1000000000000, max: Date.now() })
                                }),
                                { minLength: 1, maxLength: 5 }
                            ),
                            totalPrice: fc.float({ min: Math.fround(0.01), max: Math.fround(100000), noNaN: true })
                        }),
                        { minLength: 1, maxLength: 10 }
                    ),
                    (orderDataArray) => {
                        // Clear storage
                        storageService.clear();
                        const manager1 = new OrderManager(storageService);

                        const createdOrderIds = [];

                        // Create orders with first manager instance
                        for (const orderData of orderDataArray) {
                            const order = manager1.createOrder(
                                orderData.customerInfo,
                                orderData.cartItems,
                                orderData.totalPrice
                            );
                            createdOrderIds.push(order.orderId);
                        }

                        // Create new manager instance (simulating page reload)
                        const manager2 = new OrderManager(storageService);

                        // Get orders from new manager instance
                        const retrievedOrders = manager2.getOrders();

                        // Verify all orders are still there
                        expect(retrievedOrders.length).toBe(createdOrderIds.length);

                        for (const orderId of createdOrderIds) {
                            const foundOrder = retrievedOrders.find(o => o.orderId === orderId);
                            expect(foundOrder).toBeDefined();
                        }

                        return true;
                    }
                ),
                { numRuns: 100 }
            );
        });
    });
});
