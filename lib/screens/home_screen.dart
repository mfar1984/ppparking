import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'top_up_screen.dart';
import 'car_register_screen.dart';
import 'compound_screen.dart';
import 'transaction_screen.dart';
import 'transfer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
   late Timer _timer;
  int _remainingSeconds = 300; 
  DateTime _currentExpiryDate = DateTime.now().add(const Duration(minutes: 5));
  bool _isAutoRenew = true;
  int _userPoints = 850;
  late AnimationController _alertController;

  late PageController _promoController;
  int _currentPromoPage = 0;
  Timer? _promoTimer;

  final List<Map<String, dynamic>> _promoData = [
    {'title': 'Weekend Special', 'subtitle': 'Enjoy 50% off city parking this Saturday and Sunday!', 'color': const Color(0xFF1565C0), 'icon': Icons.celebration_rounded},
    {'title': 'New Zone Added', 'subtitle': 'New parking zones are now available in George Town area.', 'color': const Color(0xFFEF6C00), 'icon': Icons.map_rounded},
    {'title': 'Refer a Friend', 'subtitle': 'Get 500 PTS for every friend who signs up and tops up.', 'color': const Color(0xFF00695C), 'icon': Icons.group_add_rounded},
    {'title': 'Monthly Pass Promo', 'subtitle': 'Subscribe to 3 months and get 1 month for FREE!', 'color': const Color(0xFF4527A0), 'icon': Icons.card_membership_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
    _alertController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _alertController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _alertController.forward();
        }
      });

    _promoController = PageController(initialPage: 0);
    _startPromoTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
            if (_remainingSeconds < 60) {
              if (!_alertController.isAnimating) _alertController.forward();
            } else {
              if (_alertController.isAnimating) {
                _alertController.stop();
                _alertController.reset();
              }
            }
          } else {
            if (_isAutoRenew) _renewParking(silently: true);
          }
        });
      }
    });
  }

  void _startPromoTimer() {
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_promoController.hasClients) {
        setState(() {
          _currentPromoPage = (_currentPromoPage + 1) % _promoData.length;
        });
        _promoController.animateToPage(_currentPromoPage, duration: const Duration(milliseconds: 800), curve: Curves.fastOutSlowIn);
      }
    });
  }

  void _renewParking({bool silently = false}) {
    setState(() {
      _remainingSeconds = 300; 
      _currentExpiryDate = DateTime.now().add(const Duration(minutes: 5));
    });
    if (!silently) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parking Renewed Successfully'), duration: Duration(seconds: 2)));
    }
  }

  void _showRedeemPopup() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => RedeemPointsPopup(currentPoints: _userPoints, onRedeem: (points) => setState(() => _userPoints -= points)));
  }

  void _showWeatherForecast() {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) => const WeatherForecastDrawer());
  }

  void _showExtendParkingDrawer() {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) => ExtendParkingDrawer(onExtend: (minutes) => setState(() { _remainingSeconds += minutes * 60; _currentExpiryDate = _currentExpiryDate.add(Duration(minutes: minutes)); })));
  }

  @override
  void dispose() {
    _timer.cancel();
    _promoTimer?.cancel();
    _alertController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(height: 160, width: double.infinity, decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/header_bg.png'), fit: BoxFit.cover))),
              
              SafeArea(
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/images/pp_logo.png', height: 40),
                            const SizedBox(width: 15),
                            Image.asset('assets/images/seberang_perai_logo.png', height: 40),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: Container(
                            width: 45,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: const Icon(Icons.menu_open_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: -35, left: 15, right: 15,
                child: Container(
                  height: 70, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))]),
                  child: Row(
                    children: [
                      Expanded(flex: 4, child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TopUpScreen())), child: _buildFloatingBarItem(icon: Icons.account_balance_wallet_outlined, label: 'RM 124.80', subLabel: 'Balance', color: Colors.orange[800], trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF0054A6), size: 18)))),
                      _buildVerticalDivider(),
                      Expanded(flex: 3, child: InkWell(onTap: _showWeatherForecast, child: _buildFloatingBarItem(icon: Icons.cloud_outlined, label: '32°C', subLabel: 'Sunny', color: Colors.blue[400]))),
                      _buildVerticalDivider(),
                      Expanded(flex: 3, child: InkWell(onTap: _showRedeemPopup, child: _buildFloatingBarItem(icon: Icons.stars_rounded, label: '$_userPoints', subLabel: 'Points', color: Colors.amber[700]))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 55),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: _alertController,
                    builder: (context, child) {
                      Color baseColor = const Color(0xFF4CAF50);
                      if (_remainingSeconds < 60) baseColor = Color.lerp(Colors.red, Colors.white, _alertController.value)!;
                      return _buildProfessionalCard(title: 'ACTIVE PARKING', council: 'Council of Penang Island', subtitle: 'Lebuh Light, George Town', content: _formatDuration(_remainingSeconds), bottomLabel: 'Expires at:', bottomContent: DateFormat('dd MMM yyyy, hh:mm a').format(_currentExpiryDate), baseColor: baseColor, isAlert: _remainingSeconds < 60, footer: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildAutoSwitch(isAlert: _remainingSeconds < 60), _buildExtendButton(isAlert: _remainingSeconds < 60, color: baseColor)]));
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(child: _buildProfessionalCard(title: 'SEASON PARKING', council: 'Seberang Perai City Council', subtitle: 'Zone A - All Day', content: '30 Days Remaining', bottomLabel: 'Status:', bottomContent: 'Valid until: 20 Nov 2023', baseColor: const Color(0xFF0054A6), footer: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: const Text('ACTIVE', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold))))),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildModernAction(Icons.directions_car_rounded, 'Car Register', Colors.blue, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CarRegisterScreen()));
                }),
                _buildModernAction(Icons.gavel_rounded, 'Compound', Colors.red, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CompoundScreen()));
                }),
                _buildModernAction(Icons.receipt_long_rounded, 'Transaction', Colors.orange, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionScreen()));
                }),
                _buildModernAction(Icons.swap_horiz_rounded, 'Transfer', Colors.green, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TransferScreen()));
                }),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Promotions & News', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                const SizedBox(height: 12),
                SizedBox(height: 160, child: PageView.builder(controller: _promoController, onPageChanged: (index) => setState(() => _currentPromoPage = index), itemCount: _promoData.length, itemBuilder: (context, index) => _buildFullWidthPromoCard(_promoData[index]['title'], _promoData[index]['subtitle'], _promoData[index]['color'], _promoData[index]['icon']))),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_promoData.length, (index) => AnimatedContainer(duration: const Duration(milliseconds: 300), width: _currentPromoPage == index ? 20 : 8, height: 8, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: _currentPromoPage == index ? const Color(0xFF0054A6) : Colors.grey[300])))),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard({required String title, required String council, required String subtitle, required String content, required String bottomLabel, required String bottomContent, required Color baseColor, required Widget footer, bool isAlert = false}) {
    return Container(
      height: 240, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: isAlert ? baseColor : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: isAlert ? Colors.red : baseColor.withValues(alpha: 0.3), width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(children: [Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isAlert ? Colors.white : baseColor)), const SizedBox(height: 4), FittedBox(fit: BoxFit.scaleDown, child: Text(council, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isAlert ? Colors.white : Colors.black87))), const SizedBox(height: 4), FittedBox(fit: BoxFit.scaleDown, child: Text(subtitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isAlert ? Colors.white70 : Colors.black54))), const Spacer(), FittedBox(fit: BoxFit.scaleDown, child: Text(content, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isAlert ? Colors.white : baseColor))), const Spacer(), Text(bottomLabel, style: TextStyle(fontSize: 10, color: isAlert ? Colors.white70 : Colors.grey)), FittedBox(fit: BoxFit.scaleDown, child: Text(bottomContent, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isAlert ? Colors.white : Colors.black87))), const SizedBox(height: 8), const Divider(height: 1), const SizedBox(height: 10), SizedBox(height: 38, child: Center(child: footer))],),
    );
  }

  Widget _buildModernAction(IconData icon, String label, Color themeColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                BoxShadow(color: themeColor.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: themeColor.withValues(alpha: 0.1), width: 1),
              ),
              child: Icon(icon, color: themeColor, size: 28),
            ),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildAutoSwitch({bool isAlert = false}) {
    return Row(mainAxisSize: MainAxisSize.min, children: [Text('AUTO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isAlert ? Colors.white : Colors.black54)), const SizedBox(width: 4), Transform.scale(scale: 0.6, child: CupertinoSwitch(value: _isAutoRenew, onChanged: (val) => setState(() => _isAutoRenew = val), activeColor: Colors.green))],);
  }

  Widget _buildExtendButton({required bool isAlert, required Color color}) {
    return GestureDetector(onTap: _showExtendParkingDrawer, child: Container(width: 34, height: 34, decoration: BoxDecoration(color: isAlert ? Colors.white : const Color(0xFF0054A6), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]), child: Icon(Icons.more_time_rounded, color: isAlert ? Colors.red : Colors.white, size: 18)));
  }

  Widget _buildVerticalDivider() => Container(height: 30, width: 1, color: Colors.grey[200]);

  Widget _buildFloatingBarItem({required IconData icon, required String label, required String subLabel, Color? color, Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 6),
          Flexible(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [FittedBox(fit: BoxFit.scaleDown, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))), FittedBox(fit: BoxFit.scaleDown, child: Text(subLabel, style: TextStyle(fontSize: 10, color: Colors.grey[600])))])) ,
          if (trailing != null) ...[const SizedBox(width: 4), trailing],
        ],
      ),
    );
  }

  Widget _buildFullWidthPromoCard(String title, String subtitle, Color color, IconData icon) {
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)), child: Stack(children: [Positioned(right: -10, bottom: -10, child: Icon(icon, color: Colors.white.withValues(alpha: 0.2), size: 100)), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis), const Spacer(), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Claim Now >', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: const Text('LIMITED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)))])])]));
  }
}

