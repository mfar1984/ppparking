import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Compound {
  final String id;
  final String noticeNumber;
  final String vehicleNumber;
  final DateTime date;
  final String location;
  final double amount;
  final String offense;
  bool isPaid;

  Compound({
    required this.id,
    required this.noticeNumber,
    required this.vehicleNumber,
    required this.date,
    required this.location,
    required this.amount,
    required this.offense,
    this.isPaid = false,
  });
}

class OutstandingScreen extends StatefulWidget {
  const OutstandingScreen({super.key});

  @override
  State<OutstandingScreen> createState() => _OutstandingScreenState();
}

class _OutstandingScreenState extends State<OutstandingScreen> {
  final List<Compound> _compounds = [
    Compound(
      id: '1',
      noticeNumber: 'S-2024-00124',
      vehicleNumber: 'PMG 1234',
      date: DateTime.now().subtract(const Duration(days: 15)),
      location: 'Lebuh Sungai Pinang',
      amount: 30.00,
      offense: 'Expired Parking Session',
    ),
    Compound(
      id: '2',
      noticeNumber: 'S-2024-00156',
      vehicleNumber: 'PMG 1234',
      date: DateTime.now().subtract(const Duration(days: 45)),
      location: 'Jalan Jelutong',
      amount: 50.00,
      offense: 'Parking Outside Designated Bay',
    ),
  ];

  double get _totalOutstanding => _compounds.where((c) => !c.isPaid).fold(0, (sum, item) => sum + item.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Outstanding Compounds', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          Expanded(
            child: _compounds.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _compounds.length,
                    itemBuilder: (context, index) {
                      return _buildCompoundCard(_compounds[index]);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _totalOutstanding > 0 ? _buildPayAllButton() : null,
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0054A6), Color(0xFF007BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0054A6).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Outstanding',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'RM ${_totalOutstanding.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_compounds.length} Pending Notices',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompoundCard(Compound compound) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  compound.noticeNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0054A6)),
                ),
                Text(
                  'RM ${compound.amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.redAccent),
                ),
              ],
            ),
            const Divider(height: 24),
            _infoRow(Icons.directions_car_rounded, 'Vehicle', compound.vehicleNumber),
            const SizedBox(height: 8),
            _infoRow(Icons.calendar_today_rounded, 'Date', DateFormat('dd MMM yyyy, hh:mm a').format(compound.date)),
            const SizedBox(height: 8),
            _infoRow(Icons.location_on_rounded, 'Location', compound.location),
            const SizedBox(height: 8),
            _infoRow(Icons.report_problem_rounded, 'Offense', compound.offense),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Handle payment for single compound
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0054A6),
                  side: const BorderSide(color: Color(0xFF0054A6)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('View Details & Pay'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label:', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 80, color: Colors.green[200]),
          const SizedBox(height: 20),
          const Text(
            'No Outstanding Compounds',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You are all cleared! Keep it up.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPayAllButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Handle pay all
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0054A6),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text('Pay All (RM ${_totalOutstanding.toStringAsFixed(2)})', 
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
