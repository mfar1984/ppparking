import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/park_pay_screen.dart';
import 'screens/season_pass_screen.dart';
import 'screens/find_parking_screen.dart';
import 'screens/outstanding_screen.dart';

void main() {
  runApp(const ParkingApp());
}

class ParkingApp extends StatelessWidget {
  const ParkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Park - SUK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0054A6),
          primary: const Color(0xFF0054A6),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const HomeScreen(),
    const ParkPayScreen(),
    const FindParkingScreen(), // Replaced placeholder with real map screen
    const SeasonPassScreen(), // Integrated the real Season Pass screen
    const OutstandingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF0054A6),
                image: DecorationImage(
                  image: AssetImage('assets/images/header_bg.png'),
                  fit: BoxFit.cover,
                  opacity: 0.1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_rounded, color: Color(0xFF0054A6), size: 40),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Icon(Icons.person_outline_rounded, color: Colors.white70, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Zulkifli Abdullah',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.email_outlined, color: Colors.white70, size: 14),
                      SizedBox(width: 8),
                      Text(
                        'zulkifli@example.com',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.phone_android_outlined, color: Colors.white70, size: 14),
                      SizedBox(width: 8),
                      Text(
                        '+6012-3456789',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _drawerItem(Icons.person_outline_rounded, 'Profile'),
                  _drawerItem(Icons.security_rounded, 'Security'),
                  _drawerItem(Icons.tune_rounded, 'My Preference'),
                  _drawerItem(Icons.help_outline_rounded, 'FAQ'),
                  _drawerItem(Icons.info_outline_rounded, 'About'),
                  _drawerItem(Icons.policy_outlined, 'Privacy Policies'),
                  _drawerItem(Icons.support_agent_rounded, 'Helpdesk'),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Divider(height: 1),
                  ),
                  _drawerItem(Icons.logout_rounded, 'Logout', color: Colors.redAccent),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Version 1.0.0 (Dummy)',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0054A6),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.local_parking_rounded), label: 'Park & Pay'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on_rounded), label: 'Find'),
          BottomNavigationBarItem(icon: Icon(Icons.card_membership_rounded), label: 'Season Pass'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Outstanding'),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, {Color? color}) {
    return ListTile(
      visualDensity: const VisualDensity(vertical: -2),
      leading: Icon(icon, color: color ?? Colors.black87, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: Colors.blue[100]),
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.blueGrey)),
            ],
          ),
        ),
      ),
    );
  }
}
