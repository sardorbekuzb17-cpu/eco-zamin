# GreenMarket - Green Shop

E-commerce platform for buying trees and plants.

## Project Structure

```
├── src/
│   ├── models/          # Data models
│   │   ├── Product.js
│   │   ├── CartItem.js
│   │   ├── Order.js
│   │   └── Filter.js
│   └── services/        # Business logic
│       ├── CartManager.js
│       ├── OrderManager.js
│       ├── SearchManager.js
│       └── StorageService.js
├── __tests__/           # Test files
├── GreenMarket.html     # Main HTML file
└── package.json
```

## Installation

```bash
npm install
```

## Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage
```

## Data Models

### Product
- id: string
- name: string
- price: number
- description: string
- icon: string (emoji)
- type: string
- inStock: boolean
- co2Absorption: number

### CartItem
- productId: string
- quantity: number
- addedAt: timestamp

### Order
- orderId: string
- orderNumber: string
- items: CartItem[]
- customerInfo: object
- totalPrice: number
- status: string
- createdAt: timestamp
- qrCode: string (for delivered orders)
- certificate: string (for delivered orders)

### Filter
- searchQuery: string
- minPrice: number
- maxPrice: number
- type: string

## Services

### CartManager
Manages shopping cart operations (add, remove, update items)

### OrderManager
Manages order creation and retrieval

### SearchManager
Manages product search and filtering

### StorageService
Handles localStorage operations with error handling
