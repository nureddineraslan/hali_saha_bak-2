import 'dart:convert';

import 'package:http/http.dart' as http;

class EmailService {
  Future<void> sendEmail({required String email, required String name, required String subject, required String content}) async {
    String apiUrl = 'https://api.sendinblue.com/v3/smtp/email';
    String apiKey = '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';
    Map<String, String> headers = {
      'accept': 'application/json',
      'content-type': 'application/json',
      'api-key': apiKey,
    };

    final body = jsonEncode({
      "sender": {
        "name": "Halı Saha Bak",
        "email": "halisahabak@gmail.com",
      },
      "to": [
        {
          "email": email,
          "name": name,
        }
      ],
      "subject": subject,
      "textContent": content,
    });

    await http.post(Uri.parse(apiUrl), headers: headers, body: body);
  }
}
