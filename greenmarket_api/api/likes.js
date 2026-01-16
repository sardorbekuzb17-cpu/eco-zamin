// Oddiy in-memory storage (Vercel KV o'rniga)
let likesData = {};

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
            return res.status(200).json({ likes: likesData });
        }

        if (req.method === 'POST') {
            const { productId, action } = req.body || {};

            if (!productId) {
                return res.status(400).json({ error: 'productId kerak' });
            }

            let currentCount = likesData[productId] || 0;

            if (action === 'unlike') {
                currentCount = Math.max(0, currentCount - 1);
            } else {
                currentCount = currentCount + 1;
            }

            likesData[productId] = currentCount;

            return res.status(200).json({
                productId,
                likeCount: currentCount
            });
        }

        return res.status(405).json({ error: 'Method not allowed' });
    } catch (error) {
        console.error('Error:', error);
        return res.status(500).json({ error: 'Server error', details: error.message });
    }
}
