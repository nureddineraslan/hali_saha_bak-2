import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/auth_status.dart';
import 'package:hali_saha_bak/models/responses/auth_response.dart';
import 'package:hali_saha_bak/screens/Hs/HsBottomNavBar/hs_bottom_nav_bar.dart';
import 'package:hali_saha_bak/screens/User/Register/user_register_screen.dart';
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
import '../BottomNavBar/user_bottom_nav_bar.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({Key? key}) : super(key: key);

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  TextEditingController emailController = kDebugMode
      ? TextEditingController(text: 'exitwayim@gmail.com')
      : TextEditingController();
  TextEditingController passwordController = kDebugMode
      ? TextEditingController(text: '123456')
      : TextEditingController();

  final formKey = GlobalKey<FormState>();

  Future<void> login() async {
    AuthResponse authResponse = await AuthService().hsLogin(
        email: emailController.text, password: passwordController.text);

    if (!authResponse.isSuccessful) {
      showDialog(
          context: context,
          builder: (context) => Center(
                child: AlertDialog(
                  content: Text(authResponse.message),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text('Tamam'))
                  ],
                ),
              ));
      return;
    }

    GetUserResponse getUserResponse =
        await FirestoreService().getUser(hsUser: false);
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);

    if (!getUserResponse.isSuccessful) {
      //MySnackbar.show(context, message: 'Bir hata oluştu');
      showDialog(
          context: context,
          builder: (context) => Center(
                child: AlertDialog(
                  content: Text('Bir Hata Oluştu'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text('Tamam'))
                  ],
                ),
              ));
      Navigator.pop(context);
    }

    if (getUserResponse.hsUser!) {
      if (getUserResponse.user.isDeleted) {
        /*MySnackbar.show(context, message: 'Hesabınız silinmiştir');*/
        showDialog(
            context: context,
            builder: (context) => Center(
                  child: AlertDialog(
                    content: Text('Hesabınız Silinmiştir'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text('Tamam'))
                    ],
                  ),
                ));
        Navigator.pop(context);
        return;
      }
      userProvider.setHsUserModel(getUserResponse.user);
      userProvider.setAuthStatus(AuthStatus.loggedIn);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HsBottomNavBar()),
          (route) => false);
    } else {
      if (getUserResponse.user.isDeleted) {
        // MySnackbar.show(context, message: 'Hesabınız silinmiştir');
        showDialog(
            context: context,
            builder: (context) => Center(
                  child: AlertDialog(
                    content: Text('Hesabınız Silinmiştir'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Text('Tamam'))
                    ],
                  ),
                ));
        return;
      }
      await SharedPrefsService().setUserType('user');
      userProvider.setUserModel(getUserResponse.user);
      userProvider.setAuthStatus(AuthStatus.loggedIn);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserBottomNavBar()),
          (route) => false);
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
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'Giriş Yap',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    MyTextfield(
                      controller: emailController,
                      title: 'E-posta',
                      hintText: 'E-posta giriniz.',
                      validator: (val) {
                        if (val!.length < 5) {
                          return 'Lütfen geçerli bir e-posta giriniz \n\nBoşluk Bırakmadığınızdan Emin Olunuz';
                        }
                        if (!val.isValidEmail()) {
                          return 'Lütfen geçerli bir e-posta giriniz\n\nBoşluk Bırakmadığınızdan Emin Olunuz';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    MyTextfield(
                      obscureText: true,
                      controller: passwordController,
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Tüm alanları doldurunuz.')));
                  return;
                }
                if (formKey.currentState!.validate()) {
                  showDialog(
                      context: context,
                      builder: (context) => Center(
                              child: BlurredProgressIndicator(
                            show: true,
                          )));
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserRegisterScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
