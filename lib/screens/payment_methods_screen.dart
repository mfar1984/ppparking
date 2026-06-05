import 'package:flutter/material.dart';
import 'fpx_banks_screen.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPaymentMethod(
                context,
                'FPX Online Banking',
                Icons.account_balance_rounded,
                Colors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FPXBankListScreen()),
                  );
                },
              ),
              const SizedBox(height: 15),
              _buildPaymentMethod(
                context,
                'Credit Card',
                Icons.credit_card_rounded,
                Colors.orange,
                () {},
              ),
              const SizedBox(height: 15),
              _buildPaymentMethod(
                context,
                'Debit Card',
                Icons.payments_rounded,
                Colors.green,
                () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 20),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
