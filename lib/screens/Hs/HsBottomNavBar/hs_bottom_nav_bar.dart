import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/screens/Hs/Home/hs_home_screen.dart';
import 'package:hali_saha_bak/screens/Hs/HsMyReservations/hs_my_reservations.dart';
import 'package:hali_saha_bak/screens/Hs/HsProfile/hs_profile.dart';
import 'package:hali_saha_bak/screens/Hs/TableScreen/table_screen.dart';

class HsBottomNavBar extends StatefulWidget {
  const HsBottomNavBar({Key? key}) : super(key: key);

  @override
  State<HsBottomNavBar> createState() => _HsBottomNavBarState();
}

class _HsBottomNavBarState extends State<HsBottomNavBar> {
  List<Widget> pages = [
    const HsHomeScreen(),
    const TableScreen(),
    const HsMyReservations(),
    const HsProfile(),
  ];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
        stream: Connectivity().onConnectivityChanged,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return SizedBox();
          }
         // print('snapshot.data : ${snapshot.data}');
          if (snapshot.data != ConnectivityResult.wifi && snapshot.data != ConnectivityResult.mobile) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Bağlantı Hatası'),
              ),
              body: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('İnternet bağlantısı bekleniyor'),
                ],
              )),
            );
          }
          return Scaffold(
            bottomNavigationBar: FlashyTabBar(
              backgroundColor: Colors.black,
              selectedIndex: currentIndex,
              onItemSelected: ((value) {
                setState(() {
                  currentIndex = value;
                });
              }),
              items: [
                FlashyTabBarItem(icon: Icon(Icons.home), title: Text('Ana Sayfa'), activeColor: Colors.green, inactiveColor: Colors.green[100]!),
                FlashyTabBarItem(icon: Icon(Icons.table_chart), title: Text('Çizelge'), activeColor: Colors.green, inactiveColor: Colors.green[100]!),
                FlashyTabBarItem(icon: Icon(Icons.monetization_on), title: Text('Rezervasyon'), activeColor: Colors.green, inactiveColor: Colors.green[100]!),
                FlashyTabBarItem(icon: Icon(Icons.person), title: Text('Profilim'), activeColor: Colors.green, inactiveColor: Colors.green[100]!),
              ],
            ),
            body: pages[currentIndex],
          );
        });
  }
}
