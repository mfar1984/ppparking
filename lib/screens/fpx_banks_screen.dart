import 'package:flutter/material.dart';

class FPXBankListScreen extends StatelessWidget {
  const FPXBankListScreen({super.key});

  final List<Map<String, String>> banks = const [
    {'name': 'Maybank2u', 'code': 'M2U'},
    {'name': 'CIMB Clicks', 'code': 'CIMB'},
    {'name': 'Public Bank', 'code': 'PBB'},
    {'name': 'RHB Now', 'code': 'RHB'},
    {'name': 'Hong Leong Connect', 'code': 'HLB'},
    {'name': 'AmBank', 'code': 'AMB'},
    {'name': 'Bank Islam', 'code': 'BIMB'},
    {'name': 'Affin Bank', 'code': 'AFFIN'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Bank'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: banks.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF0054A6).withValues(alpha: 0.1),
              child: Text(banks[index]['code']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            title: Text(banks[index]['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Redirecting to ${banks[index]['name']}...')),
              );
            },
          );
        },
      ),
    );
  }
}
