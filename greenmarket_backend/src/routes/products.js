const express = require('express');
const Product = require('../models/Product');
const { protect, admin } = require('../middleware/auth');
const router = express.Router();

// Barcha mahsulotlar
router.get('/', async (req, res) => {
    try {
        const { category, search, sort, limit = 20, page = 1 } = req.query;

        let query = { isAvailable: true };

        if (category) query.category = category;
        if (search) {
            query.$or = [
                { 'name.uz': { $regex: search, $options: 'i' } },
                { 'name.ru': { $regex: search, $options: 'i' } },
                { 'name.tr': { $regex: search, $options: 'i' } }
            ];
        }

        let sortOption = { createdAt: -1 };
        if (sort === 'price_asc') sortOption = { price: 1 };
        if (sort === 'price_desc') sortOption = { price: -1 };
        if (sort === 'popular') sortOption = { rating: -1 };

        const products = await Product.find(query)
            .populate('category', 'name')
            .sort(sortOption)
            .limit(parseInt(limit))
            .skip((parseInt(page) - 1) * parseInt(limit));

        const total = await Product.countDocuments(query);

        res.json({
            success: true,
            products,
            pagination: { page: parseInt(page), limit: parseInt(limit), total, pages: Math.ceil(total / limit) }
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Bitta mahsulot
router.get('/:id', async (req, res) => {
    try {
        const product = await Product.findById(req.params.id).populate('category', 'name');
        if (!product) {
            return res.status(404).json({ success: false, message: 'Mahsulot topilmadi' });
        }
        res.json({ success: true, product });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Yangi mahsulot (Admin)
router.post('/', protect, admin, async (req, res) => {
    try {
        const product = await Product.create(req.body);
        res.status(201).json({ success: true, product });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Mahsulot yangilash (Admin)
router.put('/:id', protect, admin, async (req, res) => {
    try {
        const product = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.json({ success: true, product });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Mahsulot o'chirish (Admin)
router.delete('/:id', protect, admin, async (req, res) => {
    try {
        await Product.findByIdAndDelete(req.params.id);
        res.json({ success: true, message: 'Mahsulot o\'chirildi' });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

module.exports = router;
