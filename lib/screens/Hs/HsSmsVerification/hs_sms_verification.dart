
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/users/hs_user_model.dart';
import 'package:hali_saha_bak/providers/hali_saha_provider.dart';
import 'package:hali_saha_bak/providers/user_hali_saha_provider.dart';
import 'package:hali_saha_bak/screens/Hs/HsBottomNavBar/hs_bottom_nav_bar.dart';
import 'package:hali_saha_bak/services/sms_service.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';

import '../../../models/reservation.dart';
import '../../../models/users/user_model.dart';
import '../../../providers/user_provider.dart';
import '../../../services/email_service.dart';
import '../../../services/firestore_service.dart';
import '../../../theme/colors.dart';
import '../../../utilities/my_snackbar.dart';
import '../../../widgets/my_app_bar.dart';
import '../../../widgets/my_button.dart';
import '../../../widgets/my_list_tile.dart';
import '../../User/BottomNavBar/user_bottom_nav_bar.dart';
 

class UserHsUserSmsVerification extends StatefulWidget {

  const UserHsUserSmsVerification({
    Key? key,
  }) : super(key: key);


  @override
  State<UserHsUserSmsVerification> createState() => _UserHsUserSmsVerificationState();
}

class _UserHsUserSmsVerificationState extends State<UserHsUserSmsVerification> {
  TextEditingController phoneController = TextEditingController();
  bool sent = false;
  String code = '';

  @override
  void initState() {
    super.initState();
    getPhone();
  }

  void getPhone() {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    HsUserModel? userModel = userProvider.hsUserModel;
    print(userModel?.phone.toString());
    if (userModel != null) {
      phoneController.text = userModel.phone;
    }
  }
  void verify() {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    HsUserModel? hsUserModel = userProvider.hsUserModel;
    FirestoreService().updateHsUserSmsStatus(hsUserModel!.uid.toString());
    hsUserModel.smsVerified = true;
    userProvider.setHsUserModel(hsUserModel);
 EmailService().sendEmail(
          email: '${hsUserModel.email}',
          name: 'Halı Saha Bak',
          subject: 'Halı Saha Bak Dünyasına Hoş Geldiniz',
          content: 'Halı Saha Bak Dünyasına Hoş Geldiniz.İlk Rezervasyonunu Almak İçin Hemen Bir Halı Saha Ekle.Telefonla arayan Müşterilerini Sisteme Eklemeyi Unutma  🤗🤗'
          );

  }
  Future<String> sendHsUserSmsVerification() async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    String code = randomNumeric(5);
    UserModel? userModel = userProvider.userModel;
    await SmsService().send(number: userModel!.phone, text: 'Halı Saha Bak SMS Doğrulama Kodunuz: $code');
    return code;
  }
  Future<void> sendSms() async {
    code = randomNumeric(6);
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    HsUserModel? hsUserModel = userProvider.hsUserModel;
    await SmsService().send(number: hsUserModel!.phone, text: 'Halı Saha Bak SMS Doğrulama Kodunuz: $code');
    sent = true;

    setState(() { });


  }





  @override
  Widget build(BuildContext context) {

    return MaterialApp(
     themeMode: ThemeMode.light,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                MyAppBar(title: 'SMS Doğrulaması', showBackButton: false),
                SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 75,),
                        Image.asset(
                          'assets/images/sms.png',
                          height: 200,
                        ),
                        SizedBox(height: 100,),
                        MyListTile(
                          child: Row(
                            children: [
                              Expanded(
                                child: InternationalPhoneNumberInput(
                                  isEnabled: false,
                                  selectorConfig: SelectorConfig(
                                    selectorType: PhoneInputSelectorType.DIALOG,
                                  ),
                                  spaceBetweenSelectorAndTextField: 0,
                                  inputDecoration: InputDecoration(
                                    hintText: '5XX',
                                    isDense: true,
                                    prefixStyle: TextStyle(color: MyColors.red),
                                    contentPadding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                    fillColor: MyColors.lightGrey,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                  ),
                                  onInputChanged: (val) {

                                  },
                                  locale: 'TR',
                                  errorMessage: 'Hatalı telefon numarası',
                                  textFieldController: phoneController,
                                  initialValue: PhoneNumber(isoCode: 'TR'),
                                ),
                              ),
                              if (!sent) ...[
                                SizedBox(width: 10),
                                SizedBox(
                                  width: 100,
                                  height: 40,
                                  child: MyButton(
                                    text: 'Gönder',
                                    onPressed: sendSms,
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        if (sent)
                          MyListTile(
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                Text('Telefon numaranıza gelen 6 haneli kodu giriniz.'),
                                SizedBox(height: 10),
                                Pinput(
                                  length: 6,
                                  controller: TextEditingController(),
                                  defaultPinTheme: PinTheme(
                                    width: 56,
                                    height: 56,
                                    textStyle: TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
                                    decoration: BoxDecoration(
                                      color: MyColors.lightGrey,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  submittedPinTheme: PinTheme(
                                    width: 56,
                                    height: 56,
                                    textStyle: TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
                                    decoration: BoxDecoration(
                                      color: MyColors.lightGrey,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    if (val.length == 6) {
                                      if (code.length == 6 && val == code) {
                                        verify();
                                        UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
                                        HsUserModel? hsUserModel = userProvider.hsUserModel;
                                        hsUserModel?.smsVerified=true;
                                        //Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HsBottomNavBar()), (route) => false);
                                      Navigator.pop(context);
                                      } else {
                                        MySnackbar.show(context, message: 'Doğrulama kodu hatalı');
                                      }
                                    }
                                  },
                                ),
                                SizedBox(height: 10),
                                MyListTile(
                                  child: Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Text('Kod Gelmedi mi ?',
                                        style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(height: 10,),
                                      TextButton(
                                          onPressed: () async {
                                            sendSms();
                                            MySnackbar.show(context, message: 'Telefon numaranıza Yeni bir Kod Gönderildi');
                                          },
                                          child: Text('Tekrar gönder')),
                                      SizedBox(height: 25),

                                    ],
                                  ),
                                ),
                              ],
                            ),
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
    );
  }
}
