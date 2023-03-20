import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/responses/auth_response.dart';
import 'package:hali_saha_bak/models/il_ilce_model.dart';
import 'package:hali_saha_bak/models/users/user_model.dart';
import 'package:hali_saha_bak/screens/User/BottomNavBar/user_bottom_nav_bar.dart';
import 'package:hali_saha_bak/screens/User/UserSmsVerification/user_sms_verification.dart';
import 'package:hali_saha_bak/services/auth_service.dart';
import 'package:hali_saha_bak/services/shared_prefs_service.dart';
import 'package:hali_saha_bak/utilities/extensions.dart';
import 'package:hali_saha_bak/utilities/text_input_formatters.dart';
import 'package:hali_saha_bak/widgets/blurred_progress_indicator.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';
import 'package:hali_saha_bak/widgets/my_textfield.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';
import '../../../utilities/my_snackbar.dart';
import '../../Global/select_city_screen.dart';
import '../../Global/select_district_screen.dart';
import '../EmailVerification/user_email_verification.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({Key? key}) : super(key: key);

  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  TextEditingController nameController =  TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController password2Controller = TextEditingController();

  bool cityDataLoaded = false;
  bool isLoading=false;

  Il? selectedCity;
  Ilce? selectedDistrict;

  final formKey = GlobalKey<FormState>();

  Future<void> register() async {
    UserModel userModel = await setUserModel();

    AuthResponse authResponse = await AuthService().userRegister(
      userModel: userModel,
      password: passwordController.text,

    );

    print('authResponse.isSuccessful: ${authResponse.isSuccessful}');
    print('authResponse.message: ${authResponse.message}');
    if (!authResponse.isSuccessful) {
      MySnackbar.show(context, message: authResponse.message);
      return;
    }
if(authResponse.isSuccessful){
  showDialog(
    context: context,
    builder: (context) => CircularProgressIndicator()
  );
   
  UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
  userProvider.setUserModel(userModel);
  await SharedPrefsService().setUserType('user');
  Center(child: CircularProgressIndicator());
  MySnackbar.show(context, message: 'Başarılı bir şekilde kayıt oluşturuldu, id : ${authResponse.user!.uid}');
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => UserBottomNavBar()), (route) => false);

}
    String code = await AuthService().sendEmailVerification();


  }

  Future<UserModel> setUserModel() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    UserModel hsUserModel = UserModel(
      fullName: nameController.text,
      phone: phoneController.text,
      email: emailController.text,
      city: cityController.text,
      district: districtController.text,
      reservations: [],
      favorites: [],
      fcmToken: await firebaseMessaging.getToken() ?? '',
      emailVerified: false,
    );

    return hsUserModel;
  }
  var scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          key: scaffoldKey,
          appBar: AppBar(),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary, borderRadius: BorderRadius.circular(12)),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Center(
                            child: Text(
                              'Kaydol',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20),
                          MyTextfield(
                            controller: nameController,
                            title: 'Ad Soyad',
                            inputFormatters: [
                              denyNumbers,
                            ],
                            keyboardType: TextInputType.name,
                            hintText: 'Ad soyad giriniz.',
                            validator: (val) {
                              if (val!.length < 3) {
                                return 'Lütfen geçerli bir ad soyad giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          MyTextfield(
                            controller: phoneController,
                            title: 'Telefon numarası',
                            maxLength: 11,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              allowNumbers,
                              denyCharacters,
                            ],
                            hintText: '05XX',
                            validator: (val) {
                              if (val!.length < 10) {
                                return 'Lütfen geçerli Telefon No giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          MyTextfield(
                            controller: emailController,
                            title: 'E-posta',
                            hintText: 'E-posta giriniz.',
                            validator: (val) {
                              if (val!.length < 5) {
                                return 'Lütfen geçerli bir e-posta giriniz\nBoşluk Bırakmadığınızdan Emin olunuz.';
                              }
                              if (!val.isValidEmail()) {
                                return 'Lütfen geçerli bir e-posta giriniz\nBoşluk Bırakmadığınızdan Emin olunuz.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          MyTextfield(
                            controller: cityController,
                            onTap: () async {
                              Il? newSelectedCity =
                                  await Navigator.push(context, MaterialPageRoute(builder: (context) => SelectCityScreen(selectedCity: selectedCity)));

                              if (newSelectedCity != null) {
                                if (selectedCity != null && newSelectedCity.ilAdi != selectedCity!.ilAdi) {
                                  selectedDistrict = null;
                                  districtController.clear();
                                }
                                setState(() {
                                  selectedCity = newSelectedCity;
                                  cityController.text = newSelectedCity.ilAdi;
                                });
                              }
                            },
                            readOnly: true,
                            title: 'Şehir',
                            hintText: 'Şehir seçiniz.',
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Lütfen geçerli bir şehir giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          MyTextfield(
                            controller: districtController,
                            onTap: () async {
                              if (selectedCity == null) {
                                return;
                              }
                              Ilce? newSelectedDistrict = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SelectDistrictScreen(
                                    selectedCity: selectedCity!,
                                    selectedDistrict: selectedDistrict,
                                  ),
                                ),
                              );

                              if (newSelectedDistrict != null) {
                                setState(() {
                                  selectedDistrict = newSelectedDistrict;
                                  districtController.text = newSelectedDistrict.ilceAdi;
                                });
                              }
                            },
                            readOnly: true,
                            title: 'İlçe',
                            hintText: 'İlçe seçiniz.',
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Lütfen geçerli bir ilçe giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          MyTextfield(
                            controller: passwordController,
                            obscureText: true,
                            title: 'Şifre',
                            hintText: 'Şifre giriniz.',
                            validator: (val) {
                              if (val!.length < 5) {
                                return 'Şifre en az 6 karakter olmalıdır.';
                              }
                              if (val != password2Controller.text) {
                                return 'Şifreler uyuşmuyor';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          MyTextfield(
                            controller: password2Controller,
                            obscureText: true,
                            title: 'Şifre Onay',
                            hintText: 'Şifre giriniz.',
                            validator: (val) {
                              if (val!.length < 5) {
                                return 'Şifre en az 6 karakter olmalıdır.';
                              }
                              if (val != passwordController.text) {
                                return 'Şifreler uyuşmuyor';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  MyButton(
                    text: 'KAYDOL',
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tüm alanları doldurunuz.')));
                        return;
                      }
                      if (formKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          builder: (context) => Center(child: BlurredProgressIndicator(show: true,))
                        );
                        await register();
                      }
                  },
                  ),
                  SizedBox(height: MediaQuery.of(context).viewPadding.bottom * 2)
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
