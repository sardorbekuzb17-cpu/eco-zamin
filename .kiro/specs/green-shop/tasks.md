# Implementation Plan: Green Shop

- [x] 1. Set up project structure and data models
  - Create JavaScript modules for Cart, Order, Search, and Storage services
  - Define Product, CartItem, Order, and Filter data structures
  - Set up Jest testing framework with fast-check for property-based testing
  - _Requirements: 1.1, 2.1, 3.1, 4.1, 5.1, 6.1, 7.1_

- [x] 2. Implement Storage Service
  - Create StorageService class with methods for saving and loading data from localStorage
  - Implement serialization and deserialization for cart and order data
  - Add error handling for storage quota exceeded scenarios
  - _Requirements: 2.4, 2.5_

- [x] 2.1 Write property test for Storage Service
  - **Property 6: Cart persistence round-trip**
  - **Validates: Requirements 2.4, 2.5**

- [x] 3. Implement Cart Manager
  - Create CartManager class with addItem, removeItem, updateQuantity methods
  - Implement getTotalPrice and getItemCount methods
  - Integrate with StorageService for persistence
  - Add validation for product IDs and quantities
  - _Requirements: 1.1, 1.2, 1.5, 2.1, 2.3_

- [x] 3.1 Write property test for adding products
  - **Property 1: Adding products increases cart count**
  - **Validates: Requirements 1.1**

- [x] 3.2 Write property test for duplicate products



  - **Property 2: Adding same product increases quantity**
  - **Validates: Requirements 1.2**

- [x] 3.3 Write property test for quantity changes





  - **Property 4: Quantity changes update total price correctly**
  - **Validates: Requirements 1.5, 2.1**

- [x] 3.4 Write property test for removing items





  - **Property 5: Removing items from cart**
  - **Validates: Requirements 2.3**

- [x] 3.5 Write unit tests for Cart Manager edge cases





  - Test empty cart behavior
  - Test invalid product ID handling
  - Test negative quantity handling
  - Test zero quantity removal
  - _Requirements: 1.4, 2.2_

- [x] 4. Implement Cart UI Components





  - Add "Savatga qo'shish" buttons to product cards in catalog section
  - Create cart icon with item count badge in header
  - Build cart modal that displays all cart items with quantities and prices
  - Add quantity controls (increase/decrease) in cart modal
  - Add remove button for each cart item
  - Display total price in cart modal
  - Show "Savat bo'sh" message when cart is empty
  - _Requirements: 1.1, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3_

- [x] 4.1 Write property test for cart display


  - **Property 3: Cart displays all added items**
  - **Validates: Requirements 1.3**

- [x] 5. Implement Search Manager
  - Create SearchManager class with search, filterByPrice, filterByType methods
  - Implement applyFilters method that combines multiple filters
  - Implement clearFilters method to reset to original product list
  - Add case-insensitive search functionality
  - _Requirements: 6.1, 6.3, 6.4, 6.5_

- [x] 5.1 Write property test for search functionality










  - **Property 13: Search returns matching products**
  - **Validates: Requirements 6.1**

- [x] 5.2 Write property test for price filter





  - **Property 14: Price filter returns products in range**
  - **Validates: Requirements 6.3**

- [x] 5.3 Write property test for type filter





  - **Property 15: Type filter returns matching products**
  - **Validates: Requirements 6.4**

- [x] 5.4 Write property test for clearing filters





  - **Property 16: Clearing filters returns all products**
  - **Validates: Requirements 6.5**

- [x] 5.5 Write unit tests for Search Manager edge cases




  - Test empty search query
  - Test no results found scenario
  - Test invalid price range (minPrice > maxPrice)
  - _Requirements: 6.2_

- [x] 6. Implement Search and Filter UI










  - Add search input field to catalog section
  - Add price range filter controls (min and max inputs)
  - Add product type filter dropdown
  - Add "Tozalash" button to clear all filters
  - Display "Natija topilmadi" message when no products match
  - Implement debounced search (300ms delay)
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 7. Checkpoint - Ensure all tests pass










  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. Implement Order Manager
  - Create OrderManager class with createOrder, getOrders, getOrderById methods
  - Implement generateOrderNumber method for unique order numbers
  - Implement updateOrderStatus method
  - Integrate with StorageService for order persistence
  - Add QR code generation for delivered orders
  - Add certificate generation for delivered orders
  - _Requirements: 4.4, 5.1, 5.3, 5.5_

- [x] 8.1 Write property test for order creation





  - **Property 9: Successful payment creates order**
  - **Validates: Requirements 4.4**
-

- [x] 8.2 Write property test for order history




  - **Property 10: Order history displays all orders**
  - **Validates: Requirements 5.1**

