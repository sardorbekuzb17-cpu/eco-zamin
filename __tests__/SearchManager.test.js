/**
 * SearchManager Property-Based Tests
 * Tests search and filter functionality using fast-check
 */
const fc = require('fast-check');
const SearchManager = require('../src/services/SearchManager');

// Generator for products
const productGenerator = fc.record({
    id: fc.string({ minLength: 1 }),
    name: fc.string({ minLength: 1 }),
    price: fc.integer({ min: 1, max: 1000000 }),
    description: fc.string(),
    icon: fc.string(),
    type: fc.constantFrom('daraxt', 'buta', 'meva'),
    inStock: fc.boolean(),
    co2Absorption: fc.integer({ min: 0, max: 1000 })
});

describe('SearchManager Property Tests', () => {
    /**
     * **Feature: green-shop, Property 13: Search returns matching products**
     * **Validates: Requirements 6.1**
     * 
     * For any search query, all returned products should have names that contain 
     * the search query (case-insensitive).
     */
    test('Property 13: Search returns matching products', () => {
        fc.assert(
            fc.property(
                fc.array(productGenerator, { minLength: 0, maxLength: 50 }),
                fc.string({ minLength: 1, maxLength: 20 }),
                (products, query) => {
                    const searchManager = new SearchManager(products);
                    const results = searchManager.search(query);

                    // Barcha natijalar qidiruv so'zini o'z ichiga olishi kerak
                    const lowerQuery = query.toLowerCase().trim();

                    return results.every(product =>
                        product.name.toLowerCase().includes(lowerQuery)
                    );
                }
            ),
            { numRuns: 100 }
        );
    });

    /**
     * **Feature: green-shop, Property 14: Price filter returns products in range**
     * **Validates: Requirements 6.3**
     * 
     * For any price range filter (minPrice, maxPrice), all returned products 
     * should have prices within that range (inclusive).
     */
    test('Property 14: Price filter returns products in range', () => {
        fc.assert(
            fc.property(
                fc.array(productGenerator, { minLength: 0, maxLength: 50 }),
                fc.integer({ min: 0, max: 500000 }),
                fc.integer({ min: 0, max: 500000 }),
                (products, price1, price2) => {
                    // minPrice va maxPrice ni to'g'ri tartibda qo'yamiz
                    const minPrice = Math.min(price1, price2);
                    const maxPrice = Math.max(price1, price2);

                    const searchManager = new SearchManager(products);
                    const results = searchManager.filterByPrice(minPrice, maxPrice);

                    // Barcha natijalar belgilangan narx oralig'ida bo'lishi kerak
                    return results.every(product =>
                        product.price >= minPrice && product.price <= maxPrice
                    );
                }
            ),
            { numRuns: 100 }
        );
    });

    /**
     * **Feature: green-shop, Property 15: Type filter returns matching products**
     * **Validates: Requirements 6.4**
     * 
     * For any product type filter, all returned products should have a type 
     * that matches the selected filter.
     */
    test('Property 15: Type filter returns matching products', () => {
        fc.assert(
            fc.property(
                fc.array(productGenerator, { minLength: 0, maxLength: 50 }),
                fc.constantFrom('daraxt', 'buta', 'meva'),
                (products, selectedType) => {
                    const searchManager = new SearchManager(products);
                    const results = searchManager.filterByType(selectedType);

                    // Barcha natijalar tanlangan turga mos kelishi kerak
                    return results.every(product =>
                        product.type === selectedType
                    );
                }
            ),
            { numRuns: 100 }
        );
    });

    /**
     * **Feature: green-shop, Property 16: Clearing filters returns all products**
     * **Validates: Requirements 6.5**
     * 
     * For any filtered product list, clearing all filters should return 
     * the complete original product list.
     */
    test('Property 16: Clearing filters returns all products', () => {
        // To'g'ri filtr generatori - minPrice <= maxPrice bo'lishi kerak
        const validFilterGenerator = fc.record({
            searchQuery: fc.string({ maxLength: 20 }),
            minPrice: fc.option(fc.integer({ min: 0, max: 500000 }), { nil: null }),
            maxPrice: fc.option(fc.integer({ min: 0, max: 500000 }), { nil: null }),
            type: fc.option(fc.constantFrom('daraxt', 'buta', 'meva'), { nil: null })
        }).map(filters => {
            // Agar minPrice va maxPrice ikkalasi ham mavjud bo'lsa va minPrice > maxPrice bo'lsa,
            // ularni almashtiramiz
            if (filters.minPrice !== null && filters.maxPrice !== null && filters.minPrice > filters.maxPrice) {
                return {
                    ...filters,
                    minPrice: filters.maxPrice,
                    maxPrice: filters.minPrice
                };
            }
            return filters;
        });

        fc.assert(
            fc.property(
                fc.array(productGenerator, { minLength: 1, maxLength: 50 }),
                validFilterGenerator,
                (products, filters) => {
                    const searchManager = new SearchManager(products);

                    // Filtrlarni qo'llaymiz
                    searchManager.applyFilters(filters);

                    // Filtrlarni tozalaymiz
                    const clearedResults = searchManager.clearFilters();

                    // Natija asl mahsulotlar ro'yxatiga teng bo'lishi kerak
                    // Uzunlik bir xil bo'lishi kerak
                    if (clearedResults.length !== products.length) {
                        return false;
                    }

                    // Barcha asl mahsulotlar natijada bo'lishi kerak
                    return products.every(product =>
                        clearedResults.some(result =>
                            result.id === product.id &&
                            result.name === product.name &&
                            result.price === product.price &&
                            result.type === product.type
                        )
                    );
                }
            ),
            { numRuns: 100 }
        );
    });
});

