const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const productRoutes = require('./routes/products');
const categoryRoutes = require('./routes/categories');
const orderRoutes = require('./routes/orders');
const cartRoutes = require('./routes/cart');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/cart', cartRoutes);

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', message: 'GreenMarket API ishlayapti!' });
});

// MongoDB ulanish
mongoose.connect(process.env.MONGODB_URI)
    .then(() => console.log('MongoDB ga ulandi'))
    .catch(err => console.error('MongoDB xatosi:', err));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server ${PORT} portda ishlayapti`);
});
