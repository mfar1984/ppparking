import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SeasonPassScreen extends StatefulWidget {
  const SeasonPassScreen({super.key});

  @override
  State<SeasonPassScreen> createState() => _SeasonPassScreenState();
}

class _SeasonPassScreenState extends State<SeasonPassScreen> {
  String selectedCouncil = 'MBPP'; 
  String selectedVehicle = 'PJA 1234';
  int selectedMonths = 1;

  final List<Map<String, dynamic>> passOptions = [
    {'months': 1, 'label': 'Monthly', 'price': 150.0},
    {'months': 3, 'label': 'Quarterly', 'price': 400.0},
    {'months': 6, 'label': 'Half Year', 'price': 800.0},
    {'months': 12, 'label': 'Yearly', 'price': 1500.0},
  ];

  double get totalPrice {
    return passOptions.firstWhere((opt) => opt['months'] == selectedMonths)['price'];
  }

  String get expiryDate {
    DateTime now = DateTime.now();
    DateTime expiry = DateTime(now.year, now.month + selectedMonths, now.day);
    return DateFormat('dd MMM yyyy').format(expiry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header
            Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/header_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/pp_logo.png', height: 40),
                      const SizedBox(width: 15),
                      Image.asset('assets/images/seberang_perai_logo.png', height: 40),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Select Council
                  const Text('Select Council', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('City Council of Penang Island (MBPP)', style: TextStyle(fontSize: 14)),
                          value: 'MBPP',
                          groupValue: selectedCouncil,
                          onChanged: (val) => setState(() => selectedCouncil = val!),
                          activeColor: const Color(0xFF0054A6),
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        RadioListTile<String>(
                          title: const Text('Seberang Perai City Council (MBSP)', style: TextStyle(fontSize: 14)),
                          value: 'MBSP',
                          groupValue: selectedCouncil,
                          onChanged: (val) => setState(() => selectedCouncil = val!),
                          activeColor: const Color(0xFF0054A6),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 3. Select Vehicle
                  const Text('Select Vehicle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_car_filled, color: Color(0xFF0054A6)),
                        const SizedBox(width: 15),
                        Text(selectedVehicle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Divider(),
                  const SizedBox(height: 15),

                  // 4. Pass Duration
                  const Text('Pass Duration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  Column(
                    children: passOptions.map((opt) {
                      bool isSelected = selectedMonths == opt['months'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => setState(() => selectedMonths = opt['months']),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF0054A6).withValues(alpha: 0.05) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? const Color(0xFF0054A6) : Colors.grey.shade200, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: const Color(0xFF0054A6)),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(opt['label'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      Text('${opt['months']} Month${opt['months'] > 1 ? 's' : ''} Coverage', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text(
                                  'RM ${opt['price'].toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0054A6)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 25),

                  // 5. Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0054A6),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Validity Until', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const Text('Total Amount', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(expiryDate, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('RM ${totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 6. Buy Now Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0054A6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('PURCHASE PASS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
