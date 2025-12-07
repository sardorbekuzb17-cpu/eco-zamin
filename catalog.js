// Products Database - To'liq ma'lumotlar bilan
const productsDatabase = {
    fruits: [
        {
            id: 1,
            name: "Uzum",
            description: "Samarqand, Buxoro",
            price: 20000,
            image: "🍇",
            badge: "TOP",
            benefit: "Qon aylanishini yaxshilaydi, energiya beradi, yurak mushagini mustahkamlaydi. Antioksidantlarga boy."
        },
        {
            id: 2,
            name: "Olma",
            description: "Farg'ona vodiysi",
            price: 15000,
            image: "🍎",
            badge: "Yangi",
            benefit: "Immunitetni ko'taradi, hazmni yaxshilaydi, temir moddasi bilan organizmni boyitadi."
        },
        {
            id: 3,
            name: "Gilos",
            description: "Namangan, Farg'ona",
            price: 35000,
            image: "🍒",
            badge: "",
            benefit: "Tanani toksinlardan tozalaydi, uyquni yaxshilaydi, bo'g'im og'riqlarini kamaytiradi."
        },
        {
            id: 4,
            name: "O'rik",
            description: "Samarqand, Qashqadaryo",
            price: 25000,
            image: "🥭",
            badge: "",
            benefit: "Jigar faoliyatini yaxshilaydi, terini oziqlantiradi, ko'z nurini mustahkamlaydi."
        },
        {
            id: 5,
            name: "Shaftoli",
            description: "Farg'ona, Andijon",
            price: 24000,
            image: "🍑",
            badge: "Mavsumiy",
            benefit: "Hazmni yaxshilaydi, teri elastikligini oshiradi, vitamin C manbai."
        },
        {
            id: 6,
            name: "Sitrus mevalar",
            description: "Toshkent",
            price: 22000,
            image: "🍊",
            badge: "",
            benefit: "Immunitetni mustahkamlaydi, shamollashdan himoya qiladi, yallig'lanishni kamaytiradi."
        }
    ],
    vegetables: [
        {
            id: 7,
            name: "Sabzi",
            description: "Andijon, Qo'qon",
            price: 6000,
            image: "🥕",
            badge: "",
            benefit: "Ko'rishni kuchaytiradi, qon bosimini me'yorlaydi, terini tozalaydi."
        },
        {
            id: 8,
            name: "Pomidor",
            description: "Toshkent, Sirdaryo",
            price: 8000,
            image: "🍅",
            badge: "Yangi",
            benefit: "Yallig'lanishga qarshi ta'sir, yurakni himoya qiladi, likopin manbai."
        },
        {
            id: 9,
            name: "Bodring",
            description: "Xorazm, Farg'ona",
            price: 7000,
            image: "🥒",
            badge: "",
            benefit: "Tanani sovitadi, organizmni tozalaydi, teriga namlik beradi."
        },
        {
            id: 10,
            name: "Piyoz",
            description: "Qashqadaryo",
            price: 4000,
            image: "🧅",
            badge: "",
            benefit: "Immunitetni kuchaytiradi, viruslardan himoya qiladi."
        },
        {
            id: 11,
            name: "Sarimsoq",
            description: "Surxondaryo",
            price: 15000,
            image: "🧄",
            badge: "TOP",
            benefit: "Qon tomirlarni tozalaydi, bosimni tushiradi, antibakterial ta'sir."
        }
    ],
    honey: [
        {
            id: 12,
            name: "Asal",
            description: "Namangan tog'lari, Bostanliq",
            price: 80000,
            image: "🍯",
            badge: "TOP",
            benefit: "Immunitetni ko'taradi, tomoq og'riqlarini yengillashtiradi, energiya manbai."
        },
        {
            id: 13,
            name: "Gulli asal",
            description: "Farg'ona vodiysi",
            price: 70000,
            image: "🍯",
            badge: "",
            benefit: "Allergiyaga qarshi ta'sir, hazmni yaxshilaydi."
        },
        {
            id: 14,
            name: "Tog' asali",
            description: "Chotqol, Hisor tog'lari",
            price: 90000,
            image: "🍯",
            badge: "TOP",
            benefit: "Kuchli antibakterial vosita, o'pka faoliyatini yaxshilaydi."
        }
    ],
    nuts: [
        {
            id: 15,
            name: "Bodom",
            description: "Nurota, Samarqand",
            price: 70000,
            image: "🌰",
            badge: "TOP",
            benefit: "Miyada qon aylanishini yaxshilaydi, immunitetni kuchaytiradi, teriga foydali yog'lar manbai."
        },
        {
            id: 16,
            name: "Pista",
            description: "Surxondaryo, Qoraqalpog'iston",
            price: 120000,
            image: "🥜",
            badge: "",
            benefit: "Yurakni mustahkamlaydi, organizmga energiya beradi."
        },
        {
            id: 17,
            name: "Yong'oq",
            description: "Andijon, Namangan",
            price: 90000,
            image: "🌰",
            badge: "",
            benefit: "Miya faoliyatini kuchaytiradi, stressni kamaytiradi."
        },
        {
            id: 18,
            name: "Mayiz",
            description: "Samarqand, Buxoro",
            price: 85000,
            image: "🌰",
            badge: "TOP",
            benefit: "Qon tarkibini yaxshilaydi, oshqozonni mustahkamlaydi."
        }
    ],
    dairy: [
        {
            id: 19,
            name: "Qatiq",
            description: "Jizzax",
            price: 8000,
            image: "🥛",
            badge: "Yangi",
            benefit: "Hazmni yaxshilaydi, ichak florasini mustahkamlaydi."
        },
        {
            id: 20,
            name: "Suzma",
            description: "Qashqadaryo",
            price: 10000,
            image: "🥛",
            badge: "",
            benefit: "Kaltsiyga boy, suyaklarni mustahkamlaydi."
        },
        {
            id: 21,
            name: "Sariyog'",
            description: "Andijon",
            price: 50000,
            image: "🧈",
            badge: "TOP",
            benefit: "Organizmga toza energiya beradi, jigar faoliyatini qo'llab-quvvatlaydi."
        },
        {
            id: 22,
            name: "Qaymoq",
            description: "Namangan",
            price: 35000,
            image: "🥛",
            badge: "",
            benefit: "Vitamin A va E manbai, terini oziqlantiradi."
        }
    ],
    spices: [
        {
            id: 23,
            name: "Zira",
            description: "Buxoro",
            price: 8000,
            image: "🧂",
            badge: "",
            benefit: "Hazmni yengillashtiradi, shish qotishini kamaytiradi."
        },
        {
            id: 24,
            name: "Kurkuma (Zarchava)",
            description: "Toshkent",
            price: 15000,
            image: "🟡",
            badge: "TOP",
            benefit: "Kuchli yallig'lanishga qarshi vosita, qon tozalovchi."
        },
        {
            id: 25,
            name: "Qora murch",
            description: "Import - Vietnam",
            price: 12000,
            image: "🌶️",
            badge: "",
            benefit: "Metabolizmni tezlashtiradi, ovqat hazm qilishni yaxshilaydi."
        },
        {
            id: 26,
            name: "Dolchin",
            description: "Import - Shri Lanka",
            price: 18000,
            image: "🌿",
            badge: "",
            benefit: "Qon shakarini me'yorlashtiradi."
        }
    ],
    oils: [
        {
            id: 27,
            name: "Zig'ir yog'i",
            description: "Jizzax",
            price: 45000,
            image: "🫒",
            badge: "TOP",
            benefit: "Omega-3 manbai, yurak va miya faoliyatini qo'llab-quvvatlaydi."
        },
        {
            id: 28,
            name: "Qonim (kunjut) yog'i",
            description: "Surxondaryo",
            price: 55000,
            image: "🫒",
            badge: "",
            benefit: "Teri va sochni oziqlantiradi, antioksidantlarga boy."
        },
        {
            id: 29,
            name: "Kungaboqar yog'i",
            description: "Samarqand - sovuq siqilgan",
            price: 35000,
            image: "🌻",
            badge: "Yangi",
            benefit: "Qon tomirlarni mustahkamlaydi, yengil hazm bo'ladi."
        }
    ],
    herbs: [
        {
            id: 30,
            name: "Yalpiz",
            description: "Farg'ona",
            price: 7000,
            image: "🌿",
            badge: "",
            benefit: "Asabni tinchlantiradi, oshqozonni yengillashtiradi."
        },
        {
            id: 31,
            name: "Isiriq",
            description: "Qoraqalpog'iston",
            price: 8000,
            image: "🍃",
            badge: "",
            benefit: "Uyni tozalaydi, yengil antiseptik ta'sir."
        },
        {
            id: 32,
            name: "Choyshab",
            description: "Namangan tog'lari",
            price: 15000,
            image: "🍵",
            badge: "TOP",
            benefit: "Uyquni yaxshilaydi, tinchlantiruvchi."
        },
        {
            id: 33,
            name: "Gulchoy",
            description: "Toshkent",
            price: 12000,
            image: "🌸",
            badge: "",
            benefit: "Yurak faoliyatini qo'llaydi, qon bosimini yumshoq tushiradi."
        },
        {
            id: 34,
            name: "Zira o'ti",
            description: "Qashqadaryo",
            price: 10000,
            image: "🌱",
            badge: "",
            benefit: "Qorin og'riqlarini kamaytiradi, hazm tizimini muvozanatlaydi."
        }
    ]
};

