class HsUserModel {
  final String? hs_id;
  final String name;
  final String businessName;
  final String taxNumber;
  final String phone;
  final String email;
  final String city;
  final String district;
  final String neighborhood;
  final String fcmToken;
  final bool verified;
  bool smsVerified;
  String? uid, profilePicUrl, hsPaymentId;
  bool isDeleted;

  HsUserModel({
    required this.hs_id,
    required this.name,
    required this.businessName,
    required this.taxNumber,
    required this.phone,
    required this.email,
    required this.city,
    required this.district,
    required this.neighborhood,
    required this.verified,
    this.smsVerified = false,
    required this.fcmToken,
    this.uid,
    this.profilePicUrl,
    this.hsPaymentId,
    this.isDeleted = false,
  });

  factory HsUserModel.fromJson(Map json) {
    return HsUserModel(
      hs_id: json['hs_id'],
      name: json['name'],
      businessName: json['businessName'],
      taxNumber: json['taxNumber'],
      phone: json['phone'],
      email: json['email'],
      city: json['city'],
      district: json['district'],
      neighborhood: json['neighborhood'],
      uid: json['uid'],
      verified: json['verified'],
      smsVerified: json['smsVerified'] ?? false,
      profilePicUrl: json['profilePicUrl'],
      fcmToken: json['fcmToken'],
      hsPaymentId: json['hsPaymentId'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'businessName': businessName,
      'taxNumber': taxNumber,
      'phone': phone,
      'email': email,
      'city': city,
      'district': district,
      'neighborhood': neighborhood,
      'uid': uid,
      'hsUser': true,
      'verified': verified,
      'smsVerified': smsVerified,
      'profilePicUrl': profilePicUrl,
      'fcmToken': fcmToken,
      'hs_id': hs_id,
      'hsPaymentId': hsPaymentId,
      'isDeleted': isDeleted,
    };
  }
}
