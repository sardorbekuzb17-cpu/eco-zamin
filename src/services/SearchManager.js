const Filter = require('../models/Filter');

/**
 * SearchManager
 * Manages product search and filtering
 */
class SearchManager {
    constructor(products = []) {
        this.products = products;
        this.filteredProducts = [...products];
    }

    /**
     * Search products by name
     */
    search(query) {
        if (typeof query !== 'string') {
            throw new Error('Search query must be a string');
        }

        const lowerQuery = query.toLowerCase().trim();

        if (lowerQuery === '') {
            return [...this.products];
        }

        return this.products.filter(product =>
            product.name.toLowerCase().includes(lowerQuery)
        );
    }

    /**
     * Filter products by price range
     */
    filterByPrice(minPrice, maxPrice) {
        if (minPrice !== null && (typeof minPrice !== 'number' || minPrice < 0)) {
            throw new Error('Min price must be a non-negative number or null');
        }
        if (maxPrice !== null && (typeof maxPrice !== 'number' || maxPrice < 0)) {
            throw new Error('Max price must be a non-negative number or null');
        }
        if (minPrice !== null && maxPrice !== null && minPrice > maxPrice) {
            throw new Error('Min price cannot be greater than max price');
        }

        return this.products.filter(product => {
            const meetsMin = minPrice === null || product.price >= minPrice;
            const meetsMax = maxPrice === null || product.price <= maxPrice;
            return meetsMin && meetsMax;
        });
    }

    /**
     * Filter products by type
     */
    filterByType(type) {
        if (!type || typeof type !== 'string') {
            throw new Error('Type must be a non-empty string');
        }

        return this.products.filter(product =>
            product.type === type
        );
    }

    /**
     * Apply multiple filters
     */
    applyFilters(filters) {
        if (!filters || typeof filters !== 'object') {
            throw new Error('Filters must be an object');
        }

        Filter.validate(filters);

        let results = [...this.products];

        // Apply search query
        if (filters.searchQuery && filters.searchQuery.trim() !== '') {
            const lowerQuery = filters.searchQuery.toLowerCase().trim();
            results = results.filter(product =>
                product.name.toLowerCase().includes(lowerQuery)
            );
        }

        // Apply price filter
        if (filters.minPrice !== null || filters.maxPrice !== null) {
            results = results.filter(product => {
                const meetsMin = filters.minPrice === null || product.price >= filters.minPrice;
                const meetsMax = filters.maxPrice === null || product.price <= filters.maxPrice;
                return meetsMin && meetsMax;
            });
        }

        // Apply type filter
        if (filters.type !== null && filters.type !== '') {
            results = results.filter(product => product.type === filters.type);
        }

        this.filteredProducts = results;
        return results;
    }

    /**
     * Clear all filters
     */
    clearFilters() {
        this.filteredProducts = [...this.products];
        return this.filteredProducts;
    }
}

module.exports = SearchManager;
