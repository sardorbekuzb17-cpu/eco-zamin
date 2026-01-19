const mongoose = require('mongoose');

// MyID User Model
const MyIdUserSchema = new mongoose.Schema({
    pinfl: { type: String, required: true, unique: true, index: true },
    registered_at: { type: Date, default: Date.now, index: true },
    deleted_at: Date,
});

const MyIdUser = mongoose.model('MyIdUser', MyIdUserSchema);

module.exports = async (req, res) => {
    try {
        // MongoDB ulanish
        if (mongoose.connection.readyState === 0) {
            await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/greenmarket');
        }

        const totalUsers = await MyIdUser.countDocuments({ deleted_at: null });

        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const todayUsers = await MyIdUser.countDocuments({
            registered_at: { $gte: today },
            deleted_at: null,
        });

        res.status(200).json({
            success: true,
            data: {
                total_users: totalUsers,
                today_registrations: todayUsers,
                last_updated: new Date(),
            },
        });
    } catch (error) {
        console.error('❌ Statistika olishda xato:', error.message);
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
};
