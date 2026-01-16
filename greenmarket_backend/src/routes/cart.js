const express = require('express');
const Cart = require('../models/Cart');
const { protect } = require('../middleware/auth');
const router = express.Router();

// Savatchani olish
router.get('/', protect, async (req, res) => {
    try {
        let cart = await Cart.findOne({ user: req.user._id }).populate('items.product');
        if (!cart) {
            cart = await Cart.create({ user: req.user._id, items: [] });
        }
        res.json({ success: true, cart });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Savatchaga qo'shish
router.post('/add', protect, async (req, res) => {
    try {
        const { productId, quantity = 1 } = req.body;

        let cart = await Cart.findOne({ user: req.user._id });
        if (!cart) {
            cart = await Cart.create({ user: req.user._id, items: [] });
        }

        const itemIndex = cart.items.findIndex(item => item.product.toString() === productId);

        if (itemIndex > -1) {
            cart.items[itemIndex].quantity += quantity;
        } else {
            cart.items.push({ product: productId, quantity });
        }

        cart.updatedAt = Date.now();
        await cart.save();

        cart = await Cart.findById(cart._id).populate('items.product');
        res.json({ success: true, cart });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Miqdorni yangilash
router.put('/update', protect, async (req, res) => {
    try {
        const { productId, quantity } = req.body;

        const cart = await Cart.findOne({ user: req.user._id });
        const itemIndex = cart.items.findIndex(item => item.product.toString() === productId);

        if (itemIndex > -1) {
            if (quantity <= 0) {
                cart.items.splice(itemIndex, 1);
            } else {
                cart.items[itemIndex].quantity = quantity;
            }
            cart.updatedAt = Date.now();
            await cart.save();
        }

        const updatedCart = await Cart.findById(cart._id).populate('items.product');
        res.json({ success: true, cart: updatedCart });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Savatchadan o'chirish
router.delete('/remove/:productId', protect, async (req, res) => {
    try {
        const cart = await Cart.findOne({ user: req.user._id });
        cart.items = cart.items.filter(item => item.product.toString() !== req.params.productId);
        cart.updatedAt = Date.now();
        await cart.save();

        const updatedCart = await Cart.findById(cart._id).populate('items.product');
        res.json({ success: true, cart: updatedCart });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Savatchani tozalash
router.delete('/clear', protect, async (req, res) => {
    try {
        await Cart.findOneAndUpdate({ user: req.user._id }, { items: [], updatedAt: Date.now() });
        res.json({ success: true, message: 'Savatcha tozalandi' });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

module.exports = router;
