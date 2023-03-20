
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/screens/User/Home/user_home_screen.dart';
import 'package:hali_saha_bak/screens/User/UserSmsVerification/sms_Verif_Two.dart';
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

class UserSmsVerification extends StatefulWidget {

  const UserSmsVerification({
    Key? key,
  }) : super(key: key);


  @override
  State<UserSmsVerification> createState() => _UserSmsVerificationState();
}

class _UserSmsVerificationState extends State<UserSmsVerification> {
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
    UserModel? userModel = userProvider.userModel;
    if (userModel != null) {
      phoneController.text = userModel.phone;
    }
  }
  void verify() {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    UserModel? userModel = userProvider.userModel;
 FirestoreService().updateUserSmsStatus(userModel!.uid.toString());
    userModel.smsVerified = true;
    userProvider.setUserModel(userModel);
     EmailService().sendEmail(
          email: '${userModel.email}',
          name: 'Halı Saha Bak',
          subject: 'Halı Saha Bak Dünyasına Hoş Geldiniz',
          content: 'Halı Saha Bak Dünyasına Hoş Geldiniz.İlk Rezervasyonunu Yapabilmek için Sabırsızlanıyoruz 🤗🤗'
          );
  }

  Future<void> sendSms() async {
    code = randomNumeric(6);
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    UserModel? userModel = userProvider.userModel;
    await SmsService().send(number: userModel!.phone, text: 'Halı Saha Bak SMS Doğrulama Kodunuz: $code');
    sent = true;
    userModel.smsVerified=true;
    setState(() {userModel.smsVerified=true;});
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
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(

                children: [
                  MyAppBar(title: 'SMS Doğrulaması', showBackButton: false),
                  Expanded(

                    child: SingleChildScrollView(
                      child: Column(

                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [
                          MyListTile(
                            child: Column(
                              children: [
                                Container(
                                  padding:EdgeInsets.all(40) ,
                                  child: Image.asset(
                                    'assets/images/sms.png',
                                    height: 240,
                                  ),
                                ),
                                SizedBox(height: 40,),
                                MyListTile(
                                    child: Center(child: Text("Telefonunuza 6 Haneli Kod Gönderin",style: TextStyle(fontWeight: FontWeight.w700,fontSize: 16),))
                                ),
                                SizedBox(height: 20,),
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
                                            onPressed:()
                                            async {
                                              sendSms();
                                         //  GetUserResponse getUserResponse = await FirestoreService().getUser(hsUser: false);
                                         //  if (getUserResponse.isSuccessful) {
                                         //    userProvider.userModel = getUserResponse.user;
                                         //  }
                                         //  if (!userProvider.userModel!.smsVerified) {

                                         //    print("çalıştı");
                                         //  } else {
                                         //    haliSahaProvider.getMyHaliSahas();
                                         //    print("Not working");
                                         //  }
                                         //  setState(() {});
                                            //  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => UserSmsVerificationTwo()), (route) => false);
                                                },
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
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
                                         //  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => UserBottomNavBar()), (route) => false);
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

            SizedBox()


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


    );
  }

}
