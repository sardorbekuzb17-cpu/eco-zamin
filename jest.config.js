module.exports = {
    testEnvironment: 'jsdom',
    collectCoverageFrom: [
        'src/**/*.js',
        '!src/**/*.test.js'
    ],
    coveragePathIgnorePatterns: [
        '/node_modules/'
    ],
    testMatch: [
        '**/__tests__/**/*.js',
        '**/?(*.)+(spec|test).js'
    ],
    verbose: true
};
