const express = require('express');
const Category = require('../models/Category');
const { protect, admin } = require('../middleware/auth');
const router = express.Router();

// Barcha kategoriyalar
router.get('/', async (req, res) => {
    try {
        const categories = await Category.find({ isActive: true }).sort({ order: 1 });
        res.json({ success: true, categories });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Yangi kategoriya (Admin)
router.post('/', protect, admin, async (req, res) => {
    try {
        const category = await Category.create(req.body);
        res.status(201).json({ success: true, category });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Kategoriya yangilash (Admin)
router.put('/:id', protect, admin, async (req, res) => {
    try {
        const category = await Category.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.json({ success: true, category });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

module.exports = router;
