import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/constants/my_icons.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:hali_saha_bak/screens/Hs/EditHaliSaha/edit_hali_saha.dart';
import 'package:hali_saha_bak/screens/Hs/HsManuelNewReservation/hs_manuel_new_reservation.dart';
import 'package:hali_saha_bak/utilities/enums.dart';
import 'package:hali_saha_bak/utilities/extensions.dart';
import 'package:hali_saha_bak/widgets/hs_reservation_table.dart';
import 'package:hali_saha_bak/widgets/hs_reservations_tile.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../models/comment.dart';
import '../../../providers/hali_saha_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/comment_widget.dart';
import '../../Global/image_view.dart';
import '../../User/AllComments/all_comments.dart';
import '../HaliSahaAllReservations/hali_saha_all_reservations.dart';

class HaliSahaDetail extends StatefulWidget {
  final HaliSaha haliSaha;
  const HaliSahaDetail({Key? key, required this.haliSaha}) : super(key: key);

  @override
  State<HaliSahaDetail> createState() => _HaliSahaDetailState();
}

class _HaliSahaDetailState extends State<HaliSahaDetail> {
  PageController controller = PageController();

  DateTime selectedDate = DateTime.now();
  int? selectedHour;
  String price = '';

  bool commentsLoaded = false;
  List<Comment> comments = [];

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

  @override
  Widget build(BuildContext context) {
    HaliSahaProvider haliSahaProvider = Provider.of<HaliSahaProvider>(context);
    HaliSaha haliSaha = haliSahaProvider.myHaliSahas[haliSahaProvider.myHaliSahas.indexWhere((element) => element.id == widget.haliSaha.id)];
    return Scaffold(
      appBar: AppBar(
        title: Text(haliSaha.name),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditHaliSaha(haliSaha: haliSaha),
                  ),
                );
              },
              icon: const Icon(Icons.edit)),
        ],
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

            List<Reservation> reservations = snapshot.data!.docs.map((doc) => Reservation.fromJson(doc.data())).toList();
            reservations.sort((a, b) => a.date.compareTo(b.date));

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 240,
                    child: PageView.builder(
                      controller: controller,
                      // itemCount: pages.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageView(images: haliSaha.images, index: index % haliSaha.images.length),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey.shade300,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: SizedBox(
                              height: 280,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: haliSaha.images[index % haliSaha.images.length],
                                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: HsReservationsTable(
                      haliSaha: haliSaha,
                      tableTitle: 'Rezervasyon Tablosu',
                      decreaseDate: () {
                        selectedDate = selectedDate.subtract(const Duration(days: 1));
                        selectedHour = -1;
                        setState(() {});
                      },
                      increaseDate: () {
                        selectedDate = selectedDate.add(const Duration(days: 1));
                        selectedHour = -1;
                        setState(() {});
                      },
                      selectedDate: selectedDate,
                      selectedHour: selectedHour,
                      reservations: reservations,
                      onHourSelected: (val) {
                        if (selectedHour != null &&
                            haliSaha.priceRanges.any((element) => isBetween(start: element['start'], end: element['end'], value: selectedHour!))) {
                          price = haliSaha.priceRanges
                              .where((element) => isBetween(start: element['start'], end: element['end'], value: selectedHour!))
                              .first['price']
                              .toString();
                        } else {
                          price = haliSaha.price.toString();
                        }

                        int? priceNum = int.tryParse(price);

                        setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HsManuelNewReservation(
                                selectedDate: selectedDate,
                                startHour: selectedHour!,
                                endHour: selectedHour! + 1,
                                price: priceNum!,
                                haliSaha: haliSaha,
                              ),
                            ),
                          );
                          selectedHour = val;
                          // reservation();
                        });
                      },
                    ),
                  ),
                  Center(
                    child: Wrap(
                      direction: Axis.horizontal,
                      spacing: 16,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [CircleAvatar(radius: 6, backgroundColor: Theme.of(context).colorScheme.onTertiary), SizedBox(width: 6), Text('Abonelik')],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 6, backgroundColor: Colors.green),
                            SizedBox(width: 6),
                            Text('Boş'),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 6, backgroundColor: Colors.red),
                            SizedBox(width: 6),
                            Text('Dolu'),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 6, backgroundColor: Colors.orange),
                            SizedBox(width: 6),
                            Text('Bekliyor'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Son Rezervasyonlar',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HaliSahaAllReservations(
                                    haliSaha: haliSaha,
                                    reservations: reservations,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Tümü'))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        if (reservations.length > 5)
                          for (var i = 0; i < 5; i++) HsReservationTile(reservation: reservations[i])
                        else
                          for (var reservation in reservations) HsReservationTile(reservation: reservation),
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
                        buildTitle('Standart Fiyatı'),
                        const SizedBox(height: 10),
                        Text(haliSaha.price.toString() + '₺'),
                        buildDivider(),
                        buildTitle('Adres'),
                        const SizedBox(height: 10),
                        Text('${haliSaha.city}, ${haliSaha.district}, ${haliSaha.fullAdress}'),
                        buildDivider(),
                        buildTitle('Halı Saha Tesis Özellikleri'),
                        const SizedBox(height: 10),
                        Wrap(
                          children: haliSaha.features
                              .map(
                                (feature) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/features/' + features.where((element) => element.name == feature).first.image,
                                        color: Theme.of(context).colorScheme.onBackground,
                                        fit: BoxFit.contain,
                                        scale: 2.5,
                                      ),
                                      SizedBox(height: 8),
                                      Text(iconToTurkish[features.where((element) => element.name == feature).first.image.replaceAll('.png', '')] ?? '',
                                          style: TextStyle(fontSize: 12))
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 30),
                        // MyButton(text: 'Rezervasyon Yap', onPressed: () {}),
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
                                child: Center(child: buildTitle('Yorumlar')),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => AllComments(haliSaha: haliSaha)));
                                      },
                                      child: const Text(
                                        'Tümü',
                                        style: TextStyle(color: Colors.blue),
                                      )),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          for (var comment in comments) CommentWidget(comment: comment),
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
}
