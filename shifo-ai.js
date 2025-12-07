// Shifo AI - Sun'iy Intellekt Yordamchisi
// Kasalliklar va tabiiy mahsulotlar bo'yicha maslahat beruvchi tizim

// Kasalliklar va ularning yechimlarini o'z ichiga olgan keng ma'lumotlar bazasi
const healthDatabase = {
    // Immunitet
    immunitet: {
        keywords: ['immunitet', 'shamollash', 'gripp', 'sovuq', 'virus', 'infeksiya', 'kasallik', 'himoya'],
        products: [
            { name: 'Asal', reason: 'Tabiiy antibiotik, immunitetni kuchaytiradi', category: 'honey' },
            { name: 'Sarimsoq', reason: 'Kuchli antibakterial va antivirus ta\'sir', category: 'vegetables' },
            { name: 'Sitrus mevalar', reason: 'Vitamin C manbai, immunitetni mustahkamlaydi', category: 'fruits' },
            { name: 'Kurkuma', reason: 'Yallig\'lanishga qarshi, immunitetni ko\'taradi', category: 'spices' },
            { name: 'Zig\'ir yog\'i', reason: 'Omega-3 bilan organizmni mustahkamlaydi', category: 'oils' }
        ],
        advice: 'Kuniga 1 qoshiq asal, 2-3 bo\'lak sarimsoq va sitrus mevalarni iste\'mol qiling. Issiq choy bilan ichish tavsiya etiladi.'
    },

    // Qon bosimi
    bosim: {
        keywords: ['bosim', 'gipertoniya', 'yuqori bosim', 'past bosim', 'bosh aylanishi', 'qon bosimi'],
        products: [
            { name: 'Sarimsoq', reason: 'Qon bosimini pasaytiradi, tomirlarni kengaytiradi', category: 'vegetables' },
            { name: 'Gulchoy', reason: 'Yumshoq tarzda bosimni me\'yorlashtiradi', category: 'herbs' },
            { name: 'Bodom', reason: 'Magniy manbai, bosimni barqarorlashtiradi', category: 'nuts' },
            { name: 'Sabzi', reason: 'Qon bosimini me\'yorlaydi', category: 'vegetables' },
            { name: 'Kungaboqar yog\'i', reason: 'Qon tomirlarni mustahkamlaydi', category: 'oils' }
        ],
        advice: 'Tuzni kamaytiring, kuniga 2-3 bo\'lak sarimsoq va gulchoy ichimligini iste\'mol qiling. Muntazam harakatda bo\'ling.'
    },

    // Hazm tizimi
    hazm: {
        keywords: ['hazm', 'oshqozon', 'qorin', 'ich ketish', 'qabziyat', 'shish', 'gazlar', 'ovqat hazm'],
        products: [
            { name: 'Qatiq', reason: 'Probiotiklar ichak florasini tiklaydi', category: 'dairy' },
            { name: 'Zira', reason: 'Hazmni yengillashtiradi, gazlarni chiqaradi', category: 'spices' },
            { name: 'Yalpiz', reason: 'Oshqozonni tinchlantiradi', category: 'herbs' },
            { name: 'Olma', reason: 'Tolalar bilan hazmni yaxshilaydi', category: 'fruits' },
            { name: 'Zira o\'ti', reason: 'Qorin og\'riqlarini kamaytiradi', category: 'herbs' }
        ],
        advice: 'Kuniga 1-2 stakan qatiq, zira va yalpiz choyini iste\'mol qiling. Ovqatni yaxshilab chaynang.'
    },

    // Uyqu muammolari
    uyqu: {
        keywords: ['uyqu', 'uxlamoq', 'beixtiyor', 'charchoq', 'dam olish', 'tush ko\'rish'],
        products: [
            { name: 'Choyshab', reason: 'Tabiiy tinchlantiruvchi, uyquni yaxshilaydi', category: 'herbs' },
            { name: 'Asal', reason: 'Melatonin ishlab chiqarishni rag\'batlantiradi', category: 'honey' },
            { name: 'Yong\'oq', reason: 'Stressni kamaytiradi, uyquni yaxshilaydi', category: 'nuts' },
            { name: 'Gilos', reason: 'Tabiiy melatonin manbai', category: 'fruits' },
            { name: 'Gulchoy', reason: 'Asabni tinchlantiradi', category: 'herbs' }
        ],
        advice: 'Uxlashdan 1 soat oldin choyshab choyini asal bilan iste\'mol qiling. Ekranlardan uzoqlashing.'
    },

    // Energiya va charchoq
    energiya: {
        keywords: ['energiya', 'charchoq', 'halsizlik', 'kuch', 'toliqish', 'sustlik'],
        products: [
            { name: 'Uzum', reason: 'Tez energiya beradi, qon aylanishini yaxshilaydi', category: 'fruits' },
            { name: 'Mayiz', reason: 'Uzoq muddatli energiya manbai', category: 'nuts' },
            { name: 'Asal', reason: 'Tabiiy shakar, tez energiya', category: 'honey' },
            { name: 'Bodom', reason: 'Protein va yog\'lar bilan to\'ldiradi', category: 'nuts' },
            { name: 'Sariyog\'', reason: 'Toza energiya manbai', category: 'dairy' }
        ],
        advice: 'Ertalab asal va yong\'oqlar bilan boshlansin. Kuniga 5-6 marta ozgina ovqatlaning.'
    },

    // Teri muammolari
    teri: {
        keywords: ['teri', 'akne', 'dog\'', 'qichishish', 'quruq teri', 'yallig\'lanish', 'chaqaloq'],
        products: [
            { name: 'O\'rik', reason: 'Terini oziqlantiradi, vitamin A manbai', category: 'fruits' },
            { name: 'Qonim yog\'i', reason: 'Teri va sochni oziqlantiradi', category: 'oils' },
            { name: 'Sabzi', reason: 'Terini tozalaydi, beta-karotin manbai', category: 'vegetables' },
            { name: 'Bodring', reason: 'Teriga namlik beradi', category: 'vegetables' },
            { name: 'Qaymoq', reason: 'Vitamin A va E bilan terini oziqlantiradi', category: 'dairy' }
        ],
        advice: 'Ko\'proq suv iching, kuniga 1 ta sabzi va bodring iste\'mol qiling. Qonim yog\'ini tashqi qo\'llash ham foydali.'
    },

    // Yurak va qon tomirlari
    yurak: {
        keywords: ['yurak', 'qon tomirlar', 'xolesterin', 'kardio', 'yurak urishi'],
        products: [
            { name: 'Pista', reason: 'Yurakni mustahkamlaydi, xolesterinni kamaytiradi', category: 'nuts' },
            { name: 'Zig\'ir yog\'i', reason: 'Omega-3 yurak uchun zarur', category: 'oils' },
            { name: 'Pomidor', reason: 'Likopin yurakni himoya qiladi', category: 'vegetables' },
            { name: 'Uzum', reason: 'Yurak mushagini mustahkamlaydi', category: 'fruits' },
            { name: 'Gulchoy', reason: 'Yurak faoliyatini qo\'llaydi', category: 'herbs' }
        ],
        advice: 'Yog\'li baliqlar, yong\'oqlar va mevalarni ko\'proq iste\'mol qiling. Jismoniy faollikni oshiring.'
    },

    // Jigar
    jigar: {
        keywords: ['jigar', 'gepatit', 'zaharlanish', 'toksin', 'tozalash'],
        products: [
            { name: 'O\'rik', reason: 'Jigar faoliyatini yaxshilaydi', category: 'fruits' },
            { name: 'Kurkuma', reason: 'Jigerni tozalaydi va himoya qiladi', category: 'spices' },
            { name: 'Sariyog\'', reason: 'Jigar faoliyatini qo\'llab-quvvatlaydi', category: 'dairy' },
            { name: 'Sarimsoq', reason: 'Jigerni toksinlardan tozalaydi', category: 'vegetables' },
            { name: 'Gilos', reason: 'Tanani toksinlardan tozalaydi', category: 'fruits' }
        ],
        advice: 'Alkogol va yog\'li ovqatlardan qoching. Kurkuma va sarimsoqni muntazam iste\'mol qiling.'
    },

    // Bosh og'rig'i
    bosh: {
        keywords: ['bosh og\'rig\'i', 'migren', 'bosh', 'og\'riq', 'bosh aylanishi'],
        products: [
            { name: 'Yalpiz', reason: 'Bosh og\'rig\'ini yengillashtiradi', category: 'herbs' },
            { name: 'Asal', reason: 'Qon shakarini barqarorlashtiradi', category: 'honey' },
            { name: 'Yong\'oq', reason: 'Magniy manbai, migrenni kamaytiradi', category: 'nuts' },
            { name: 'Gulchoy', reason: 'Asabni tinchlantiradi', category: 'herbs' },
            { name: 'Bodring', reason: 'Suvsizlanishni bartaraf etadi', category: 'vegetables' }
        ],
        advice: 'Ko\'proq suv iching, yalpiz choyini iste\'mol qiling. Stressdan qoching va yetarli uxlang.'
    },

    // Bo'g'im og'riqlari
    bogim: {
        keywords: ['bo\'g\'im', 'artrit', 'revmatizm', 'og\'riq', 'yallig\'lanish', 'qo\'l', 'oyoq'],
        products: [
            { name: 'Kurkuma', reason: 'Kuchli yallig\'lanishga qarshi', category: 'spices' },
            { name: 'Gilos', reason: 'Bo\'g\'im og\'riqlarini kamaytiradi', category: 'fruits' },
            { name: 'Zig\'ir yog\'i', reason: 'Omega-3 yallig\'lanishni kamaytiradi', category: 'oils' },
            { name: 'Sarimsoq', reason: 'Yallig\'lanishga qarshi ta\'sir', category: 'vegetables' },
            { name: 'Asal', reason: 'Tabiiy yallig\'lanishga qarshi vosita', category: 'honey' }
        ],
        advice: 'Kurkuma va asal aralashmasini kuniga 2 marta iste\'mol qiling. Yengil mashqlar qiling.'
    },

    // Qon shakari (diabet)
    shakar: {
        keywords: ['shakar', 'diabet', 'qand', 'glyukoza', 'insulin'],
        products: [
            { name: 'Dolchin', reason: 'Qon shakarini me\'yorlashtiradi', category: 'spices' },
            { name: 'Yong\'oq', reason: 'Qon shakarini barqarorlashtiradi', category: 'nuts' },
            { name: 'Olma', reason: 'Tolalar qon shakarini nazorat qiladi', category: 'fruits' },
            { name: 'Kurkuma', reason: 'Insulin sezgirligini oshiradi', category: 'spices' },
            { name: 'Qatiq', reason: 'Probiotiklar metabolizmni yaxshilaydi', category: 'dairy' }
        ],
        advice: 'Oddiy shakardan qoching. Dolchin va yong\'oqlarni muntazam iste\'mol qiling. Shifokoringiz bilan maslahatlashing.'
    },

    // Ko'z
    koz: {
        keywords: ['ko\'z', 'ko\'rish', 'nur', 'ko\'z og\'rig\'i', 'ko\'z toliqishi'],
        products: [
            { name: 'Sabzi', reason: 'Beta-karotin ko\'rishni kuchaytiradi', category: 'vegetables' },
            { name: 'O\'rik', reason: 'Vitamin A ko\'z nurini mustahkamlaydi', category: 'fruits' },
            { name: 'Yong\'oq', reason: 'Vitamin E ko\'zni himoya qiladi', category: 'nuts' },
            { name: 'Bodom', reason: 'Ko\'z sog\'lig\'i uchun zarur vitaminlar', category: 'nuts' },
            { name: 'Qonim yog\'i', reason: 'Ko\'z to\'qimalarini oziqlantiradi', category: 'oils' }
        ],
        advice: 'Kuniga 1-2 ta sabzi va o\'rik iste\'mol qiling. Ekran vaqtini cheklang va ko\'z mashqlarini qiling.'
    }
};

