import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/auth_status.dart';
import 'package:hali_saha_bak/models/responses/get_user_response.dart';
import 'package:hali_saha_bak/providers/user_provider.dart';
import 'package:hali_saha_bak/screens/Auth/ChooseType/choose_type_screen.dart';
import 'package:hali_saha_bak/screens/Global/no_internet.dart';
import 'package:hali_saha_bak/screens/Hs/HsBottomNavBar/hs_bottom_nav_bar.dart';
import 'package:hali_saha_bak/services/auth_service.dart';
import 'package:hali_saha_bak/services/firestore_service.dart';
import 'package:hali_saha_bak/services/shared_prefs_service.dart';
import 'package:hali_saha_bak/utilities/my_snackbar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:new_version/new_version.dart';
import 'package:provider/provider.dart';

import '../../../utilities/globals.dart';
import '../../User/BottomNavBar/user_bottom_nav_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void init() {
    NewVersion newVersion = NewVersion(
      androidId: 'com.falcon.halisahabak',
      iOSId: 'com.falcon.halisahabak',
    );
    newVersion.showAlertIfNecessary(context: context);
  }

  Future<void> navigate() async {
    await Future.delayed(const Duration(seconds: 1));

    initializeDateFormatting('tr');

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

    User? user = AuthService().getUser();

    if (user == null) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ChooseTypeScreen()), (route) => false);
      userProvider.setAuthStatus(AuthStatus.notLoggedIn);
      return;
    }

    String? userType = await SharedPrefsService().getUserType();

    GetUserResponse getUserResponse = await FirestoreService().getUser(hsUser: userType == 'hs_user');

    if (!getUserResponse.isSuccessful) {
      MySnackbar.show(context, message: getUserResponse.message);
      await AuthService().logout();
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ChooseTypeScreen()), (route) => false);
      return;
    }

    if (getUserResponse.hsUser!) {
      userProvider.setHsUserModel(getUserResponse.user);
      userProvider.setAuthStatus(AuthStatus.loggedIn);

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HsBottomNavBar()), (route) => false);
    } else {
      userProvider.setUserModel(getUserResponse.user);
      userProvider.setAuthStatus(AuthStatus.loggedIn);

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const UserBottomNavBar()), (route) => false);
    }
  }

  void notificationListener() {
    FirebaseMessaging.instance.subscribeToTopic('topics-all');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      // MySnackbar.show(snackbarKey.currentState!.context, message: 'Got a message whilst in the foreground!');

      SnackBar snackBar = SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${message.data['title']}'),
            Text('${message.data['body']}'),
          ],
        ),
        // padding: EdgeInsets.only(
        //   bottom: MediaQuery.of(snackbarKey.currentState!.context).size.height - 10,
        // ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.only(bottom: 20, right: 20, left: 20),
      );

      snackbarKey.currentState!.clearSnackBars();

      snackbarKey.currentState?.showSnackBar(snackBar);

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    connectivityCheck().then((value) {
      if (value) {
        init();
        notificationListener();
        navigate();
      }
    });
  }

  Future<bool> connectivityCheck() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => NoInternet()), (val) => false);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Image.asset('assets/images/pitch.png'),
        ),
      ),
    );
  }
}
