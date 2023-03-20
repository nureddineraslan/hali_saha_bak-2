import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hali_saha_bak/models/il_ilce_model.dart';
import 'package:hali_saha_bak/models/users/hs_user_model.dart';
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

class HsEditProfile extends StatefulWidget {
  const HsEditProfile({Key? key}) : super(key: key);

  @override
  State<HsEditProfile> createState() => _HsEditProfileState();
}

class _HsEditProfileState extends State<HsEditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController businessNameController = TextEditingController();
  TextEditingController taxController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController neighborhoodController = TextEditingController();

  bool cityDataLoaded = false;

  Il? selectedCity;
  Ilce? selectedDistrict;

  final formKey = GlobalKey<FormState>();

  Future<void> update() async {
    HsUserModel hsUserModel = setHsUserModel();

    await FirestoreService().updateHsUserModel(hsUserModel: hsUserModel);

    FirestoreService().updateHsUserSmsStatus(hsUserModel.uid.toString());
    hsUserModel.smsVerified = true;
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

    if (hsUserModel.district != userProvider.hsUserModel!.district) {
      UserHaliSahaProvider userHaliSahaProvider = Provider.of<UserHaliSahaProvider>(context, listen: false);
      userHaliSahaProvider.getHaliSahasByDistrict(district: hsUserModel.district, force: true,city: hsUserModel.city);
    }

    userProvider.setHsUserModel(hsUserModel);

    await SharedPrefsService().setUserType('hs_user');
    //MySnackbar.show(context, message: 'Başarılı bir şekilde kayıt güncellendi.');
    Navigator.pop(context);
  }

  HsUserModel setHsUserModel() {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    HsUserModel _hsUserModel = userProvider.hsUserModel!;

    HsUserModel hsUserModel = HsUserModel(
      name: nameController.text,
      businessName: businessNameController.text,
      taxNumber: taxController.text,
      phone: phoneController.text,
      email: emailController.text,
      city: cityController.text,
      district: districtController.text,
      neighborhood: neighborhoodController.text,
      fcmToken: _hsUserModel.fcmToken,
      verified: _hsUserModel.verified,
      hs_id: _hsUserModel.hs_id,
      uid: _hsUserModel.uid,
      profilePicUrl: _hsUserModel.profilePicUrl,
    );

    return hsUserModel;
  }

  void setHsUser() async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    HsUserModel hsUserModel = userProvider.hsUserModel!;
    nameController.text = hsUserModel.name;
    businessNameController.text = hsUserModel.businessName;
    taxController.text = hsUserModel.taxNumber;
    phoneController.text = hsUserModel.phone;
    emailController.text = hsUserModel.email;
    cityController.text = hsUserModel.city;
    districtController.text = hsUserModel.district;
    neighborhoodController.text = hsUserModel.neighborhood;
    String jsonString = await rootBundle.loadString('assets/json/il-ilce.json');

    final dynamic jsonResponse = json.decode(jsonString);

    List cities = jsonResponse.map((x) => Il.fromJson(x)).toList();

    selectedCity = cities.where((element) => element.ilAdi == hsUserModel.city).first;
  }

  @override
  void initState() {
    super.initState();
    setHsUser();
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
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary, borderRadius: BorderRadius.circular(12)),
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
                        keyboardType: TextInputType.name,
                        inputFormatters: [
                          denyNumbers,
                        ],
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
                        controller: businessNameController,
                        title: 'İşletme Adı',
                        hintText: 'İşletme değiştirilemez.',
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      MyTextfield(
                        controller: taxController,
                        title: 'Vergi Numarası',
                        keyboardType: TextInputType.number,
                        inputFormatters: [allowNumbers],
                        hintText: 'Vergi numarası giriniz.',
                        validator: (val) {
                          if (val!.length < 10) {
                            return 'Lütfen geçerli bir vergi numarası giriniz';
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
                  /*    MyTextfield(
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
                        controller: neighborhoodController,
                        title: 'Mahalle',
                        hintText: 'Mahalle giriniz.',
                      ),
                      const SizedBox(height: 20),*/
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
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