// Current state
let currentCategory = 'all';
let currentSort = 'default';
let searchQuery = '';

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    renderProducts();
    setupEventListeners();
});

// Setup event listeners
function setupEventListeners() {
    // Category filter
    document.querySelectorAll('.category-item').forEach(item => {
        item.addEventListener('click', () => {
            document.querySelectorAll('.category-item').forEach(i => i.classList.remove('active'));
            item.classList.add('active');
            currentCategory = item.dataset.category;
            updateCategoryTitle();
            renderProducts();
        });
    });

    // Sort
    document.getElementById('sortSelect').addEventListener('change', (e) => {
        currentSort = e.target.value;
        renderProducts();
    });

    // Search
    document.getElementById('searchInput').addEventListener('input', (e) => {
        searchQuery = e.target.value.toLowerCase();
        renderProducts();
    });
}

// Update category title
function updateCategoryTitle() {
    const titles = {
        all: 'Barcha mahsulotlar',
        fruits: 'Mevalar',
        vegetables: 'Sabzavotlar',
        honey: 'Asal',
        nuts: 'Yong\'oqlar',
        dairy: 'Sut mahsulotlari',
        spices: 'Ziravorlar',
        oils: 'Shifobaxsh yog\'lar',
        herbs: 'Giyohlar'
    };
    document.getElementById('categoryTitle').textContent = titles[currentCategory];
}

