import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hali_saha_bak/main.dart';
import 'package:hali_saha_bak/models/comment.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:hali_saha_bak/models/users/hs_user_model.dart';
import 'package:hali_saha_bak/models/responses/get_user_response.dart';
import 'package:hali_saha_bak/models/users/user_model.dart';
import 'package:hali_saha_bak/services/auth_service.dart';

class FirestoreService {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future<List> filterHaliSahas(String key) async {
    QuerySnapshot querySnapshot = await firebaseFirestore.collection('hali_sahas').where('name', isEqualTo: key).get();
    querySnapshot.docs.map((e) => print(e.data()));
    return querySnapshot.docs.map((e) => HaliSaha.fromJson(e.data() as Map)).toList();
  }

  Future<void> createNewHsUserModel({required HsUserModel hsUserModel}) async {
    await firebaseFirestore.collection('hs_users').doc(hsUserModel.uid).set(hsUserModel.toJson());
  }


  Future<void> createNewUserModel({required UserModel userModel}) async {
    await firebaseFirestore.collection('users').doc(userModel.uid).set(userModel.toJson());
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await firebaseFirestore.collection('system').doc('statistics').get();
    Map mRservationsCount = (documentSnapshot.data() as Map)['mUsersCount'] as Map;
    if (mRservationsCount[DateTime.now().month.toString()] != null) {
      mRservationsCount[DateTime.now().month.toString()] = (mRservationsCount[DateTime.now().month] ?? 0) + 1;
    } else {
      mRservationsCount[DateTime.now().month.toString()] = 1;
    }
    await firebaseFirestore.collection('system').doc('statistics').update({
      'mUsersCount': mRservationsCount,
    });
  }
  Future<void> updateUserSmsStatus(String uid) async {
    await firebaseFirestore.collection('users').doc(uid).update({'smsVerified': true });
  }
  Future<void> updateHsUserSmsStatus(String uid) async {
    await firebaseFirestore.collection('hs_users').doc(uid).update({'smsVerified': true });
  }
  Future<void> updateUserModel({required UserModel userModel}) async {
    await firebaseFirestore.collection('users').doc(userModel.uid).update(userModel.toJson());
  }

  Future<void> updateHsUserToken(String token, String uid) async {
    await firebaseFirestore.collection('hs_users').doc(uid).update({'fcmToken': token});
  }

  Future<void> updateUserToken(String token, String uid) async {
    await firebaseFirestore.collection('users').doc(uid).update({'fcmToken': token});
  }

  Future<void> updateHsUserModel({required HsUserModel hsUserModel}) async {
    print(hsUserModel.uid);
    await firebaseFirestore.collection('hs_users').doc(hsUserModel.uid).update(hsUserModel.toJson());
  }

  Future<GetUserResponse> getUser({required bool hsUser}) async {
    final String colName = hsUser ? 'hs_users' : 'users';

    try {
      User? user = AuthService().getUser();
     // print('user!.uid: ${user!.uid}');
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await firebaseFirestore.collection(colName).doc(user?.uid).get();

     // print('documentSnapshot data: ${documentSnapshot.data()}');
   
      Map data = documentSnapshot.data()!;

      bool hsUser = data['hsUser'] ?? false;

      late HsUserModel hsUserModel;
      late UserModel userModel;

      String token = await firebaseMessaging.getToken() ?? '';

      if (hsUser) {
       // print('data: ${data}');
        hsUserModel = HsUserModel.fromJson(data);

        if (token.isNotEmpty && token != hsUserModel.fcmToken) {
          await FirestoreService().updateHsUserToken(token, hsUserModel.uid!);
        }

        return GetUserResponse(isSuccessful: true, message: 'Başarılı', user: hsUserModel, hsUser: true);
      } else {
        userModel = UserModel.fromJson(data);

        if (token.isNotEmpty && token != userModel.fcmToken) {
          await FirestoreService().updateUserToken(token, userModel.uid!);
        }

        return GetUserResponse(isSuccessful: true, message: 'Başarılı', user: userModel, hsUser: false);
      }
    } catch (e) {
      return GetUserResponse(isSuccessful: false, message: e.toString(), hsUser: null);
    }
  }

  Future<void> createNewHaliSaha(HaliSaha haliSaha) async {
    await firebaseFirestore.collection('hali_sahalar').doc(haliSaha.id).set(haliSaha.toJson());
    await firebaseFirestore.collection('hali_sahalar').doc(haliSaha.id).collection('comments').doc('ratings').set({});
  }

  Future<void> editHaliSaha(HaliSaha haliSaha) async {
    await firebaseFirestore.collection('hali_sahalar').doc(haliSaha.id).update(haliSaha.toJson());
  }


