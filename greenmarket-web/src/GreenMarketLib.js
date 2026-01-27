/**
 * GreenMarket Library - Barcha funksiyalarni birlashtiruvchi asosiy kutubxona
 * Optimallashtirilgan va tez ishlaydigan versiya
 */

// Models
import Product from './models/Product.js';
import CartItem from './models/CartItem.js';
import Order from './models/Order.js';
import CheckoutForm from './models/CheckoutForm.js';
import Filter from './models/Filter.js';

// Services
import CartManager from './services/CartManager.js';
import OrderManager from './services/OrderManager.js';
import SearchManager from './services/SearchManager.js';
import StorageService from './services/StorageService.js';
import PaymentHandler from './services/PaymentHandler.js';
import ProductManager from './services/ProductManager.js';
import ErrorHandler from './services/ErrorHandler.js';
import NotificationService from './services/NotificationService.js';

// Utils
import LazyLoader from './utils/LazyLoader.js';
import { Debouncer, debounce, throttle } from './utils/Debouncer.js';
import VirtualScroller from './utils/VirtualScroller.js';
import { EventDelegator, delegate } from './utils/EventDelegator.js';

// i18n
import { I18n, i18n } from './i18n/i18n.js';

/**
 * GreenMarket - Asosiy kutubxona klassi
 */
class GreenMarket {
    constructor(config = {}) {
        this.config = {
            storagePrefix: config.storagePrefix || 'greenmarket',
            enableCache: config.enableCache !== false,
            enableLazyLoad: config.enableLazyLoad !== false,
            language: config.language || 'uz',
            ...config
        };

        // Servislarni initsializatsiya qilish
        this.storage = new StorageService(this.config.storagePrefix);
        this.errorHandler = new ErrorHandler();
        this.notification = new NotificationService();

        this.cart = new CartManager(this.storage, this.errorHandler);
        this.orders = new OrderManager(this.storage, this.errorHandler);
        this.products = new ProductManager();
        this.search = new SearchManager(this.products.getAllProducts());
        this.payment = new PaymentHandler(this.errorHandler);

        // Utilitylar
        this.lazyLoader = new LazyLoader();
        this.debouncer = new Debouncer();
        this.eventDelegator = new EventDelegator();

        // i18n
        this.i18n = i18n;
        this.i18n.setLanguage(this.config.language);

        // Lazy loading ni yoqish
        if (this.config.enableLazyLoad) {
            this.initLazyLoading();
        }
    }

    /**
     * Lazy loading ni ishga tushirish
     */
    initLazyLoading() {
        if (typeof document !== 'undefined') {
            document.addEventListener('DOMContentLoaded', () => {
                this.lazyLoader.observeImages();
            });
        }
    }

    /**
     * Mahsulotlarni qidirish (debounce bilan)
     */
    searchProducts(query, callback, delay = 300) {
        this.debouncer.debounce('search', () => {
            const results = this.search.search(query);
            if (callback) callback(results);
        }, delay);
    }

    /**
     * Filtrlarni qo'llash (debounce bilan)
     */
    applyFilters(filters, callback, delay = 200) {
        this.debouncer.debounce('filter', () => {
            const results = this.search.applyFilters(filters);
            if (callback) callback(results);
        }, delay);
    }

    /**
     * Savatga mahsulot qo'shish
     */
    async addToCart(productId, quantity = 1) {
        try {
            await this.cart.addItem(productId, quantity);
            this.notification.success('Mahsulot savatga qo\'shildi!');
            return true;
        } catch (error) {
            this.notification.error(this.errorHandler.getUserFriendlyMessage(error));
            return false;
        }
    }

    /**
     * Buyurtma berish
     */
    async createOrder(customerInfo, paymentMethod, paymentDetails) {
        try {
            const cartItems = this.cart.getItems();
            const totalPrice = this.cart.getTotalPrice(this.products.getAllProducts());

            // To'lovni amalga oshirish
            const paymentResult = await this.payment.processPaymentWithRetry(
                paymentMethod,
                paymentDetails,
                totalPrice
            );

            if (!paymentResult.success) {
                this.notification.error(paymentResult.message);
                return null;
            }

            // Buyurtma yaratish
            const order = await this.orders.createOrder(customerInfo, cartItems, totalPrice);

            // Savatni tozalash
            await this.cart.clear();

            this.notification.success('Buyurtma muvaffaqiyatli yaratildi!');
            return order;
        } catch (error) {
            this.notification.error(this.errorHandler.getUserFriendlyMessage(error));
            return null;
        }
    }

    /**
     * Tilni o'zgartirish
     */
    changeLanguage(lang) {
        if (this.i18n.setLanguage(lang)) {
            this.i18n.translatePage();
            this.notification.success(`Til o'zgartirildi: ${lang.toUpperCase()}`);
            return true;
        }
        return false;
    }

    /**
     * Event delegation orqali event qo'shish
     */
    on(container, eventType, selector, handler) {
        return this.eventDelegator.on(container, eventType, selector, handler);
    }

    /**
     * Virtual scrolling yaratish
     */
    createVirtualScroller(container, options) {
        return new VirtualScroller(container, options);
    }

    /**
     * Kutubxonani tozalash
     */
    destroy() {
        this.debouncer.clear();
        this.eventDelegator.clear();
        this.lazyLoader.clearCache();
    }

    /**
     * Statistika olish
     */
    getStats() {
        return {
            cartItems: this.cart.getItemCount(),
            totalOrders: this.orders.getOrders().length,
            totalProducts: this.products.getAllProducts().length,
            storageStatus: this.storage.getStorageStatus(),
            currentLanguage: this.i18n.getLanguage()
        };
    }
}

// Export
export default GreenMarket;

// Agar module.exports kerak bo'lsa
if (typeof module !== 'undefined' && module.exports) {
    module.exports = GreenMarket;
}

// Global o'zgaruvchi (browser uchun)
if (typeof window !== 'undefined') {
    window.GreenMarket = GreenMarket;
}
