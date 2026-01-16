// Buyurtmalar uchun API
let ordersData = [];
let orderIdCounter = 1000;

export default async function handler(req, res) {
    // CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }

    try {
        if (req.method === 'GET') {
            // Barcha buyurtmalarni olish
            const { userId } = req.query;

            if (userId) {
                // Foydalanuvchi buyurtmalarini olish
                const userOrders = ordersData.filter(order => order.userId === userId);
                return res.status(200).json({ orders: userOrders });
            }

            // Barcha buyurtmalar
            return res.status(200).json({ orders: ordersData });
        }

        if (req.method === 'POST') {
            // Yangi buyurtma yaratish
            const { userId, items, total, customerInfo, deliveryAddress } = req.body || {};

            if (!userId || !items || !total) {
                return res.status(400).json({
                    error: 'userId, items va total majburiy'
                });
            }

            const newOrder = {
                orderId: `ORD-${orderIdCounter++}`,
                userId,
                items,
                total,
                customerInfo: customerInfo || {},
                deliveryAddress: deliveryAddress || {},
                status: 'pending', // pending, confirmed, delivering, delivered, cancelled
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString()
            };

            ordersData.push(newOrder);

            return res.status(201).json({
                success: true,
                order: newOrder,
                message: 'Buyurtma muvaffaqiyatli yaratildi'
            });
        }

        if (req.method === 'PUT') {
            // Buyurtma holatini yangilash
            const { orderId, status } = req.body || {};

            if (!orderId || !status) {
                return res.status(400).json({
                    error: 'orderId va status majburiy'
                });
            }

            const orderIndex = ordersData.findIndex(order => order.orderId === orderId);

            if (orderIndex === -1) {
                return res.status(404).json({ error: 'Buyurtma topilmadi' });
            }

            ordersData[orderIndex].status = status;
            ordersData[orderIndex].updatedAt = new Date().toISOString();

            return res.status(200).json({
                success: true,
                order: ordersData[orderIndex],
                message: 'Buyurtma holati yangilandi'
            });
        }

        return res.status(405).json({ error: 'Method not allowed' });
    } catch (error) {
        console.error('Error:', error);
        return res.status(500).json({
            error: 'Server xatosi',
            details: error.message
        });
    }
}
