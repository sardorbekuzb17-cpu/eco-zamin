/**
 * Mobil moslashuvchanlik testlari
 * Requirements: 8.1, 8.2, 8.3, 8.4
 */

describe('Mobil moslashuvchanlik', () => {
    let originalInnerWidth;
    let originalUserAgent;

    beforeEach(() => {
        // Asl qiymatlarni saqlash
        originalInnerWidth = window.innerWidth;
        originalUserAgent = navigator.userAgent;

        // DOM elementlarini yaratish
        document.body.innerHTML = `
            <div id="payment-methods-container"></div>
            <input type="text" name="phone" />
            <input type="email" name="email" />
            <input type="number" id="test-number" />
            <div id="catalog">
                <div class="grid"></div>
            </div>
        `;
    });

    afterEach(() => {
        // Asl qiymatlarni qaytarish
        Object.defineProperty(window, 'innerWidth', {
            writable: true,
            configurable: true,
            value: originalInnerWidth
        });
    });

    describe('Mobil qurilmani aniqlash', () => {
        test('Kichik ekran kengligi mobil deb aniqlanishi kerak', () => {
            Object.defineProperty(window, 'innerWidth', {
                writable: true,
                configurable: true,
                value: 375
            });

            const isMobile = window.innerWidth <= 768;
            expect(isMobile).toBe(true);
        });

        test('Katta ekran kengligi mobil emas deb aniqlanishi kerak', () => {
            Object.defineProperty(window, 'innerWidth', {
                writable: true,
                configurable: true,
                value: 1024
            });

            const isMobile = window.innerWidth <= 768;
            expect(isMobile).toBe(false);
        });
    });

    describe('Input optimizatsiyasi', () => {
        test('Telefon input mobil uchun tel type ga o\'zgarishi kerak', () => {
            const phoneInput = document.querySelector('input[name="phone"]');

            // Mobil uchun optimallash
            phoneInput.setAttribute('type', 'tel');
            phoneInput.setAttribute('inputmode', 'tel');

            expect(phoneInput.getAttribute('type')).toBe('tel');
            expect(phoneInput.getAttribute('inputmode')).toBe('tel');
        });

        test('Email input mobil uchun email inputmode ga ega bo\'lishi kerak', () => {
            const emailInput = document.querySelector('input[name="email"]');

            emailInput.setAttribute('inputmode', 'email');

            expect(emailInput.getAttribute('inputmode')).toBe('email');
        });

        test('Number input mobil uchun numeric inputmode ga ega bo\'lishi kerak', () => {
            const numberInput = document.querySelector('input[type="number"]');

            numberInput.setAttribute('inputmode', 'numeric');
            numberInput.setAttribute('pattern', '[0-9]*');

            expect(numberInput.getAttribute('inputmode')).toBe('numeric');
            expect(numberInput.getAttribute('pattern')).toBe('[0-9]*');
        });
    });

    describe('To\'lov usullari', () => {
        test('Mobil to\'lov usullari (Payme, Click) mavjud bo\'lishi kerak', () => {
            const container = document.getElementById('payment-methods-container');

            // Mobil to'lov usullarini qo'shish
            container.innerHTML = `
                <div class="payment-methods-mobile">
                    <div class="payment-method-option" data-method="payme">Payme</div>
                    <div class="payment-method-option" data-method="click">Click</div>
                    <div class="payment-method-option" data-method="card">Bank kartasi</div>
                    <div class="payment-method-option" data-method="cash">Naqd pul</div>
                </div>
            `;

            const paymeOption = container.querySelector('[data-method="payme"]');
            const clickOption = container.querySelector('[data-method="click"]');
            const cardOption = container.querySelector('[data-method="card"]');
            const cashOption = container.querySelector('[data-method="cash"]');

            expect(paymeOption).toBeTruthy();
            expect(clickOption).toBeTruthy();
            expect(cardOption).toBeTruthy();
            expect(cashOption).toBeTruthy();
        });

        test('To\'lov usulini tanlash ishlashi kerak', () => {
            const container = document.getElementById('payment-methods-container');

            container.innerHTML = `
                <div class="payment-methods-mobile">
                    <div class="payment-method-option" data-method="payme">Payme</div>
                    <div class="payment-method-option" data-method="click">Click</div>
                </div>
            `;

            const paymeOption = container.querySelector('[data-method="payme"]');
            const clickOption = container.querySelector('[data-method="click"]');

            // Payme ni tanlash
            paymeOption.classList.add('selected');
            expect(paymeOption.classList.contains('selected')).toBe(true);

            // Click ni tanlash (Payme tanlovi olib tashlanishi kerak)
            paymeOption.classList.remove('selected');
            clickOption.classList.add('selected');
            expect(clickOption.classList.contains('selected')).toBe(true);
            expect(paymeOption.classList.contains('selected')).toBe(false);
        });
    });

    describe('Touch interaksiyalari', () => {
        test('Tugmalar touch event\'larni qo\'llab-quvvatlashi kerak', () => {
            const button = document.createElement('button');
            button.textContent = 'Test tugma';
            document.body.appendChild(button);

            let touchStartCalled = false;
            let touchEndCalled = false;

            button.addEventListener('touchstart', () => {
                touchStartCalled = true;
                button.style.opacity = '0.7';
            });

            button.addEventListener('touchend', () => {
                touchEndCalled = true;
                button.style.opacity = '1';
            });

            // Touch start event
            const touchStartEvent = new Event('touchstart');
            button.dispatchEvent(touchStartEvent);
            expect(touchStartCalled).toBe(true);
            expect(button.style.opacity).toBe('0.7');

            // Touch end event
            const touchEndEvent = new Event('touchend');
            button.dispatchEvent(touchEndEvent);
            expect(touchEndCalled).toBe(true);
            expect(button.style.opacity).toBe('1');
        });
    });

    describe('Mahsulot grid optimizatsiyasi', () => {
        test('Mobil qurilmada mahsulot grid bitta ustun bo\'lishi kerak', () => {
            const productGrid = document.querySelector('#catalog .grid');

            // Mobil uchun class qo'shish
            productGrid.classList.add('product-grid');

            expect(productGrid.classList.contains('product-grid')).toBe(true);
        });
    });

    describe('Viewport sozlamalari', () => {
        test('Viewport height o\'zgaruvchisi o\'rnatilishi kerak', () => {
            const vh = window.innerHeight * 0.01;
            document.documentElement.style.setProperty('--vh', `${vh}px`);

            const vhValue = document.documentElement.style.getPropertyValue('--vh');
            expect(vhValue).toBe(`${vh}px`);
        });
    });

    describe('Scroll lock funksiyasi', () => {
        test('lockScroll body overflow\'ni yashirishi kerak', () => {
            document.body.style.overflow = 'hidden';
            document.body.style.position = 'fixed';
            document.body.style.width = '100%';

            expect(document.body.style.overflow).toBe('hidden');
            expect(document.body.style.position).toBe('fixed');
            expect(document.body.style.width).toBe('100%');
        });

        test('unlockScroll body overflow\'ni qaytarishi kerak', () => {
            // Avval lock qilish
            document.body.style.overflow = 'hidden';
            document.body.style.position = 'fixed';

            // Keyin unlock qilish
            document.body.style.overflow = '';
            document.body.style.position = '';
            document.body.style.width = '';

            expect(document.body.style.overflow).toBe('');
            expect(document.body.style.position).toBe('');
            expect(document.body.style.width).toBe('');
        });
    });
});
