import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:hali_saha_bak/models/users/hs_user_model.dart';
import 'package:hali_saha_bak/providers/hali_saha_reservations_provider.dart';
import 'package:hali_saha_bak/providers/user_provider.dart';
import 'package:hali_saha_bak/screens/Auth/Splash/splash_screen.dart';
import 'package:hali_saha_bak/screens/Hs/CreateHaliSaha/create_hali_saha.dart';
import 'package:hali_saha_bak/screens/Hs/HsMyReservations/hs_my_reservations.dart';
import 'package:hali_saha_bak/services/auth_service.dart';
import 'package:hali_saha_bak/services/firestore_service.dart';
import 'package:hali_saha_bak/utilities/my_snackbar.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';
import 'package:provider/provider.dart';

import '../../../models/responses/get_user_response.dart';
import '../../../providers/hali_saha_provider.dart';
import '../../../widgets/hs_reservations_tile.dart';
import '../../User/UserSmsVerification/user_sms_verification.dart';
import '../HsSmsVerification/hs_sms_verification.dart';

class HsHomeScreen extends StatefulWidget {
  const HsHomeScreen({Key? key}) : super(key: key);

  @override
  State<HsHomeScreen> createState() => _HsHomeScreenState();
}

class _HsHomeScreenState extends State<HsHomeScreen> {
  User? user;

  void getHaliSahasByDistrict() {
    HaliSahaProvider haliSahaProvider = Provider.of<HaliSahaProvider>(context, listen: false);
    haliSahaProvider.getMyHaliSahas();
  }

  void getMyReservations() {
    HaliSahaReservationsProvider haliSahaReservationsProvider = Provider.of<HaliSahaReservationsProvider>(context, listen: false);
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    haliSahaReservationsProvider.getMyReservations(hsUserModel: userProvider.hsUserModel!);
  }

