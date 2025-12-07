/**
 * Setup verification test
 * Ensures Jest and fast-check are properly configured
 */
const fc = require('fast-check');

describe('Test Setup', () => {
    test('Jest is working', () => {
        expect(true).toBe(true);
    });

    test('fast-check is working', () => {
        fc.assert(
            fc.property(fc.integer(), (n) => {
                return n === n;
            })
        );
    });
});
