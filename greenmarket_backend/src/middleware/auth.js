const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Token tekshirish
exports.protect = async (req, res, next) => {
    try {
        let token;
        if (req.headers.authorization?.startsWith('Bearer')) {
            token = req.headers.authorization.split(' ')[1];
        }

        if (!token) {
            return res.status(401).json({ success: false, message: 'Avtorizatsiya talab qilinadi' });
        }

        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = await User.findById(decoded.id);

        if (!req.user) {
            return res.status(401).json({ success: false, message: 'Foydalanuvchi topilmadi' });
        }

        next();
    } catch (error) {
        res.status(401).json({ success: false, message: 'Token yaroqsiz' });
    }
};

// Admin tekshirish
exports.admin = (req, res, next) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ success: false, message: 'Admin huquqi talab qilinadi' });
    }
    next();
};
