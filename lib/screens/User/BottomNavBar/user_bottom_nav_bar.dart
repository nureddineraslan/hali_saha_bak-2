import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/screens/User/Favorites/favorites_screen.dart';
import 'package:hali_saha_bak/screens/User/Home/user_home_screen.dart';
import 'package:hali_saha_bak/screens/User/MyReservations/my_reservations.dart';
import 'package:hali_saha_bak/screens/User/Profile/user_profile.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class UserBottomNavBar extends StatefulWidget {
  const UserBottomNavBar({Key? key}) : super(key: key);

  @override
  State<UserBottomNavBar> createState() => _UserBottomNavBarState();
}

int currentUserBottomIndex = 0;

class _UserBottomNavBarState extends State<UserBottomNavBar> {
  List<Widget> pages = [
    const UserHomeScreen(),
    const MyReservations(),
    const FavoritesScreen(),
    const UserProfile(),
  ];
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
        stream: Connectivity().onConnectivityChanged,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return SizedBox();
          }
          print('snapshot.data : ${snapshot.data}');
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
              selectedIndex: currentUserBottomIndex,
              onItemSelected: ((value) {
                setState(() {
                  currentUserBottomIndex = value;
                });
              }),
              items: [
                FlashyTabBarItem(icon: Icon(Icons.home), title: Text('Ana Sayfa'), activeColor: Colors.green, inactiveColor: Colors.green[100]!),
                FlashyTabBarItem(icon: Icon(Icons.monetization_on), title: Text('Rezervasyon'), activeColor: Colors.green, inactiveColor: Colors.green[100]!),
                FlashyTabBarItem(icon: Icon(Icons.favorite), title: Text('Favorilerim'), activeColor: Colors.green, inactiveColor: Colors.green[100]!),
                FlashyTabBarItem(icon: Icon(Icons.person), title: Text('Profilim'), activeColor: Colors.green, inactiveColor: Colors.green[100]!),
              ],
            ),
            body: pages[currentUserBottomIndex],
          );
        });
  }
}