describe('SearchManager Unit Tests - Edge Cases', () => {
    const sampleProducts = [
        {
            id: '1',
            name: 'Olma daraxti',
            price: 50000,
            description: 'Mevali daraxt',
            icon: '🍎',
            type: 'daraxt',
            inStock: true,
            co2Absorption: 20
        },
        {
            id: '2',
            name: 'Nok daraxti',
            price: 45000,
            description: 'Mevali daraxt',
            icon: '🍐',
            type: 'daraxt',
            inStock: true,
            co2Absorption: 18
        },
        {
            id: '3',
            name: 'Atirgul butasi',
            price: 15000,
            description: 'Gullovchi buta',
            icon: '🌹',
            type: 'buta',
            inStock: true,
            co2Absorption: 5
        }
    ];

    /**
     * Test empty search query
     * Requirements: 6.2
     */
    test('Empty search query returns all products', () => {
        const searchManager = new SearchManager(sampleProducts);

        // Bo'sh string bilan qidiruv
        const results1 = searchManager.search('');
        expect(results1).toHaveLength(sampleProducts.length);
        expect(results1).toEqual(sampleProducts);

        // Faqat bo'sh joylar bilan qidiruv
        const results2 = searchManager.search('   ');
        expect(results2).toHaveLength(sampleProducts.length);
        expect(results2).toEqual(sampleProducts);
    });

    /**
     * Test no results found scenario
     * Requirements: 6.2
     */
    test('Search with no matching results returns empty array', () => {
        const searchManager = new SearchManager(sampleProducts);

        // Hech qanday mahsulotga mos kelmaydigan qidiruv
        const results = searchManager.search('Banan');
        expect(results).toHaveLength(0);
        expect(results).toEqual([]);
    });

    test('Filter with no matching results returns empty array', () => {
        const searchManager = new SearchManager(sampleProducts);

        // Hech qanday mahsulot narxi bu oraliqda emas
        const results = searchManager.filterByPrice(100000, 200000);
        expect(results).toHaveLength(0);
        expect(results).toEqual([]);
    });

    test('Type filter with no matching products returns empty array', () => {
        const searchManager = new SearchManager(sampleProducts);

        // 'meva' turida mahsulot yo'q
        const results = searchManager.filterByType('meva');
        expect(results).toHaveLength(0);
        expect(results).toEqual([]);
    });

    /**
     * Test invalid price range (minPrice > maxPrice)
     * Requirements: 6.2
     */
    test('Invalid price range throws error', () => {
        const searchManager = new SearchManager(sampleProducts);

        // minPrice > maxPrice bo'lsa xato qaytarishi kerak
        expect(() => {
            searchManager.filterByPrice(100000, 50000);
        }).toThrow('Min price cannot be greater than max price');
    });

    test('Negative price values throw error', () => {
        const searchManager = new SearchManager(sampleProducts);

        expect(() => {
            searchManager.filterByPrice(-1000, 50000);
        }).toThrow('Min price must be a non-negative number or null');

        expect(() => {
            searchManager.filterByPrice(0, -5000);
        }).toThrow('Max price must be a non-negative number or null');
    });

    test('Non-string search query throws error', () => {
        const searchManager = new SearchManager(sampleProducts);

        expect(() => {
            searchManager.search(123);
        }).toThrow('Search query must be a string');

        expect(() => {
            searchManager.search(null);
        }).toThrow('Search query must be a string');
    });

    test('Empty product list returns empty results', () => {
        const searchManager = new SearchManager([]);

        const searchResults = searchManager.search('Olma');
        expect(searchResults).toHaveLength(0);

        const priceResults = searchManager.filterByPrice(0, 100000);
        expect(priceResults).toHaveLength(0);

        const typeResults = searchManager.filterByType('daraxt');
        expect(typeResults).toHaveLength(0);
    });
});
