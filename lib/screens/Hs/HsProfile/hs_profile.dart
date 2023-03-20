import 'dart:io';
import 'package:hali_saha_bak/screens/Hs/MyHaliSahas/hs_my_halisahas_two.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/auth_status.dart';
import 'package:hali_saha_bak/models/users/hs_user_model.dart';
import 'package:hali_saha_bak/providers/user_provider.dart';
import 'package:hali_saha_bak/screens/Auth/Splash/splash_screen.dart';
import 'package:hali_saha_bak/screens/Hs/HsEditProfile/hs_edit_profile.dart';
import 'package:hali_saha_bak/screens/Hs/HsSmsVerification/hs_sms_verification.dart';
import 'package:hali_saha_bak/screens/Hs/MyHaliSahas/hs_my_hali_sahas.dart';
import 'package:hali_saha_bak/services/auth_service.dart';
import 'package:hali_saha_bak/utilities/my_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../main.dart';
import '../../../models/responses/get_user_response.dart';
import '../../../providers/user_hali_saha_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../services/storage_service.dart';
import '../../Auth/ChooseType/choose_type_screen.dart';
import '../HsMyReservations/hs_my_reservations.dart';

class HsProfile extends StatefulWidget {
  const HsProfile({Key? key}) : super(key: key);

  @override
  State<HsProfile> createState() => _HsProfileState();
}

class _HsProfileState extends State<HsProfile> {

  Future<void> getUser() async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    GetUserResponse getUserResponse = await FirestoreService().getUser(hsUser: true);

    if (!getUserResponse.isSuccessful) {
      MySnackbar.show(context, message: getUserResponse.message);
      await AuthService().logout();
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ChooseTypeScreen()), (route) => false);
      return;
    }

    if (getUserResponse.hsUser!) {
      userProvider.setHsUserModel(getUserResponse.user);
      userProvider.setAuthStatus(AuthStatus.loggedIn);
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> pickProfilePic() async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    HsUserModel? hsUserModel = userProvider.hsUserModel;

    XFile? image;
    ImagePicker imagePicker = ImagePicker();

    await showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: const Text('Resim yükle'),
              children: [
                ListTile(
                  onTap: () async {
                    image = await imagePicker.pickImage(source: ImageSource.gallery);
                    setState(() {});
                    Navigator.pop(context);
                  },
                  title: const Text('Galeri'),
                ),
                ListTile(
                  onTap: () async {
                    image = await imagePicker.pickImage(source: ImageSource.camera);
                    setState(() {});
                    Navigator.pop(context);
                  },
                  title: const Text('Kamera'),
                ),
              ],
            ));

    if (image != null) {
      String newProfilePictureUrl = await StorageService().uploadImage(File(image!.path), profilePicUrl: true, name: hsUserModel!.name);
      hsUserModel.profilePicUrl = newProfilePictureUrl;
      await AuthService().getUser()!.updatePhotoURL(newProfilePictureUrl);
      setState(() {});
      userProvider.notify();
      await FirestoreService().updateHsUserModel(hsUserModel: hsUserModel);
      MySnackbar.show(context, message: 'Başarıyla güncellendi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    HsUserModel? hsUserModel = userProvider.hsUserModel;
    UserHaliSahaProvider userHaliSahaProvider = Provider.of<UserHaliSahaProvider>(context);
    final box = context.findRenderObject() as RenderBox?;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          IconButton(
            onPressed: () {
              if(!hsUserModel!.smsVerified==true) {
                print("Sms verified false");
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const UserHsUserSmsVerification()));
              }
              if(!hsUserModel.smsVerified==false){
                print("Sms verified true");
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const HsEditProfile()));
              }
            },
            //  onPressed: () {
          //    Navigator.push(context, MaterialPageRoute(builder: (context) => const HsEditProfile()));
          //  },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Builder(builder: (context) {
        if (hsUserModel == null) {
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
                            backgroundImage: hsUserModel.profilePicUrl != null ? NetworkImage(hsUserModel.profilePicUrl!) : null,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hsUserModel.businessName,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text('ID: ${hsUserModel.hs_id.toString()}'),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.call_outlined),
                  title: Text(
                    hsUserModel.phone,
                    style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(
                    hsUserModel.email,
                    style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HsMyReservations()));
                  },
                  leading: const Icon(Icons.favorite_outline),
                  title: const Text(
                    'Rezervasyonlarım',
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHaliSahas(),
                      ),
                    );
                  },
                  leading: Icon(Icons.sports_baseball_outlined),
                  title: Text(
                    'Saha Düzenle',
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHaliSahasTwo(),
                      ),
                    );
                  },
                  leading: Icon(Icons.calendar_today_outlined),
                  title: Text(
                    'Abonelik Ekle',
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: ()async{
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
                      style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
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
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SplashScreen()), (route) => false);
                  },
                  leading: const Icon(
                    Icons.logout_outlined,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Çıkış Yap',
                    style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),
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
                                content: Text('Hesabınızı silmek istediğinize emin misiniz?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Hayır'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await FirestoreService().updateIsDeleted(uid: hsUserModel.uid!, isDeleted: true, hsUser: true);
                                      await AuthService().logout();
                                      userProvider.setAuthStatus(AuthStatus.notLoggedIn);
                                      userHaliSahaProvider.haliSahas = [];
                                      userHaliSahaProvider.haliSahasGet = false;
                                      userProvider.setUserModel(null);
                                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SplashScreen()), (route) => false);
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
                            style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold),
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
