import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/constants/my_icons.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:hali_saha_bak/screens/User/HaliSahaDetail/hali_saha_detail.dart';
import 'package:hali_saha_bak/services/firestore_service.dart';
import 'package:share/share.dart';

class ReservationDetail extends StatefulWidget {
  const ReservationDetail({Key? key, required this.reservation})
      : super(key: key);

  final Reservation reservation;

  @override
  State<ReservationDetail> createState() => _ReservationDetailState();
}

class _ReservationDetailState extends State<ReservationDetail> {
  @override
  Widget build(BuildContext context) {
    Reservation _reservation = widget.reservation;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezervasyon Detayları'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirestoreService().reservationStream(_reservation),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.data == null) {
              return Center(child: Text('No data'));
            }

            Reservation reservation =
                Reservation.fromJson(snapshot.data!.data()!);

            return SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 22),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Durum:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey),
                            ),
                            Text(
                              reservation.statusString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: reservation.statusColor(),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tarih:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey),
                            ),
                            Text(
                              reservation.stringDate(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rezervasyon\nID:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey),
                            ),
                            Text(
                              reservation.id.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ReservationHaliSahaWidget(reservation: reservation),
                    const Divider(),
                    const SizedBox(height: 20),
                    // InfoWidget(
                    //   infoKey: 'Rezervasyon ID',
                    //   value: reservation.id.toString(),
                    // ),
                    InfoWidget(
                      infoKey: 'Müşteri Adı',
                      value: reservation.user.fullName,
                    ),
                    /*InfoWidget(
                      infoKey: 'Telefon',
                      value: reservation.user.phone,
                    ),*/
                    InfoWidget(
                      infoKey: 'Tesis No',
                      value: reservation.haliSaha.id,
                    ),
                   /* InfoWidget(
                      infoKey: 'E-posta',
                      value: reservation.user.email,
                    ),*/
                    InfoWidget(
                      infoKey: 'Tarih',
                      value: reservation.stringDate(),
                    ),
                    InfoWidget(
                      infoKey: 'Saat',
                      value: reservation.hourRange(),
                    ),
                    InfoWidget(
                      infoKey: reservation.servisSecildi==true? 'Servis Kalkış Noktası':'Servis Var mı',
                      value: reservation.servisSecildi==true? reservation.selectedPlace: 'Yok',
                    ),

                    const Divider(),
                    InfoWidget(
                      infoKey: 'Kapora',
                      value: (reservation.kapora).toString() + '₺',
                    ),
                    InfoWidget(
                      infoKey: 'Toplam Tutar',
                      value: reservation.servisSecildi==true? (reservation.haliSaha.servisUcreti.toString()+reservation.haliSaha.price.toString() +'₺'): (reservation.haliSaha.price.toString() + '₺'),
                    ),
                    const Divider(),
                    if (reservation.notes != null && reservation.notes != '')
                      InfoWidget(
                        infoKey: 'Ek Not',
                        value: reservation.notes!,
                      ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen()));
                        if (Platform.isAndroid) {
                          // Android-specific code
                          //t.ly/5oBj
                          Share.share(
                              ' ${reservation.stringDate()} günü\nHalı Saha Bak Uygulamasından \nAldığımız Maçın Detayları:\n\nSaha: ${reservation.haliSaha.hsUser.businessName} Tesisi\nMaç Saati: ${reservation.hourRange()}\n\nGelmeyi SAKIN UNUTMA!!\n\nHalı Saha Bak Uygulamasını İndirerek\nSende Kolayca Rezervasyon Yapabilirsin \n\nt.ly/5oBj');
                        } else if (Platform.isIOS) {
                          // iOS-specific code
                          Share.share(
                              ' ${reservation.stringDate()} günü\nHalı Saha Bak Uygulamasından \nAldığımız Maçın Detayları:\n\nSaha: ${reservation.haliSaha.hsUser.businessName} Tesisi\nMaç Saati: ${reservation.hourRange()}\n\nGelmeyi SAKIN UNUTMA!!\n\nHalı Saha Bak Uygulamasını İndirerek\nSende Kolayca Rezervasyon Yapabilirsin \n\nt.ly/Mtph');
                       }
                      },
                      child: Text('Paylaş'),
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}

class InfoWidget extends StatelessWidget {
  const InfoWidget({
    Key? key,
    required this.infoKey,
    required this.value,
    this.equalFlex = false,
  }) : super(key: key);

  final String infoKey;
  final String value;
  final bool equalFlex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: !equalFlex ? 4 : 5,
            child: Text(
              '$infoKey:',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: !equalFlex ? 6 : 5,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReservationHaliSahaWidget extends StatelessWidget {
  const ReservationHaliSahaWidget({
    Key? key,
    required this.reservation,
  }) : super(key: key);

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    UserHaliSahaDetail(haliSaha: reservation.haliSaha)));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        height: 80,
        width: double.infinity,
        child: Row(
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  reservation.haliSaha.images.first,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      reservation.haliSaha.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '${reservation.haliSaha.city}/${reservation.haliSaha.district}',
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          children: reservation.haliSaha.features
                              .map(
                                (feature) => Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 2, vertical: 2),
                                  height: 12,
                                  child: Image.asset(
                                    'assets/images/features/' +
                                        features
                                            .where((element) =>
                                                element.name == feature)
                                            .first
                                            .image,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
