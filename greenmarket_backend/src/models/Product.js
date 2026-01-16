const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
    name: {
        uz: { type: String, required: true },
        ru: { type: String, required: true },
        tr: { type: String, required: true }
    },
    description: {
        uz: String,
        ru: String,
        tr: String
    },
    price: { type: Number, required: true },
    oldPrice: Number,
    unit: { type: String, enum: ['kg', 'dona', 'boglam', 'litr'], default: 'kg' },
    category: { type: mongoose.Schema.Types.ObjectId, ref: 'Category', required: true },
    image: { type: String, required: true },
    images: [String],
    stock: { type: Number, default: 0 },
    isAvailable: { type: Boolean, default: true },
    isNew: { type: Boolean, default: false },
    isOrganic: { type: Boolean, default: false },
    rating: { type: Number, default: 0 },
    reviewCount: { type: Number, default: 0 },
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Product', productSchema);
