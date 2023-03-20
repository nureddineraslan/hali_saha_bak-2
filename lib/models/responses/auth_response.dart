import 'package:firebase_auth/firebase_auth.dart';

class AuthResponse {
  final bool isSuccessful;
  final String message;
  final User? user;

  AuthResponse({required this.isSuccessful, required this.message, this.user});
}