  @override
  void initState() {
    super.initState();
    getHaliSahasByDistrict();
    user = AuthService().getUser();
    Future.delayed(Duration.zero, () {
      getMyReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    HaliSahaProvider haliSahaProvider = Provider.of<HaliSahaProvider>(context);
    HaliSahaReservationsProvider haliSahaReservationsProvider = Provider.of<HaliSahaReservationsProvider>(context);
    List<HaliSaha> myHaliSahas = haliSahaProvider.myHaliSahas;

    HsUserModel? hsUserModel = userProvider.hsUserModel;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: false,
        title: Text(
          'Merhaba, ${hsUserModel != null ? hsUserModel.businessName : ''}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (!userProvider.hsUserModel!.smsVerified == true) ...[],
          if (userProvider.hsUserModel!.smsVerified == true) ...[
            myHaliSahas.isNotEmpty
                ? IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateHaliSaha()));
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ))
                : const SizedBox(),
          ],


        ],
      ),
      body: SafeArea(
        child: Builder(builder: (context) {
          print(hsUserModel?.smsVerified);
          if (user == null || hsUserModel == null) {
            return buildNullUserScreen();
          }

          if (!hsUserModel.smsVerified==true) {
            return buildSmsNotVerifiedScreen(context);
          }
          if (!haliSahaProvider.myHaliSahasGet) {
            return const Center(child: CircularProgressIndicator());
          }
          if (myHaliSahas.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Daha önce eklenmiş bir halı sahanız bulunmamakta.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  MyButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateHaliSaha()));
                    },
                    text: 'Halı Saha Ekle',
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              Column(
                children: [
                  Container(width: double.infinity, height: 200, color: Colors.green),
                  Container(
                    color: Colors.transparent,
                    height: 100,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: CurvePainter(),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                      'Hesap Özeti',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white70),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      haliSahaReservationsProvider.waitingReservations().toString(),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const Text(
                                      'Bekleyenler',
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                )),
                                const Center(
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 20,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white70),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      haliSahaReservationsProvider.totalReservations().toString(),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const Text(
                                      'Toplam',
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                )),
                                const Center(
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 20,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Son Rezervasyonlar',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => HsMyReservations()));
                                    },
                                    child: const Text('Tümü'))
                              ],
                            ),
                            Expanded(
                              child: DefaultTabController(
                                length: haliSahaProvider.myHaliSahas.length,
                                child: Column(
                                  children: [
                                    TabBar(
                                      isScrollable: true,
                                      tabs: haliSahaProvider.myHaliSahas.map((e) => Tab(text: e.name)).toList(),
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                          children: haliSahaProvider.myHaliSahas.map((e) {
                                        HaliSaha haliSaha = e;
                                        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                            stream: FirestoreService().haliSahaStream(haliSaha),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasError) {
                                                return const Center(
                                                  child: Text('Beklenmedik bir hata oluştu'),
                                                );
                                              }

                                              if (!snapshot.hasData) {
                                                return const Center(
                                                  child: CircularProgressIndicator(),
                                                );
                                              }

                                              if (snapshot.data == null) {
                                                return const Center(
                                                  child: Text('Beklenmedik bir hata oluştu'),
                                                );
                                              }
                                              List<Reservation> reservations = snapshot.data!.docs.map((doc) => Reservation.fromJson(doc.data())).toList();
                                              if (reservations.isEmpty) {
                                                return Center(
                                                  child: Text('Rezervasyon bulunamadı'),
                                                );
                                              }
                                              reservations.sort((a, b) => b.createdDate.compareTo(a.createdDate));
                                              return SingleChildScrollView(
                                                child: ListView.builder(
                                                  itemCount: reservations.length < 5 ? reservations.length : 5,
                                                  shrinkWrap: true,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemBuilder: (context, index) {
                                                    Reservation reservation = reservations[index];
                                                    return HsReservationTile(reservation: reservation);
                                                  },
                                                ),
                                              );
                                            });
                                      }).toList()),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Center buildNullUserScreen() {
    return const Center(
      child: Text('Hata Oluştu. Lütfen tekrar deneyiniz.'),
    );
  }

  Column buildVerifyEmailScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: Text('Devam edebilmek için hesabınızı onaylayınız'),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: MyButton(
            text: 'Kontrol et',
            onPressed: () async {
              await user!.reload();
              setState(() {
                user = AuthService().getUser();
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: MyButton(
            text: 'Tekrar gönder',
            onPressed: () async {
              await AuthService().sendEmailVerification();
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20.0),
          child: MyButton(
            text: 'Çıkış Yap',
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SplashScreen()), (route) => false);
            },
          ),
        )
      ],
    );
  }

  Column buildNotVerifiedScreen(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    HaliSahaProvider haliSahaProvider = Provider.of<HaliSahaProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: Text(
            'Devam edebilmeniz için hesabınızın onaylanmasını bekleyiniz',
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: MyButton(
            text: 'Kontrol et',
            onPressed: () async {
              GetUserResponse getUserResponse = await FirestoreService().getUser(hsUser: true);
              if (getUserResponse.isSuccessful) {
                userProvider.hsUserModel = getUserResponse.user;
              }
              if (!userProvider.hsUserModel!.verified && !userProvider.hsUserModel!.smsVerified) {
                MySnackbar.show(context, message: 'Hesabınız onaylanmamış.');
                print("çalıştı");
              } else {
                haliSahaProvider.getMyHaliSahas();
                print("Not working");
              }
              setState(() {});
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: MyButton(
            text: 'Çıkış Yap',
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const SplashScreen()), (route) => false);
            },
          ),
        )
      ],
    );
  }

  Column buildSmsNotVerifiedScreen(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    HaliSahaProvider haliSahaProvider = Provider.of<HaliSahaProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/smsv.png',
          height: 200,
        ),
        SizedBox(
          height: 50,
        ),
        const Center(
          child: Text(
            'Sms Doğrulaması Yapılmadı',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
        SizedBox(
          height: 25,
        ),
        const Center(
          child: Text(
            'Devam Edebilmeniz İçin Lütfen Telefon Numaranızı Doğrulayın',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 14, color: Colors.grey),
          ),
        ),
        SizedBox(
          height: 50,
        ),
        Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                if(ThemeMode!=ThemeMode.dark)...[
                  Card(
                    color: Colors.green.shade100,
                    elevation: 8,
                    child: Container(
                      height: 55,width: 55,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        // color: Colors.blueGrey,

                      ),
                      child: IconButton(
                        icon: (Icon(Icons.arrow_forward)),
                        color: Colors.green,
                        onPressed: () async {
                          HsUserModel? hsUserModel = userProvider.hsUserModel;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserHsUserSmsVerification()),
                          );
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],


              ],
            )
          //   MyButton(
          //     text: 'Sms Doğrula',
          //     onPressed: () async {
          //       HsUserModel? hsUserModel = userProvider.hsUserModel;
          //       Navigator.push(context, MaterialPageRoute(builder: (context) => UserSmsVerification()), );
          //       setState(() {

          //       });
          //     },
          //   ),
        ),
      ],
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.green;
    paint.style = PaintingStyle.fill;

    var path = Path();

    path.moveTo(0, size.height * 0.26);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height * 0.26);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
