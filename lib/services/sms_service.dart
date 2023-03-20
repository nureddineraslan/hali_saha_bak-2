import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';

class SmsService {

  //Eski Sms Service
  /*
  Future<void> send({required String number, required String text, String sender = 'HALISAHABAK'}) async {
    String baseUrl =
        "https://api.iletimerkezi.com/v1/send-sms/get/?username=5438755396&password=Halisaha0.&text=${text} SMS ID = ${randomNumeric(3)}&receipents=$number&sender=$sender";

    http.Response response = await http.get(Uri.parse(baseUrl));
   
    print(response.body);
    print(response.statusCode);
  }
*/

  Future<dynamic> send({required String number, required String text, }) async {
    http.Response response = await http.post(
      Uri.parse('https://halisahabak.com/sms.php'),
      body: {
        'text': '${text}',
        'number': '$number',

      },
    );
  
  }

}
