import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:renohouz_worker/providers/location_provider.dart';
import 'package:renohouz_worker/providers/user_provider.dart';
import 'package:renohouz_worker/utils/debugger.dart';
import 'package:renohouz_worker/views/activity_page.dart';
import 'package:renohouz_worker/views/jobs_page.dart';
import 'package:renohouz_worker/views/pending_page.dart';
import 'package:renohouz_worker/views/profile_page.dart';
import 'package:renohouz_worker/views/suspended_page.dart';
import 'package:renohouz_worker/views/wallet_page.dart';

class Shell extends StatefulWidget {
  const Shell({Key? key}) : super(key: key);

  @override
  _ShellState createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _currentPageIndex = 0;

  List<Widget> bodies = const [JobsPage(), ActivityPage(), WalletPage(), ProfilePage()];

  Future<void> checkVersion(BuildContext ctx) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    Debugger.log("--- app version ---");
    Debugger.log(packageInfo.version);
    Debugger.log("--- app version ---");
  }

  @override
  void initState() {
    super.initState();
    context.read<LocationProvider>().initialize();
    context.read<UserProvider>().saveFcmToken();
    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      Debugger.log("execute post frame");
      await checkVersion(context);
      //await checkLocation(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider user = context.read<UserProvider>();
    if (user.status == 'pending') return const PendingPage();
    if (user.status == 'suspended') return const SuspendedPage();
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentPageIndex,
        children: bodies,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work_rounded), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded), label: 'Account')
        ],
        currentIndex: _currentPageIndex,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
      ),
    );
  }
}
