/**
 * LazyLoader - Rasmlar va modullarni lazy loading qilish uchun
 */
class LazyLoader {
    constructor() {
        this.imageObserver = null;
        this.moduleCache = new Map();
        this.initImageObserver();
    }

    /**
     * Intersection Observer ni ishga tushirish
     */
    initImageObserver() {
        if ('IntersectionObserver' in window) {
            this.imageObserver = new IntersectionObserver(
                (entries) => {
                    entries.forEach(entry => {
                        if (entry.isIntersecting) {
                            this.loadImage(entry.target);
                            this.imageObserver.unobserve(entry.target);
                        }
                    });
                },
                {
                    rootMargin: '50px' // 50px oldindan yuklash
                }
            );
        }
    }

    /**
     * Rasmni lazy load qilish
     */
    loadImage(img) {
        const src = img.dataset.src;
        if (!src) return;

        img.src = src;
        img.removeAttribute('data-src');
        img.classList.add('loaded');
    }

    /**
     * Barcha lazy rasmlarni kuzatish
     */
    observeImages() {
        if (!this.imageObserver) {
            // Fallback: barcha rasmlarni darhol yuklash
            document.querySelectorAll('img[data-src]').forEach(img => {
                this.loadImage(img);
            });
            return;
        }

        document.querySelectorAll('img[data-src]').forEach(img => {
            this.imageObserver.observe(img);
        });
    }

    /**
     * Modulni dinamik yuklash (kesh bilan)
     */
    async loadModule(modulePath) {
        // Keshdan tekshirish
        if (this.moduleCache.has(modulePath)) {
            return this.moduleCache.get(modulePath);
        }

        try {
            const module = await import(modulePath);
            this.moduleCache.set(modulePath, module);
            return module;
        } catch (error) {
            console.error(`Modulni yuklashda xatolik: ${modulePath}`, error);
            throw error;
        }
    }

    /**
     * Keshni tozalash
     */
    clearCache() {
        this.moduleCache.clear();
    }
}

// Export
if (typeof module !== 'undefined' && module.exports) {
    module.exports = LazyLoader;
}

// Global instance
if (typeof window !== 'undefined') {
    window.LazyLoader = LazyLoader;
    window.lazyLoader = new LazyLoader();
}
