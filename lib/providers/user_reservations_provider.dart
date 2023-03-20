import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:hali_saha_bak/models/users/user_model.dart';
import 'package:hali_saha_bak/services/email_service.dart';
import 'package:hali_saha_bak/services/firestore_service.dart';
import 'package:hali_saha_bak/services/notification_service.dart';
import 'package:hali_saha_bak/services/sms_service.dart';
import 'package:hali_saha_bak/utilities/date_formatters.dart';
import 'package:workmanager/workmanager.dart';

class UserReservationsProvider extends ChangeNotifier {
  List<Reservation> myReservations = [];
  bool myReservationsGet = false;
  bool allReservationsGet = false;

  Future<void> getMyReservations({bool force = false, required UserModel userModel, bool all = false}) async {
    if (!force && myReservationsGet || allReservationsGet) {
      return;
    }

    myReservations = await FirestoreService().getMyReservations(userModel, all: all);

    allReservationsGet = true;
    myReservationsGet = true;
    if (all) {
    } else {}

    notifyListeners();
  }

  Future<void> createReservation({required Reservation reservation}) async {
    await FirestoreService().createReservation(reservation: reservation);
     await NotificationService().sendNotification(
      token: reservation.haliSaha.hsUser.fcmToken,
      title: 'Yeni Rezervasyon Yapıldı ⚽',
      body: '${reservation.user.fullName} adlı kullanıcı ${reservation.stringDate()} günü ${reservation.hourRange()} saatleri için rezervasyon yaptı.',
    );
   
    DateTime scheduleDate = DateTime(
      reservation.date.year,
      reservation.date.month,
      reservation.date.day,
      reservation.startHour - 1,
      15,
    );

    Duration difference = scheduleDate.difference(DateTime.now());

    if (!Platform.isIOS) {
      await Workmanager().registerOneOffTask('1', 'test-task-1', initialDelay: difference, inputData: {
        'number': reservation.haliSaha.hsUser.phone,
        'text': 'Saat ${reservation.hourRange()} ⚽ rezervasyonunuz yaklaştı.',
        'email': reservation.user.email,
        'name': reservation.user.fullName,
      });
    }

   if(reservation.status==1){
     await NotificationService().scheduleNotification(
       dateTime: scheduleDate,
       title: '${reservation.haliSaha.hsUser.businessName} tesisi',
       body: 'Saat ${reservation.hourRange()} ⚽ rezervasyonunuz yaklaştı.',
       reservation: reservation,

     );
   }

    EmailService().sendEmail(
      email: reservation.user.email,
      name: reservation.user.fullName,
      subject: 'Rezervasyon Bilgisi',
      content: '${reservation.haliSaha.hsUser.businessName} tesisi için rezervasyonunuz alındı. En kısa sürede dönüş yapılacaktır.',
    );

    EmailService().sendEmail(
      email: reservation.haliSaha.hsUser.email,
      name: reservation.haliSaha.hsUser.email,
      subject: 'Yeni rezervasyon Bildirimi 🔔 ',
      content:
          '${reservation.hourRange()} saati, ${reservation.stringDate()} günü ${reservation.haliSaha.name} adlı halı saha için, ${reservation.user.fullName} tarafından rezervasyon alınmıştır. Lütfen panelinizden ilgili aksiyonu alınız.\n Servis kalkış yeri ${reservation.selectedPlace}\'dir',
    );

    if(reservation.servisSecildi==true){
  SmsService().send(
        number: reservation.haliSaha.hsUser.phone,
        text:
            '${reservation.hourRange()} saati, ${reservation.stringDate()} günü ${reservation.haliSaha.name} adlı halı saha için, ${reservation.user.fullName} tarafından rezervasyon alınmıştır. Lütfen panelinizden ilgili aksiyonu alınız.\n\n -Servis kalkış yeri- \n ${reservation.selectedPlace}\'dir');

             Map? systemVariables = await FirestoreService().getSystemVariables();
                                        if (systemVariables != null) {
                                          if (systemVariables['phone'] != null) {
                                              if(reservation.isManuel==true){
                                                SmsService().send(
                                                    number: systemVariables['phone'],
                                                    text:
                                                    '-Yeni Ödeme Bildirimi-\n\n${reservation.date.toDateString()} günü ${reservation.hourRange()} saatlerinde ${reservation.haliSaha.name} halı sahasında yeni rezervasyon alındı  Lütfen aksiyon alınız. \n\nReservation ID : ${reservation.id}\n\nHS ID : ${reservation.haliSaha.id}.\n${DateTime.now().toDateStringWithTime()}');

                                              }
                                  }
                                          if (systemVariables['email'] != null) {
                                            EmailService().sendEmail(
                                                email: '${systemVariables['email']}',
                                                name: 'Admin',
                                                subject: 'Yeni Ödeme Bildirimi',
                                                content:
                                                                     '-Yeni Ödeme Bildirimi-\n\n${reservation.date.toDateString()} günü ${reservation.hourRange()} saatlerinde ${reservation.haliSaha.name} halı sahasında yeni rezervasyon alındı m Lütfen aksiyon alınız. \n\nReservation ID : ${reservation.id}\n\nHS ID : ${reservation.haliSaha.id}.\n${DateTime.now().toDateStringWithTime()}');

                                          
                                          }
                                        }
    }
    if(reservation.servisSecildi!=true){
       SmsService().send(
        number: reservation.haliSaha.hsUser.phone,
        text:
            '${reservation.hourRange()} saati, ${reservation.stringDate()} günü ${reservation.haliSaha.name} adlı halı saha için, ${reservation.user.fullName} tarafından rezervasyon alınmıştır. Lütfen panelinizden ilgili aksiyonu alınız.\nMüşteri Servis İstemedi ');

   
 Map? systemVariables = await FirestoreService().getSystemVariables();
                                        if (systemVariables != null) {
                                          if (systemVariables['phone'] != null) {
                                             SmsService().send(
                                                    number: systemVariables['phone'],//'05438755396',
                                                    text:
                                                    '-Yeni Ödeme Bildirimi-\n\n${reservation.date.toDateString()} günü ${reservation.hourRange()} saatlerinde ${reservation.haliSaha.name} halı sahasında yeni rezervasyon alındı m Lütfen aksiyon alınız. \n\nReservation ID : ${reservation.id}\n\nHS ID : ${reservation.haliSaha.id}.\n${DateTime.now().toDateStringWithTime()}');

                                  }
                                          if (systemVariables['email'] != null) {
                                            EmailService().sendEmail(
                                                email: '${systemVariables['email']}',
                                                name: 'Admin',
                                                subject: 'Yeni Ödeme Bildirimi',
                                                content:
                                                                     '-Yeni Ödeme Bildirimi-\n\n${reservation.date.toDateString()} günü ${reservation.hourRange()} saatlerinde ${reservation.haliSaha.name} halı sahasında yeni rezervasyon alındı m Lütfen aksiyon alınız. \n\nReservation ID : ${reservation.id}\n\nHS ID : ${reservation.haliSaha.id}.\n${DateTime.now().toDateStringWithTime()}');

                                          
                                          }
                                        }
    }
   
    myReservations.add(reservation);

    myReservationsGet = false;

    notifyListeners();
  }
}
