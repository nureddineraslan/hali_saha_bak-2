import 'package:flutter/material.dart';
import 'package:hali_saha_bak/screens/User/Home/user_home_screen.dart';
import 'package:hali_saha_bak/services/firestore_service.dart';
import 'package:hali_saha_bak/services/sms_service.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';

import '../../../models/reservation.dart';
import '../../../models/responses/get_user_response.dart';
import '../../../models/users/user_model.dart';
import '../../../providers/hali_saha_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../services/email_service.dart';
import '../../../theme/colors.dart';
import '../../../utilities/my_snackbar.dart';
import '../../../widgets/my_app_bar.dart';
import '../../../widgets/my_button.dart';
import '../../../widgets/my_list_tile.dart';
import '../BottomNavBar/user_bottom_nav_bar.dart';

class UserSmsVerificationTwo extends StatefulWidget {
  const UserSmsVerificationTwo({
    Key? key,
  }) : super(key: key);

  @override
  State<UserSmsVerificationTwo> createState() => _UserSmsVerificationTwoState();
}

class _UserSmsVerificationTwoState extends State<UserSmsVerificationTwo> {
  TextEditingController phoneController = TextEditingController();
  bool sent = false;
  String code = '';

  @override
  void initState() {
    super.initState();
    getPhone();
  }

  void getPhone() {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    UserModel? userModel = userProvider.userModel;
    if (userModel != null) {
      phoneController.text = userModel.phone;
    }
  }

  Future<void> verify() async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    UserModel? userModel = userProvider.userModel;
    FirestoreService().updateUserSmsStatus(userModel!.uid.toString());
    userModel.smsVerified = true;
    userProvider.setUserModel(userModel);
    setState(() {});

    Map? systemVariables = await FirestoreService().getSystemVariables();

     
      EmailService().sendEmail(
          email: '${userModel.email}',
          name: 'Halı Saha Bak',
          subject: 'Halı Saha Bak Dünyasına Hoş Geldiniz',
          content: 'Halı Saha Bak Dünyasına Hoş Geldiniz.İlk Rezervasyonunu Yapabilmek için Sabırsızlanıyoruz 🤗🤗'
          );
     
  }

  Future<void> sendSms() async {
    code = randomNumeric(6);
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    UserModel? userModel = userProvider.userModel;
    await SmsService().send(
        number: userModel!.phone,
        text: 'Halı Saha Bak SMS Doğrulama Kodunuz: $code');
    sent = true;
    userModel.smsVerified = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    HaliSahaProvider haliSahaProvider = Provider.of<HaliSahaProvider>(context);
    return MaterialApp(
      themeMode: ThemeMode.dark,
      home: Scaffold(
        body: Container(
          color: Colors.white10,
          child: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Wrap(
                  children: [
                    MyAppBar(title: 'SMS Doğrulaması', showBackButton: false),
                    Container(
                      padding: EdgeInsets.only(top: 65),
                      child: Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Image.asset(
                              'assets/images/otp.png',
                              height: 200,
                            ),
                            Column(
                              children: [
                                MyListTile(
                                    child: Center(
                                        child: Text(
                                  'Telefon numaranıza gelen 6 haneli kodu giriniz.',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                ))),
                                SizedBox(
                                  height: 20,
                                ),
                                MyListTile(
                                  child: Column(
                                    children: [
                                      SizedBox(height: 10),
                                      SizedBox(height: 10),
                                      Pinput(
                                        length: 6,
                                        controller: TextEditingController(),
                                        defaultPinTheme: PinTheme(
                                          width: 56,
                                          height: 56,
                                          textStyle: TextStyle(
                                              fontSize: 20,
                                              color:
                                                  Color.fromRGBO(30, 60, 87, 1),
                                              fontWeight: FontWeight.w600),
                                          decoration: BoxDecoration(
                                            color: MyColors.lightGrey,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        submittedPinTheme: PinTheme(
                                          width: 56,
                                          height: 56,
                                          textStyle: TextStyle(
                                              fontSize: 20,
                                              color:
                                                  Color.fromRGBO(30, 60, 87, 1),
                                              fontWeight: FontWeight.w600),
                                          decoration: BoxDecoration(
                                            color: MyColors.lightGrey,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          if (val.length == 6) {
                                            if (code.length == 6 &&
                                                val == code) {
                                              verify();
                                              Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          UserBottomNavBar()),
                                                  (route) => false);
                                            } else {
                                              MySnackbar.show(context,
                                                  message:
                                                      'Doğrulama kodu hatalı');
                                            }
                                          }
                                        },
                                      ),
                                      SizedBox(height: 25),
                                    ],
                                  ),
                                ),
                                MyListTile(
                                  child: Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Text(
                                        'Kod Gelmedi mi ?',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      TextButton(
                                          onPressed: () async {
                                            sendSms();
                                            MySnackbar.show(context,
                                                message:
                                                    'Telefon numaranıza Yeni bir Kod Gönderildi');
                                          },
                                          child: Text('Tekrar gönder')),
                                      SizedBox(height: 25),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
