import 'package:flutter/material.dart';
import 'package:hali_saha_bak/screens/Hs/HsBottomNavBar/hs_bottom_nav_bar.dart';
import 'package:hali_saha_bak/services/auth_service.dart';
import 'package:hali_saha_bak/utilities/my_snackbar.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';
import 'package:pinput/pinput.dart';

// ignore: must_be_immutable
class HsEmailVerification extends StatefulWidget {
  HsEmailVerification({Key? key, required this.code}) : super(key: key);

  String code;

  @override
  State<HsEmailVerification> createState() => _HsEmailVerificationState();
}

class _HsEmailVerificationState extends State<HsEmailVerification> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('E-posta onayı'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                'Lütfen e-posta adresinize gönderilen 5 haneli kodu giriniz. Kod gelmediyse spam klasörünü kontrol ediniz.',
                textAlign: TextAlign.center,
              ),
            ),
            Pinput(
              length: 5,
              controller: controller,
              onChanged: (val) {
                if (val.toString() == widget.code) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HsBottomNavBar()), (route) => false);
                } else {
                  if (val.toString().length == 5) {
                    MySnackbar.show(context, message: 'Yanlış kod girildi');
                  }
                }
              },
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: MyButton(
                text: 'Onayla',
                onPressed: () async {
                  if (controller.text.isEmpty) {
                    return;
                  }
                  if (controller.text.toString() == widget.code) {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HsBottomNavBar()), (route) => false);
                  } else {
                    MySnackbar.show(context, message: 'Yanlış kod girildi');
                  }
                },
              ),
            ),
            SizedBox(height: 40),
            Text('E-posta almadınız mı?'),
            TextButton(
                onPressed: () async {
                  widget.code = await AuthService().sendEmailVerification();
                  MySnackbar.show(context, message: 'E-posta adresinize yeni bir kod gönderildi');
                },
                child: Text('Tekrar gönder')),
          ],
        ),
      ),
    );
  }
}
