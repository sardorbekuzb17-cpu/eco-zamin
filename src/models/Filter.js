/**
 * Filter data model
 * Represents search and filter criteria for products
 */
class Filter {
    constructor({
        searchQuery = '',
        minPrice = null,
        maxPrice = null,
        type = null
    }) {
        this.searchQuery = searchQuery;
        this.minPrice = minPrice;
        this.maxPrice = maxPrice;
        this.type = type;
    }

    /**
     * Validate filter data
     */
    static validate(filter) {
        if (filter.minPrice !== null && (typeof filter.minPrice !== 'number' || filter.minPrice < 0)) {
            throw new Error('Min price must be a non-negative number or null');
        }
        if (filter.maxPrice !== null && (typeof filter.maxPrice !== 'number' || filter.maxPrice < 0)) {
            throw new Error('Max price must be a non-negative number or null');
        }
        if (filter.minPrice !== null && filter.maxPrice !== null && filter.minPrice > filter.maxPrice) {
            throw new Error('Min price cannot be greater than max price');
        }
        return true;
    }
}

module.exports = Filter;
