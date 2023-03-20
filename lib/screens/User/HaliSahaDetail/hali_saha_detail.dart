import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:hali_saha_bak/constants/my_icons.dart';
import 'package:hali_saha_bak/models/comment.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/models/users/reserv_model.dart';
import 'package:hali_saha_bak/providers/user_hali_saha_provider.dart';
import 'package:hali_saha_bak/providers/user_reservations_provider.dart';
import 'package:hali_saha_bak/screens/Global/image_view.dart';
import 'package:hali_saha_bak/screens/User/AllComments/all_comments.dart';
import 'package:hali_saha_bak/screens/User/BottomNavBar/user_bottom_nav_bar.dart';
import 'package:hali_saha_bak/screens/User/Payment/payment_real.dart';
import 'package:hali_saha_bak/utilities/enums.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';
import 'package:hali_saha_bak/widgets/my_textfield.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../models/reservation.dart';
import '../../../models/users/user_model.dart';
import '../../../providers/hali_saha_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../utilities/extensions.dart';
import '../../../utilities/my_snackbar.dart';
import '../../../widgets/comment_widget.dart';
import '../Reservation/components/reservations_table.dart';

class UserHaliSahaDetail extends StatefulWidget {
  final HaliSaha haliSaha;

  const UserHaliSahaDetail({Key? key, required this.haliSaha})
      : super(key: key);

  @override
  State<UserHaliSahaDetail> createState() => _UserHaliSahaDetailState();
}

class _UserHaliSahaDetailState extends State<UserHaliSahaDetail> {
  PageController controller = PageController();
  TextEditingController commentController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  double? rating;

  bool commentsLoaded = false;
  List<Comment> comments = [];

  bool servisVarmi = false;

  set setName(bool durum) {
    servisSecildi = durum;
  }

  bool servisSecildi = false;
  bool kontrol = false;
  DateTime selectedDate = DateTime.now();
  int? selectedHour;
  String price = '';
  var ucret = '';

