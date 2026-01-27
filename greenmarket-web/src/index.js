// Models
const Product = require('./models/Product');
const CartItem = require('./models/CartItem');
const Order = require('./models/Order');
const Filter = require('./models/Filter');

// Services
const CartManager = require('./services/CartManager');
const OrderManager = require('./services/OrderManager');
const SearchManager = require('./services/SearchManager');
const StorageService = require('./services/StorageService');

module.exports = {
    // Models
    Product,
    CartItem,
    Order,
    Filter,

    // Services
    CartManager,
    OrderManager,
    SearchManager,
    StorageService
};
