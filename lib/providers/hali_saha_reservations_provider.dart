import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:hali_saha_bak/models/users/hs_user_model.dart';

import '../services/firestore_service.dart';

class HaliSahaReservationsProvider extends ChangeNotifier {
  Map<HaliSaha, List<Reservation>> myReservations = {};
  List<Reservation> allReservations = [];
  bool myReservationsGet = false;

  Future<void> getMyReservations({bool force = false, required HsUserModel hsUserModel}) async {
    if (!force && myReservationsGet) {
      return;
    }

    myReservations = await FirestoreService().getHaliSahaReservations(hsUserModel);
    myReservations.forEach((key, value) {
      allReservations.addAll(value);
    });
    myReservationsGet = true;
    notifyListeners();
  }

  int totalReservations() {
    int count = allReservations.length;
    return count;
  }

  int waitingReservations() {
    int count = allReservations.where((element) => element.status == 0).length;

    return count;
  }

  List<Reservation> sortedReservations() {
    List<Reservation> myAllReservations = allReservations;
    myAllReservations.sort((a, b) => b.date.compareTo(a.date));
    return myAllReservations;
  }
}