class WeatherForecastDrawer extends StatelessWidget {
  const WeatherForecastDrawer({super.key});
  @override Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> forecasts = [{'time': now, 'temp': '32°C', 'icon': Icons.wb_sunny_rounded, 'desc': 'Sunny'}, {'time': now.add(const Duration(minutes: 30)), 'temp': '31°C', 'icon': Icons.cloud_rounded, 'desc': 'Cloudy'}, {'time': now.add(const Duration(minutes: 60)), 'temp': '29°C', 'icon': Icons.cloud_queue_rounded, 'desc': 'Partly Cloudy'}, {'time': now.add(const Duration(minutes: 90)), 'temp': '28°C', 'icon': Icons.grain_rounded, 'desc': 'Light Rain'}, {'time': now.add(const Duration(minutes: 120)), 'temp': '27°C', 'icon': Icons.thunderstorm_rounded, 'desc': 'Thunderstorm'}];
    return Container(padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))), const SizedBox(height: 25), const Row(children: [Icon(Icons.location_on_rounded, color: Color(0xFF0054A6)), SizedBox(width: 10), Text('George Town, Penang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]), const SizedBox(height: 20), const Divider(), const SizedBox(height: 10), const Text('30-Minute Interval Forecast', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)), const SizedBox(height: 20), Column(children: forecasts.map((f) { return Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(children: [SizedBox(width: 80, child: Text(DateFormat('hh:mm a').format(f['time']), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))), Icon(f['icon'], color: const Color(0xFF0054A6), size: 28), const SizedBox(width: 20), Expanded(child: Text(f['desc'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))), Text(f['temp'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0054A6)))],)); }).toList()), const SizedBox(height: 30), const Text('Data provided by MET Malaysia', style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)), const SizedBox(height: 20)]));
  }
}

class ExtendParkingDrawer extends StatelessWidget {
  final Function(int) onExtend;
  const ExtendParkingDrawer({super.key, required this.onExtend});
  @override Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [{'label': '30 Mins', 'value': 30, 'price': 'RM 0.40'}, {'label': '1 Hour', 'value': 60, 'price': 'RM 0.80'}, {'label': '2 Hours', 'value': 120, 'price': 'RM 1.60'}, {'label': '4 Hours', 'value': 240, 'price': 'RM 3.20'}, {'label': 'Full Day', 'value': 480, 'price': 'RM 6.00'}];
    return Container(padding: const EdgeInsets.all(25), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))), const SizedBox(height: 25), const Text('Extend Parking Duration', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 10), const Text('Select additional time for your current session', style: TextStyle(color: Colors.grey, fontSize: 14)), const SizedBox(height: 30), Column(children: options.map((opt) { return Padding(padding: const EdgeInsets.only(bottom: 12), child: InkWell(onTap: () { onExtend(opt['value']); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully extended by ${opt['label']}!'))); }, child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [const Icon(Icons.timer_outlined, color: Color(0xFF0054A6)), const SizedBox(width: 15), Text(opt['label'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]), Text(opt['price'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0054A6)))],)),),); }).toList()), const SizedBox(height: 20)]));
  }
}

class RedeemPointsPopup extends StatefulWidget {
  final int currentPoints;
  final Function(int) onRedeem;
  const RedeemPointsPopup({super.key, required this.currentPoints, required this.onRedeem});
  @override State<RedeemPointsPopup> createState() => _RedeemPointsPopupState();
}
class _RedeemPointsPopupState extends State<RedeemPointsPopup> {
  double _redeemPoints = 0;
  @override Widget build(BuildContext context) {
    double cashbackAmount = _redeemPoints / 500;
    return Container(padding: const EdgeInsets.all(25), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))), const SizedBox(height: 25), const Text('Redeem Your Points', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Text('5 Points = 1 Sen Cashback', style: TextStyle(color: Colors.grey[600], fontSize: 14)), const SizedBox(height: 30), Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('${_redeemPoints.toInt()}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF0054A6))), const SizedBox(width: 10), const Text('PTS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey))]), Text('Equivalent to RM ${cashbackAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)), const SizedBox(height: 30), Slider(value: _redeemPoints, min: 0, max: widget.currentPoints.toDouble(), divisions: widget.currentPoints > 0 ? widget.currentPoints : 1, activeColor: const Color(0xFF0054A6), onChanged: (value) => setState(() => _redeemPoints = value)), Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('0', style: TextStyle(color: Colors.grey)), Text('Total: ${widget.currentPoints} PTS', style: const TextStyle(fontWeight: FontWeight.bold))])), const SizedBox(height: 40), SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _redeemPoints > 0 ? () { widget.onRedeem(_redeemPoints.toInt()); Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully redeemed RM ${cashbackAmount.toStringAsFixed(2)}!'))); } : null, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0054A6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text('CLAIM CASHBACK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))), const SizedBox(height: 20)]));
  }
}
