import 'package:flutter/material.dart';
import 'package:hali_saha_bak/screens/Guest/select_city_district.dart';
import 'package:hali_saha_bak/screens/Hs/Login/hs_login_screen.dart';
import 'package:hali_saha_bak/screens/User/Login/user_login_screen.dart';

import '../../../widgets/my_button.dart';

class ChooseTypeScreen extends StatefulWidget {
  const ChooseTypeScreen({Key? key}) : super(key: key);

  @override
  State<ChooseTypeScreen> createState() => _ChooseTypeScreenState();
}

class _ChooseTypeScreenState extends State<ChooseTypeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
            SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              'assets/images/background2.png',
              fit: BoxFit.fitWidth,
            ),
          ), 
         /*  ClipRect(
            child: Container(
              height: 450,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(80),
                color: Colors.yellow,
              ),
              child: Image.asset('assets/images/background.png',
                  fit: BoxFit.fitWidth),
            ),
          ), */
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                const Text(
                  'Hoşgeldiniz.',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                MyButton(
                  text: 'Halı Saha Yönetimi Girişi',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HsLoginScreen()));
                  },
                ),
                const SizedBox(height: 20),
                MyButton(
                  text: 'Kullanıcı Girişi',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserLoginScreen()));
                  },
                ),
                const SizedBox(height: 20),
                MyButton(
                  text: 'Misafir Girişi',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SelectCityDistrict()));
                  },
                ),
                SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
