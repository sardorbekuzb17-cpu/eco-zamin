import { kv } from '@vercel/kv';

export default async function handler(req, res) {
    // CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }

    try {
        if (req.method === 'GET') {
            // Barcha like'larni olish
            const likes = await kv.hgetall('product_likes') || {};
            return res.status(200).json({ likes });
        }

        if (req.method === 'POST') {
            const { productId } = req.body || req.query;

            if (!productId) {
                return res.status(400).json({ error: 'productId kerak' });
            }

            // Like qo'shish
            const newCount = await kv.hincrby('product_likes', productId, 1);

            return res.status(200).json({
                productId,
                likeCount: newCount
            });
        }

        return res.status(405).json({ error: 'Method not allowed' });
    } catch (error) {
        console.error('Error:', error);
        return res.status(500).json({ error: 'Server error' });
    }
}
