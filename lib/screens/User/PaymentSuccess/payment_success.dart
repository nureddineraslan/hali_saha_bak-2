import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:hali_saha_bak/services/api_service.dart';
import 'package:hali_saha_bak/services/sms_service.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_reservations_provider.dart';
import '../BottomNavBar/user_bottom_nav_bar.dart';

class PaymentSuccess extends StatefulWidget {
  const PaymentSuccess({Key? key, required this.reservation}) : super(key: key);

  final Reservation reservation;

  @override
  State<PaymentSuccess> createState() => _PaymentSuccessState();
}

class _PaymentSuccessState extends State<PaymentSuccess> {
  bool createReservationDone = false;

  @override
  void initState() {
    super.initState();
    createReservation();
  }

  Future<void> createReservation() async {
    
    UserReservationsProvider userReservationsProvider = Provider.of<UserReservationsProvider>(context, listen: false);
   await userReservationsProvider.createReservation(reservation: widget.reservation);

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
        title: Text('Ödeme Başarılı'),
      ),
      body: Builder(builder: (context) {
        if (!createReservationDone) {
          return Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/payment.png',
                height: 300,
              ),
              Text(
                'Rezervasyon oluşturuldu. Rezervasyon ID\'si ${widget.reservation.id}. Payment ID\'si ${widget.reservation.paymentId}.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              MyButton(
                text: 'Ana Sayfaya Dön',
                onPressed: () {
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
