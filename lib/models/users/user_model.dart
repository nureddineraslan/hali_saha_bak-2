class UserModel {
  final String fullName;
  final String phone;
  final String email;
  final String city;
  final String district;
  final String fcmToken;
  String? uid, profilePicUrl;
  bool? emailVerified;
  bool smsVerified;
  List reservations, favorites;
  final bool isDeleted;

  UserModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.city,
    required this.district,
    required this.reservations,
    required this.favorites,
    required this.fcmToken,
    this.uid,
    this.emailVerified,
    this.smsVerified = false,
    this.profilePicUrl,
    this.isDeleted = false,
  });

  factory UserModel.fromJson(Map json) {
    return UserModel(
      email: json['email'],
      uid: json['uid'],
      phone: json['phone'],
      fullName: json['fullName'],
      city: json['city'],
      district: json['district'],
      reservations: json['reservations'] ?? [],
      favorites: json['favorites'] ?? [],
      profilePicUrl: json['profilePicUrl'],
      fcmToken: json['fcmToken'] ??
          'clDh5_01RHi8sgft8S_xCV:APA91bGquTbOTV08iW-zBtKWaLR5npmwtO2VYwvoxU08euFVvr1GTdckfc8wr0_ALno8YuCaVWhGbCgxiw7gWUkDiVLrlY26LdIbVAbc0YVZncq4TsdPXGMZQz-v7-60FR2jSmVGagUI',
      emailVerified: json['emailVerified'] ?? false,
      smsVerified: json['smsVerified'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson({
    bool withReservations = true,
    bool withFavorites = true,
  }) {
    Map<String, dynamic> result = {
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'uid': uid,
      'city': city,
      'district': district,
      'hsUser': false,
      'reservations': reservations,
      'favorites': favorites,
      'profilePicUrl': profilePicUrl,
      'fcmToken': fcmToken,
      'emailVerified': emailVerified,
      'smsVerified': smsVerified,
      'isDeleted': isDeleted,
    };

    if (!withReservations) {
      result.remove('reservations');
    }

    if (!withFavorites) {
      result.remove('favorites');
    }

    return result;
  }
}
