import 'package:flutter/material.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';
import 'package:hali_saha_bak/widgets/my_textfield.dart';

import '../services/auth_service.dart';
import '../utilities/my_snackbar.dart';

class ForgotPasswordWidget extends StatelessWidget {
  const ForgotPasswordWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () async {
          String? email;
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'E-posta adresinizi giriniz',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 10),
                    MyTextfield(
                      hintText: "Email",
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                    SizedBox(height: 10),
                    MyButton(
                      text: 'Gönder',
                      onPressed: () {
                        if (email != null) {
                          AuthService().sendPasswordLink(email!);
                          MySnackbar.show(context, message: 'Şifre sıfırlama linki gönderildi');
                          Navigator.pop(context);
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        },
        child: const Text(
          'Şifremi unuttum',
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
