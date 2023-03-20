class Comment {
  final int id;
  final double rating;
  final String message;
  final String userUID;
  final String username;
  final String? userProfilePicUrl;
  final String haliSahaId;
  final DateTime createdDate;

  Comment({
    required this.id,
    required this.rating,
    required this.message,
    required this.userUID,
    required this.username,
    required this.userProfilePicUrl,
    required this.haliSahaId,
    required this.createdDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'message': message,
      'userUID': userUID,
      'username': username,
      'userProfilePicUrl': userProfilePicUrl,
      'haliSahaId': haliSahaId,
      'createdDate': createdDate.toString(),
    };
  }

  factory Comment.fromJson(Map json) {
    return Comment(
      id: json['id'],
      rating: json['rating'].runtimeType == int ? json['rating'].toDouble() : json['rating'],
      message: json['message'],
      userUID: json['userUID'],
      username: json['username'],
      userProfilePicUrl: json['userProfilePicUrl'],
      haliSahaId: json['haliSahaId'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}
