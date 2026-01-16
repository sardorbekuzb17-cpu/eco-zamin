const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const userSchema = new mongoose.Schema({
    name: { type: String, required: true },
    phone: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    email: { type: String },
    address: {
        region: String,
        district: String,
        street: String
    },
    role: { type: String, enum: ['user', 'admin'], default: 'user' },
    favorites: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Product' }],
    createdAt: { type: Date, default: Date.now }
});

// Parolni hash qilish
userSchema.pre('save', async function (next) {
    if (!this.isModified('password')) return next();
    this.password = await bcrypt.hash(this.password, 10);
    next();
});

// Parolni tekshirish
userSchema.methods.comparePassword = async function (password) {
    return await bcrypt.compare(password, this.password);
};

// JWT token yaratish
userSchema.methods.generateToken = function () {
    return jwt.sign({ id: this._id, role: this.role }, process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRE
    });
};

module.exports = mongoose.model('User', userSchema);
