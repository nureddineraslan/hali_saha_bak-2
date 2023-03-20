import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hali_saha_bak/models/il_ilce_model.dart';
import 'package:hali_saha_bak/models/users/user_model.dart';
import 'package:hali_saha_bak/providers/user_hali_saha_provider.dart';
import 'package:hali_saha_bak/services/firestore_service.dart';
import 'package:hali_saha_bak/utilities/text_input_formatters.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';
import 'package:hali_saha_bak/widgets/my_textfield.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import '../../../services/shared_prefs_service.dart';
import '../../../utilities/my_snackbar.dart';
import '../../../widgets/forgot_password_widget.dart';
import '../../Global/select_city_screen.dart';
import '../../Global/select_district_screen.dart';

class UserEditProfile extends StatefulWidget {
  const UserEditProfile({Key? key}) : super(key: key);

  @override
  State<UserEditProfile> createState() => _UserEditProfileState();
}

class _UserEditProfileState extends State<UserEditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController districtController = TextEditingController();

  bool cityDataLoaded = false;

  Il? selectedCity;
  Ilce? selectedDistrict;

  final formKey = GlobalKey<FormState>();
  Future<void> update() async {
    UserModel userModel = setUserModel();
    await FirestoreService().updateUserModel(userModel: userModel);
    FirestoreService().updateUserSmsStatus(userModel.uid.toString());
    userModel.smsVerified = true;
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userModel.district != userProvider.userModel!.district) {
      UserHaliSahaProvider userHaliSahaProvider = Provider.of<UserHaliSahaProvider>(context, listen: false);
      userHaliSahaProvider.getHaliSahasByDistrict(district: userModel.district, force: true,city: userModel.city);
    }

    userProvider.setUserModel(userModel);

    await SharedPrefsService().setUserType('user');

    print("KAyıt Güncellendi");
    Navigator.pop(context);
  }

  /*
  Future<void> update() async {
   UserModel userModel = setUserModel();
 await FirestoreService().updateUserModel(userModel: userModel);



   UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

   if (userModel.district != userProvider.userModel!.district) {
     UserHaliSahaProvider userHaliSahaProvider = Provider.of<UserHaliSahaProvider>(context, listen: false);
     userHaliSahaProvider.getHaliSahasByDistrict(district: userModel.district, force: true);
     FirestoreService().updateUserSmsStatus(userModel!.uid.toString());

   userProvider.setUserModel(userModel);

   await SharedPrefsService().setUserType('user');

   Navigator.pop(context);
   print("güncellendi");
 }

return;

 // UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

 // if (userModel.district != userProvider.userModel!.district) {
 //   UserHaliSahaProvider userHaliSahaProvider = Provider.of<UserHaliSahaProvider>(context, listen: false);
 //   userHaliSahaProvider.getHaliSahasByDistrict(district: userModel.district, force: true);
 // }

 // userProvider.setUserModel(userModel);

 // await SharedPrefsService().setUserType('user');

 // Navigator.pop(context);
 // print("güncellendi");
  }*/

  UserModel setUserModel() {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    UserModel hsUserModel = UserModel(
      fullName: nameController.text,
      phone: phoneController.text,
      email: emailController.text,
      city: cityController.text,
      district: districtController.text,
      uid: userProvider.userModel!.uid,
      reservations: userProvider.userModel!.reservations,
      favorites: userProvider.userModel!.favorites,
      profilePicUrl: userProvider.userModel!.profilePicUrl,
      fcmToken: userProvider.userModel!.fcmToken,
    );

    return hsUserModel;
  }

  Future<void> setUser() async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    UserModel userModel = userProvider.userModel!;
    nameController.text = userModel.fullName;
    phoneController.text = userModel.phone;
    emailController.text = userModel.email;
    cityController.text = userModel.city;
    districtController.text = userModel.district;

    String jsonString = await rootBundle.loadString('assets/json/il-ilce.json');

    final dynamic jsonResponse = json.decode(jsonString);

    List cities = jsonResponse.map((x) => Il.fromJson(x)).toList();

    selectedCity = cities.where((element) => element.ilAdi == userModel.city).first;
  }

  @override
  void initState() {
    super.initState();
    setUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilimi Düzenle'),
      ),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          allowNumbers,
                          denyCharacters,
                        ],
                        hintText: '05XX',
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
                        title: 'E-posta (değiştirilemez)',
                        hintText: 'E-posta giriniz.',
                        readOnly: true,
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
                    ],
                  ),
                ),
              ),
              const ForgotPasswordWidget(),
              const SizedBox(height: 20),
              MyButton(
                text: 'GÜNCELLE',
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tüm alanları doldurunuz.')));
                    return;
                  }
                  update();

                //  Navigator.pop(context);
                },
              ),
              SizedBox(height: MediaQuery.of(context).viewPadding.bottom * 2)
            ],
          ),
        ),
      ),
    );
  }
}