- [x] 8.3 Write property test for order details
















  - **Property 11: Order details contain complete information**
  - **Validates: Requirements 5.3, 5.4**

- [x] 8.4 Write property test for delivered orders







  - **Property 12: Delivered orders have QR code and certificate**
  - **Validates: Requirements 5.5**

- [ ] 8.5 Write unit tests for Order Manager
  - Test order number uniqueness
  - Test order not found scenario
  - Test empty order list
  - _Requirements: 5.2_

- [x] 9. Implement Checkout Form





  - Create checkout form modal with fields: name, phone, address, email
  - Add "Buyurtma berish" button in cart modal
  - Implement form validation for all fields
  - Add phone number format validation (Uzbekistan format)
  - Add email format validation
  - Display validation error messages
  - Prevent submission with invalid data
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 9.1 Write property test for form validation


  - **Property 7: Form validation rejects invalid inputs**
  - **Validates: Requirements 3.2, 3.3, 3.4, 4.3**

- [x] 9.2 Write property test for valid form submission


  - **Property 8: Valid form submission proceeds to next step**
  - **Validates: Requirements 3.5**

- [x] 10. Implement Payment Flow





  - Create payment page that displays order summary
  - Add payment method selection (card, cash on delivery, mobile payment)
  - Create payment form for card details (simulated)
  - Implement payment validation
  - Create success confirmation page with order number
  - Create error page for failed payments with retry option
  - Clear cart after successful payment
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 10.1 Write property test for payment methods


  - **Property 20: Mobile payment methods available**
  - **Validates: Requirements 8.4**
-

- [x] 11. Implement Order History UI




  - Create "Mening buyurtmalarim" page/section
  - Display list of all orders with order number, date, and status
  - Show "Buyurtmalar yo'q" message when no orders exist
  - Implement order details view when clicking an order
  - Display product list, total price, and delivery address in order details
  - Show QR code and certificate for delivered orders
  - Add navigation link to order history in header
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 12. Implement Product Management (Admin)





  - Create admin panel for product management
  - Implement add product functionality with form
  - Implement edit product functionality
  - Implement delete product functionality
  - Add product image upload capability
  - Implement out-of-stock toggle
  - Disable "Savatga qo'shish" button for out-of-stock products
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 12.1 Write property test for product CRUD


  - **Property 17: Product CRUD operations persist**
  - **Validates: Requirements 7.1, 7.2, 7.3**

- [x] 12.2 Write property test for out-of-stock products

  - **Property 18: Out-of-stock products cannot be purchased**
  - **Validates: Requirements 7.4**

- [x] 12.3 Write property test for product images

  - **Property 19: Product images persist and display**
  - **Validates: Requirements 7.5**


- [x] 12.4 Write unit tests for admin functionality

  - Test duplicate product ID prevention
  - Test invalid product data validation
  - Test image upload failure handling
  - _Requirements: 7.1, 7.2, 7.5_

- [x] 13. Implement Mobile Responsiveness
  - Ensure cart modal is full-screen on mobile devices
  - Make checkout form mobile-friendly with appropriate input types
  - Optimize product grid for mobile screens
  - Test touch interactions for all buttons and controls
  - Ensure mobile payment methods are included in payment options
  - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [x] 14. Add Accessibility Features







  - Add ARIA labels to all interactive elements
  - Implement keyboard navigation for cart and modals
  - Ensure proper focus management when opening/closing modals
  - Add screen reader announcements for cart updates
  - Verify color contrast meets WCAG AA standards
  - _Requirements: All_

- [x] 15. Implement Error Handling and Edge Cases




  - Add localStorage quota exceeded handling
  - Implement graceful degradation when localStorage is unavailable
  - Add error boundaries for UI components
  - Implement retry logic for failed operations
  - Add user-friendly error messages throughout the application
  - _Requirements: All_

- [x] 16. Performance Optimization





  - Implement debouncing for search input (300ms)
  - Add lazy loading for product images
  - Cache product list in sessionStorage
  - Implement pagination if product count exceeds 50
  - Optimize cart calculations to avoid unnecessary re-renders
  - _Requirements: 6.1, 8.5_

- [x] 17. Final Integration and Polish





  - Integrate all components into GreenMarket.html
  - Ensure smooth transitions between all pages/sections
  - Test complete user flows (browse → cart → checkout → payment → order history)
  - Fix any visual inconsistencies with existing design
  - Ensure all Unicode icons display correctly
  - _Requirements: All_
-

- [x] 18. Final Checkpoint - Ensure all tests pass




  - Ensure all tests pass, ask the user if questions arise.
