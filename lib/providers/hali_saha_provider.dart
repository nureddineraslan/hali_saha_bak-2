import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';

import '../services/firestore_service.dart';

class HaliSahaProvider extends ChangeNotifier {
  List<HaliSaha> myHaliSahas = [];
  bool myHaliSahasGet = false;

  Future<void> getMyHaliSahas({bool force = false}) async {
    if (!force && myHaliSahasGet) {
      return;
    }

    myHaliSahas = await FirestoreService().getMyHaliSahas();
    myHaliSahasGet = true;
    notifyListeners();
  }

  Future<void> editHaliSaha(HaliSaha haliSaha) async {
    await FirestoreService().editHaliSaha(haliSaha);
    myHaliSahas[myHaliSahas.indexWhere((element) => element.id == haliSaha.id)] = haliSaha;
    notifyListeners();
  }

  Future<void> createHaliSaha(HaliSaha haliSaha) async {
    await FirestoreService().createNewHaliSaha(haliSaha);
    myHaliSahas.add(haliSaha);
    notifyListeners();
  }
}
