import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/screens/Auth/Splash/splash_screen.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';

class NoInternet extends StatefulWidget {
  const NoInternet({Key? key}) : super(key: key);

  @override
  State<NoInternet> createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  @override
  Widget build(BuildContext context) {
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: MyButton(
              text: 'Yeniden Dene',
              onPressed: () async {
                ConnectivityResult result = await Connectivity().checkConnectivity();
                if (result != ConnectivityResult.none) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SplashScreen()), (val) => false);
                }
              },
            ),
          )
        ],
      )),
    );
  }
}
