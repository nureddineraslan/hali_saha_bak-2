import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/models/il_ilce_model.dart';
import 'package:hali_saha_bak/services/firestore_service.dart';

class GuestProvider extends ChangeNotifier {
  Il? selectedIl;
  Ilce? selectedIlce;

  List<HaliSaha> haliSahaList = [];

  TextEditingController ilController = TextEditingController();
  TextEditingController ilceController = TextEditingController();

  bool haliSahasGet = false;

  Future<void> getHaliSahaList() async {
    haliSahaList = await FirestoreService().getHaliSahasByDistrict(district: selectedIlce!.ilceAdi,city: selectedIl!.ilAdi);
    haliSahasGet = true;
    notifyListeners();

  }
}
