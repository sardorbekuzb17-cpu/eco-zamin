/**
 * EventDelegator - Event delegation uchun utility
 * Memory leak va performance muammolarini oldini oladi
 */
class EventDelegator {
    constructor() {
        this.handlers = new Map();
    }

    /**
     * Event listener qo'shish (delegation bilan)
     */
    on(container, eventType, selector, handler) {
        const key = `${eventType}-${selector}`;

        // Wrapper funksiya
        const wrapper = (event) => {
            const target = event.target.closest(selector);
            if (target && container.contains(target)) {
                handler.call(target, event);
            }
        };

        // Listener qo'shish
        container.addEventListener(eventType, wrapper);

        // Keshga saqlash (keyinchalik o'chirish uchun)
        if (!this.handlers.has(container)) {
            this.handlers.set(container, new Map());
        }
        this.handlers.get(container).set(key, { wrapper, eventType });

        return () => this.off(container, eventType, selector);
    }

    /**
     * Event listener o'chirish
     */
    off(container, eventType, selector) {
        const key = `${eventType}-${selector}`;
        const containerHandlers = this.handlers.get(container);

        if (containerHandlers && containerHandlers.has(key)) {
            const { wrapper, eventType: type } = containerHandlers.get(key);
            container.removeEventListener(type, wrapper);
            containerHandlers.delete(key);

            if (containerHandlers.size === 0) {
                this.handlers.delete(container);
            }
        }
    }

    /**
     * Barcha listenerlarni o'chirish
     */
    offAll(container) {
        const containerHandlers = this.handlers.get(container);

        if (containerHandlers) {
            containerHandlers.forEach(({ wrapper, eventType }, key) => {
                container.removeEventListener(eventType, wrapper);
            });
            this.handlers.delete(container);
        }
    }

    /**
     * Barcha containerlar uchun barcha listenerlarni o'chirish
     */
    clear() {
        this.handlers.forEach((containerHandlers, container) => {
            this.offAll(container);
        });
    }
}

// Helper funksiya
function delegate(container, eventType, selector, handler) {
    return eventDelegator.on(container, eventType, selector, handler);
}

// Export
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { EventDelegator, delegate };
}

// Global instance
if (typeof window !== 'undefined') {
    window.EventDelegator = EventDelegator;
    window.eventDelegator = new EventDelegator();
    window.delegate = delegate;
}
