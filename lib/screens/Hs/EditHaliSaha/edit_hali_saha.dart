import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hali_saha_bak/constants/my_icons.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/models/il_ilce_model.dart';
import 'package:hali_saha_bak/models/users/hs_user_model.dart';
import 'package:hali_saha_bak/providers/hali_saha_provider.dart';
import 'package:hali_saha_bak/providers/user_provider.dart';
import 'package:hali_saha_bak/screens/Hs/PriceRange/price_range_screen.dart';
import 'package:hali_saha_bak/services/storage_service.dart';
import 'package:hali_saha_bak/utilities/my_snackbar.dart';
import 'package:hali_saha_bak/utilities/text_input_formatters.dart';
import 'package:hali_saha_bak/widgets/my_textfield_underline.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../widgets/my_button.dart';
import '../../../widgets/my_textfield.dart';
import '../../Global/select_city_screen.dart';
import '../../Global/select_district_screen.dart';
import '../ClosedRange/closed_range.dart';
import '../SubsciberRange/subscriber_range.dart';

class EditHaliSaha extends StatefulWidget {
  const EditHaliSaha({Key? key, required this.haliSaha}) : super(key: key);

  final HaliSaha haliSaha;

  @override
  State<EditHaliSaha> createState() => _EditHaliSahaState();
}

class _EditHaliSahaState extends State<EditHaliSaha> {
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

  List<FeatureIcon> selectedFeatures = [];

  List<String?> images = [
    'https://foto.haberler.com/galeri/2014/07/24/hic-bitmeyen-halisaha-geyikleri_92262_b.jpg',
    'https://foto.haberler.com/galeri/2014/07/24/hic-bitmeyen-halisaha-geyikleri_92262_b.jpg',
    'https://foto.haberler.com/galeri/2014/07/24/hic-bitmeyen-halisaha-geyikleri_92262_b.jpg',
    null,
    null,
    null,
  ];

