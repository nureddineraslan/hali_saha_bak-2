import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/auth_status.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/models/users/hs_user_model.dart';
import 'package:hali_saha_bak/models/users/user_model.dart';

import '../models/users/reserv_model.dart';

class UserProvider extends ChangeNotifier {
  HsUserModel? hsUserModel;
  UserModel? userModel;
  ReservModel? reservModel;
  HaliSaha? haliSaha;
  AuthStatus authStatus = AuthStatus.notLoggedIn;

  void setAuthStatus(AuthStatus newAuthStatus) {
    authStatus = newAuthStatus;
    notifyListeners();
  }

  void setHsUserModel(HsUserModel newHsUserModel) {
    hsUserModel = newHsUserModel;
    notifyListeners();
  }

  void setUserModel(UserModel? newUserModel) {
    userModel = newUserModel;
    notifyListeners();
  }


  void notify() {
    notifyListeners();
  }
}
