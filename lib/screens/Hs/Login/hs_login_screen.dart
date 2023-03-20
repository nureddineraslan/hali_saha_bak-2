import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/auth_status.dart';
import 'package:hali_saha_bak/models/responses/auth_response.dart';
import 'package:hali_saha_bak/screens/Hs/HsBottomNavBar/hs_bottom_nav_bar.dart';
import 'package:hali_saha_bak/screens/Hs/Register/hs_register_screen.dart';
import 'package:hali_saha_bak/services/auth_service.dart';
import 'package:hali_saha_bak/services/firestore_service.dart';
import 'package:hali_saha_bak/utilities/extensions.dart';
import 'package:hali_saha_bak/utilities/my_snackbar.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';
import 'package:provider/provider.dart';

import '../../../models/responses/get_user_response.dart';
import '../../../providers/user_provider.dart';
import '../../../services/shared_prefs_service.dart';
import '../../../widgets/blurred_progress_indicator.dart';
import '../../../widgets/forgot_password_widget.dart';
import '../../../widgets/my_textfield.dart';

class HsLoginScreen extends StatefulWidget {
  const HsLoginScreen({Key? key}) : super(key: key);

  @override
  State<HsLoginScreen> createState() => _HsLoginScreenState();
}

class _HsLoginScreenState extends State<HsLoginScreen> {
  TextEditingController emailController = kDebugMode ? TextEditingController(text: 'mirsaidefendi@gmail.com') : TextEditingController();
  TextEditingController passwordController = kDebugMode ? TextEditingController(text: '123456') : TextEditingController();

  final formKey = GlobalKey<FormState>();

  Future<void> login() async {
    AuthResponse authResponse = await AuthService().hsLogin(email: emailController.text, password: passwordController.text);
    print('authResponse.isSuccessful: ${authResponse.isSuccessful}');
    if (!authResponse.isSuccessful) {
      //MySnackbar.show(context, message: authResponse.message);
      showDialog(
          context: context,
          builder: (context) => Center(
            child: AlertDialog(
              content: Text(authResponse.message),
              actions: [
                TextButton(onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                }, child:Text('Tamam') )
              ],
            ),
          )
      );
      return;
    }



    GetUserResponse getUserResponse = await FirestoreService().getUser(hsUser: true);
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);



    if (!getUserResponse.isSuccessful) {
     // MySnackbar.show(context, message: getUserResponse.message);
      showDialog(
          context: context,
          builder: (context) => Center(
            child: AlertDialog(
              content: Text(getUserResponse.message),
              actions: [
                TextButton(onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                }, child:Text('Tamam') )
              ],
            ),
          )
      );
    }

    if (getUserResponse.hsUser!) {
      if (getUserResponse.user.isDeleted) {
       // MySnackbar.show(context, message: 'Hesabınız silinmiştir');
        showDialog(
            context: context,
            builder: (context) => Center(
              child: AlertDialog(
                content: Text('Hesabınız Silinmiştir'),
                actions: [
                  TextButton(onPressed: (){
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }, child:Text('Tamam') )
                ],
              ),
            )
        );
        return;
      }
      await SharedPrefsService().setUserType('hs_user');
      userProvider.setHsUserModel(getUserResponse.user);
      userProvider.setAuthStatus(AuthStatus.loggedIn);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HsBottomNavBar()), (route) => false);
    } else {
      if (getUserResponse.user.isDeleted) {
       // MySnackbar.show(context, message: 'Hesabınız silinmiştir');
        showDialog(
            context: context,
            builder: (context) => Center(
              child: AlertDialog(
                content: Text('Hesabınız Silinmiştir'),
                actions: [
                  TextButton(onPressed: (){
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }, child:Text('Tamam') )
                ],
              ),
            )
        );
        return;
      }
      // userProvider.setHsUserModel(getUserResponse.user);
      userProvider.setAuthStatus(AuthStatus.loggedIn);
      MySnackbar.show(context, message: 'Normal user olarak homea girilecek');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary, borderRadius: BorderRadius.circular(12)),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'Giriş Yap',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    MyTextfield(
                      controller: emailController,
                      title: 'E-posta',
                      hintText: 'E-posta giriniz.',
                      validator: (val) {
                        if (val!.length < 5) {
                          return 'Lütfen geçerli bir e-posta giriniz';
                        }
                        if (!val.isValidEmail()) {
                          return 'Lütfen geçerli bir e-posta giriniz';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    MyTextfield(
                      controller: passwordController,
                      obscureText: true,
                      title: 'Şifre',
                      hintText: 'Şifre giriniz.',
                      validator: (val) {
                        if (val!.length < 5) {
                          return 'Şifre en az 6 karakter olmalıdır.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const ForgotPasswordWidget(),
            MyButton(
              text: 'Giriş Yap',
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tüm alanları doldurunuz.')));
                  return;
                }
                if (formKey.currentState!.validate()) {
                  showDialog(
                      context: context,
                      builder: (context) => Center(child: BlurredProgressIndicator(show: true,))
                  );
                  await login();
                }

              },
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('Veya'),
            ),
            MyButton(
              text: 'Kaydol',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HsRegisterScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
