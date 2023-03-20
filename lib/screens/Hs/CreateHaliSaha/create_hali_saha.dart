import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hali_saha_bak/constants/my_icons.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/models/il_ilce_model.dart';
import 'package:hali_saha_bak/models/users/hs_user_model.dart';
import 'package:hali_saha_bak/providers/user_provider.dart';
import 'package:hali_saha_bak/screens/Hs/ClosedRange/closed_range.dart';
import 'package:hali_saha_bak/screens/Hs/SubsciberRange/subscriber_range.dart';
import 'package:hali_saha_bak/services/email_service.dart';
import 'package:hali_saha_bak/services/firestore_service.dart';
import 'package:hali_saha_bak/services/sms_service.dart';
import 'package:hali_saha_bak/services/storage_service.dart';
import 'package:hali_saha_bak/utilities/my_snackbar.dart';
import 'package:hali_saha_bak/utilities/text_input_formatters.dart';
import 'package:hali_saha_bak/widgets/my_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import '../../../providers/hali_saha_provider.dart';
import '../../../widgets/my_button.dart';
import '../../Global/select_city_screen.dart';
import '../../Global/select_district_screen.dart';
import '../PriceRange/price_range_screen.dart';

class CreateHaliSaha extends StatefulWidget {
  const CreateHaliSaha({Key? key}) : super(key: key);

  @override
  State<CreateHaliSaha> createState() => _CreateHaliSahaState();
}

class _CreateHaliSahaState extends State<CreateHaliSaha> {
  final ImagePicker picker = ImagePicker();

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController fullAdressController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController placesController = TextEditingController();
  TextEditingController comissionController = TextEditingController();
  TextEditingController servisUcretiController = TextEditingController();
  TextEditingController servicePhoneNumberController = TextEditingController();

  var formKey = GlobalKey<FormState>();

  Il? selectedCity;
  Ilce? selectedDistrict;
  bool servisVarmi = false;

  List<FeatureIcon> selectedFeatures = [];

  List<String?> images = [
    'https://ohalisaha.com/Content/images/SahaFotolar/d5ba0dfe-d141-4610-9b45-5086396b21f7.jpg',
    'https://ohalisaha.com/Content/images/SahaFotolar/d5ba0dfe-d141-4610-9b45-5086396b21f7.jpg',
    'https://ohalisaha.com/Content/images/SahaFotolar/d5ba0dfe-d141-4610-9b45-5086396b21f7.jpg',
  ];

  List<Map> ranges = [];
  List<Map> closedRanges = [];
  List<Map> subscriberRanges = [];
  List<String> servicePlaces = [];
  bool noServicePlace = false;