  List ranges = [];
  List closedRanges = [];
  List subscriberRanges = [];
  List servicePlaces = [];
  bool noServicePlace = false;
  bool servisVarmi = false;
  Future<void> pickImage(int index) async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    HsUserModel hsUserModel = userProvider.hsUserModel!;
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File imageFile = File(image.path);
      String imageURL = await StorageService().uploadImage(imageFile, name: hsUserModel.name);
      setState(() {
        images[index] = imageURL;
      });
    }
  }

  Future<void> editHaliSaha() async {
    if (!formKey.currentState!.validate()) {
      MySnackbar.show(context, message: 'Lütfen tüm alanları doldurunuz');
      return;
    }
    if (images.where((element) => element != null).length < 3) {
      MySnackbar.show(context, message: 'Lütfen tüm en az 3 resim yükleyiniz');
      return;
    }


    if (servisVarmi==true) {
      if (servicePlaces.isEmpty && !noServicePlace) {
        MySnackbar.show(context,
            message: 'Lütfen en az 1 servis yerini seçiniz');

        return;
      }
      if (servicePhoneNumberController.text.isEmpty) {
        MySnackbar.show(context,
            message: 'Lütfen servis telefon numarasını giriniz');

        return;
      }

    }

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    HaliSahaProvider haliSahaProvider = Provider.of<HaliSahaProvider>(context, listen: false);
    HsUserModel hsUserModel = userProvider.hsUserModel!;
    if (servisVarmi == false) {
      servisUcretiController.text = 0.toString();
    }
    HaliSaha haliSaha = HaliSaha(
      servisVarmi: servisVarmi,
      name: nameController.text,
      description: descriptionController.text,
      city: cityController.text,
      district: districtController.text,
      fullAdress: fullAdressController.text,
      images: images.where((element) => element != null).toList(),
      features: selectedFeatures.map((e) => e.name).toList(),
      id: widget.haliSaha.id,
      hsUser: hsUserModel,
      price: int.parse(priceController.text),
      priceRanges: ranges,
      closedRanges: closedRanges,
      subscriberRanges: subscriberRanges,
      servicePlaces:  servisVarmi !=true ? [] : servicePlaces,
      kapora: double.parse(comissionController.text),
      servisUcreti: servisVarmi==false ? 0: int.parse(servisUcretiController.text),
      servicePhoneNumber: servisVarmi ==false ? '' : servicePhoneNumberController.text,
    );
    await haliSahaProvider.editHaliSaha(haliSaha);
    Navigator.pop(context);
    MySnackbar.show(context, message: 'Başarıyla güncellendi.');
  }

  void setHaliSaha() {
    HaliSaha haliSaha = widget.haliSaha;
    nameController.text = haliSaha.name;
    descriptionController.text = haliSaha.description;
    priceController.text = haliSaha.price.toString();
    for (var i = 0; i < haliSaha.images.length; i++) {
      images[i] = haliSaha.images[i];
    }
    cityController.text = haliSaha.city;
    districtController.text = haliSaha.district;
    fullAdressController.text = haliSaha.fullAdress;
    selectedFeatures = haliSaha.features.map((e) => features.where((element) => element.name == e).first).toList();
    ranges = widget.haliSaha.priceRanges;
    comissionController.text = widget.haliSaha.kapora.toString();
    closedRanges = widget.haliSaha.closedRanges;
    subscriberRanges = widget.haliSaha.subscriberRanges;
    print(widget.haliSaha.servicePlaces);
    widget.haliSaha.servicePlaces.forEach((element) {
      if (!servicePlaces.contains(element)) {
        servicePlaces.add(element);
      }
    });
    //noServicePlace = servicePlaces.isEmpty;
    servicePhoneNumberController.text = widget.haliSaha.servicePhoneNumber;
    servisUcretiController.text = widget.haliSaha.servisUcreti.toString();
    servisVarmi = widget.haliSaha.servisVarmi;
    setState(() {
      servisVarmi;
    });
  }

  @override
  void initState() {
    super.initState();
    setHaliSaha();
    servisVarmi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halı Saha Düzenle'),
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
                MyTextfieldUnderline(
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
                MyTextfieldUnderline(
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
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: servisVarmi,
                  onChanged: (degis) {
                    setState(() {
                      servisVarmi = degis!;
                    });
                  },
                  title: Text('Servisiniz Var mı'),
                ),
                if (servisVarmi != false) ...[
                  MyTextfield(
                    hintText: 'Servis iletişim numarası',
                    title: 'Numara',
                    controller: servicePhoneNumberController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      allowNumbers,
                      denyCharacters,
                    ],
                    maxLength: 13,
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
                    maxLength: 13,
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
                MyTextfieldUnderline(
                  controller: priceController,
                  title: 'Standart Fiyat',
                  keyboardType: TextInputType.number,
                  suffixText: '₺',
                  validator: (val) {
                    if (val!.isEmpty) {
                      return 'Lütfen geçerli bir fiyat giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                MyTextfieldUnderline(
                  controller: comissionController,
                  title: 'Kapora Tutarı',
                  keyboardType: TextInputType.number,
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
                    ? ListTile(
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
                        Map? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriberRangeScreen()));

                        if (result != null) {
                          subscriberRanges.add({
                            'start': result['range'].start.hour,
                            'end': result['range'].end.hour == 00.00 ? 24 : result['range'].end.hour,
                            'days': result['days'],
                            'subscriber': result['subscriber'],
                          });
                        }
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
                      GestureDetector(
                        onTap: () {
                          pickImage(images.indexOf(image));
                        },
                        child: Container(
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
                      )
                  ],
                ),
                const SizedBox(height: 20),
                MyTextfieldUnderline(
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
                MyTextfieldUnderline(
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
                MyTextfieldUnderline(
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
                  crossAxisCount: 5,
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
                          borderRadius: BorderRadius.circular(8),
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
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
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
                const SizedBox(height: 20),
                MyButton(
                  text: 'Güncelle',
                  onPressed: editHaliSaha,
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
