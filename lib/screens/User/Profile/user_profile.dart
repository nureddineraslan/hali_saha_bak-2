import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/main.dart';
import 'package:hali_saha_bak/models/auth_status.dart';
import 'package:hali_saha_bak/models/users/user_model.dart';
import 'package:hali_saha_bak/providers/user_provider.dart';
import 'package:hali_saha_bak/screens/Auth/Splash/splash_screen.dart';
import 'package:hali_saha_bak/screens/User/AllReservations/all_reservations.dart';
import 'package:hali_saha_bak/screens/User/EditProfile/user_edit_profile.dart';
import 'package:hali_saha_bak/screens/User/Favorites/favorites_screen.dart';
import 'package:hali_saha_bak/screens/User/UserSmsVerification/user_sms_verification.dart';
import 'package:hali_saha_bak/services/auth_service.dart';
import 'package:hali_saha_bak/utilities/my_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_hali_saha_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../services/storage_service.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Future<void> pickProfilePic() async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    UserModel? userModel = userProvider.userModel;

    XFile? image;
    ImagePicker imagePicker = ImagePicker();

    await showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: const Text('Resim yükle'),
              children: [
                ListTile(
                  onTap: () async {
                    image = await imagePicker.pickImage(
                        source: ImageSource.gallery);
                    setState(() {});
                    Navigator.pop(context);
                  },
                  title: const Text('Galeri'),
                ),
                ListTile(
                  onTap: () async {
                    image =
                        await imagePicker.pickImage(source: ImageSource.camera);
                    setState(() {});
                    Navigator.pop(context);
                  },
                  title: const Text('Kamera'),
                ),
              ],
            ));

    if (image != null) {
      String newProfilePictureUrl = await StorageService().uploadImage(
          File(image!.path),
          profilePicUrl: true,
          name: userModel!.fullName);
      userModel.profilePicUrl = newProfilePictureUrl;
      await AuthService().getUser()!.updatePhotoURL(newProfilePictureUrl);
      setState(() {});
      userProvider.notify();
      await FirestoreService().updateUserModel(userModel: userModel);
      MySnackbar.show(context, message: 'Başarıyla güncellendi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    UserModel? userModel = userProvider.userModel;
    UserHaliSahaProvider userHaliSahaProvider =
        Provider.of<UserHaliSahaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          IconButton(
            onPressed: () {
              if (!userModel!.smsVerified == true) {
                print("Sms verified false");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserSmsVerification()));
              }
              if (!userModel.smsVerified == false) {
                print("Sms verified true");
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserEditProfile()));
              }
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Builder(builder: (context) {
        if (userModel == null) {
          return const SizedBox();
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[300]!,
                            backgroundImage: userModel.profilePicUrl != null
                                ? NetworkImage(userModel.profilePicUrl!)
                                : null,
                            child: const Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
                          ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: pickProfilePic,
                                child: const CircleAvatar(
                                  radius: 16,
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.blue,
                                ),
                              ))
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userModel.fullName,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w600),
                          ),
                          Text(userModel.city),
                        ],
                      )
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.call_outlined),
                  title: Text(
                    userModel.phone,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(
                    userModel.email,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserAllReservations()));
                  },
                  leading: const Icon(Icons.payment_outlined),
                  title: const Text(
                    'Rezervasyonlarım',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FavoritesScreen()));
                  },
                  leading: const Icon(Icons.favorite_outline),
                  title: const Text(
                    'Favorilerin',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                // const ListTile(
                //   leading: Icon(Icons.payment_outlined),
                //   title: Text(
                //     'Ödemelerin',
                //     style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                //   ),
                // ),
                GestureDetector(
                  onTap: () {
                    if (Platform.isAndroid) {
                      // Android-specific code
                           Share.share(
                        'Halı Saha Bak Uygulamasını  Kullanarak Sende Hızlıca Rezervasyon Yapabilirsin \nt.ly/5oBj');
               
                    } else if (Platform.isIOS) {
                      // iOS-specific code
                           Share.share(
                        'Halı Saha Bak Uygulamasını  Kullanarak Sende Hızlıca Rezervasyon Yapabilirsin \nt.ly/Mtph');
               
                    }
                  },
                  child: const ListTile(
                    leading: Icon(Icons.people_alt_outlined),
                    title: Text(
                      'Arkadaşına Öner',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  onTap: () async {
                    await AuthService().logout();
                    userProvider.setAuthStatus(AuthStatus.notLoggedIn);
                    userHaliSahaProvider.haliSahas = [];
                    userHaliSahaProvider.haliSahasGet = false;
                    userProvider.setUserModel(null);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SplashScreen()),
                        (route) => false);
                  },
                  leading: const Icon(
                    Icons.logout_outlined,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Çıkış Yap',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                FutureBuilder<Map<String, dynamic>?>(
                    future: FirestoreService().getSystemVariables(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }
                      if (snapshot.data == null) {
                        return const SizedBox();
                      }

                      if (snapshot.data!['showDeleteButtons'] == true) {
                        return ListTile(
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Dikkat'),
                                content: Text(
                                    'Hesabınızı silmek istediğinize emin misiniz?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Hayır'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await FirestoreService().updateIsDeleted(
                                          uid: userModel.uid!,
                                          isDeleted: true,
                                          hsUser: false);
                                      await AuthService().logout();
                                      userProvider.setAuthStatus(
                                          AuthStatus.notLoggedIn);
                                      userHaliSahaProvider.haliSahas = [];
                                      userHaliSahaProvider.haliSahasGet = false;
                                      userProvider.setUserModel(null);
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SplashScreen()),
                                          (route) => false);
                                    },
                                    child: const Text('Evet'),
                                  ),
                                ],
                              ),
                            );
                          },
                          leading: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          title: const Text(
                            'Hesabımı sil',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    }),
                const Divider(),
                const ListTile(
                  title: Text(
                    'Version $appVersion',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
