import 'dart:convert';

import 'package:hali_saha_bak/models/reservation.dart';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';

class ApiService {
  Future<void> reservationBackend(Reservation reservation) async {
    String smsUrl = 'https://reservation-api.halisahabak.com/sms';
    String reservationUrl = 'https://reservation-api.halisahabak.com/reservation';
    print(reservation.date);
    String date = reservation.date.toUtc().toIso8601String();

    print('date: $date');

    String message = '${reservation.haliSaha.name} adlı halı saha rezervasyonunuz yaklaştı.';
    String phoneNumber = '+9${reservation.user.phone}';

    String haliSahaId = reservation.haliSaha.id;
    String reservationId = reservation.id.toString();
    String paymentTransactionId = reservation.paymentTransactionId!;

    Map smsData = {
      'date': date,
      'message': message,
      'phoneNumber': phoneNumber,
    };
    print('smsData: $smsData');
    http.Response smsRequest = await http.post(Uri.parse(smsUrl), body: smsData);

    Map reservationData = {
      'date': date,
      'reservationId': reservationId,
      'haliSahaId': haliSahaId,
      'paymentTransactionId': paymentTransactionId,
    };
    print('reservationData: $reservationData');
    http.Response reservationRequest = await http.post(Uri.parse(reservationUrl), body: reservationData);

    print('smsRequest.statusCode = ${smsRequest.statusCode}');
    print('smsRequest.body = ${smsRequest.body}');
    print('reservationRequest.statusCode = ${reservationRequest.statusCode}');
    print('reservationRequest.body = ${reservationRequest.body}');
  }

  Future<Map> createHaliSaha({
    required String id,
    required String adress,
    required String taxOffice,
    required String taxNumber,
    required String companyName,
    required String companyEmail,
    required String companyIban,
    required String companyType,
  }) async {
    http.Response response = await http.post(
      Uri.parse('https://halisahabak.com/create.php'),
      body: {
        'id': id,
        'adress': adress,
        'taxOffice': taxOffice,
        'taxNumber': taxNumber,
        'companyName': companyName,
        'companyEmail': companyEmail,
        'companyIban': companyIban,
        'companyType': companyType,
      },
    );

    if (jsonDecode(response.body)['status'] == 'error') {
      return {'status': 'error', 'response': jsonDecode(response.body)['response']};
    } else {
      return {'status': 'success', 'response': jsonDecode(response.body)['response']};
    }
  }

  Future<dynamic> payment({
    required String cardName,
    required String cardNumber,
    required String cardMonth,
    required String cardYear,
    required String cardCvc,
    required String customerName,
    required String customerSurname,
    required String customerPhone,
    required String customerEmail,
    required String customerAdress,
    required String customerCity,
    required String sellerCode,
    required String customerId,
    required double price,
    required int commission,
  }) async {
    print('gelen cardNumber   : $cardNumber');
    print('gelen price   : $price');
    print('gelen commission   : $commission');
    print('customerId : $customerId');
    http.Response response = await http.post(
      Uri.parse('https://halisahabak.com/3Dpayment.php'),
      body: {
        'cardName': cardName,
        'cardNumber': cardNumber.replaceAll(' ', ''),
        'cardMonth': cardMonth,
        'cardYear': cardYear,
        'cardCvc': cardCvc,
        'customerName': customerName,
        'customerSurName': customerSurname,
        'customerPhone': customerPhone,
        'customerEmail': customerEmail,
        'customerAdress': customerAdress,
        'customerCity': customerCity,
        'customerCountry': 'Turkey',
        'customerZipCode': '34379',
        'sellerCode': sellerCode,
        'price': price.toString(),
        'commission': commission.toString(),
        'customerId': randomAlpha(6),
        // 'paymentTransactionId': paymentTransactionId,
      },
    );

    print(response.statusCode);
    print(response.body);

    return (jsonDecode(response.body));
  }

  Future<dynamic> returnPayment(String paymentId) async {
    http.Response response = await http.post(
      Uri.parse('https://halisahabak.com/return.php'),
      body: {
        'paymentId': paymentId,
      },
    );
    return (jsonDecode(response.body));
  }

}
