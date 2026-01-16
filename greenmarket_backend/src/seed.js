const mongoose = require('mongoose');
require('dotenv').config();

const Category = require('./models/Category');
const Product = require('./models/Product');
const User = require('./models/User');

const categories = [
    { name: { uz: 'Mevalar', ru: 'Фрукты', tr: 'Meyveler' }, icon: '🍎', order: 1 },
    { name: { uz: 'Sabzavotlar', ru: 'Овощи', tr: 'Sebzeler' }, icon: '🥦', order: 2 },
    { name: { uz: "Ko'katlar", ru: 'Зелень', tr: 'Yeşillikler' }, icon: '🌿', order: 3 },
    { name: { uz: 'Sut mahsulotlari', ru: 'Молочные продукты', tr: 'Süt ürünleri' }, icon: '🥛', order: 4 },
];

const seedDB = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log('MongoDB ga ulandi');

        // Tozalash
        await Category.deleteMany({});
        await Product.deleteMany({});

        // Kategoriyalar
        const createdCategories = await Category.insertMany(categories);
        console.log('Kategoriyalar yaratildi');

        // Mahsulotlar
        const products = [
            {
                name: { uz: 'Qizil Olma', ru: 'Красное яблоко', tr: 'Kırmızı Elma' },
                description: { uz: 'Yangi, shirin olma', ru: 'Свежее сладкое яблоко', tr: 'Taze tatlı elma' },
                price: 15000, unit: 'kg', category: createdCategories[0]._id,
                image: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400',
                stock: 100, isAvailable: true
            },
            {
                name: { uz: 'Banan', ru: 'Банан', tr: 'Muz' },
                description: { uz: 'Import qilingan banan', ru: 'Импортный банан', tr: 'İthal muz' },
                price: 22000, unit: 'kg', category: createdCategories[0]._id,
                image: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400',
                stock: 80, isAvailable: true
            },
            {
                name: { uz: 'Sabzi', ru: 'Морковь', tr: 'Havuç' },
                description: { uz: 'Yangi sabzi', ru: 'Свежая морковь', tr: 'Taze havuç' },
                price: 4500, unit: 'kg', category: createdCategories[1]._id,
                image: 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400',
                stock: 150, isAvailable: true, isNew: true
            },
            {
                name: { uz: 'Pomidor', ru: 'Помидор', tr: 'Domates' },
                description: { uz: 'Mahalliy pomidor', ru: 'Местный помидор', tr: 'Yerli domates' },
                price: 12000, unit: 'kg', category: createdCategories[1]._id,
                image: 'https://images.unsplash.com/photo-1546470427-227c7369a9b8?w=400',
                stock: 200, isAvailable: true
            },
            {
                name: { uz: 'Bodring', ru: 'Огурец', tr: 'Salatalık' },
                description: { uz: 'Yangi bodring', ru: 'Свежий огурец', tr: 'Taze salatalık' },
                price: 8000, unit: 'kg', category: createdCategories[1]._id,
                image: 'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=400',
                stock: 120, isAvailable: true
            },
            {
                name: { uz: "Ukrop", ru: 'Укроп', tr: 'Dereotu' },
                description: { uz: "Yangi ko'kat", ru: 'Свежая зелень', tr: 'Taze yeşillik' },
                price: 3000, unit: 'boglam', category: createdCategories[2]._id,
                image: 'https://images.unsplash.com/photo-1466637574441-749b8f19452f?w=400',
                stock: 50, isAvailable: true, isOrganic: true
            },
        ];

        await Product.insertMany(products);
        console.log('Mahsulotlar yaratildi');

        // Admin foydalanuvchi
        const adminExists = await User.findOne({ phone: '+998901234567' });
        if (!adminExists) {
            await User.create({
                name: 'Admin',
                phone: '+998901234567',
                password: 'admin123',
                role: 'admin'
            });
            console.log('Admin yaratildi: +998901234567 / admin123');
        }

        console.log('Seed muvaffaqiyatli yakunlandi!');
        process.exit(0);
    } catch (error) {
        console.error('Seed xatosi:', error);
        process.exit(1);
    }
};

seedDB();
