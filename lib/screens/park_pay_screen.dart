import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ParkPayScreen extends StatefulWidget {
  const ParkPayScreen({super.key});

  @override
  State<ParkPayScreen> createState() => _ParkPayScreenState();
}

class _ParkPayScreenState extends State<ParkPayScreen> {
  String selectedCouncil = 'MBPP'; // MBPP = Penang Island, MBSP = Seberang Perai
  String parkingType = 'Hourly'; // 'OneDay' or 'Hourly'
  String selectedVehicle = 'PJA 1234';
  int selectedHours = 1;
  int selectedMinutes = 0;
  bool setExpiryAlert = true;

  double get hourlyRate => selectedCouncil == 'MBPP' ? 1.20 : 0.80;
  double get dailyRate => selectedCouncil == 'MBPP' ? 9.00 : 6.00;

  double get totalPrice {
    if (parkingType == 'OneDay') return dailyRate;
    return (selectedHours * hourlyRate) + (selectedMinutes / 60 * hourlyRate);
  }

  // Get current Malaysian Time (+8)
  DateTime get nowMalaysia => DateTime.now().toUtc().add(const Duration(hours: 8));

  String get endTime {
    DateTime now = nowMalaysia;
    
    // Determine the start point for calculation
    DateTime baseStartTime;
    DateTime operationalStart = DateTime(now.year, now.month, now.day, 8, 0);
    
    if (now.isBefore(operationalStart)) {
      // If before 8:00 AM, start counting from 8:00 AM
      baseStartTime = operationalStart;
    } else {
      // If after 8:00 AM, start counting from now
      baseStartTime = now;
    }

    DateTime calculatedEndTime;
    if (parkingType == 'OneDay') {
      // One day ends at 6:00 PM today
      calculatedEndTime = DateTime(now.year, now.month, now.day, 18, 0);
    } else {
      // Hourly ends [baseStartTime + selected duration]
      calculatedEndTime = baseStartTime.add(Duration(hours: selectedHours, minutes: selectedMinutes));
    }

    // Limit to 6:00 PM
    DateTime limit = DateTime(now.year, now.month, now.day, 18, 0);
    if (calculatedEndTime.isAfter(limit)) {
      calculatedEndTime = limit;
    }

    return DateFormat('hh:mm a').format(calculatedEndTime);
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

                  // 4. Parking Duration
                  const Text('Parking Duration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  // One Day Option
                  InkWell(
                    onTap: () => setState(() => parkingType = 'OneDay'),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: parkingType == 'OneDay' ? const Color(0xFF0054A6).withValues(alpha: 0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: parkingType == 'OneDay' ? const Color(0xFF0054A6) : Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(parkingType == 'OneDay' ? Icons.radio_button_checked : Icons.radio_button_off, color: const Color(0xFF0054A6)),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text('One Day Park (RM ${dailyRate.toStringAsFixed(2)})', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Hourly Option
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: parkingType == 'Hourly' ? const Color(0xFF0054A6).withValues(alpha: 0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: parkingType == 'Hourly' ? const Color(0xFF0054A6) : Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => setState(() => parkingType = 'Hourly'),
                          child: Row(
                            children: [
                              Icon(parkingType == 'Hourly' ? Icons.radio_button_checked : Icons.radio_button_off, color: const Color(0xFF0054A6)),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text('Hourly (RM ${hourlyRate.toStringAsFixed(2)} / hour)', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        if (parkingType == 'Hourly') ...[
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildTimeAdjuster('Hour', selectedHours, (val) => setState(() => selectedHours = (selectedHours + val).clamp(1, 10))),
                              _buildTimeAdjuster('Minute', selectedMinutes, (val) => setState(() => selectedMinutes = (selectedMinutes + val).clamp(0, 45)), step: 30),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 5. End Time & Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0054A6),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Time', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text(endTime, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Total Amount', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('RM ${totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 6. Set Expiry Alert
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Set Expiry Alert', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      Switch(
                        value: setExpiryAlert,
                        onChanged: (val) => setState(() => setExpiryAlert = val),
                        activeColor: const Color(0xFF0054A6),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 7. Disclaimer Note
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade800, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Note : Kindly note that transactions are non-refundable. Please ensure accurate details for the selected Council, car plate number and number of hours as mistakes in entry will not be eligible for a refund.',
                            style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 8. Pay Now Button
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
                      child: const Text('PAY NOW', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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

  Widget _buildTimeAdjuster(String label, int value, Function(int) onAdjust, {int step = 1}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildRoundBtn(Icons.remove, () => onAdjust(-step)),
            Container(
              width: 60,
              alignment: Alignment.center,
              child: Text(
                value.toString().padLeft(2, '0'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            _buildRoundBtn(Icons.add, () => onAdjust(step)),
          ],
        ),
      ],
    );
  }

  Widget _buildRoundBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF0054A6)),
      ),
    );
  }
}
