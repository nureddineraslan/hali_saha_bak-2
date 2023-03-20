import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/providers/guest_provider.dart';
import 'package:hali_saha_bak/providers/hali_saha_provider.dart';
import 'package:hali_saha_bak/providers/hali_saha_reservations_provider.dart';
import 'package:hali_saha_bak/providers/user_favorites_provider.dart';
import 'package:hali_saha_bak/providers/user_hali_saha_provider.dart';
import 'package:hali_saha_bak/providers/user_provider.dart';
import 'package:hali_saha_bak/providers/user_reservations_provider.dart';
import 'package:hali_saha_bak/screens/Auth/Splash/splash_screen.dart';
import 'package:hali_saha_bak/services/email_service.dart';
import 'package:hali_saha_bak/services/sms_service.dart';
import 'package:hali_saha_bak/utilities/globals.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

const String appVersion = '2.0.0';

//? koyu tema üzerinden geçilecek
//? ödeme sistemi entegrasyonları (in progress) (iptal etme kaldı, )
//? kapora oranı sistemi eklenecek
//? rezervasyonlarım sayfasında indicator'ın altına bu işlemin uzun süreceği hk bilgi verilecek (Yükleniyor... Bu işlem uzun sürebilir)

//? 55 dk kala rezerv yapılamaz
//? eğer search edilince gelen halı sahalarda birden çok hs sahibi olan varsa tek gözükecek
//? rezervasyon onayı bottom sheet height ve UI değişikliği yapılacak
//? user rezerv table için bekliyor statüsündekiler kapanacak (kırmızı olacak)
//? hs tarafı manuel rezerv oluştur sayfası Dark mode ekle
//? hs tarafında manuel rezerv oluştur emin misiniz diye sor
//? hs tarafın ana sayfa sayaç rezervasyonlar yazıları değişecek
//? hs halı saha düzenlemede verilerin inital olarak gelmesi
//? yeni hs oluşturulurken resimler 6 tane ile sınırlı olmayacak

//? son 48 saat içinde ise
//? kullanıcı eğer yarına rezerv oluşturuyorsa rezervasyon onayının yapılması gerekir

//? iptal edildiyse iptal, rezerv saati geçtiyse tamamlandı, son 55 dk ise rezerve edildi else bekliyor
//? user tarafında rezerv detail sayfasındaki durum metinleri kontrolleri arttırılacak
//? rezerve edildi için de bir renk seçilecek
//? abonelik ise mavi, rezerv edildi için mor denenecek

//? user rezervasyon detay sayfası stream
//? select city ve district için arama özelliği eklenecek

//? payment success sayfası ekle

//? payment scereen dark mode colors
//? halı saha düzenleme sayfası defult info getir
//? comission system addition

//? halı saha düzenle eklenen abone aralığı silme
//? halı saha düzenle eklenen abone aralığı ekleme müşteri adı zorunlu
//? halı saha düzenle kapalı saat aralığı silme
//? halı saha düzenle farklı fiyat aralığı silme

//? manuel oluşturunca geri atacak
//? ikonların yazıları türkçe olacak

//? rezervasyon yapılınca rezervasyon saatinden 1 saat sonrasına ödeme onay kontrolü gerçekleşecek
//? sms gönderimi cron job olarak backendde tutulacak
//? manuel rezervasyonda email null, email gönderilmeyecek sadece sms

//* hs register kısmında sıkıntı var response null geliyor
//! manuel giden rezervasyonların iyzico ile bir işi yok (isManuel gibi bir parametre eklenecek)
//! iptal edilince iotal edilenler col içine eklnecek
//! hs ana sayfa sayımları

//! hs_register_screen.dart 104 line
//! yeni hs oluşturulunca nurettin no sms gidecek

//! edit this in create_hali_saha.dart 116 line
//! yeni halı saha user kaydı oluşturuluğu zaman sms, bildirim, email gidecek. panele eklenecek

//! ödeme sonucu https://dribbble.com/shots/14187992-payment-successful foto koyulacak

