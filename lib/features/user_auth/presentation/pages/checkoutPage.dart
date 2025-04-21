import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laptop_harbor/cartProvider.dart';
import 'dart:math';
import 'package:laptop_harbor/features/user_auth/presentation/mainNavigationShell.dart';


class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  static const double taxRate = 0.10;
  static const double shippingFee = 20.0;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final subtotal = cart.totalPrice;
    final tax = subtotal * taxRate;
    final grandTotal = subtotal + tax + shippingFee;

    // Controllers for form fields
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final postalCodeController = TextEditingController();

    String generateTrackingNumber() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random();
  return List.generate(10, (index) => chars[rand.nextInt(chars.length)]).join();
}

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shipping Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
              TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City')),
              TextField(controller: postalCodeController, decoration: const InputDecoration(labelText: 'Postal Code')),
              const SizedBox(height: 30),

              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SummaryRow(label: 'Subtotal', value: subtotal),
              SummaryRow(label: 'Tax (10%)', value: tax),
              SummaryRow(label: 'Shipping Fee', value: shippingFee),
              const Divider(),
              SummaryRow(label: 'Grand Total', value: grandTotal, bold: true),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Show confirmation dialog
                    final shouldProceed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Order'),
                        content: const Text('Are you sure you want to place this order?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Proceed'),
                          ),
                        ],
                      ),
                    );

                    // If user cancels
                    if (shouldProceed != true) return;

                    // Save order to Firestore
                    await FirebaseFirestore.instance.collection('orders').add({
                      'fullName': nameController.text,
                      'address': addressController.text,
                      'city': cityController.text,
                      'postalCode': postalCodeController.text,
                      'items': cart.items.values.map((item) {
                        return {
                          'name': item.name,
                          'price': item.price,
                          'quantity': item.quantity,
                        };
                      }).toList(),
                      'subtotal': subtotal,
                      'tax': tax,
                      'shippingFee': shippingFee,
                      'total': grandTotal,
                      'status': 'Shipped',
                      'carrier': 'UPS',
                      'trackingNumber':  generateTrackingNumber(),
                      'orderedAt': Timestamp.now(),
                    });

                    // Show order placed dialog
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Order Confirmed'),
                        content: const Text('Your order has been successfully placed!'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); 

                              // Access provider and navigate safely after dialog is closed
                              Future.microtask(() {
                                final cartProvider = Provider.of<CartProvider>(context, listen: false);
                                cartProvider.clearCart();

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MainNavigationPage()),
                                  (route) => false,
                                );
                              });
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Confirm Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
