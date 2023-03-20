import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';

import '../services/firestore_service.dart';

class UserHaliSahaProvider extends ChangeNotifier {
  List<HaliSaha> haliSahas = [];
  List<HaliSaha> searchedHaliSahas = [];
  bool haliSahasGet = false;
  bool search = false;
  bool searched = false;
  TextEditingController searchController = TextEditingController();

  void openSearch() {
    search = true;
    notifyListeners();
  }

  void closeSearch() {
    print('closeSearch');
    search = false;
    searchController.clear();
    searched = false;
    searchedHaliSahas = [];
    notifyListeners();
  }

  Future<void> searchHaliSahas(String searchText, city) async {
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        closeSearch();
      }
    });
    if (searchText.trim().isEmpty || searchText.isEmpty) {
      searched = false;
      searchedHaliSahas = [];

      notifyListeners();
      return;
    }
    searchedHaliSahas = await FirestoreService().searchHaliSahas(searchText.trim(), city);

    Map<String, List<HaliSaha>> copiedHaliSahas = {};

    //
    searchedHaliSahas.forEach((haliSaha) {
      bool hasSameHaliSaha = searchedHaliSahas.where((element) => element.hsUser.uid == element.hsUser.uid).length != 0;
      if (hasSameHaliSaha) {
        if (copiedHaliSahas[haliSaha.hsUser.uid] != null) {
          copiedHaliSahas[haliSaha.hsUser.uid]!.add(haliSaha);
        } else {
          copiedHaliSahas.addAll({
            haliSaha.hsUser.uid!: [haliSaha]
          });
        }
      }
    });

    if (copiedHaliSahas.entries.isNotEmpty) {
      copiedHaliSahas.entries.forEach((_element) {
        searchedHaliSahas.removeWhere((element) => element.hsUser.uid == _element.value.first.hsUser.uid);
        searchedHaliSahas.add(_element.value.first);
        searchedHaliSahas.where((element) => element.hsUser.uid == _element.value.first.hsUser.uid).first.similarHaliSahas = _element.value;
        _element.value.removeAt(0);
      });
    }
    searched = true;
    notifyListeners();
  }

  Future<void> getHaliSahasByDistrict({bool force = false, required String district,required String city}) async {
    if (!force && haliSahasGet) {
      return;
    }
    haliSahas = [];
    haliSahas = await FirestoreService().getHaliSahasByDistrict(district: district,city: city);

    Map<String, List<HaliSaha>> copiedHaliSahas = {};

    haliSahas.forEach((haliSaha) {
      bool hasSameHaliSaha = haliSahas.where((element) => element.hsUser.uid == element.hsUser.uid).length != 0;
      if (hasSameHaliSaha) {
        if (copiedHaliSahas[haliSaha.hsUser.uid] != null) {
          copiedHaliSahas[haliSaha.hsUser.uid]!.add(haliSaha);
        } else {
          copiedHaliSahas.addAll({
            haliSaha.hsUser.uid!: [haliSaha]
          });
        }
      }
    });

    if (copiedHaliSahas.entries.isNotEmpty) {
      copiedHaliSahas.entries.forEach((_element) {
        haliSahas.removeWhere((element) => element.hsUser.uid == _element.value.first.hsUser.uid);
        haliSahas.add(_element.value.first);
        haliSahas.where((element) => element.hsUser.uid == _element.value.first.hsUser.uid).first.similarHaliSahas = _element.value;
        _element.value.removeAt(0);
      });
    }



    haliSahasGet = true;
    notifyListeners();
  }
}