//* halı sahanın 1 ay içerisindeki tamamlanan rezervasyonlarında, rezervasyon fiyati kapora ile oranlanıp sistem komisyon oranı kadar da ciro olacak
//* rezervasyon yapılınca ciroya ekleme yapılacak, iptal edilen rezervasyonlar cirodan çıkarılacak

//* 16 agu
//! timestamp utc check edilecek
//? abonelik aralığı gün eklenecek
//! halı saha komisyon oranı eklenecek, hs kendi modelindeki comission oranına göre hesaplanacak
//? hs create oluştur içinde servis yok butonu işaretlendiyse kontrol edilmeyecek, servis yok demektir işte, user tarafında da olacak
//? 19 ağustos servis yok kısmını servis noktası gibi ekledik
//! favorilerimde bug fix edilecek (çoklu halı saha ise tüm halı sahalarda ilkini açıyor)
//? halı saha ara textfield bug
//? halı saha aratma kısmında işletme adı

//* 19 agu
//* multiple phone number feeature (düşünülecek)

//* web
//! hs web manuel rezervasyon

//* rezervasyon detayı bottom sheet ui değişecek
//* iptal edilen rezervasyon için mail ve sms gönderimi,
//* tasarımlarda değişecek yerler var

//* hs admin için password ve email eklenecek
//* hs admin her yere payment, payment transaction id vs bilgileri gözükecek
//* hs admin tarafı ui değişecek

//* web taraflarına rezervasyon onayında servsi şöför msms gönderimi eklenmeli

//* ödeme onayı yapılacak mobilde
//*

FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    String number = inputData!['number'];
    String text = inputData['text'];
    String email = inputData['email'];
    String name = inputData['name'];
    await SmsService().send(number: number, text: text);
    await EmailService().sendEmail(
      email: email,
      name: name,
      subject: 'Rezervasyon Bilgisi',
      content: text,
    );
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  firebaseMessaging.requestPermission();
  firebaseMessaging.getToken().then((token) {
    debugPrint('token : $token');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => HaliSahaProvider()),
        ChangeNotifierProvider(create: (context) => UserHaliSahaProvider()),
        ChangeNotifierProvider(create: (context) => UserReservationsProvider()),
        ChangeNotifierProvider(create: (context) => HaliSahaReservationsProvider()),
        ChangeNotifierProvider(create: (context) => UserFavoritesProvider()),
        ChangeNotifierProvider(create: (context) => GuestProvider()),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: snackbarKey,
        title: 'Halı Saha Bak',
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        darkTheme: ThemeData.dark().copyWith(
          listTileTheme: ListTileThemeData(
            textColor: Colors.white,
          ),
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.black,
          ),
          bottomAppBarColor: Colors.black,
          scaffoldBackgroundColor: Colors.grey[900],
          colorScheme: ColorScheme.dark(
            onSecondary: Colors.white.withOpacity(0.2),
            onPrimaryContainer: Colors.grey[900],
            onSurface: Colors.white,
            onTertiary: Colors.white,
            onPrimary: Colors.white,
            onInverseSurface: Colors.black,
          ),
          primaryColor: Colors.green,
          tabBarTheme: TabBarTheme(labelStyle: TextStyle(color: Colors.green), labelColor: Colors.green),
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            elevation: 0,
          ),
        ),
        theme: ThemeData(
          listTileTheme: ListTileThemeData(
            textColor: Colors.black,
          ),
          bottomAppBarColor: Colors.black,
          textTheme: TextTheme(button: TextStyle(color: Colors.black)),
          colorScheme: ColorScheme.light(
            onSecondary: Colors.white,
            onPrimaryContainer: Colors.grey[100],
            onSurface: Colors.black,
            onTertiary: Colors.grey[800]!,
            onPrimary: Colors.black,
            onInverseSurface: Colors.white,
          ),
          primarySwatch: Colors.green,
          primaryColor: Colors.green,
          tabBarTheme: TabBarTheme(labelStyle: TextStyle(color: Colors.green), labelColor: Colors.green),
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            elevation: 0,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
