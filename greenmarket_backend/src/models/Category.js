const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
    name: {
        uz: { type: String, required: true },
        ru: { type: String, required: true },
        tr: { type: String, required: true }
    },
    icon: String,
    image: String,
    isActive: { type: Boolean, default: true },
    order: { type: Number, default: 0 },
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Category', categorySchema);
