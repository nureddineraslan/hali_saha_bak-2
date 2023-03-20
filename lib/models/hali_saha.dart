import 'package:hali_saha_bak/models/users/hs_user_model.dart';

class HaliSaha {
  final String name, description, city, district, fullAdress, id;
  final List images, features;
  final HsUserModel hsUser;
  final int price;
  final List priceRanges;
  final List closedRanges;
  final List subscriberRanges;
  final List servicePlaces;
  final double kapora;
  final int servisUcreti;
   
  final double iyzicoComission;
  double? averageRating;
  List<HaliSaha> similarHaliSahas;
  String? zSearchKey;
  final String servicePhoneNumber;
  bool servisVarmi=false;


  HaliSaha({
    required this.name,
    required this.description,
    required this.city,
    required this.district,
    required this.fullAdress,
    required this.images,
    required this.features,
    required this.id,
    required this.hsUser,
    required this.price,
    required this.priceRanges,
    required this.closedRanges,
    required this.subscriberRanges,
    required this.servicePlaces,
    required this.servisVarmi,


    required this.kapora,
    required this.servisUcreti,
    this.iyzicoComission = 20,
    this.similarHaliSahas = const [],
    this.zSearchKey,
    required this.servicePhoneNumber,
  });

  factory HaliSaha.fromJson(Map json) {
    return HaliSaha(
      name: json['name'],
      description: json['description'],
      city: json['city'],
      district: json['district'],
      fullAdress: json['fullAdress'],
      images: json['images'],
      features: json['features'],
      id: json['id'],
      hsUser: HsUserModel.fromJson(json['hsUser']),
      price: json['price'],
      
      priceRanges: json['priceRanges'] ?? [],
      closedRanges: json['closedRanges'] ?? [],
      subscriberRanges: json['subscriberRanges'] ?? [],
      servicePlaces: json['servicePlaces'] ?? [],
      
      servisUcreti: json['servisUcreti'] != null
          ? json['servisUcreti'].toInt()
          : 100.toInt(),
      kapora:
          json['kapora'] != null ? json['kapora'].toDouble() : 50.toDouble(),
      iyzicoComission: json['iyzicoComission'] != null
          ? json['iyzicoComission'].toDouble()
          : 20,
      servicePhoneNumber: json['servicePhoneNumber'] ?? '',
      servisVarmi: json['servisVarmi']??false,

   );
  }

  Map<String, dynamic> toJson({bool withReservations = true}) {
    Map<String, dynamic> result = {
      'name': name,
      'description': description,
      'city': city,
      'district': district,
      'fullAdress': fullAdress,
      'images': images,
      'features': features,
      'id': id,
      'hsUser': hsUser.toJson(),
      'price': price,
      'priceRanges': priceRanges,
      'closedRanges': closedRanges,
      'subscriberRanges': subscriberRanges,
      'servicePlaces': servicePlaces,
      'searchKey': name.toLowerCase(),
      'kapora': kapora,
      'servisUcreti': servisUcreti,
      'servisVarmi': servisVarmi,

      'iyzicoComission': iyzicoComission,
      'servicePhoneNumber': servicePhoneNumber,
    };

    if (!withReservations) {
      result.remove('reservations');
    }

    return result;
  }
}
