const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    items: [{
        product: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
        name: String,
        price: Number,
        quantity: Number
    }],
    totalAmount: { type: Number, required: true },
    deliveryFee: { type: Number, default: 0 },
    address: {
        region: String,
        district: String,
        street: String,
        apartment: String,
        landmark: String
    },
    phone: { type: String, required: true },
    paymentMethod: { type: String, enum: ['cash', 'payme', 'click', 'card'], default: 'cash' },
    paymentStatus: { type: String, enum: ['pending', 'paid', 'failed'], default: 'pending' },
    status: {
        type: String,
        enum: ['pending', 'confirmed', 'preparing', 'delivering', 'delivered', 'cancelled'],
        default: 'pending'
    },
    deliveryTime: String,
    note: String,
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Order', orderSchema);
