import 'package:flutter/material.dart';
import 'package:hali_saha_bak/utilities/my_snackbar.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../../models/users/user_model.dart';
import '../../../providers/user_provider.dart';
import '../../../services/auth_service.dart';
import '../BottomNavBar/user_bottom_nav_bar.dart';

// ignore: must_be_immutable
class UserEmailVerification extends StatefulWidget {
  UserEmailVerification({Key? key, required this.code}) : super(key: key);

  String code;

  @override
  State<UserEmailVerification> createState() => _UserEmailVerificationState();
}

class _UserEmailVerificationState extends State<UserEmailVerification> {
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
            SizedBox(height: 20),
            Pinput(
              length: 5,
              controller: controller,
              onChanged: (val) {
                if (val.toString() == widget.code) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => UserBottomNavBar()), (route) => false);
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
                onPressed: () {
                  if (controller.text.isEmpty) {
                    return;
                  }
                  if (controller.text.toString() == widget.code) {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => UserBottomNavBar()), (route) => false);
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
