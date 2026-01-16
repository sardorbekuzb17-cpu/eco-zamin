// GreenMarket - 100% Tarjima Tizimi
let T = {}; // Tarjimalar
let currentLang = localStorage.getItem('lang') || 'uz';

// Tilni yuklash
async function loadLanguage(lang) {
    try {
        const res = await fetch(`lang/${lang}.json`);
        if (!res.ok) throw new Error('Til fayli topilmadi');
        T = await res.json();
        currentLang = lang;
        localStorage.setItem('lang', lang);
        document.documentElement.lang = lang;
        console.log(`✅ Til yuklandi: ${lang}`, T);
        applyAllTranslations();
        updateRadios();
    } catch (e) {
        console.error('Xatolik:', e);
        if (lang !== 'uz') loadLanguage('uz');
    }
}

// Ichki kalitni olish: "nav.home" -> T.nav.home
function get(key) {
    const result = key.split('.').reduce((o, k) => o?.[k], T);
    if (!result) {
        console.warn(`⚠️ Tarjima topilmadi: "${key}"`);
        return null;
    }
    return result;
}

// Barcha tarjimalarni qo'llash
function applyAllTranslations() {
    if (!T || Object.keys(T).length === 0) {
        console.warn('⚠️ Tarjimalar yuklanmagan');
        return;
    }
    
    // data-i18n elementlari
    const elements = document.querySelectorAll('[data-i18n]');
    console.log(`📝 ${elements.length} ta element topildi`);
    
    elements.forEach(el => {
        const key = el.dataset.i18n;
        const val = get(key);
        if (val && val !== key) {
            // Emoji va boshqa HTML elementlarini saqlash uchun innerHTML ishlatamiz
            el.innerHTML = val;
            console.log(`✅ "${key}" -> "${val}"`);
        } else if (!val) {
            console.warn(`⚠️ Tarjima topilmadi: "${key}"`);
        }
    });

    // Placeholder
    document.querySelectorAll('[data-i18n-ph]').forEach(el => {
        const val = get(el.dataset.i18nPh);
        if (val) el.placeholder = val;
    });

    // Title
    if (T.title) document.title = T.title;
}

// Radio tugmalarni yangilash
function updateRadios() {
    document.querySelectorAll('input[name="language"]').forEach(r => {
        r.checked = r.value === currentLang;
    });
}

// Tilni o'zgartirish
function changeLanguage(lang) {
    loadLanguage(lang);
}


// Sahifa yuklanganda
document.addEventListener('DOMContentLoaded', () => {
    loadLanguage(currentLang);
});