// Chat messages array
let chatMessages = [];

// Tez savollar funksiyasi
function askQuestion(question) {
    document.getElementById('userInput').value = question;
    sendMessage();
}

// Xabar yuborish
function sendMessage() {
    const input = document.getElementById('userInput');
    const message = input.value.trim();

    if (!message) return;

    // Add user message
    addMessage(message, 'user');
    input.value = '';

    // Show typing indicator
    showTypingIndicator();

    // Process message and respond
    setTimeout(() => {
        hideTypingIndicator();
        const response = processHealthQuery(message);
        addMessage(response.text, 'ai', response.products);
    }, 1500);
}

// Xabar qo'shish
function addMessage(text, type, products = null) {
    const messagesContainer = document.getElementById('chatMessages');
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${type}-message`;

    if (type === 'user') {
        messageDiv.innerHTML = `
            <div class="message-avatar">
                <i class="fas fa-user"></i>
            </div>
            <div class="message-content">
                <p>${text}</p>
            </div>
        `;
    } else {
        let productsHTML = '';
        if (products && products.length > 0) {
            productsHTML = products.map(p => `
                <div class="product-recommendation">
                    <h4><i class="fas fa-leaf"></i> ${p.name}</h4>
                    <p>${p.reason}</p>
                    <a href="catalog.html#${p.category}" class="product-link">
                        Katalogda ko'rish <i class="fas fa-arrow-right"></i>
                    </a>
                </div>
            `).join('');
        }

        messageDiv.innerHTML = `
            <div class="message-avatar">
                <i class="fas fa-robot"></i>
            </div>
            <div class="message-content">
                <p>${text}</p>
                ${productsHTML}
            </div>
        `;
    }

    messagesContainer.appendChild(messageDiv);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

// Typing indicator
function showTypingIndicator() {
    const messagesContainer = document.getElementById('chatMessages');
    const typingDiv = document.createElement('div');
    typingDiv.className = 'message ai-message typing-message';
    typingDiv.innerHTML = `
        <div class="message-avatar">
            <i class="fas fa-robot"></i>
        </div>
        <div class="message-content">
            <div class="typing-indicator">
                <div class="typing-dot"></div>
                <div class="typing-dot"></div>
                <div class="typing-dot"></div>
            </div>
        </div>
    `;
    messagesContainer.appendChild(typingDiv);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

function hideTypingIndicator() {
    const typingMessage = document.querySelector('.typing-message');
    if (typingMessage) {
        typingMessage.remove();
    }
}

// Sog'liq so'rovini qayta ishlash
function processHealthQuery(query) {
    const lowerQuery = query.toLowerCase();
    let matchedConditions = [];
    let allProducts = [];

    // Find matching health conditions
    for (const [condition, data] of Object.entries(healthDatabase)) {
        const matches = data.keywords.some(keyword => lowerQuery.includes(keyword));
        if (matches) {
            matchedConditions.push({ condition, data });
        }
    }

    // If matches found
    if (matchedConditions.length > 0) {
        const primary = matchedConditions[0];
        const products = primary.data.products.slice(0, 3); // Top 3 products

        let responseText = `Men sizning muammongizni tushundim. `;

        if (matchedConditions.length === 1) {
            responseText += `${getConditionName(primary.condition)} uchun quyidagi tabiiy mahsulotlarni tavsiya qilaman:\n\n`;
        } else {
            responseText += `Siz haqida bir nechta muammolarni aytdingiz. Asosiy muammo uchun tavsiyalar:\n\n`;
        }

        responseText += primary.data.advice;

        return {
            text: responseText,
            products: products
        };
    }

    // No specific match - general advice
    return {
        text: `Kechirasiz, men sizning muammongizni aniq tushunmadim. Iltimos, aniqroq yozing:\n\n` +
            `Masalan:\n` +
            `• "Immunitetni qanday ko'tarish mumkin?"\n` +
            `• "Qon bosimi yuqori"\n` +
            `• "Hazm muammosi bor"\n` +
            `• "Uyqum yomon"\n\n` +
            `Yoki yuqoridagi tez savollardan birini tanlang.`,
        products: []
    };
}

// Get condition name in Uzbek
function getConditionName(condition) {
    const names = {
        immunitet: 'Immunitet',
        bosim: 'Qon bosimi',
        hazm: 'Hazm tizimi',
        uyqu: 'Uyqu',
        energiya: 'Energiya va charchoq',
        teri: 'Teri',
        yurak: 'Yurak',
        jigar: 'Jigar',
        bosh: 'Bosh og\'rig\'i',
        bogim: 'Bo\'g\'im og\'riqlari',
        shakar: 'Qon shakari',
        koz: 'Ko\'z'
    };
    return names[condition] || condition;
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    console.log('Shifo AI yuklandi va tayyor!');
});
