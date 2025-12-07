/**
 * Debouncer - Funksiyalarni debounce qilish uchun utility
 */
class Debouncer {
    constructor() {
        this.timers = new Map();
    }

    /**
     * Funksiyani debounce qilish
     */
    debounce(key, func, delay = 300) {
        // Oldingi timerni tozalash
        if (this.timers.has(key)) {
            clearTimeout(this.timers.get(key));
        }

        // Yangi timer o'rnatish
        const timer = setTimeout(() => {
            func();
            this.timers.delete(key);
        }, delay);

        this.timers.set(key, timer);
    }

    /**
     * Funksiyani throttle qilish
     */
    throttle(key, func, delay = 300) {
        if (this.timers.has(key)) {
            return; // Hali kutish vaqti tugamagan
        }

        func();

        const timer = setTimeout(() => {
            this.timers.delete(key);
        }, delay);

        this.timers.set(key, timer);
    }

    /**
     * Barcha timerlarni tozalash
     */
    clear() {
        this.timers.forEach(timer => clearTimeout(timer));
        this.timers.clear();
    }

    /**
     * Ma'lum bir timerni tozalash
     */
    clearTimer(key) {
        if (this.timers.has(key)) {
            clearTimeout(this.timers.get(key));
            this.timers.delete(key);
        }
    }
}

// Helper funksiyalar
function debounce(func, delay = 300) {
    let timer;
    return function (...args) {
        clearTimeout(timer);
        timer = setTimeout(() => func.apply(this, args), delay);
    };
}

function throttle(func, delay = 300) {
    let lastCall = 0;
    return function (...args) {
        const now = Date.now();
        if (now - lastCall >= delay) {
            lastCall = now;
            func.apply(this, args);
        }
    };
}

// Export
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { Debouncer, debounce, throttle };
}

// Global instance
if (typeof window !== 'undefined') {
    window.Debouncer = Debouncer;
    window.debouncer = new Debouncer();
    window.debounce = debounce;
    window.throttle = throttle;
}
