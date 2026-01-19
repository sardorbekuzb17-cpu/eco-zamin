const mongoose = require('mongoose');

// MyID User Model
const MyIdUserSchema = new mongoose.Schema({
    pinfl: { type: String, required: true, unique: true, index: true },
    myid_code: { type: String, required: true },
    profile: mongoose.Schema.Types.Mixed,
    face_image: String,
    auth_method: { type: String, default: 'sdk_direct' },
    status: { type: String, enum: ['active', 'inactive', 'blocked'], default: 'active' },
    registered_at: { type: Date, default: Date.now, index: true },
    last_login: { type: Date, default: Date.now },
    deleted_at: Date,
});

const MyIdUser = mongoose.model('MyIdUser', MyIdUserSchema);

module.exports = async (req, res) => {
    try {
        // MongoDB ulanish
        if (mongoose.connection.readyState === 0) {
            await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/greenmarket');
        }

        const users = await MyIdUser.find({ deleted_at: null })
            .select('-face_image')
            .sort({ registered_at: -1 });

        res.status(200).json({
            success: true,
            data: {
                total: users.length,
                users,
            },
        });
    } catch (error) {
        console.error('❌ Foydalanuvchilar olishda xato:', error.message);
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
};
