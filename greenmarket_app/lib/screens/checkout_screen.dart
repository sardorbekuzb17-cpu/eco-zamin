import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../l10n/app_localizations.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, int> cartItems;
  final int total;
  final List<dynamic> products;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.total,
    required this.products,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isLoading = false;
  String _selectedPaymentMethod = 'cash';

  static const String _apiUrl = 'https://greenmarket-api.vercel.app/api/orders';

  AppLocalizations get l10n => AppLocalizations.of(context)!;
  String get _langCode => Localizations.localeOf(context).languageCode;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Buyurtma ma'lumotlarini tayyorlash
      final orderItems = widget.cartItems.entries.map((entry) {
        final product = widget.products.firstWhere((p) => p.id == entry.key);
        return {
          'productId': entry.key,
          'productName': product.getName(_langCode),
          'quantity': entry.value,
          'price': product.price,
          'total': product.price * entry.value,
        };
      }).toList();

      final orderData = {
        'userId': 'guest_${DateTime.now().millisecondsSinceEpoch}',
        'items': orderItems,
        'total': widget.total,
        'customerInfo': {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'note': _noteController.text,
        },
        'deliveryAddress': {'address': _addressController.text},
        'paymentMethod': _selectedPaymentMethod,
      };

      // Serverga yuborish
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (mounted) {
          _showSuccessDialog(data['order']['orderId']);
        }
      } else {
        throw Exception('Buyurtma yuborishda xatolik');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF15803D),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 20),
            const Text(
              'Buyurtma qabul qilindi!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2E1A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Buyurtma raqami: $orderId',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tez orada siz bilan bog\'lanamiz',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dialog
                  Navigator.of(context).pop(); // Checkout screen
                  Navigator.of(context).pop(); // Cart screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15803D),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Bosh sahifaga qaytish',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A2E1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buyurtmani rasmiylashtirish',
          style: TextStyle(
            color: Color(0xFF1A2E1A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummary(),
              const SizedBox(height: 24),
              _buildCustomerInfoSection(),
              const SizedBox(height: 24),
              _buildPaymentMethodSection(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Buyurtma tafsilotlari',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 16),
          ...widget.cartItems.entries.map((entry) {
            final product = widget.products.firstWhere(
              (p) => p.id == entry.key,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${product.getName(_langCode)} x${entry.value}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  Text(
                    '${(product.price * entry.value).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} so\'m',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jami:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${widget.total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} so\'m',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF15803D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shaxsiy ma\'lumotlar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Ism va familiya',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ism va familiyani kiriting';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Telefon raqam',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Telefon raqamni kiriting';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Yetkazib berish manzili',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Manzilni kiriting';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Izoh (ixtiyoriy)',
              prefixIcon: const Icon(Icons.note_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'To\'lov usuli',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedPaymentMethod = 'cash';
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedPaymentMethod == 'cash'
                    ? const Color(0xFFF0FDF4)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedPaymentMethod == 'cash'
                      ? const Color(0xFF15803D)
                      : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedPaymentMethod == 'cash'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: _selectedPaymentMethod == 'cash'
                        ? const Color(0xFF15803D)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Naqd pul',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Yetkazib berishda to\'lash',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedPaymentMethod = 'card';
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedPaymentMethod == 'card'
                    ? const Color(0xFFF0FDF4)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedPaymentMethod == 'card'
                      ? const Color(0xFF15803D)
                      : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedPaymentMethod == 'card'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: _selectedPaymentMethod == 'card'
                        ? const Color(0xFF15803D)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Karta orqali',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Online to\'lov',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF15803D),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Buyurtma berish',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