  Future<List<HaliSaha>> getMyHaliSahas() async {
    User? user = AuthService().getUser();
    if (user == null) {
      return [];
    }
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await firebaseFirestore.collection('hali_sahalar').where('hsUser.uid', isEqualTo: user.uid).get();

    List<HaliSaha> myHaliSahas = querySnapshot.docs.map((e) => HaliSaha.fromJson(e.data())).toList();

    return myHaliSahas;
  }

  Future<List<HaliSaha>> getHaliSahasByDistrict({required String district,required String city}) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await firebaseFirestore.collection('hali_sahalar').where('city', isEqualTo: city).where('district',isEqualTo: district).get();
    List<HaliSaha> myHaliSahas = querySnapshot.docs.map((e) => HaliSaha.fromJson(e.data())).toList();
    for (var element in myHaliSahas) {
      element.averageRating = await getHaliSahaAverageRating(element);
    }
    return myHaliSahas;
  }Future<List<HaliSaha>> getHaliSaha({required String id}) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await firebaseFirestore.collection('hali_sahalar').get();
    List<HaliSaha> myHaliSahas = querySnapshot.docs.map((e) => HaliSaha.fromJson(e.data())).toList();
    for (var element in myHaliSahas) {
      element.averageRating = await getHaliSahaAverageRating(element);
    }
    return myHaliSahas;
  }

  Future<void> createReservation({required Reservation reservation, bool guest = false}) async {
    DocumentSnapshot<Map<String, dynamic>> userDocumentSnapshot = await firebaseFirestore.collection('users').doc(reservation.user.uid).get();
    List userReservations = userDocumentSnapshot.data() == null ? [] : (userDocumentSnapshot.data() as Map)['reservations'] ?? [];

    userReservations.add({
      'reservation_id': reservation.id,
      'hs_user_id': reservation.haliSaha.id,
    });

    if (!guest) {
      await firebaseFirestore.collection('users').doc(reservation.user.uid).update({
        'reservations': userReservations,
      });
    }

    await firebaseFirestore.collection('hali_sahalar').doc(reservation.haliSaha.id).collection('reservations').doc(reservation.id.toString()).set(
          reservation.toJson(),
        );

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await firebaseFirestore.collection('system').doc('statistics').get();
    Map mRservationsCount = (documentSnapshot.data() as Map)['mReservationsCount'] as Map;
    if (mRservationsCount[DateTime.now().month.toString()] != null) {
      (mRservationsCount[DateTime.now().month.toString()] = mRservationsCount[DateTime.now().month] ?? 0) + 1;
    } else {
      mRservationsCount[DateTime.now().month.toString()] = 1;
    }
    await firebaseFirestore.collection('system').doc('statistics').update({
      'mReservationsCount': mRservationsCount,
    });
  }

  Future<List<Reservation>> getMyReservations(UserModel userModel, {bool all = false}) async {
    List mapReservations = userModel.reservations;
    List<Reservation> reservations = [];

    int length = all ? mapReservations.length : 8;

    for (var i = 0; i < length; i++) {
      Map reservation = mapReservations[i];
      String hsUserId = reservation['hs_user_id'];
      int reservationId = reservation['reservation_id'];

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await firebaseFirestore.collection('hali_sahalar').doc(hsUserId).collection('reservations').where('id', isEqualTo: reservationId).get();

      for (var item in querySnapshot.docs) {
        reservations.add(Reservation.fromJson(item.data()));
      }
    }
    reservations.sort(((a, b) => b.createdDate.compareTo(a.createdDate)));
    return reservations;
  }

  Future<Map<HaliSaha, List<Reservation>>> getHaliSahaReservations(HsUserModel hsUserModel) async {
    Map<HaliSaha, List<Reservation>> reservations = {};
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await firebaseFirestore.collection('hali_sahalar').where('hsUser.uid', isEqualTo: hsUserModel.uid).get();

    for (var element in querySnapshot.docs) {
      await firebaseFirestore.collection('hali_sahalar').doc(element.id).collection('reservations').get().then((value) {
        List<Reservation> data = value.docs.map((e) => Reservation.fromJson(e.data())).toList();
        data.sort(((a, b) => b.date.compareTo(a.date)));
        reservations.putIfAbsent(HaliSaha.fromJson(element.data()), () => data);
      });
    }
    return reservations;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> haliSahaStream(HaliSaha haliSaha) {
    return firebaseFirestore.collection('hali_sahalar').doc(haliSaha.id).collection('reservations').snapshots();
  }

  Future<void> setReservationStatus({required Reservation reservation, required int status}) async {
    await firebaseFirestore.collection('hali_sahalar').doc(reservation.haliSaha.id).collection('reservations').doc(reservation.id.toString()).update({
      'status': status,
    });
  }

  Future<void> addToCancels(Reservation reservation) async {
    await firebaseFirestore.collection('hali_saha_iptaller').add({
      'reservationId': reservation.id,
      'haliSahaId': reservation.haliSaha.id,
      'archive': false,
    });
  }

  Future<void> addToAccepts(Reservation reservation) async {
    await firebaseFirestore.collection('hali_saha_onaylar').add({
      'reservationId': reservation.id,
      'haliSahaId': reservation.haliSaha.id,
      'archive': false,
    });
  }

  Future<List<HaliSaha>> getHaliSahaByIdList(List ids) async {
    List<HaliSaha> haliSahas = [];
    for (var id in ids) {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await firebaseFirestore.collection('hali_sahalar').doc(id).get();
      HaliSaha haliSaha = HaliSaha.fromJson(documentSnapshot.data() as Map);
      haliSahas.add(haliSaha);
    }

    return haliSahas;
  }

  Future<List<Comment>> getHaliSahaComments(HaliSaha haliSaha, {bool all = false}) async {
    Query query = firebaseFirestore.collection('hali_sahalar').doc(haliSaha.id).collection('comments');
    QuerySnapshot<Object?> querySnapshot;
    if (all) {
      querySnapshot = await query.get();
    } else {
      querySnapshot = await query.limit(5).get();
    }

    querySnapshot.docs.removeWhere((element) => element.id == 'ratings');
    List<Comment> comments = [];

    for (var e in querySnapshot.docs) {
      if (e.id != 'ratings') {
        comments.add(Comment.fromJson(e.data() as Map));
      }
    }

    return comments;
  }

  Future<void> sendComment(Comment comment) async {
    await firebaseFirestore.collection('system').doc('waiting_comments').collection('comments').add(comment.toJson());
    // await firebaseFirestore.collection('hali_sahalar').doc(comment.haliSahaId).collection('comments').doc('ratings').update({
    //   '${DateTime.now().millisecondsSinceEpoch}': comment.rating,
    // });
    // await firebaseFirestore.collection('hali_sahalar').doc(comment.haliSahaId).collection('comments').doc(comment.id.toString()).set(comment.toJson());
  }

  Future<double> getHaliSahaAverageRating(HaliSaha haliSaha) async {
    double average = 0;
    await firebaseFirestore.collection('hali_sahalar').doc(haliSaha.id).collection('comments').doc('ratings').get().then((value) {
      if (value.exists && value.data() != null) {
        Map ratings = value.data() as Map;
        if (ratings.isEmpty) {
          return 0;
        }
        double sum = 0;
        ratings.forEach((key, value) {
          sum += value;
        });
        average = sum / ratings.length;
        average = double.parse(average.toStringAsFixed(2));
      }
    });
    return average;
  }

  void setCode({required String uid, required String code}) {
    firebaseFirestore.collection('users').doc(uid).update({
      'code': code,
    });
  }

  void setHsCode({required String uid, required String code}) {
    firebaseFirestore.collection('hs_users').doc(uid).update({
      'code': code,
    });
  }

  Future<List<HaliSaha>> searchHaliSahas(String searchText, String city) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await firebaseFirestore.collection('hali_sahalar').get();
    List<HaliSaha> myHaliSahas = querySnapshot.docs.map((e) => HaliSaha.fromJson(e.data())).toList();
    for (var element in myHaliSahas) {
      element.averageRating = await getHaliSahaAverageRating(element);
    }
    myHaliSahas
        .removeWhere((HaliSaha element) => element.hsUser.businessName.toLowerCase().contains(searchText.toLowerCase()) == false || element.city != city);
    return myHaliSahas;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> reservationStream(Reservation reservation) {
    Stream<DocumentSnapshot<Map<String, dynamic>>> stream =
        firebaseFirestore.collection('hali_sahalar').doc(reservation.haliSaha.id).collection('reservations').doc(reservation.id.toString()).snapshots();
    return stream;
  }

  Future<int> getCommission() async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await firebaseFirestore.collection('system').doc('values').get();
    var commission = (documentSnapshot.data() as Map)['commission'];
    return commission;
  }

  Future<Map<String, dynamic>?> getSystemVariables() async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await firebaseFirestore.collection('system').doc('variables').get();
    if (documentSnapshot.exists) {
      return documentSnapshot.data();
    }
    return null;
  }

  Future<void> updateIsDeleted({required String uid, required bool isDeleted, required bool hsUser}) async {
    await firebaseFirestore.collection(hsUser ? 'hs_users' : 'users').doc(uid).update({
      'isDeleted': isDeleted,
    });
  }
}
