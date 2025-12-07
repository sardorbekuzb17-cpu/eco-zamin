/**
 * GreenMarket Internationalization (i18n) Library
 * Supports: O'zbek (uz), English (en), Русский (ru)
 */

class I18n {
    constructor() {
        this.translations = {};
        this.currentLanguage = localStorage.getItem('language') || 'uz';
        this.supportedLanguages = ['uz', 'en', 'ru'];
        this.listeners = [];
    }

    /**
     * Tarjimalarni yuklash
     */
    async loadTranslations() {
        try {
            const [uz, en, ru] = await Promise.all([
                fetch('./src/i18n/uz.json').then(r => r.json()),
                fetch('./src/i18n/en.json').then(r => r.json()),
                fetch('./src/i18n/ru.json').then(r => r.json())
            ]);
            this.translations = { uz, en, ru };
            return true;
        } catch (error) {
            console.error('Tarjimalarni yuklashda xatolik:', error);
            return false;
        }
    }

    /**
     * Tarjimalarni to'g'ridan-to'g'ri o'rnatish (fetch ishlamasa)
     */
    setTranslations(translations) {
        this.translations = translations;
    }

    /**
     * Joriy tilni olish
     */
    getLanguage() {
        return this.currentLanguage;
    }

    /**
     * Tilni o'zgartirish
     */
    setLanguage(lang) {
        if (!this.supportedLanguages.includes(lang)) {
            console.warn(`Til qo'llab-quvvatlanmaydi: ${lang}`);
            return false;
        }
        this.currentLanguage = lang;
        localStorage.setItem('language', lang);
        this.notifyListeners();
        return true;
    }

    /**
     * Tarjimani olish (nested keys: "header.home")
     */
    t(key, defaultValue = '') {
        const keys = key.split('.');
        let value = this.translations[this.currentLanguage];

        for (const k of keys) {
            if (value && typeof value === 'object' && k in value) {
                value = value[k];
            } else {
                return defaultValue || key;
            }
        }
        return value || defaultValue || key;
    }

    /**
     * Til nomi va bayrog'ini olish
     */
    getLanguageInfo(lang = null) {
        const targetLang = lang || this.currentLanguage;
        const data = this.translations[targetLang];
        return {
            code: targetLang,
            name: data?.langName || targetLang,
            flag: data?.langFlag || ''
        };
    }

    /**
     * Barcha qo'llab-quvvatlanadigan tillar
     */
    getAllLanguages() {
        return this.supportedLanguages.map(lang => this.getLanguageInfo(lang));
    }

    /**
     * Til o'zgarganda chaqiriladigan callback qo'shish
     */
    onLanguageChange(callback) {
        this.listeners.push(callback);
        return () => {
            this.listeners = this.listeners.filter(l => l !== callback);
        };
    }

    /**
     * Listenerlarni xabardor qilish
     */
    notifyListeners() {
        this.listeners.forEach(callback => callback(this.currentLanguage));
    }

    /**
     * DOM elementlarini tarjima qilish (data-i18n attribute)
     */
    translatePage() {
        document.querySelectorAll('[data-i18n]').forEach(el => {
            const key = el.getAttribute('data-i18n');
            const translation = this.t(key);
            if (translation) {
                el.textContent = translation;
            }
        });

        // Placeholder uchun
        document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
            const key = el.getAttribute('data-i18n-placeholder');
            const translation = this.t(key);
            if (translation) {
                el.placeholder = translation;
            }
        });

        // Title uchun
        const titleKey = this.t('title');
        if (titleKey) {
            document.title = titleKey;
        }
    }
}

// Global instance
const i18n = new I18n();

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { I18n, i18n };
}