// Get filtered products
function getFilteredProducts() {
    let products = [];

    // Get products by category
    if (currentCategory === 'all') {
        Object.values(productsDatabase).forEach(category => {
            products = products.concat(category);
        });
    } else {
        products = productsDatabase[currentCategory] || [];
    }

    // Filter by search
    if (searchQuery) {
        products = products.filter(p =>
            p.name.toLowerCase().includes(searchQuery) ||
            p.description.toLowerCase().includes(searchQuery)
        );
    }

    // Sort products
    switch (currentSort) {
        case 'price-asc':
            products.sort((a, b) => a.price - b.price);
            break;
        case 'price-desc':
            products.sort((a, b) => b.price - a.price);
            break;
        case 'name-asc':
            products.sort((a, b) => a.name.localeCompare(b.name));
            break;
        case 'name-desc':
            products.sort((a, b) => b.name.localeCompare(a.name));
            break;
    }

    return products;
}

// Render products
function renderProducts() {
    const grid = document.getElementById('productsGrid');
    const products = getFilteredProducts();

    if (products.length === 0) {
        grid.innerHTML = `
            <div class="empty-state">
                <i class="fas fa-box-open"></i>
                <h3>Mahsulot topilmadi</h3>
                <p>Boshqa kategoriyani tanlang yoki qidiruvni o'zgartiring</p>
            </div>
        `;
        return;
    }

    grid.innerHTML = products.map(product => `
        <div class="product-card" data-id="${product.id}">
            <div class="product-image">${product.image}</div>
            ${product.badge ? `<span class="product-badge">${product.badge}</span>` : ''}
            <h3 class="product-name">${product.name}</h3>
            <p class="product-description">${product.description}</p>
            ${product.benefit ? `<p class="product-benefit"><i class="fas fa-heart-pulse"></i> ${product.benefit}</p>` : ''}
            <div class="product-footer">
                <span class="product-price">${formatPrice(product.price)}</span>
                <button class="add-to-cart" onclick="addToCart(${product.id})">
                    <i class="fas fa-shopping-cart"></i>
                </button>
            </div>
        </div>
    `).join('');

    // Add animation
    document.querySelectorAll('.product-card').forEach((card, index) => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        setTimeout(() => {
            card.style.transition = 'all 0.4s ease';
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
        }, index * 50);
    });
}

// Format price
function formatPrice(price) {
    return new Intl.NumberFormat('uz-UZ').format(price) + ' so\'m';
}

// Add to cart
function addToCart(productId) {
    // Find product
    let product = null;
    Object.values(productsDatabase).forEach(category => {
        const found = category.find(p => p.id === productId);
        if (found) product = found;
    });

    if (product) {
        alert(`"${product.name}" savatga qo'shildi!\n\nNarxi: ${formatPrice(product.price)}`);

        // Add animation
        const button = event.target.closest('.add-to-cart');
        button.innerHTML = '<i class="fas fa-check"></i>';
        button.style.background = 'linear-gradient(135deg, #10b981, #059669)';

        setTimeout(() => {
            button.innerHTML = '<i class="fas fa-shopping-cart"></i>';
            button.style.background = 'linear-gradient(135deg, #7000FF, #A855F7)';
        }, 2000);
    }
}
