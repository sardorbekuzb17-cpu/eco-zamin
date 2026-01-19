const mongoose = require('mongoose');

const myIdUserSchema = new mongoose.Schema({
    // MyID ma'lumotlari
    pinfl: {
        type: String,
        required: true,
        unique: true,
        index: true
    },
    myid_code: {
        type: String,
        required: true
    },

    // Profil ma'lumotlari
    profile: {
        first_name: String,
        last_name: String,
        middle_name: String,
        birth_date: String,
        gender: String,
        nationality: String,
        passport_number: String,
        passport_series: String,
        passport_issue_date: String,
        passport_expiry_date: String,
        passport_issuer: String,
    },

    // Rasmlar (base64)
    face_image: String,
    passport_image: String,

    // Taqqoslash natijasi
    comparison_value: Number,

    // Autentifikatsiya usuli
    auth_method: {
        type: String,
        enum: ['sdk_direct', 'simple_authorization', 'empty_session'],
        default: 'sdk_direct'
    },

    // Holat
    status: {
        type: String,
        enum: ['active', 'inactive', 'blocked'],
        default: 'active'
    },

    // Vaqtlar
    registered_at: {
        type: Date,
        default: Date.now,
        index: true
    },
    last_login: {
        type: Date,
        default: Date.now
    },

    // Qo'shimcha ma'lumotlar
    device_info: {
        device_id: String,
        device_name: String,
        os: String,
        app_version: String,
    },

    // Metadata
    metadata: mongoose.Schema.Types.Mixed,

    // Soft delete
    deleted_at: Date,
});

// Indekslar
myIdUserSchema.index({ pinfl: 1 });
myIdUserSchema.index({ registered_at: -1 });
myIdUserSchema.index({ status: 1 });

// Virtual - to'liq ism
myIdUserSchema.virtual('full_name').get(function () {
    const profile = this.profile || {};
    return `${profile.first_name || ''} ${profile.last_name || ''}`.trim();
});

// Metodlar
myIdUserSchema.methods.toJSON = function () {
    const obj = this.toObject();
    // Rasmlarni qaytarmaylik (juda katta)
    delete obj.face_image;
    delete obj.passport_image;
    return obj;
};

module.exports = mongoose.model('MyIdUser', myIdUserSchema);
