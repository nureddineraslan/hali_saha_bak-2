import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:hali_saha_bak/screens/User/HaliSahaDetail/hali_saha_detail.dart';
import 'package:hali_saha_bak/services/firestore_service.dart';
import 'package:hali_saha_bak/utilities/text_input_formatters.dart';
import 'package:quiver/strings.dart';
import 'package:random_string/random_string.dart';

import '../../../models/il_ilce_model.dart';
import '../../../models/users/user_model.dart';
import '../../../services/sms_service.dart';
import '../../../utilities/my_snackbar.dart';
import '../../../widgets/my_button.dart';
import '../../../widgets/my_textfield.dart';

class HsManuelNewReservation extends StatefulWidget {
  const HsManuelNewReservation(
      {Key? key,
      required this.selectedDate,
      required this.startHour,
      required this.endHour,
      required this.price,
      required this.haliSaha,
      this.onAccept})
      : super(key: key);

  final DateTime selectedDate;
  final int startHour, endHour;
  final int price;
  final HaliSaha haliSaha;
  final void Function()? onAccept;

  @override
  State<HsManuelNewReservation> createState() => _HsManuelNewReservationState();
}

class _HsManuelNewReservationState extends State<HsManuelNewReservation> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  // TextEditingController emailController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool cityDataLoaded = false;
  bool resAcceptServisSecildi = false;
  String selectedPlace = '';

  Il? selectedCity;
  Ilce? selectedDistrict;

  final formKey = GlobalKey<FormState>();

  Future<void> createReservation() async {
    UserModel userModel = await setUserModel();
    final void Function()? onAccept;
    Reservation reservation = Reservation(
        id: int.parse(randomNumeric(6)),
        date: widget.selectedDate,
        createdDate: DateTime.now(),
        startHour: widget.startHour,
        endHour: widget.endHour,
        price: widget.price.toDouble(),
        haliSaha: widget.haliSaha,
        user: userModel,
        kapora: widget.haliSaha.kapora.toDouble(),
        paid: false,
        status: 1,
        selectedPlace: selectedPlace,
        isManuel: true,
        servisUcreti: widget.haliSaha.servisUcreti.toDouble(),
        servisSecildi: resAcceptServisSecildi);

    //* 3 ağustos manuel rezervasyon için email kaldırıldı
    // EmailService().sendEmail(
    //   email: reservation.user.email,
    //   name: reservation.user.fullName,
    //   subject: 'Halı Saha Bak Rezervasyonu',
    //   content:
    //       '${reservation.stringDate()} günü ${reservation.hourRange()} saatlerinde ${reservation.haliSaha.name} halı sahamız için rezervasyonunuz oluşturulmuştur. Lütfen ilgili saatte ${reservation.selectedPlace}\'de hazır bulunalım.',
    // );
    print('reservation.stringDate() : ${reservation.stringDate()}');
    SmsService().send(
      number: reservation.user.phone,
      text:
          '${reservation.stringDate()} günü ${reservation.hourRange()} saatlerinde ${reservation.haliSaha.name} halı sahamız için rezervasyonunuz oluşturulmuştur. Lütfen ilgili saatte ${reservation.selectedPlace}\'de hazır bulunalım. Halı Saha Bak uygulamasını indirerek hızlıca rezervasyon oluşturabilirsiniz.',
    );

    await FirestoreService()
        .createReservation(reservation: reservation, guest: true);

  /*  MySnackbar.show(context,
        message: 'Başarılı bir şekilde rezervasyon oluşturuldu');
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);*/
  }

  Future<UserModel> setUserModel() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    UserModel hsUserModel = UserModel(
      fullName: nameController.text,
      phone: phoneController.text,
      email: '',
      city: widget.haliSaha.city,
      district: widget.haliSaha.district,
      reservations: [],
      favorites: [],
      fcmToken: await firebaseMessaging.getToken() ?? '',
    );

    return hsUserModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Center(
                        child: Text(
                          'Yeni Rezervasyon',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),

                      MyTextfield(
                        controller: nameController,
                        title: 'Ad Soyad',
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
                        controller: phoneController,
                        title: 'Telefon numarası',
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
                      // const SizedBox(height: 20),
                      // MyTextfield(
                      //   controller: emailController,
                      //   title: 'E-posta',
                      //   hintText: 'E-posta giriniz.',
                      //   validator: (val) {
                      //     if (val!.length < 5) {
                      //       return 'Lütfen geçerli bir e-posta giriniz';
                      //     }
                      //     if (!val.isValidEmail()) {
                      //       return 'Lütfen geçerli bir e-posta giriniz';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      const SizedBox(height: 20),
                      if (widget.haliSaha.servisVarmi != false) ...[
                        CheckboxListTile(
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: resAcceptServisSecildi,
                          activeColor: Colors.red,
                          onChanged: (degis) {
                            setState(() {
                              resAcceptServisSecildi = degis!;
                            }); // //servisSecildi==widget.servisVarmi;
                          },
                          title: Text(
                            'Servis Olacak Mı ?',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (resAcceptServisSecildi != false) ...[
                          const SizedBox(height: 10),
                          Center(
                              child: Text(
                            'Servis Kalkış Noktası Seçiniz',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          )),
                          const SizedBox(height: 20),
                          GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 4,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                            children: [
                              for (var place in widget.haliSaha.servicePlaces)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedPlace = place;
                                    });
                                  },
                                  child: SelectPlaceWidget(
                                    place: place,
                                    selected: selectedPlace == place,
                                  ),
                                )
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              MyButton(
                text: 'OLUŞTUR',
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text('Hata'),
                              content: Text('Lütfen Tüm Alanları Doldurunuz'),
                              actions: [
                                TextButton(
                                  child: Text('Tamam'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ));
                    return;
                  }
                  if (resAcceptServisSecildi == true && selectedPlace == '') {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text('Hata'),
                              content: Text(
                                  'Lütfen Bir Servis Kalkış Noktası Seçiniz'),
                              actions: [
                                TextButton(
                                  child: Text('Tamam'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ));

                    return;
                  }
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text('Dikkat'),
                            content: Text(
                                'Rezervasyon oluşturmak istediğinize emin misiniz?'),
                            actions: [
                              TextButton(
                                child: Text('İPTAL'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: Text('EVET'),
                                onPressed: () async {
                                 Navigator.pop(context);
                                 Navigator.pop(context);
                                   await createReservation();
                                 
                                },
                              ),
                            ],
                          ));
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
