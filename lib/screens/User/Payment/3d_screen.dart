import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:hali_saha_bak/providers/user_reservations_provider.dart';
import 'package:hali_saha_bak/screens/User/PaymentFailed/payment_failed.dart';
import 'package:hali_saha_bak/screens/User/PaymentSuccess/payment_success.dart';
import 'package:hali_saha_bak/services/notification_service.dart';
import 'package:hali_saha_bak/services/sms_service.dart';
import 'package:provider/provider.dart';

class ThreeDScreen extends StatefulWidget {
  const ThreeDScreen({Key? key, required this.html, required this.reservation})
      : super(key: key);

  final String html;
  final Reservation reservation;
  @override
  State<ThreeDScreen> createState() => _ThreeDScreenState();
}

class _ThreeDScreenState extends State<ThreeDScreen> {
  void readJS(
      String? html, UserReservationsProvider userReservationsProvider) async {
    if (html == null) {
      return;
    }
    String newHtml = html
        .replaceAll('<html><head></head><body>', '')
        .replaceAll('</body></html>', '');
    if (newHtml.contains('"response":"success"')) {
      print(newHtml);
      dynamic data = jsonDecode(newHtml);
      print('data = $data');
      String paymentId = data["data"]["paymentId"];
      String paymentTransactionId = data["transaction_id"];
      print('paymentId: $paymentId');
      widget.reservation.paymentId = paymentId;
      widget.reservation.paymentTransactionId = paymentTransactionId;
      
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => PaymentSuccess(
                    reservation: widget.reservation,
                  )),
          (route) => false);
    } else if (newHtml.contains('"response":"failure')) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => PaymentFailed()),
          (route) => false);

      /*  showDialog(
       barrierDismissible: false,
       context: context,
       builder: (context) => AlertDialog(
         title: Text('Hata'),
         content: Text('Ödeme işlemi başarısız oldu'),
         actions: [
           TextButton(
             onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => UserBottomNavBar()), (route) => false),
             child: Text('Tamam'),
           ),
         ],
       ),
     );*/
      print('newHtml = $newHtml');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  late InAppWebViewController controller;

  @override
  Widget build(BuildContext context) {
    UserReservationsProvider userReservationsProvider =
        Provider.of<UserReservationsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödeme'),
        automaticallyImplyLeading: false,
      ),
      body: InAppWebView(
        onWebViewCreated: (_) {
          controller = _;
          controller.loadData(data: widget.html);
        },
        onLoadStop: (InAppWebViewController controller, Uri? uri) async {
          String? html = await controller.getHtml();
          readJS(html, userReservationsProvider);
        },
        initialFile: widget.html,
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
              preferredContentMode: UserPreferredContentMode.MOBILE),
        ),
      ),
    );
  }
}
