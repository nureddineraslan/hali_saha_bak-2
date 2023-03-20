import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/models/responses/get_user_response.dart';
import 'package:hali_saha_bak/providers/hali_saha_provider.dart';
import 'package:hali_saha_bak/screens/Hs/CreateHaliSaha/create_hali_saha.dart';
import 'package:hali_saha_bak/services/firestore_service.dart';
import 'package:hali_saha_bak/widgets/hali_saha_duzenle.dart';
import 'package:provider/provider.dart';

import '../../../models/users/hs_user_model.dart';
import '../../../providers/user_provider.dart';
import '../../../services/auth_service.dart';
import '../../../utilities/my_snackbar.dart';
import '../../../widgets/hali_saha_widget.dart';
import '../../../widgets/my_button.dart';
import '../../Auth/Splash/splash_screen.dart';

class MyHaliSahasTwo extends StatefulWidget {
  const MyHaliSahasTwo({Key? key}) : super(key: key);

  @override
  State<MyHaliSahasTwo> createState() => _MyHaliSahasTwoState();
}

class _MyHaliSahasTwoState extends State<MyHaliSahasTwo> {
  User? user;

  void getHaliSahasByDistrict() {
    HaliSahaProvider haliSahaProvider = Provider.of<HaliSahaProvider>(context, listen: false);
    haliSahaProvider.getMyHaliSahas();
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
    HaliSahaProvider haliSahaProvider = Provider.of<HaliSahaProvider>(context);
    List<HaliSaha> myHaliSahas = haliSahaProvider.myHaliSahas;
    HsUserModel? hsUserModel = userProvider.hsUserModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saha Seçin'),
      ),
      body: SafeArea(
        child: Builder(builder: (context) {
          if (hsUserModel == null) {
            return buildNullUserScreen();
          }
          if (!hsUserModel.verified) {
            return buildNotVerifiedScreen(context);
          }
          if (!haliSahaProvider.myHaliSahasGet) {
            return const Center(child: CircularProgressIndicator());
          }
          if (myHaliSahas.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Daha önce eklenmiş bir halı sahanız bulunmamakta.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  MyButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateHaliSaha()));
                    },
                    text: 'Halı Saha Ekle',
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  ListView.builder(
                    itemCount: myHaliSahas.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      HaliSaha haliSaha = myHaliSahas[index];
                      return HaliSahaWidgetTwo(
                        haliSaha: haliSaha,
                        isHaliSaha: true,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Center buildNullUserScreen() {
    return const Center(
      child: Text('Hata Oluştu. Lütfen tekrar deneyiniz.'),
    );
  }

  Column buildVerifyEmailScreen(BuildContext context) {
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
            text: 'Tekrar gönder',
            onPressed: () async {
              await AuthService().sendEmailVerification();
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

  Column buildNotVerifiedScreen(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    HaliSahaProvider haliSahaProvider = Provider.of<HaliSahaProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: Text(
            'Devam edebilmeniz için hesabınızın onaylanmasını bekleyiniz',
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: MyButton(
            text: 'Kontrol et',
            onPressed: () async {
              GetUserResponse getUserResponse = await FirestoreService().getUser(hsUser: true);
              if (getUserResponse.isSuccessful) {
                userProvider.hsUserModel = getUserResponse.user;
              }
              if (!userProvider.hsUserModel!.verified) {
                MySnackbar.show(context, message: 'Hesabınız onaylanmamış.');
              } else {
                haliSahaProvider.getMyHaliSahas();
              }
              setState(() {});
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
}
