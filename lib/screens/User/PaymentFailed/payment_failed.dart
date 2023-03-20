import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:hali_saha_bak/services/api_service.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_reservations_provider.dart';
import '../BottomNavBar/user_bottom_nav_bar.dart';

class PaymentFailed extends StatefulWidget {
  const PaymentFailed({Key? key,  }) : super(key: key);



  @override
  State<PaymentFailed> createState() => _PaymentFailedState();
}

class _PaymentFailedState extends State<PaymentFailed> {
  bool createReservationDone = false;

  @override
  void initState() {
    super.initState();
    createReservation();
  }

  Future<void> createReservation() async {
    UserReservationsProvider userReservationsProvider = Provider.of<UserReservationsProvider>(context, listen: false);
    //await userReservationsProvider.createReservation(reservation: widget.reservation);
    currentUserBottomIndex = 0;
    // await ApiService().reservationBackend(widget.reservation);
    setState(() {
      createReservationDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ödeme Başarısız'),
      ),
      body: Builder(builder: (context) {
        if (!createReservationDone) {
          return Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/close.png',
                height: 150,
              ),
              SizedBox(height: 80),
              Text(
                'Ödeme Almada sorun yaşandı.Lütfen Tekrar Deneyiniz.\n\nSorunun Devam etmesi halinde bankanız ile iletişime geçiniz',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700,fontSize: 16),
              ),
              SizedBox(height: 80),
              MyButton(
                text: 'Ana Sayfaya Dön',
                onPressed: () {
                 //Navigator.pop(context);
                 Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => UserBottomNavBar()), (route) => false);
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
