import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';

import '../services/firestore_service.dart';

class UserFavoritesProvider extends ChangeNotifier {
  List<HaliSaha> favoriteHaliSahas = [];
  bool favoriteHaliSahasGet = false;

  Future<void> getfavoriteHaliSahas({bool force = false, required List haliSahaIds}) async {
    if (!force && favoriteHaliSahasGet) {
      return;
    }
    favoriteHaliSahas = await FirestoreService().getHaliSahaByIdList(haliSahaIds);
    favoriteHaliSahasGet = true;
    notifyListeners();
  }

  void addHaliSaha(HaliSaha haliSaha) {
    favoriteHaliSahas.add(haliSaha);
    notifyListeners();
  }

  void removeHaliSaha(HaliSaha haliSaha) {
    favoriteHaliSahas.remove(haliSaha);
    notifyListeners();
  }
}
