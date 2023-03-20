import 'package:firebase_auth/firebase_auth.dart';

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

bool isBetween({required int start, required int end, required int value}) {
  return start <= value && value < end;
}

String getMessageFromErrorCode(FirebaseAuthException error) {
  print(error.code);
  switch (error.code) {
    case "ERROR_EMAIL_ALREADY_IN_USE":
    case "account-exists-with-different-credential":
    case "email-already-in-use":
      return "Bu E-mail zaten kullanılmış.";
    case "ERROR_WRONG_PASSWORD":
    case "wrong-password":
      return "Yanlış e-posta/şifre kombinasyonu.";
    case "ERROR_USER_NOT_FOUND":
    case "user-not-found":
      return "Bu e-posta ile kayıtlı bir kullanıcı bulunamadı.";
    case "ERROR_USER_DISABLED":
    case "user-disabled":
      return "Kullanıcı devre dışı bırakıldı.";
    case "ERROR_TOO_MANY_REQUESTS":
    case "too-many-requests":
    case "operation-not-allowed":
      return "Bu hesaba giriş yapmak için çok fazla istek var.";
    case "ERROR_INVALID_EMAIL":
    case "invalid-email":
      return "Email adresi geçersiz.";
    case "network-request-failed":
      return "İnternetinizi kontrol ediniz.";
    default:
      return "Giriş başarısız. Lütfen tekrar deneyin.";
  }
}
