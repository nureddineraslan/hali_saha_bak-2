import 'package:firebase_auth/firebase_auth.dart';
import 'package:hali_saha_bak/models/responses/auth_response.dart';
import 'package:hali_saha_bak/models/users/hs_user_model.dart';
import 'package:hali_saha_bak/models/users/user_model.dart';
import 'package:hali_saha_bak/services/email_service.dart';
import 'package:hali_saha_bak/services/firestore_service.dart';
import 'package:hali_saha_bak/services/shared_prefs_service.dart';
import 'package:hali_saha_bak/services/sms_service.dart';
import 'package:hali_saha_bak/utilities/extensions.dart';
import 'package:provider/provider.dart';
import 'package:random_string/random_string.dart';

import '../providers/user_provider.dart';

class AuthService {

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirestoreService firestoreService = FirestoreService();

  Future<AuthResponse> hsRegister({required HsUserModel hsUserModel, required String password}) async {
    late UserCredential userCredential;
    try {
      userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: hsUserModel.email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      return AuthResponse(isSuccessful: false, message: getMessageFromErrorCode(error), user: null);
    }

    hsUserModel.uid = userCredential.user!.uid;
    await firestoreService.createNewHsUserModel(hsUserModel: hsUserModel);

    return AuthResponse(isSuccessful: true, message: 'Başarılı', user: userCredential.user);
  }

  Future<AuthResponse> hsLogin({required String email, required String password}) async {
    late UserCredential userCredential;
    try {
      userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      return AuthResponse(isSuccessful: false, message: getMessageFromErrorCode(error), user: null);
    }

    return AuthResponse(isSuccessful: true, message: 'Başarılı', user: userCredential.user);
  }

  Future<AuthResponse> userRegister({required UserModel userModel, required String password}) async {
    late UserCredential userCredential;
    try {
      print('userModel.email: ${userModel.email}');
      userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: userModel.email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      return AuthResponse(isSuccessful: false, message: getMessageFromErrorCode(error), user: null);
    }

    userModel.uid = userCredential.user!.uid;
    await firestoreService.createNewUserModel(userModel: userModel);

    return AuthResponse(isSuccessful: true, message: 'Başarılı', user: userCredential.user);
  }

  Future<String> sendEmailVerification() async {
    String code = randomNumeric(5);
    print('firebaseAuth.currentUser!.email : ${firebaseAuth.currentUser!.email}');
    await EmailService().sendEmail(
      email: firebaseAuth.currentUser!.email!,
      name: 'Halı Saha Bak',
      subject: 'Halı Saha Bak Dünyasına Hoş Geldiniz',
      content: 'Halı Saha Bak ile hızlıca rezervasyon işlemlerini yapabilirsiniz ',
    );
    return code;
  }


  Future<String> sendSmsVerification() async {
    String code = randomNumeric(5);

  EmailService().sendEmail(
    email: firebaseAuth.currentUser!.email!,
    name: 'Halı Saha Bak',
    subject: 'Halı Saha Bak Dünyasına Hoş Geldiniz',
    content: 'Halısahabak Dünyasına Hoş Geldin.Hemen Saha Oluşturarak Müşterilerin Seni Farketmelerini Sağlayabilirsin.Tanıdıklarına Tavsiye Etmeyi Unutma 🤗🤗',
  );
    return code;
  }
  

  User? getUser() {
    return firebaseAuth.currentUser;
  }

  Future<void> logout() async {
    await SharedPrefsService().clearUserType();
    await firebaseAuth.signOut();
  }

  Future<void> sendPasswordLink(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> anonymousSingIn() async {
    await firebaseAuth.signInAnonymously();
  }
}