  Future<void> pickImage() async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    HsUserModel hsUserModel = userProvider.hsUserModel!;
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File imageFile = File(image.path);
      String imageURL = await StorageService().uploadImage(imageFile, name: hsUserModel.name);
      setState(() {
        images.add(imageURL);
      });
    }
  }

  Future<void> createHaliSaha() async {
    if (!formKey.currentState!.validate()) {
      MySnackbar.show(context, message: 'Lütfen tüm alanları doldurunuz');
      return;
    }

    if (images.where((element) => element != null).length < 3) {
      MySnackbar.show(context, message: 'Lütfen  en az 3 resim yükleyiniz');
      return;
    }

    if (servisVarmi==true) {
      if (servicePlaces.isEmpty  ) {
        MySnackbar.show(context, message: 'Lütfen en az 1 servis yerini seçiniz');
        return;
      }
      if (servicePhoneNumberController.text.isEmpty) {
        MySnackbar.show(context, message: 'Lütfen servis telefon numarasını giriniz');

        return;
      }

    }

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    HsUserModel hsUserModel = userProvider.hsUserModel!;

    HaliSaha haliSaha = HaliSaha(
        name: nameController.text,
        description: descriptionController.text,
        city: cityController.text,
        district: districtController.text,
        fullAdress: fullAdressController.text,
        images: images.where((element) => element != null).toList(),
        features: selectedFeatures.map((e) => e.name).toList(),
        id: randomNumeric(12),
        hsUser: hsUserModel,
        price: int.parse(priceController.text),
        priceRanges: ranges,
        closedRanges: closedRanges,
        subscriberRanges: subscriberRanges,
        servicePlaces: noServicePlace ? [] : servicePlaces,
        kapora: double.parse(comissionController.text),
        servisUcreti: servisVarmi == true ? int.parse(servisUcretiController.text) : 0,
        servicePhoneNumber: servicePhoneNumberController.text,
        servisVarmi: servisVarmi
    );
    HaliSahaProvider haliSahaProvider = Provider.of<HaliSahaProvider>(context, listen: false);
    await haliSahaProvider.createHaliSaha(haliSaha);
    Map? systemVariables = await FirestoreService().getSystemVariables();
    if (systemVariables == null) {
      print('admine mesajlar gönderilemedi');
    } else {
      if (systemVariables['phone'] != null) {
        SmsService().send(
            number: '${systemVariables['phone']}', text: '${haliSaha.hsUser.businessName} adlı işletme ${haliSaha.name} adlı yeni bir halı saha oluşturdu.');
      }
      if (systemVariables['email'] != null) {
        EmailService().sendEmail(
            email: '${systemVariables['email']}',
            name: 'Admin',
            subject: 'Yeni Halı Saha Bildirimi',
            content: '${haliSaha.hsUser.businessName} adlı işletme ${haliSaha.name} adlı yeni bir halı saha oluşturdu.');
      }
    }
    Navigator.pop(context);
  MySnackbar.show(context, message: 'Başarıyla oluşturuldu.');

  }

  bool selected = false;

  @override
  void initState() {
    super.initState();
    setCityInfo();
  }

  Future<void> setCityInfo() async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    HsUserModel hsUserModel = userProvider.hsUserModel!;
    String jsonString = await rootBundle.loadString('assets/json/il-ilce.json');

    final dynamic jsonResponse = json.decode(jsonString);

    List cities = jsonResponse.map((x) => Il.fromJson(x)).toList();
    setState(() {
      selectedCity = cities.where((element) => element.ilAdi == hsUserModel.city).first;
      selectedDistrict = selectedCity!.ilceler.where((element) => element.ilceAdi == hsUserModel.district).first;
      cityController.text = selectedCity!.ilAdi;
      districtController.text = selectedDistrict!.ilceAdi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Halı Saha Oluştur'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                MyTextfield(
                  hintText: 'Halı saha adı giriniz',
                  title: 'Halı Saha Adı',
                  controller: nameController,
                  maxLength: 40,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Lütfen bu alanı doldurunuz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 20),
                MyTextfield(
                  hintText: 'Açıklama giriniz',
                  title: 'Halı Saha Açıklaması',
                  controller: descriptionController,
                  maxLines: 4,
                  maxLength: 200,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Lütfen bu alanı doldurunuz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                CheckboxListTile(
                  activeColor: Colors.red,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: servisVarmi,
                  onChanged: (degis) {
                    setState(() {
                      servisVarmi = degis!;
                    });
                  },
                  title: Text(
                    'Servisiniz Var mı ?',
                    style: TextStyle(fontSize: 15),
                  ),
                ),



                if (servisVarmi ==true) ...[
                  MyTextfield(
                    hintText: 'Servis iletişim numarası',
                    title: 'Numara',
                    controller: servicePhoneNumberController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      allowNumbers,
                      denyCharacters,
                    ],
                    maxLength: 11,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Lütfen bu alanı doldurunuz';
                      }
                      return null;
                    },
                  ),
                  MyTextfield(
                    hintText: 'Servis Ücreti',
                    title: 'Ücreti',
                    controller: servisUcretiController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      allowNumbers,
                      denyCharacters,
                    ],
                    maxLength: 3,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Lütfen bu alanı doldurunuz';
                      }
                      return null;
                    },
                  ),
                  const Text(
                    'Servis Noktaları',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: MyTextfield(
                          hintText: 'Servis noktası giriniz',
                          controller: placesController,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: Text('Ekle'),
                        onPressed: () {
                          if (placesController.text.isNotEmpty && !servicePlaces.contains(placesController.text)) {
                            setState(() {
                              servicePlaces.add(placesController.text);
                              placesController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (!noServicePlace)
                    for (var place in servicePlaces)
                      ListTile(
                        leading: Icon(Icons.check, color: Colors.green),
                        title: Text(place),
                        trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                servicePlaces.remove(place);
                              });
                            },
                            icon: Icon(Icons.close)),
                      ),
                ],

                // CheckboxListTile(
                //   value: noServicePlace,
                //   onChanged: (val) {
                //     setState(() {
                //       noServicePlace = val!;
                //     });
                //   },
                //   title: Text('Servis yok'),
                //   controlAffinity: ListTileControlAffinity.leading,
                // ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                MyTextfield(
                  hintText: 'Fiyat giriniz',
                  title: 'Standart Fiyat',
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    allowNumbers,
                    denyCharacters,
                  ],
                  suffixText: '₺',
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Lütfen geçerli bir adres giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                MyTextfield(
                  hintText: 'Kapora tutarı giriniz',
                  controller: comissionController,
                  title: 'Kapora Tutarı',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    allowNumbers,
                    denyCharacters,
                  ],
                  suffixText: '₺',
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Lütfen geçerli bir adres giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Farklı Fiyat Aralıkları',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    TextButton(
                      onPressed: () async {
                        Map result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const PriceRangeScreen()));

                        ranges.add({
                          'price': result['price'],
                          'start': result['range'].start.hour,
                          'end': result['range'].end.hour,
                        });
                        setState(() {});
                      },
                      child: const Text('Ekle'),
                    )
                  ],
                ),
                ranges.isEmpty
                    ? const ListTile(
                        title: Text('-'),
                      )
                    : Column(
                        children: [
                          for (var i = 0; i < ranges.length; i++)
                            ListTile(
                              title: Text('${ranges[i]['start'].toString().padLeft(2, '0')}:00 - ${ranges[i]['end'].toString().padLeft(2, '0')}:00'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${ranges[i]['price']}₺'),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          ranges.removeAt(i);
                                        });
                                      },
                                      icon: Icon(Icons.close)),
                                ],
                              ),
                            ),
                        ],
                      ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kapalı Saat Aralıkları',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    TextButton(
                      onPressed: () async {
                        Map result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const CloseRangeScreen()));

                        closedRanges.add({
                          'start': result['range'].start.hour,
                          'end': result['range'].end.hour == 00.00 ? 24 : result['range'].end.hour,
                        });
                        setState(() {});
                      },
                      child: const Text('Ekle'),
                    )
                  ],
                ),
                closedRanges.isEmpty
                    ? const ListTile(
                        title: Text('-'),
                      )
                    : Column(
                        children: [
                          for (var i = 0; i < closedRanges.length; i++)
                            ListTile(
                              title:
                                  Text('${closedRanges[i]['start'].toString().padLeft(2, '0')}:00 - ${closedRanges[i]['end'].toString().padLeft(2, '0')}:00'),
                              trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      closedRanges.removeAt(i);
                                    });
                                  },
                                  icon: Icon(Icons.close)),
                            ),
                        ],
                      ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Abonelik Aralıkları',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    TextButton(
                      onPressed: () async {
                        Map result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriberRangeScreen()));

                        subscriberRanges.add({
                          'start': result['range'].start.hour,
                          'end': result['range'].end.hour == 00.00 ? 24 : result['range'].end.hour,
                          'days': result['days'],
                          'subscriber': result['subscriber'],
                        });
                        setState(() {});
                      },
                      child: const Text('Ekle'),
                    )
                  ],
                ),
                subscriberRanges.isEmpty
                    ? const ListTile(
                        title: Text('-'),
                      )
                    : Column(
                        children: [
                          for (var i = 0; i < subscriberRanges.length; i++)
                            ListTile(
                              title: Text(
                                  '${subscriberRanges[i]['start'].toString().padLeft(2, '0')}:00 - ${subscriberRanges[i]['end'].toString().padLeft(2, '0')}:00'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${subscriberRanges[i]['subscriber']}'),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          subscriberRanges.removeAt(i);
                                        });
                                      },
                                      icon: Icon(Icons.close)),
                                ],
                              ),
                            ),
                        ],
                      ),

                const SizedBox(height: 20),
                const Text(
                  'Halı Saha Resimleri',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  shrinkWrap: true,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var image in images)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: image == null
                            ? const Center(
                                child: Icon(
                                Icons.add,
                                color: Colors.grey,
                              ))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    GestureDetector(
                      onTap: () {
                        pickImage();
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                              child: Icon(
                            Icons.add,
                            color: Colors.grey,
                          ))),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                MyTextfield(
                  hintText: 'Şehir seçiniz',
                  title: 'Şehir',
                  controller: cityController,
                  onTap: () async {
                    Il? newSelectedCity = await Navigator.push(context, MaterialPageRoute(builder: (context) => SelectCityScreen(selectedCity: selectedCity)));

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
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Lütfen geçerli bir şehir giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                MyTextfield(
                  hintText: 'İlçe seçiniz',
                  title: 'İlçe',
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
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Lütfen geçerli bir ilçe giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                MyTextfield(
                  hintText: 'Adres giriniz',
                  title: 'Açık Adres',
                  controller: fullAdressController,
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Lütfen geçerli bir adres giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Halı Saha Tesis Özellikleri',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: features.map((feature) {
                    bool added = selectedFeatures.contains(feature);
                    return GestureDetector(
                      onTap: () {
                        if (added) {
                          selectedFeatures.remove(feature);
                        } else {
                          selectedFeatures.add(feature);
                        }
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: added ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Image.asset(
                                'assets/images/features/${feature.image}',
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  feature.name,
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   mainAxisSize: MainAxisSize.min,
                //   children: [
                //     for (var i = 0; i < features.length; i++)
                //       SwitchListTile(
                //         value: features.values.toList()[i],
                //         onChanged: (val) {
                //           setState(() {
                //             features[features.keys.toList()[i]] = val;
                //           });
                //         },
                //         title: Text(features.keys.toList()[i]),
                //       ),
                //   ],
                // ),
                const SizedBox(height: 20),
                MyButton(
                  text: 'Oluştur',
                  onPressed: createHaliSaha,
                ),
                SizedBox(
                  height: Platform.isIOS ? MediaQuery.of(context).viewPadding.bottom * 2 : 30,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
