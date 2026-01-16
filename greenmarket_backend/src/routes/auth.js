const express = require('express');
const User = require('../models/User');
const { protect } = require('../middleware/auth');
const router = express.Router();

// Ro'yxatdan o'tish
router.post('/register', async (req, res) => {
    try {
        const { name, phone, password } = req.body;

        const existingUser = await User.findOne({ phone });
        if (existingUser) {
            return res.status(400).json({ success: false, message: 'Bu telefon raqami allaqachon ro\'yxatdan o\'tgan' });
        }

        const user = await User.create({ name, phone, password });
        const token = user.generateToken();

        res.status(201).json({
            success: true,
            token,
            user: { id: user._id, name: user.name, phone: user.phone, role: user.role }
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Kirish
router.post('/login', async (req, res) => {
    try {
        const { phone, password } = req.body;

        const user = await User.findOne({ phone });
        if (!user) {
            return res.status(401).json({ success: false, message: 'Telefon yoki parol noto\'g\'ri' });
        }

        const isMatch = await user.comparePassword(password);
        if (!isMatch) {
            return res.status(401).json({ success: false, message: 'Telefon yoki parol noto\'g\'ri' });
        }

        const token = user.generateToken();

        res.json({
            success: true,
            token,
            user: { id: user._id, name: user.name, phone: user.phone, role: user.role }
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

// Profil olish
router.get('/me', protect, async (req, res) => {
    res.json({ success: true, user: req.user });
});

// Profil yangilash
router.put('/me', protect, async (req, res) => {
    try {
        const { name, email, address } = req.body;
        const user = await User.findByIdAndUpdate(
            req.user._id,
            { name, email, address },
            { new: true }
        );
        res.json({ success: true, user });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

module.exports = router;
