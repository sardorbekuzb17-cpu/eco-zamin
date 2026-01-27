/**
 * VirtualScroller - Katta ro'yxatlar uchun virtual scrolling
 */
class VirtualScroller {
    constructor(container, options = {}) {
        this.container = container;
        this.items = [];
        this.itemHeight = options.itemHeight || 100;
        this.bufferSize = options.bufferSize || 5;
        this.renderItem = options.renderItem || ((item) => item.toString());

        this.scrollTop = 0;
        this.visibleStart = 0;
        this.visibleEnd = 0;

        this.init();
    }

    /**
     * Initsializatsiya
     */
    init() {
        this.container.style.position = 'relative';
        this.container.style.overflow = 'auto';

        // Scroll event
        this.container.addEventListener('scroll', () => {
            this.scrollTop = this.container.scrollTop;
            this.render();
        });
    }

    /**
     * Ma'lumotlarni o'rnatish
     */
    setItems(items) {
        this.items = items;
        this.render();
    }

    /**
     * Ko'rinadigan elementlarni hisoblash
     */
    calculateVisible() {
        const containerHeight = this.container.clientHeight;
        const totalHeight = this.items.length * this.itemHeight;

        this.visibleStart = Math.max(0, Math.floor(this.scrollTop / this.itemHeight) - this.bufferSize);
        this.visibleEnd = Math.min(
            this.items.length,
            Math.ceil((this.scrollTop + containerHeight) / this.itemHeight) + this.bufferSize
        );

        return { totalHeight, visibleStart: this.visibleStart, visibleEnd: this.visibleEnd };
    }

    /**
     * Render qilish
     */
    render() {
        const { totalHeight, visibleStart, visibleEnd } = this.calculateVisible();

        // Container balandligini o'rnatish
        this.container.style.height = `${totalHeight}px`;

        // Faqat ko'rinadigan elementlarni render qilish
        const fragment = document.createDocumentFragment();

        for (let i = visibleStart; i < visibleEnd; i++) {
            const item = this.items[i];
            const element = this.renderItem(item, i);

            // Pozitsiyani o'rnatish
            if (element instanceof HTMLElement) {
                element.style.position = 'absolute';
                element.style.top = `${i * this.itemHeight}px`;
                element.style.width = '100%';
                element.style.height = `${this.itemHeight}px`;
            }

            fragment.appendChild(element);
        }

        // Eski elementlarni tozalash va yangisini qo'shish
        this.container.innerHTML = '';
        this.container.appendChild(fragment);
    }

    /**
     * Yangilash
     */
    update() {
        this.render();
    }

    /**
     * Tozalash
     */
    destroy() {
        this.container.innerHTML = '';
        this.items = [];
    }
}

// Export
if (typeof module !== 'undefined' && module.exports) {
    module.exports = VirtualScroller;
}

if (typeof window !== 'undefined') {
    window.VirtualScroller = VirtualScroller;
}