  Future<void> reservation({HaliSaha? myhaliSaha}) async {
    if (selectedHour != null) {
      UserHaliSahaProvider userHaliSahaProvider =
          Provider.of<UserHaliSahaProvider>(context, listen: false);
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      HaliSaha haliSaha = myhaliSaha ??
          userHaliSahaProvider.haliSahas[userHaliSahaProvider.haliSahas
              .indexWhere((element) => element.id == widget.haliSaha.id)];
      if (selectedHour != null &&
          haliSaha.priceRanges.any((element) => isBetween(
              start: element['start'],
              end: element['end'],
              value: selectedHour!))) {
        price = haliSaha.priceRanges
            .where((element) => isBetween(
                start: element['start'],
                end: element['end'],
                value: selectedHour!))
            .first['price']
            .toString();
      } else {
        price = haliSaha.price.toString();
      }

      double? priceNum = (haliSaha.price * haliSaha.kapora / 100);
      double? kaporaNum = haliSaha.kapora;
      double? servisUcretiNum = haliSaha.servisUcreti.toDouble();

      if (priceNum == null) {
        MySnackbar.show(context, message: 'Fiyat bilgisinde bir hata oluştu');
        return;
      }
      if (kaporaNum == null) {
        MySnackbar.show(context, message: 'Fiyat bilgisinde bir hata oluştu');
        return;
      }

      // String hours = '${selectedHour.toString().padLeft(2, '0')}:00 - ${(selectedHour! + 1).toString().padLeft(2, '0')}:00';

      // Reservation reservation = Reservation(
      //   id: DateTime.now().millisecondsSinceEpoch,
      //   date: selectedDate,
      //   createdDate: DateTime.now(),
      //   startHour: selectedHour!,
      //   endHour: selectedHour! + 1,
      //   price: priceNum.toDouble(),
      //   haliSaha: haliSaha,
      //   user: userProvider.userModel!,
      //   paid: false,
      //   status: 0,
      //   notes: notesController.text,
      // );

      // await FirestoreService().addToBucket(reservation);
      // MySnackbar.show(context, message: 'Başarıyla eklendi');

      // print('haliSaha.hsUser.hsPaymentId : ${haliSaha.hsUser.hsPaymentId}');

      // UserReservationsProvider userReservationsProvider = Provider.of<UserReservationsProvider>(context, listen: false);

      // await userReservationsProvider.createReservation(
      //   reservation: Reservation(
      //     id: int.parse(randomNumeric(6)),
      //     date: selectedDate,
      //     createdDate: DateTime.now(),
      //     startHour: selectedHour!,
      //     endHour: selectedHour! + 1,
      //     price: priceNum.toDouble(),
      //     haliSaha: haliSaha,
      //     user: userProvider.userModel!,
      //     paid: false,
      //     status: 0,
      //     notes: notesController.text,
      //     selectedPlace: selectedPlace,
      //   ),
      // );

      // MySnackbar.show(context, message: 'Rezervasyon başarılı bir şekilde oluşturuldu');

      Reservation reservation = Reservation(
          id: int.parse(randomNumeric(6)),
          date: DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, selectedHour ?? 0),
          createdDate: DateTime.now().toUtc(),
          startHour: selectedHour!,
          endHour: selectedHour! + 1,
          price: priceNum.toDouble(),
          haliSaha: haliSaha,
          kapora: kaporaNum.toDouble(),/* servisSecildi == false
              ? kaporaNum.toDouble()
              : kaporaNum.toDouble() + haliSaha.servisUcreti.toDouble() / 14, */
          servisUcreti: servisUcretiNum.toDouble(),
          user: userProvider.userModel!,
          paid: false,
          status: 0,
          notes: notesController.text,
          selectedPlace: servisSecildi == false ? '' : selectedPlace,
          servisSecildi: servisSecildi);

      // UserReservationsProvider userReservationsProvider = Provider.of<UserReservationsProvider>(context, listen: false);
      // await userReservationsProvider.createReservation(reservation: reservation);
      // currentUserBottomIndex = 0; 5124 4002 4884 7008

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreenReal(
            hsPaymentId: haliSaha.hsUser.hsPaymentId!,
            fromReservationScreen: false,
            reservation: reservation,
          ),
        ),
      );
    }
  }

  Future<void> sendComment(haliSaha) async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    UserModel userModel = userProvider.userModel!;

    if (commentController.text.isEmpty) {
      MySnackbar.show(context, message: 'Yorum yazınız');
      return;
    }
    if (rating == null) {
      MySnackbar.show(context, message: 'Puan seçiniz');
      return;
    }
    Comment comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch,
      rating: rating!,
      message: commentController.text,
      userUID: userModel.uid!,
      username: userModel.fullName,
      userProfilePicUrl: userModel.profilePicUrl,
      haliSahaId: haliSaha.id,
      createdDate: DateTime.now(),
    );
    await FirestoreService().sendComment(comment);
    MySnackbar.show(context, message: 'Yorumunuz için teşekkür ederiz.');
    setState(() {
      comments.add(comment);
      rating = null;
      commentController.clear();
      FocusManager.instance.primaryFocus!.unfocus();
    });
  }

  Future<void> getComments() async {
    comments = await FirestoreService().getHaliSahaComments(widget.haliSaha);
    setState(() {
      commentsLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    getComments();
  }

  String selectedPlace = '';

  late bool servisDurum;

  @override
  Widget build(BuildContext context) {
    UserHaliSahaProvider userHaliSahaProvider =
        Provider.of<UserHaliSahaProvider>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);
    ReservModel? reservModel;
    UserModel? userModel = userProvider.userModel;
    HaliSaha haliSaha = userHaliSahaProvider.haliSahas
            .any((element) => element.id == widget.haliSaha.id)
        ? userHaliSahaProvider.haliSahas[userHaliSahaProvider.haliSahas
            .indexWhere((element) => element.id == widget.haliSaha.id)]
        : widget.haliSaha;
    print(haliSaha.similarHaliSahas);

    return Builder(builder: (context) {
      if (haliSaha.similarHaliSahas.isNotEmpty) {
        List<HaliSaha> haliSahas = [];
        haliSahas.addAll(haliSaha.similarHaliSahas);

        haliSahas.add(haliSaha);
        return DefaultTabController(
          length: haliSahas.length,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                isScrollable: true,
                tabs: haliSahas.map((element) {
                  return Tab(
                    text: element.name,
                  );
                }).toList(),
              ),
            ),
            body: TabBarView(
              children: [
                for (var haliSaha in haliSahas)
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirestoreService().haliSahaStream(haliSaha),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Beklenmedik bir hata oluştu'),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.data == null) {
                          return const Center(
                            child: Text('Beklenmedik bir hata oluştu'),
                          );
                        }

                        List<Reservation> reservations = snapshot.data!.docs
                            .map((doc) => Reservation.fromJson(doc.data()))
                            .toList();
                        reservations.sort((a, b) => a.date.compareTo(b.date));

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 240,
                                child: PageView.builder(
                                  controller: controller,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ImageView(
                                                images: haliSaha.images,
                                                index: index %
                                                    haliSaha.images.length),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          color: Colors.grey.shade300,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        child: SizedBox(
                                          height: 280,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl: haliSaha.images[index %
                                                  haliSaha.images.length],
                                              placeholder: (context, url) => Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: SmoothPageIndicator(
                                  controller: controller,
                                  count: haliSaha.images.length,
                                  effect: const ExpandingDotsEffect(
                                    dotHeight: 8,
                                    dotWidth: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: ReservationsTable(
                                  decreaseDate: () {
                                    selectedDate = selectedDate
                                        .subtract(const Duration(days: 1));
                                    selectedHour = -1;
                                    setState(() {});
                                  },
                                  increaseDate: () {
                                    selectedDate = selectedDate
                                        .add(const Duration(days: 1));
                                    selectedHour = -1;
                                    setState(() {});
                                  },
                                  selectedDate: selectedDate,
                                  selectedHour: selectedHour,
                                  reservations: reservations,
                                  onHourSelected: (val) {
                                    setState(() {
                                      selectedHour = val;
                                      if (selectedHour != null &&
                                          haliSaha.priceRanges.any((element) =>
                                              isBetween(
                                                  start: element['start'],
                                                  end: element['end'],
                                                  value: selectedHour!))) {
                                        price = haliSaha.priceRanges
                                            .where((element) => isBetween(
                                                start: element['start'],
                                                end: element['end'],
                                                value: selectedHour!))
                                            .first['price']
                                            .toString();
                                      } else {
                                        price = haliSaha.price.toString();
                                      }
                                      showCupertinoModalBottomSheet(
                                        context: context,
                                        builder: (context) => StatefulBuilder(
                                            builder: (context, setState) {
                                          return ReservationAcceptBottomSheet(
                                            commission: haliSaha.kapora,
                                            price: price,
                                            servisUcreti: haliSaha.servisUcreti,
                                            hours:
                                                '${selectedHour.toString().padLeft(2, '0')}:00 - ${(selectedHour! + 1).toString().padLeft(2, '0')}:00',
                                            date:
                                                '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                                            places: haliSaha.servicePlaces,
                                            selectedPlace: selectedPlace,
                                            servisVarmi: haliSaha.servisVarmi,
                                            servisSecildi: servisSecildi,
                                            onAccept: () {
                                              servisSecildi = true;
                                              print(
                                                  'Birden Fazla SAhası olan onAccep servissecildimi:${servisSecildi}');

                                              // if (!servisSecildi == true) {
                                              if (haliSaha.servicePlaces
                                                      .isNotEmpty &&
                                                  selectedPlace == '') {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: Text('Hata'),
                                                    content: Text(
                                                        'Lütfen bir kalkış noktası seçiniz '),
                                                    actions: [
                                                      TextButton(
                                                        child: Text('Tamam'),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                );
                                                return;
                                              }
                                              // }

                                              Navigator.pop(context);
                                              reservation(myhaliSaha: haliSaha);
                                            },
                                            onAcceptTwo: () {
                                              print('note ${notesController}');
                                              servisSecildi = false;
                                              print(
                                                  'Birden fazla sahası olan onAccepTwo servisSecildiMi: ${servisSecildi}');
                                              print(
                                                  'Servis Varmi ${haliSaha.servisVarmi}');

                                              /*         if(haliSaha.servicePlaces.isNotEmpty &&selectedPlace==''){
                                        print("kolman çalıştı servis secildi$servisSecildi");
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Hata'),
                                            content: Text(
                                                'Accepto noktası seçiniz'),
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
                                      }*/

                                              /* else if(!servisSecildi==true){
                                        print("asagidaki servis durum: $servisSecildi");
                                        print("asagisi");
                                      }*/

                                              reservation(myhaliSaha: haliSaha);
                                            },
                                            // onServisFalse: () {
                                            //   setState(() {
                                            //     servisSecildi = false;
                                            //     print('onServisFalse durum :${servisSecildi}');
                                            //   });
                                            // },
                                            // onServisTrue: () {
                                            //   setState(() {
                                            //     servisSecildi == true;
                                            //     print('onServisTrue durum :${servisSecildi}');
                                            //   });
                                            // },
                                            onSelectPlace: (val) {
                                              print(
                                                  "birden fazla sahası olan onSelece calisti");
                                              setState(() {
                                                selectedPlace = val;
                                              });
                                            },
                                            textEditingController:
                                                notesController,
                                          );
                                        }),
                                      );
                                    });
                                  },
                                  haliSaha: haliSaha,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Center(
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  spacing: 16,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                            radius: 6,
                                            backgroundColor:
                                                Colors.purpleAccent),
                                        SizedBox(width: 6),
                                        Text('Abonelik')
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                            radius: 6,
                                            backgroundColor: Colors.green),
                                        SizedBox(width: 6),
                                        Text('Boş'),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                            radius: 6,
                                            backgroundColor: Colors.red),
                                        SizedBox(width: 6),
                                        Text('Dolu'),
                                      ],
                                    ),
                                    // Row(
                                    //   mainAxisSize: MainAxisSize.min,
                                    //   children: [
                                    //     CircleAvatar(
                                    //         radius: 6,
                                    //         backgroundColor: Colors.orange),
                                    //     SizedBox(width: 6),
                                    //     Text('Bekliyor'),
                                    //   ],
                                    // ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                            radius: 6,
                                            backgroundColor: Colors.grey[300]),
                                        SizedBox(width: 6),
                                        Text('Kapalı')
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildTitle('Halı Saha Açıklaması'),
                                    const SizedBox(height: 10),
                                    Text(haliSaha.description),
                                    Text("solman"),
                                    buildDivider(),
                                    buildTitle('Halı Saha Fiyatı'),
                                    const SizedBox(height: 10),
                                    Text(haliSaha.price.toString() + '₺'),
                                    buildDivider(),
                                    buildTitle('Adres'),
                                    const SizedBox(height: 10),
                                    Text(
                                        '${haliSaha.city}, ${haliSaha.district}, ${haliSaha.fullAdress}'),
                                    buildDivider(),
                                    buildTitle('Halı Saha Tesis Özellikleri'),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      children: haliSaha.features
                                          .map(
                                            (feature) => Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                              child: Column(
                                                children: [
                                                  Image.asset(
                                                    'assets/images/features/' +
                                                        features
                                                            .where((element) =>
                                                                element.name ==
                                                                feature)
                                                            .first
                                                            .image,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onBackground,
                                                    fit: BoxFit.contain,
                                                    scale: 2.5,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                      iconToTurkish[features
                                                              .where((element) =>
                                                                  element
                                                                      .name ==
                                                                  feature)
                                                              .first
                                                              .image
                                                              .replaceAll(
                                                                  '.png',
                                                                  '')] ??
                                                          '',
                                                      style: TextStyle(
                                                          fontSize: 12))
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Builder(builder: (context) {
                                  if (!commentsLoaded) {
                                    return const SizedBox(
                                      height: 200,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  return FutureBuilder<List<Comment>>(
                                      future: FirestoreService()
                                          .getHaliSahaComments(haliSaha),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SizedBox(
                                            height: 200,
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        }
                                        List<Comment> _comments =
                                            snapshot.data!;
                                        return Column(
                                          children: [
                                            Row(
                                              children: [
                                                const Expanded(
                                                    child: SizedBox()),
                                                Expanded(
                                                  child: Center(
                                                      child: buildTitle(
                                                          'Yorumlar')),
                                                ),
                                                Expanded(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: TextButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      AllComments(
                                                                          haliSaha:
                                                                              haliSaha)));
                                                        },
                                                        child: const Text(
                                                          'Tümü',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue),
                                                        )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            for (var comment in _comments)
                                              CommentWidget(comment: comment),
                                            if (userModel != null &&
                                                userModel.reservations.any(
                                                    (element) =>
                                                        element['hs_user_id'] ==
                                                        haliSaha.id))
                                              Column(
                                                children: [
                                                  RatingStars(
                                                    value: rating ?? 0,
                                                    onValueChanged: (val) {
                                                      setState(() {
                                                        rating = val;
                                                      });
                                                    },
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20.0),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: TextFormField(
                                                            controller:
                                                                commentController,
                                                            decoration:
                                                                const InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(),
                                                              labelText:
                                                                  'Yorum Yap',
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            sendComment(
                                                                haliSaha);
                                                          },
                                                          icon: const Icon(
                                                              Icons.send),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        );
                                      });
                                }),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        );
                      }),
              ],
            ),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            title: Text(haliSaha.name),
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirestoreService().haliSahaStream(haliSaha),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Beklenmedik bir hata oluştu'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data == null) {
                  return const Center(
                    child: Text('Beklenmedik bir hata oluştu'),
                  );
                }

                List<Reservation> reservations = snapshot.data!.docs
                    .map((doc) => Reservation.fromJson(doc.data()))
                    .toList();
                reservations.sort((a, b) => a.date.compareTo(b.date));

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 240,
                        child: PageView.builder(
                          controller: controller,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageView(
                                        images: haliSaha.images,
                                        index: index % haliSaha.images.length),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.grey.shade300,
                                ),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                child: SizedBox(
                                  height: 280,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: haliSaha.images[
                                          index % haliSaha.images.length],
                                      placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: SmoothPageIndicator(
                          controller: controller,
                          count: haliSaha.images.length,
                          effect: const ExpandingDotsEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ReservationsTable(
                          decreaseDate: () {
                            selectedDate =
                                selectedDate.subtract(const Duration(days: 1));
                            selectedHour = -1;
                            setState(() {});
                          },
                          increaseDate: () {
                            selectedDate =
                                selectedDate.add(const Duration(days: 1));
                            selectedHour = -1;
                            setState(() {});
                          },
                          selectedDate: selectedDate,
                          selectedHour: selectedHour,
                          reservations: reservations,
                          onHourSelected: (val) {
                            setState(() {
                              selectedHour = val;
                              if (selectedHour != null &&
                                  haliSaha.priceRanges.any((element) =>
                                      isBetween(
                                          start: element['start'],
                                          end: element['end'],
                                          value: selectedHour!))) {
                                price = haliSaha.priceRanges
                                    .where((element) => isBetween(
                                        start: element['start'],
                                        end: element['end'],
                                        value: selectedHour!))
                                    .first['price']
                                    .toString();
                              } else {
                                price = haliSaha.price.toString();
                              }
                              showCupertinoModalBottomSheet(
                                context: context,
                                builder: (context) => StatefulBuilder(
                                    builder: (context, setState) {
                                  return ReservationAcceptBottomSheet(
                                    commission: haliSaha.kapora,
                                    price: price,
                                    servisUcreti: haliSaha.servisUcreti,
                                    hours:
                                        '${selectedHour.toString().padLeft(2, '0')}:00 - ${(selectedHour! + 1).toString().padLeft(2, '0')}:00',
                                    date:
                                        '${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}',
                                    places: haliSaha.servicePlaces,
                                    selectedPlace: selectedPlace,
                                    servisVarmi: haliSaha.servisVarmi,
                                    servisSecildi: servisSecildi,
                                    onAccept: () {
                                      servisSecildi = true;
                                      print(
                                          'tekil saha onAceppt servisdurum: ${servisSecildi},');
                                      print('Tekil saha onAccept Calisti');
                                      if (haliSaha.servicePlaces.isNotEmpty &&
                                          selectedPlace == '') {
                                        print(
                                            "Tekil saha çalıştı servis secildi$servisSecildi");
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Hata'),
                                            content: Text(
                                                'Lütfen bir kalkış tekil saha noktası seçiniz '),
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

                                      /* else if(!servisSecildi==true){
                                        print("asagidaki servis durum: $servisSecildi");
                                        print("asagisi");
                                      }*/

                                      Navigator.pop(context);
                                      reservation();
                                    },
                                    onAcceptTwo: () {
                                      servisSecildi = false;
                                      print(
                                          'Tek saha servisdurum: ${servisSecildi}');
                                      print('Tek saha onAcceeptTwo calisti');
                                      /*         if(haliSaha.servicePlaces.isNotEmpty &&selectedPlace==''){
                                        print("kolman çalıştı servis secildi$servisSecildi");
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Hata'),
                                            content: Text(
                                                'Accepto noktası seçiniz'),
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
                                      }*/

                                      /* else if(!servisSecildi==true){
                                        print("asagidaki servis durum: $servisSecildi");
                                        print("asagisi");
                                      }*/

                                      Navigator.pop(context);
                                      reservation();
                                    },
                                    onSelectPlace: (val) {
                                      print("asagidaki onSelect calisdi");
                                      setState(() {
                                        selectedPlace = val;
                                      });
                                    },
                                    textEditingController: notesController,
                                  );
                                }),
                              );
                            });
                          },
                          haliSaha: haliSaha,
                        ),
                      ),
                      Center(
                        child: Wrap(
                          direction: Axis.horizontal,
                          spacing: 16,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                    radius: 6,
                                    backgroundColor: Colors.purpleAccent),
                                SizedBox(width: 6),
                                Text('Abonelik')
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                    radius: 6, backgroundColor: Colors.green),
                                SizedBox(width: 6),
                                Text('Boş'),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                    radius: 6, backgroundColor: Colors.red),
                                SizedBox(width: 6),
                                Text('Dolu'),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                    radius: 6, backgroundColor: Colors.orange),
                                SizedBox(width: 6),
                                Text('Bekliyor'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSecondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildTitle('Halı Saha Açıklaması'),
                            const SizedBox(height: 10),
                            Text(haliSaha.description),
                            buildDivider(),
                            buildTitle('Halı Saha Fiyatı'),
                            const SizedBox(height: 10),
                            Text(haliSaha.price.toString() + '₺'),
                            buildDivider(),
                            buildTitle('Adres'),
                            const SizedBox(height: 10),
                            Text(
                                '${haliSaha.city}, ${haliSaha.district}, ${haliSaha.fullAdress}'),
                            buildDivider(),
                            buildTitle('Halı Saha Tesis Özellikleri'),
                            const SizedBox(height: 10),
                            Wrap(
                              children: haliSaha.features
                                  .map(
                                    (feature) => Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/features/' +
                                                features
                                                    .where((element) =>
                                                        element.name == feature)
                                                    .first
                                                    .image,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                            fit: BoxFit.contain,
                                            scale: 2.5,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                              iconToTurkish[features
                                                      .where((element) =>
                                                          element.name ==
                                                          feature)
                                                      .first
                                                      .image
                                                      .replaceAll(
                                                          '.png', '')] ??
                                                  '',
                                              style: TextStyle(fontSize: 12))
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSecondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Builder(builder: (context) {
                          if (!commentsLoaded) {
                            return const SizedBox(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return Column(
                            children: [
                              Row(
                                children: [
                                  const Expanded(child: SizedBox()),
                                  Expanded(
                                    child:
                                        Center(child: buildTitle('Yorumlar')),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AllComments(
                                                            haliSaha:
                                                                haliSaha)));
                                          },
                                          child: const Text(
                                            'Tümü',
                                            style:
                                                TextStyle(color: Colors.blue),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              for (var comment in comments)
                                CommentWidget(comment: comment),
                              if (userModel != null &&
                                  userModel.reservations.any((element) =>
                                      element['hs_user_id'] == haliSaha.id))
                                Column(
                                  children: [
                                    RatingStars(
                                      value: rating ?? 0,
                                      onValueChanged: (val) {
                                        setState(() {
                                          rating = val;
                                        });
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: commentController,
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: 'Yorum Yap',
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              sendComment(haliSaha);
                                            },
                                            icon: const Icon(Icons.send),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                );
              }),
        );
      }
    });
  }

  Text buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    );
  }

  Column buildDivider() {
    return Column(
      children: const [
        SizedBox(height: 10),
        Divider(),
        SizedBox(height: 10),
      ],
    );
  }

  awaitApiService() {}
}

class ReservationAcceptBottomSheet extends StatefulWidget {
  const ReservationAcceptBottomSheet({
    Key? key,
    required this.price,
    required this.servisUcreti,
    required this.date,
    required this.hours,
    required this.places,
    required this.commission,
    this.onAccept,
    this.onAcceptTwo,
    this.onServisFalse,
    this.onServisTrue,
    this.servisVarmi = false,
    required this.onSelectPlace,
    required this.textEditingController,
    required this.selectedPlace,
    required this.servisSecildi,
  }) : super(key: key);

  final String price, date, hours, selectedPlace;
  final List places;
  final void Function()? onAccept; //bottomSheet
  final void Function()? onServisFalse; //bottomSheet
  final void Function()? onServisTrue; //bottomSheet
  final void Function()? onAcceptTwo; //bottomSheet
  final void Function(String) onSelectPlace;
  final TextEditingController textEditingController;

  final double commission;
  final bool servisVarmi;
  final bool servisSecildi;
  final int servisUcreti;

  @override
  State<ReservationAcceptBottomSheet> createState() =>
      _ReservationAcceptBottomSheetState();
}

class _ReservationAcceptBottomSheetState
    extends State<ReservationAcceptBottomSheet> {
  bool servisVarmi = false;
  bool resAcceptServisSecildi = false;
  bool servisSecildMi = false;
  TextEditingController noteController = TextEditingController();
  get onServisFalse => onServisFalse;

  get onServisTrue => null;

  @override
  Widget build(BuildContext context) {
    HaliSaha? haliSaha;
    return Material(
      borderRadius: BorderRadius.circular(20),
      child: SingleChildScrollView(
        child: Container(
          height: 1000,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Rezervasyon özeti',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 30),

              ListTile(
                title: Text(
                  'Tarih',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: Text(
                  widget.date,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Saat',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                trailing: Text(
                  widget.hours,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Divider(),
              ListTile(
                title: Text(
                  'Kapora Tutarı',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                trailing: Text(
                  
                  widget.commission.toString() + ' ₺',
                  /* resAcceptServisSecildi == true
                      ? ((int.parse(widget.servisUcreti.toString()) / 14) +
                              widget.commission)
                          .toString()
                      : widget.commission.toString() + '₺', */
                    
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Divider(),
             
              Builder(
                builder: (context) {
                  // if (widget.selectedPlace.isEmpty) {
                  //   print("servis yok");

                  //  // (int.parse(widget.price) * widget.servisUcreti);
                  //   return Center(
                  //     child: Text(
                  //       'Servis yok',
                  //       style:
                  //           TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  //     ),
                  //   );
                  // }

                  //  else {

                  return Column(
                    children: [
                      if (resAcceptServisSecildi == true) ...[
                      /* Container(
                                child: ListTile(
                                  title: Text('Servis Ücreti'),
                                  trailing: Text(
                                    (widget.servisUcreti).toString() + ' ₺',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),  
                              Divider(), */
                      
                        resAcceptServisSecildi == true
                            ?   ListTile(
                            title: Text('Tesiste Ödenecek\nTutar'),
                            trailing: resAcceptServisSecildi == true
                                ? Text(
                                  (
                                    
                                    int.parse(widget.price) +
                                        double.parse(widget.servisUcreti.toString())-double.parse(widget.commission.toString()))
                                    .toString() +
                                "₺")
                                : Text(
                                    widget.price,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ))
                            : SizedBox(),
                        Text(
                          'Servis Kalkış Noktası ',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 10),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 5,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          children: [
                            for (var place in widget.places)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    widget.onSelectPlace(place);
                                  });
                                },
                                child: SelectPlaceWidget(
                                  place: place,
                                  selected: widget.selectedPlace == place,
                                ),
                              ),
                          ],
                        ),
                      ],
                      if (resAcceptServisSecildi == false) ...[
                        ListTile(
                            title: Text('Tesiste Ödenecek\nTutar'),
                            trailing: Text((int.parse(widget.price) -
                                        double.parse(
                                            widget.commission.toString()))
                                    .toString() +
                                "₺")),
                      ],
                      SizedBox(
                        height: 20,
                      ),
                      Divider(),
                      if (widget.servisVarmi == true) ...[
                        CheckboxListTile(
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: resAcceptServisSecildi,
                          activeColor: Colors.red,
                          onChanged: (degis) {
                            setState(() {
                              resAcceptServisSecildi = degis!;
                              print('Hotmail Degis:${degis}');
                            }); // //servisSecildi==widget.servisVarmi;
                          },
                          title: Text(
                            'Servis Çağırmak İstiyor Musunuz?',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                  //  }else bitiş
                },
              ),
              //   Spacer(),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
              //   children: [
              //     Column(
              //       children: [
              //         Text(
              //           'Tarih',
              //           style: TextStyle(fontSize: 14),
              //         ),
              //         Text(
              //           widget.date,
              //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              //         ),
              //       ],
              //     ),
              //     Column(
              //       children: [
              //         Text(
              //           'Saat',
              //           style: TextStyle(fontSize: 14),
              //         ),
              //         Text(
              //           widget.hours,
              //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
              // SizedBox(height: 30),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
              //   children: [
              //     Column(
              //       children: [
              //         Text(
              //           'Kapora',
              //           style: TextStyle(fontSize: 14),
              //         ),
              //         Text(
              //           (int.parse(widget.price) * widget.commission / 100).toString() + ' ₺',
              //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              //         ),
              //       ],
              //     ),
              //     Column(
              //       children: [
              //         Text(
              //           'Toplam Tutar',
              //           style: TextStyle(fontSize: 14),
              //         ),
              //         Text(
              //           widget.price + ' ₺',
              //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
              const SizedBox(height: 50),

              GestureDetector(
                onTap: resAcceptServisSecildi != true
                    ? widget.onAcceptTwo
                    : widget.onAccept,
                child: Container(
                  height: 45,
                  width: double.infinity,
                  child: Center(
                      child: Text(
                    "Ödemeye Geç",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                  )),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              //
              // MyButton(
              //   text: 'Ödemeye Geç ',
              //   onPressed: resAcceptServisSecildi != true
              //       ? widget.onAcceptTwo
              //       : widget.onAccept,
              // ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectPlaceWidget extends StatelessWidget {
  const SelectPlaceWidget({
    Key? key,
    required this.place,
    required this.selected,
  }) : super(key: key);

  final String place;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: selected ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          place,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: selected ? Colors.white : Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
