import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Checkout extends StatefulWidget {
  final DateTime selectedDate;
  final String selectedTimeSlot;
  final String sizeLabel;
  final int price;

  const Checkout({
    super.key,
    required this.selectedDate,
    required this.selectedTimeSlot,
    required this.sizeLabel,
    required this.price,
  });

  @override
  State<Checkout> createState() => _CheckoutUIState();
}

class _CheckoutUIState extends State<Checkout> {
  bool isLoading = false;

  Future<void> _startPayment() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse('https://your-server.com/create-payment-intent');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'amount': widget.price * 100, 'currency': 'AED'}),
      );

      if (response.statusCode != 200) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception("Failed to fetch payment intent");
      }

      final jsonResponse = json.decode(response.body);
      final clientSecret = jsonResponse['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Houzy',
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Payment Successful')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Payment failed: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      appBar: AppBar(
        title: const Text('Booking Checkout'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF54A00),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildBookingSummary(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: !isLoading ? _startPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF54A00),
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 6,
                ),
                icon: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.payment, color: Colors.white),
                label: Text(
                  isLoading ? 'Processing...' : 'Continue to Pay',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    final formattedPrice = NumberFormat.currency(
      locale: 'en_AE',
      symbol: 'AED ',
    ).format(widget.price);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _summaryRow("Service", "Regular Cleaning"),
          _summaryRow("Size", widget.sizeLabel),
          _summaryRow("Date", DateFormat('MMM d, yyyy').format(widget.selectedDate)),
          _summaryRow("Time", widget.selectedTimeSlot),
          const Divider(),
          _summaryRow("Total", formattedPrice, isBold: true),
          const SizedBox(height: 6),
          const Text("One-time payment", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
