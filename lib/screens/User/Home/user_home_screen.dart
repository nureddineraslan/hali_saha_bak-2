import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/providers/user_hali_saha_provider.dart';
import 'package:hali_saha_bak/providers/user_provider.dart';
import 'package:hali_saha_bak/screens/Auth/Splash/splash_screen.dart';
import 'package:hali_saha_bak/screens/User/BottomNavBar/user_bottom_nav_bar.dart';
import 'package:hali_saha_bak/services/auth_service.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';

import '../../../models/responses/get_user_response.dart';
import '../../../models/users/hs_user_model.dart';
import '../../../models/users/user_model.dart';
import '../../../providers/hali_saha_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../services/sms_service.dart';
import '../../../utilities/my_snackbar.dart';
import '../../../widgets/hali_saha_widget.dart';
import '../../Hs/HsSmsVerification/hs_sms_verification.dart';
import '../UserSmsVerification/user_sms_verification.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

String code = '';
bool sent = false;

class _UserHomeScreenState extends State<UserHomeScreen> {
  User? user;

  Future<void> getHaliSahasByDistrict({bool force = false}) async {
    UserHaliSahaProvider userHaliSahaProvider = Provider.of<UserHaliSahaProvider>(context, listen: false);
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    await userHaliSahaProvider.getHaliSahasByDistrict(district: userProvider.userModel!.district, force: force,city: userProvider.userModel!.city);
  }

  void verify() {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    UserModel? userModel = userProvider.userModel;
    FirestoreService().updateUserSmsStatus(userModel!.uid.toString());
    userModel.smsVerified = true;
    userProvider.setUserModel(userModel);
  }

  Future<void> sendSms() async {
    code = randomNumeric(6);
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    UserModel? userModel = userProvider.userModel;
    await SmsService().send(number: userModel!.phone, text: 'Halı Saha Bak SMS Doğrulama Kodunuz: $code');
    sent = true;
    userModel.smsVerified = true;
    setState(() {
      userModel.smsVerified = true;
    });
  }

  @override
  void initState() {
    super.initState();
    getHaliSahasByDistrict();
    user = AuthService().getUser();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    UserHaliSahaProvider userHaliSahaProvider = Provider.of<UserHaliSahaProvider>(context);
    List<HaliSaha> haliSahas = userHaliSahaProvider.searched && userHaliSahaProvider.searchController.text.isNotEmpty
        ? userHaliSahaProvider.searchedHaliSahas
        : userHaliSahaProvider.haliSahas;

    UserModel? userModel = userProvider.userModel;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: userHaliSahaProvider.search
            ? TextField(
                controller: userHaliSahaProvider.searchController,
                decoration: InputDecoration(
                  fillColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Halı saha ara',
                ),
                onChanged: (val) {
                  userHaliSahaProvider.searchHaliSahas(val, userProvider.userModel!.city);
                },
              )
            : const Text('Halı Sahalar'),
        actions: [
          if (!userProvider.userModel!.smsVerified == true) ...[],
          if (userProvider.userModel!.smsVerified == true) ...[
            userHaliSahaProvider.search
                ? IconButton(icon: Icon(Icons.clear), onPressed: userHaliSahaProvider.closeSearch)
                : IconButton(onPressed: userHaliSahaProvider.openSearch, icon: Icon(Icons.search)),
          ],
        ],
      ),
      body: Builder(builder: (context) {
        print(userProvider.userModel!.smsVerified);
        if (userProvider.userModel == null) {
          print("1.Sms boş");
          return buildEmailNotVerified(context);
        }
        if (!userModel!.smsVerified == true) {
          return buildSmsNotVerifiedScreen(context);
        }
        if (!userHaliSahaProvider.haliSahasGet) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (haliSahas.length == 0) {
          return Center(
              child: Text(
            'Tesis Bulunamadı\n\nÇok Yakında Bu Lokasyonda Hizmet Vermeye Başlayacağız',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ));
        }
        return Container(
          child: RefreshIndicator(
            onRefresh: () {
              return getHaliSahasByDistrict(force: true);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: haliSahas.length,
                dragStartBehavior: DragStartBehavior.start,
                itemBuilder: (BuildContext context, index) {
                  HaliSaha haliSaha = haliSahas[index];
                  return HaliSahaWidget(
                    haliSaha: haliSaha,
                    isHaliSaha: false,
                  );
                },
              ),
            ),
          ),
        );
      }),
    );
  }

  Column buildEmailNotVerified(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: Text('Devam edebilmek için hesabınızı onaylayınız'),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: MyButton(
            text: 'Kontrol et',
            onPressed: () async {
              await user!.reload();
              setState(() {
                user = AuthService().getUser();
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: MyButton(
            text: 'Çıkış Yap',
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SplashScreen()), (route) => false);
            },
          ),
        )
      ],
    );
  }

  Column buildSmsNotVerifiedScreen(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    HaliSahaProvider haliSahaProvider = Provider.of<HaliSahaProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/smsv.png',
          height: 200,
        ),
        SizedBox(
          height: 50,
        ),
        const Center(
          child: Text(
            'Sms Doğrulaması Yapılmadı',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        const Center(
          child: Text(
            'Devam Edebilmeniz İçin Lütfen Telefon Numaranızı Doğrulayın',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.grey),
          ),
        ),
        SizedBox(
          height: 50,
        ),
        Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                if (ThemeMode != ThemeMode.dark) ...[
                  Card(
                    color: Colors.green.shade100,
                    elevation: 8,
                    child: Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        // color: Colors.blueGrey,
                      ),
                      child: IconButton(
                        icon: (Icon(Icons.arrow_forward)),
                        color: Colors.green,
                        onPressed: () async {
                          HsUserModel? hsUserModel = userProvider.hsUserModel;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserSmsVerification()),
                          );
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ],
            )
            //   MyButton(
            //     text: 'Sms Doğrula',
            //     onPressed: () async {
            //       HsUserModel? hsUserModel = userProvider.hsUserModel;
            //       Navigator.push(context, MaterialPageRoute(builder: (context) => UserSmsVerification()), );
            //       setState(() {

            //       });
            //     },
            //   ),
            ),
      ],
    );
  }
}
