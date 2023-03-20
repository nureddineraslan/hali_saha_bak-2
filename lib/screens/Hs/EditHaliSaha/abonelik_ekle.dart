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

class EditHaliSahaTwo extends StatefulWidget {
  const EditHaliSahaTwo({Key? key, required this.haliSaha}) : super(key: key);

  final HaliSaha haliSaha;

  @override
  State<EditHaliSahaTwo> createState() => _EditHaliSahaTwoState();
}

class _EditHaliSahaTwoState extends State<EditHaliSahaTwo> {
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

  Future<void> EditHaliSahaTwo() async {
    if (!formKey.currentState!.validate()) {
      MySnackbar.show(context, message: 'Lütfen tüm alanları doldurunuz');
      return;
    }





    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    HaliSahaProvider haliSahaProvider = Provider.of<HaliSahaProvider>(context, listen: false);
    HsUserModel hsUserModel = userProvider.hsUserModel!;

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
      servicePlaces: noServicePlace ? [] : servicePlaces,
      kapora: double.parse(comissionController.text),
      servisUcreti: int.parse(servisUcretiController.text),
      servicePhoneNumber: servicePhoneNumberController.text,
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
    noServicePlace = servicePlaces.isEmpty;
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
        title: const Text('Abonelik Ekle'),
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

                SizedBox(height: 30,),

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
                         SizedBox(height: 30,),
                          for (var i = 0; i < subscriberRanges.length; i++)
                            Card(
                             elevation: 6,
                              child: ListTile(
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
                            ),
                        ],
                      ),
             
                MyButton(
                  text: 'Güncelle',
                  onPressed: EditHaliSahaTwo,
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
