import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/responses/auth_response.dart';
import 'package:hali_saha_bak/models/users/hs_user_model.dart';
import 'package:hali_saha_bak/models/il_ilce_model.dart';
import 'package:hali_saha_bak/screens/Hs/EmailVerification/hs_email_verification.dart';
import 'package:hali_saha_bak/screens/Hs/HsBottomNavBar/hs_bottom_nav_bar.dart';
import 'package:hali_saha_bak/screens/Hs/HsSmsVerification/hs_sms_verification.dart';
import 'package:hali_saha_bak/services/api_service.dart';
import 'package:hali_saha_bak/services/auth_service.dart';
import 'package:hali_saha_bak/services/sms_service.dart';
import 'package:hali_saha_bak/utilities/extensions.dart';
import 'package:hali_saha_bak/utilities/text_input_formatters.dart';
import 'package:hali_saha_bak/widgets/blurred_progress_indicator.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';
import 'package:hali_saha_bak/widgets/my_textfield.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';

import '../../../providers/user_provider.dart';
import '../../../services/shared_prefs_service.dart';
import '../../../utilities/my_snackbar.dart';
import '../../Global/select_city_screen.dart';
import '../../Global/select_district_screen.dart';
import 'package:iban/iban.dart';

class HsRegisterScreen extends StatefulWidget {
  const HsRegisterScreen({Key? key}) : super(key: key);

  @override
  State<HsRegisterScreen> createState() => _HsRegisterScreenState();
}

