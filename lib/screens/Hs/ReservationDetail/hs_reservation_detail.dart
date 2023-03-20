import 'package:flutter/material.dart';
import 'package:hali_saha_bak/constants/my_icons.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:hali_saha_bak/screens/Hs/HaliSahaDetail/hali_saha_detail.dart';
import 'package:hali_saha_bak/services/email_service.dart';
import 'package:hali_saha_bak/services/notification_service.dart';
import 'package:hali_saha_bak/services/sms_service.dart';
import 'package:hali_saha_bak/utilities/date_formatters.dart';
import 'package:hali_saha_bak/utilities/my_snackbar.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';

import '../../../services/firestore_service.dart';

class HsReservationDetail extends StatefulWidget {
  const HsReservationDetail({Key? key, required this.reservation}) : super(key: key);

  final Reservation reservation;

  @override
  State<HsReservationDetail> createState() => _HsReservationDetailState();
}

class _HsReservationDetailState extends State<HsReservationDetail> {
  @override
  Widget build(BuildContext context) {
    Reservation reservation = widget.reservation;
    print(reservation.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezervasyon Detayları'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 22),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Durum:',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
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
                  const SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tarih:',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                      Text(
                        reservation.stringDate(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ), const SizedBox(width:35),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tesis No:',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                      Text(
                        widget.reservation.haliSaha.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12
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
              InfoWidget(
                infoKey: 'Müşteri Adı',
                value: reservation.user.fullName,
              ),
              InfoWidget(
                infoKey: 'Rezervasyon ID',
                value: reservation.id.toString(),
              ),
              if(reservation.isManuel!=true)...[
                InfoWidget(
                  infoKey: 'Payment ID',
                  value: reservation.paymentId.toString(),
                ),
              ],
              InfoWidget(
                infoKey: 'Telefon',
                value: reservation.user.phone,
              ),
             if(reservation.isManuel!=true)...[
               InfoWidget(
                 infoKey: 'E-posta',
                 value: reservation.user.email,
               ),
             ],
              InfoWidget(
                infoKey: 'Tarih',
                value: reservation.stringDate(),
              ),
              InfoWidget(
                infoKey: 'Saat',
                value: reservation.hourRange(),
              ),
             reservation.servisSecildi==true? InfoWidget(
                infoKey: 'Servis Kalkış Noktası',
                value: reservation.selectedPlace,
              ):InfoWidget(infoKey: 'Servis Var Mı', value: 'Yok'),
              const Divider(),
     if(reservation.servisSecildi==true)...[
       if(reservation.kapora!=0 && reservation.isManuel!=true)...[
         InfoWidget(
           infoKey: 'Ödenen Kapora',
           value:  ((reservation.servisUcreti/14)+reservation.kapora).toString() + '₺',
         ),
       ]
     ],

     if(reservation.kapora==0)...[

             ],
            /*  if(reservation.isManuel==true )...[
               InfoWidget(
                 infoKey: 'Tesisde Ödenecek Tutar',
                 value:  reservation.servisSecildi==true  ? (reservation.servisUcreti+reservation.price).toString() +'₺':(reservation.price).toString()+'₺',
               ),
             ],if(reservation.isManuel!=true )...[
               InfoWidget(
                 infoKey: 'Ödenen Kapora',
                 value:  reservation.servisSecildi==true  ? (reservation.servisUcreti+reservation.kapora).toString()+'₺':(reservation.kapora ).toString(),
               ),
             ], */
              InfoWidget(
                infoKey: 'Ödeme Yapıldı Mı ?',
                value: (reservation.isManuel == true) ? 'Hayır' : 'Evet',
              ),
              const Divider(),
              const SizedBox(height: 20),
              MyButton(
                text: reservation.status == 2 ? 'İptal Edildi' : 'İptal Et',
                onPressed: reservation.status != 2
                    ? reservation.difference().inHours > -1
                        ? () async {
                            showDialog(
                             useSafeArea: false,
                             useRootNavigator: false,
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Dikkat'),
                                content: Text('Bu rezervasyonu iptal etmek istediğinize emin misiniz?'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Hayır')),
                                  TextButton(
                                      onPressed: () async {
                                        if (reservation.paymentId == null) {
                                          MySnackbar.show(context, message: 'Payment ID alınmamış, iptal edilemez.');
                                          return;
                                        }
                                        // dynamic returning = await ApiService().returnPayment(reservation.paymentId!);
                                        // MySnackbar.show(context, message: returning);

                                        await FirestoreService().setReservationStatus(reservation: reservation, status: 2);
                                        await FirestoreService().addToCancels(reservation);
                                        setState(() {
                                          reservation.status = 2;
                                        });
                                        EmailService().sendEmail(
                                          email: reservation.user.email,
                                          name: reservation.user.fullName,
                                          subject: 'Hali Saha Bak Rezervasyon İptali',
                                          content:
                                              '${reservation.date.toDateString()} günü ${reservation.hourRange()} saatlerinde ${reservation.haliSaha.name} halı sahamız için rezervasyonunuz iptal edilmiştir.',
                                        );

                                        SmsService().send(
                                            number: reservation.user.phone,
                                            text:
                                                '${reservation.date.toDateString()} günü ${reservation.hourRange()} saatlerinde ${reservation.haliSaha.name} halı sahamız için rezervasyonunuz iptal edilmiştir.');

                                        if (reservation.selectedPlace != 'Servis Yok' &&
                                            !reservation.selectedPlace.toLowerCase().replaceAll(' ', '').contains('servisyok') &&
                                            reservation.haliSaha.servicePhoneNumber != '') {
                                          SmsService().send(
                                            number: reservation.haliSaha.servicePhoneNumber,
                                            text:
                                                '${reservation.haliSaha.name} için ${reservation.stringDate()} günü ${reservation.hourRange()} saatleri için rezervasyon iptal edilmiştir.',
                                          );
                                        }

                                        Map? systemVariables = await FirestoreService().getSystemVariables();
                                        if (systemVariables != null) {
                                          if (systemVariables['phone'] != null) {
                                              if(reservation.isManuel==true){
                                                SmsService().send(
                                                    number: systemVariables['phone'],
                                                    text:
                                                    '-Manuel İptal Bildirimi-\n\n${reservation.date.toDateString()} günü ${reservation.hourRange()} saatlerinde ${reservation.haliSaha.name} halı sahasında rezervasyon iptali mevcut Lütfen aksiyon alınız. \n\nReservation ID : ${reservation.id}\n\nHS ID : ${reservation.haliSaha.id}.\n${DateTime.now().toDateStringWithTime()}');

                                              }
                                              if(reservation.isManuel!=true){
                                                SmsService().send(
                                                    number: systemVariables['phone'],
                                                    text:
                                                    '-Rezervasyon İptal Bildirimi-\n\n${reservation.date.toDateString()} günü ${reservation.hourRange()} saatlerinde ${reservation.haliSaha.name} halı sahasında rezervasyon iptali mevcut.Ödemenin iade edilmesi için panelden iyzico iptale tıklayın \n\nReservation ID : ${reservation.id}\n\nHS ID : ${reservation.haliSaha.id}.\n\n${DateTime.now().toDateStringWithTime()}');

                                              }
                                  }
                                          if (systemVariables['email'] != null) {
                                          if(reservation.isManuel==true){
                                              EmailService().sendEmail(
                                                email: '${systemVariables['email']}',
                                                name: 'Admin',
                                                subject: 'Manuel İptali Bildirimi',
                                                content:
                                                    'Manuel iptal bildirimi - \n\n ${reservation.date.toDateString()} günü ${reservation.hourRange()} saatlerinde ${reservation.haliSaha.name} halı sahasında rezervasyon iptali mevcut. Lütfen aksiyon alınız. HS ID : ${reservation.haliSaha.id}. ${DateTime.now().toDateStringWithTime()}');
                                          
                                          }
                                          if(reservation.isManuel!=true){
                                              EmailService().sendEmail(
                                                email: '${systemVariables['email']}',
                                                name: 'Admin',
                                                subject: 'Ödeme İptali Bildirimi',
                                                content:
                                                  '-Rezervasyon İptal Bildirimi-\n\n${reservation.date.toDateString()} günü ${reservation.hourRange()} saatlerinde ${reservation.haliSaha.name} halı sahasında rezervasyon iptali mevcut.Ödemenin iade edilmesi için panelden iyzico iptale tıklayın \n\nReservation ID : ${reservation.id}\n\nHS ID : ${reservation.haliSaha.id}.\n\n${DateTime.now().toDateStringWithTime()}');

                                          }
                                          
                                          }
                                        }

                                        NotificationService().sendNotification(
                                          token: reservation.user.fcmToken,
                                          title: 'Rezervasyonunuz İptal Edildi',
                                          body:
                                              '${reservation.date.toDateString()} günü ${reservation.hourRange()} saatlerinde ${reservation.haliSaha.name} halı sahamız için rezervasyonunuz iptal edilmiştir.',
                                        );

                                        Navigator.pop(context);
                                      },
                                      child: Text('Evet')),
                                ],
                              ),
                            );
                          }
                        : null
                    : null,
              ),
              const SizedBox(height: 20),
              MyButton(
                text: reservation.status == 1 ? 'Onaylandı' : 'Onayla',
                onPressed: reservation.status != 1
                    ? reservation.status == 2
                        ? null
                        : () async {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Dikkat'),
                                content: Text('Bu rezervasyonu onaylamak istediğinize emin misiniz?'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Hayır')),
                                  TextButton(
                                      onPressed: () async {
                                        await FirestoreService().setReservationStatus(
                                          reservation: reservation,
                                          status: 1,
                                        );
                                        await FirestoreService().addToAccepts(reservation);
                                        setState(() {
                                          reservation.status = 1;
                                        });
                                        EmailService().sendEmail(
                                            email: reservation.user.email,
                                            name: reservation.user.fullName,
                                            subject: 'Hali Saha Bak Rezervasyon Onayı',
                                            content:
                                                'Sayın ${reservation.user.fullName}; ${reservation.haliSaha.hsUser.businessName}, ${reservation.haliSaha.name} saat ${reservation.hourRange()} için rezervasyonunuz onaylanmıştır. Lütfen ${reservation.selectedPlace} adresinde servisimizi bekleyin.');

                                        SmsService().send(
                                            number: reservation.user.phone,
                                            text:
                                                reservation.servisSecildi==true? 'Sayın ${reservation.user.fullName}; ${reservation.haliSaha.hsUser.businessName}, ${reservation.haliSaha.name} saat ${reservation.hourRange()} için rezervasyonunuz onaylanmıştır. Lütfen  ${reservation.selectedPlace} adresinde saat ${reservation.startHour-1} de servisimizi bekleyin.':'Sayın ${reservation.user.fullName}; ${reservation.haliSaha.hsUser.businessName}, ${reservation.haliSaha.name} saat ${reservation.hourRange()} için rezervasyonunuz onaylanmıştır.Lütfen ${reservation.hourRange()} vaktinde sahada olunuz'
                                                );

                                        
                                        if(reservation.servisSecildi==true){
                                            SmsService().send(
                                            number: reservation.haliSaha.servicePhoneNumber,
                                            text:
                                       /*          '${reservation.haliSaha.name} için ${reservation.stringDate()} günü ${reservation.hourRange()} saatleri için rezervasyon oluşturulmuştur. Servis kalkış noktası ${reservation.selectedPlace}.',
                                        */  
                                          '-Servis Bildirimi-\n\n  ${reservation.haliSaha.name} için ${reservation.stringDate()} günü ${reservation.hourRange()} saatleri için rezervasyon oluşturulmuştur. Servis kalkış noktası ${reservation.selectedPlace}.'
                                              
                                         );
                                        }

                                        Map? systemVariables = await FirestoreService().getSystemVariables();
                                        if (systemVariables != null) {
                                          if (systemVariables['phone'] != null) {
                                            SmsService().send(
                                                number: systemVariables['phone'],
                                                text:
                                                    '-Onay Bildirimi- \n\n${reservation.date.toDateString()} günü\n\n${reservation.hourRange()} saatlerinde\n\n${reservation.haliSaha.name} halı sahası için rezervasyon onaylanmıştır. Lütfen aksiyon alınız.\n\nPayment ID : ${reservation.paymentId}.\n\nHS ID : ${reservation.haliSaha.id}.\n\Reserv ID:${reservation.id} \n\nİşlemin Tarihi \n${DateTime.now().toDateStringWithTime()}');
                                          }
                                          if (systemVariables['email'] != null) {
                                               EmailService().sendEmail(
                                            email: systemVariables['email'],
                                            name: reservation.user.fullName,
                                            subject: 'Onay Bildirimi',
                                            content:
                                                   '-Onay Bildirimi- \n\n${reservation.date.toDateString()} günü\n\n${reservation.hourRange()} saatlerinde\n\n${reservation.haliSaha.name} halı sahası için rezervasyon onaylanmıştır. Lütfen aksiyon alınız.\n\nPayment ID : ${reservation.paymentId}.\n\nHS ID : ${reservation.haliSaha.id}.\n\Reserv ID:${reservation.id} \n\nİşlemin Tarihi \n${DateTime.now().toDateStringWithTime()}');
                                         
                                           }
                                        }

                                        NotificationService().sendNotification(
                                          
                                          token: reservation.user.fcmToken,
                                          title: 'Rezervasyonunuz Onaylandı',
                                          body:
                                              '${reservation.date.toDateString()} günü ${reservation.hourRange()} saatlerinde ${reservation.haliSaha.name} halı sahamızda bekleriz.',
                                        );

                                        Navigator.pop(context);
                                      },
                                      child: Text('Evet')),
                                ],
                              ),
                            );
                          }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoWidget extends StatelessWidget {
  const InfoWidget({
    Key? key,
    required this.infoKey,
    required this.value,
  }) : super(key: key);

  final String infoKey;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              '$infoKey:',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 6,
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
        Navigator.push(context, MaterialPageRoute(builder: (context) => HaliSahaDetail(haliSaha: reservation.haliSaha)));
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
                                  margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                  height: 12,
                                  child: Image.asset(
                                    'assets/images/features/' + features.where((element) => element.name == feature).first.image,
                                    color: Theme.of(context).colorScheme.onBackground,
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
