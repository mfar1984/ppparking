import 'package:flutter/material.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Transaction History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF0054A6),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Parking'),
              Tab(text: 'Wallet'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ParkingTransactions(),
            WalletTransactions(),
          ],
        ),
      ),
    );
  }
}

class ParkingTransactions extends StatelessWidget {
  const ParkingTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> data = [
      {'plate': 'PJA 1234', 'location': 'Lebuh Light', 'date': 'Today, 10:30 AM', 'amount': 0.80, 'duration': '1 Hour'},
      {'plate': 'PJA 1234', 'location': 'Beach Street', 'date': 'Yesterday, 02:15 PM', 'amount': 1.60, 'duration': '2 Hours'},
      {'plate': 'PPC 8888', 'location': 'Gurney Drive', 'date': '18 Oct 2023', 'amount': 0.40, 'duration': '30 Mins'},
      {'plate': 'PJA 1234', 'location': 'Queensbay', 'date': '15 Oct 2023', 'amount': 2.40, 'duration': '3 Hours'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.local_parking, color: Color(0xFF0054A6)),
            ),
            title: Text(item['plate'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['location'], style: const TextStyle(fontSize: 12)),
                Text(item['date'], style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('- RM ${item['amount'].toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                Text(item['duration'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WalletTransactions extends StatelessWidget {
  const WalletTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> data = [
      {'type': 'Top Up', 'method': 'FPX Online Banking', 'date': 'Today, 09:00 AM', 'amount': 50.00, 'isAdd': true},
      {'type': 'Parking Payment', 'method': 'Wallet Deduction', 'date': 'Yesterday, 02:15 PM', 'amount': 1.60, 'isAdd': false},
      {'type': 'Cashback', 'method': 'Points Redemption', 'date': '18 Oct 2023', 'amount': 5.00, 'isAdd': true},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item['isAdd'] ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item['isAdd'] ? Icons.add_card : Icons.payment,
                color: item['isAdd'] ? Colors.green : Colors.red,
              ),
            ),
            title: Text(item['type'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['method'], style: const TextStyle(fontSize: 12)),
                Text(item['date'], style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
            trailing: Text(
              '${item['isAdd'] ? '+' : '-'} RM ${item['amount'].toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: item['isAdd'] ? Colors.green : Colors.red,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