class _HsRegisterScreenState extends State<HsRegisterScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController businessNameController = TextEditingController();
  TextEditingController taxNumberController = TextEditingController();
  TextEditingController taxOfficeController = TextEditingController();
  TextEditingController ibanController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController neighborhoodController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController password2Controller = TextEditingController();
  TextEditingController adressController = TextEditingController();

  Il? selectedCity;
  Ilce? selectedDistrict;
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();

  Future<void> register() async {
    HsUserModel hsUserModel = await setHsUserModel();

    Map result = await ApiService().createHaliSaha(
      id: hsUserModel.hs_id!,
      adress: adressController.text,
      taxOffice: taxOfficeController.text,
      taxNumber: taxNumberController.text,
      companyName: nameController.text,
      companyEmail: emailController.text,
      companyIban: ibanController.text.replaceAll(' ', ''),
      companyType: 'person',
    );

    if (result['status'] == 'error') {
      MySnackbar.show(context, message: result['response']);
    } else {
      print(result);

      try {
        String hsPaymentId = result['response'];
        hsUserModel.hsPaymentId = hsPaymentId;
      } catch (e) {}
      MySnackbar.show(context, message: 'Kayıt başarılı');
    }

    AuthResponse authResponse = await AuthService().hsRegister(
      hsUserModel: hsUserModel,
      password: passwordController.text,
    );

    if (!authResponse.isSuccessful) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Hata'),
          content: Text(authResponse.message),
          actions: [
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      );
      return;
    }
    if (authResponse.isSuccessful) {
      isLoading = true;
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      userProvider.setHsUserModel(hsUserModel);
      await SharedPrefsService().setUserType('hs_user');

      SmsService().send(
          number: '05438755396',
          text:
              '-Yeni Tesis Bildirimi- \n\n${hsUserModel.businessName} adlı yeni tesis hesabı oluşturuldu.\n\nHsUser Id:${hsUserModel.uid}');

      MySnackbar.show(context,
          message:
              'Başarılı bir şekilde kayıt oluşturuldu, id : ${authResponse.user!.uid}');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HsBottomNavBar()),
          (route) => false);
    }

    String code = await AuthService().sendEmailVerification();
  }

  Future<HsUserModel> setHsUserModel() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    HsUserModel hsUserModel = HsUserModel(
      hs_id: randomNumeric(6),
      name: nameController.text,
      businessName: businessNameController.text,
      taxNumber: taxNumberController.text,
      phone: phoneController.text,
      email: emailController.text,
      city: cityController.text,
      district: districtController.text,
      neighborhood: neighborhoodController.text,
      verified: false,
      fcmToken: await firebaseMessaging.getToken() ?? '',
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
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSecondary,
                        borderRadius: BorderRadius.circular(12)),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Center(
                            child: Text(
                              'Kaydol',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20),
                          MyTextfield(
                            controller: nameController,
                            title: 'Halı Saha Sahibi Adı Soyadı',
                            hintText: 'Ad soyad giriniz.',
                            keyboardType: TextInputType.name,
                            inputFormatters: [
                              denyNumbers,
                            ],
                            validator: (val) {
                              if (val!.length < 3) {
                                return 'Lütfen geçerli bir ad soyad giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          MyTextfield(
                            controller: businessNameController,
                            title: 'İşletme Adı(değiştirilemez)',
                            hintText: 'İşletme adı giriniz.',
                            validator: (val) {
                              if (val!.length < 3) {
                                return 'Lütfen geçerli bir işletme adı giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          MyTextfield(
                            controller: taxNumberController,
                            title: 'Vergi Numarası',
                            keyboardType: TextInputType.number,
                            inputFormatters: [allowNumbers, denyCharacters],
                            hintText: 'Vergi numarası giriniz.',
                            maxLength: 11,
                            validator: (val) {
                              if (val!.length != 11) {
                                return 'Lütfen geçerli bir vergi numarası giriniz.Sonuna 0 ekleyiniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          MyTextfield(
                            controller: ibanController,
                            title: 'IBAN',
                            hintText: 'IBAN GİRİNİZ',
                            maxLines: 1,
                            validator: (val) {
                              if (val! == null) {
                                return 'Lütfen geçerli bir IBAN giriniz';
                              }
                              if (!isValid(val.replaceAll(
                                ' ',
                                '',
                              ))) {
                                return 'Lütfen geçerli bir iban giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          MyTextfield(
                            controller: taxOfficeController,
                            title: 'Vergi Dairesi',
                            hintText: 'Vergi Dairesi giriniz.',
                            validator: (val) {
                              if (val!.length < 5) {
                                return 'Lütfen geçerli bir Vergi Dairesi giriniz';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.name,
                            inputFormatters: [
                              denyNumbers,
                            ],
                          ),
                          const SizedBox(height: 20),
                          MyTextfield(
                            controller: phoneController,
                            title: 'Telefon numarası',
                            maxLength: 11,
                            hintText: '05XX',
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              allowNumbers,
                              denyCharacters,
                            ],
                            validator: (val) {
                              if (val!.length < 3) {
                                return 'Lütfen geçerli bir ad soyad giriniz';
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
                                return 'Lütfen geçerli bir e-posta giriniz';
                              }
                              if (!val.isValidEmail() && val.contains(' ')) {
                                return 'Geçersiz E posta Formatı\nVe lütfen boşluk tuşuna basmadığınızdan emin olun';
                              }
                              /* if () {
                                return 'Lütfen Boşluk Bırakmayınız';
                              }*/
                              return null;
                            },
                          ),
                          const SizedBox(height: 25),
                          MyTextfield(
                            controller: cityController,
                            onTap: () async {
                              Il? newSelectedCity = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SelectCityScreen(
                                          selectedCity: selectedCity)));

                              if (newSelectedCity != null) {
                                if (selectedCity != null &&
                                    newSelectedCity.ilAdi !=
                                        selectedCity!.ilAdi) {
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
                                  districtController.text =
                                      newSelectedDistrict.ilceAdi;
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
                            controller: neighborhoodController,
                            title: 'Mahalle',
                            hintText: 'Mahalle giriniz.',
                            validator: (val) {
                              if (val!.length < 5) {
                                return 'Lütfen geçerli bir mahalle giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          MyTextfield(
                            controller: adressController,
                            title: 'Adres',
                            hintText: 'Adres giriniz.',
                            validator: (val) {
                              if (val!.length < 5) {
                                return 'Lütfen geçerli bir adres giriniz.';
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
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Tüm alanları doldurunuz.')));
                        return;
                      }
                      if (formKey.currentState!.validate()) {
                        showDialog(
                            context: context,
                            builder: (context) => Center(
                                    child: BlurredProgressIndicator(
                                  show: true,
                                )));
                        await register();
                      }
                    },
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).viewPadding.bottom * 2)
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
