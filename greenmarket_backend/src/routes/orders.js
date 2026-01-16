const express = require('express');
const Order = require('../models/Order');
const Cart = require('../models/Cart');
const { protect, admin } = require('../middleware/auth');
const router = express.Router();

// Buyurtma yaratish
router.post('/', protect, async (req, res) => {
    try {
        const { items, address, phone, paymentMethod, deliveryTime, note } = req.body;

        const totalAmount = items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
        const deliveryFee = totalAmount >= 100000 ? 0 : 15000;

        const order = await Order.create({
            user: req.user._id,
            items,
            totalAmount: totalAmount + deliveryFee,
            deliveryFee,
            address,
            phone,
            paymentMethod,
            deliveryTime,
            note
        });

        // Savatchani tozalash
        await Cart.findOneAndUpdate({ user: req.user._id }, { items: [] });

        res.status(201).json({ success: true, order });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Foydalanuvchi buyurtmalari
router.get('/my', protect, async (req, res) => {
    try {
        const orders = await Order.find({ user: req.user._id })
            .populate('items.product', 'name image')
            .sort({ createdAt: -1 });
        res.json({ success: true, orders });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Bitta buyurtma
router.get('/:id', protect, async (req, res) => {
    try {
        const order = await Order.findById(req.params.id).populate('items.product', 'name image');
        if (!order) {
            return res.status(404).json({ success: false, message: 'Buyurtma topilmadi' });
        }
        res.json({ success: true, order });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Barcha buyurtmalar (Admin)
router.get('/', protect, admin, async (req, res) => {
    try {
        const { status, page = 1, limit = 20 } = req.query;
        let query = {};
        if (status) query.status = status;

        const orders = await Order.find(query)
            .populate('user', 'name phone')
            .sort({ createdAt: -1 })
            .limit(parseInt(limit))
            .skip((parseInt(page) - 1) * parseInt(limit));

        const total = await Order.countDocuments(query);

        res.json({ success: true, orders, pagination: { page: parseInt(page), total } });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Buyurtma statusini yangilash (Admin)
router.put('/:id/status', protect, admin, async (req, res) => {
    try {
        const { status } = req.body;
        const order = await Order.findByIdAndUpdate(
            req.params.id,
            { status, updatedAt: Date.now() },
            { new: true }
        );
        res.json({ success: true, order });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

module.exports = router;
