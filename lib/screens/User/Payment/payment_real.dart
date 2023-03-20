import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:hali_saha_bak/models/users/hs_user_model.dart';
import 'package:hali_saha_bak/models/users/user_model.dart';
import 'package:hali_saha_bak/providers/user_provider.dart';
import 'package:hali_saha_bak/screens/User/Payment/3d_screen.dart';
import 'package:hali_saha_bak/services/api_service.dart';
import 'package:hali_saha_bak/theme/colors.dart';
import 'package:hali_saha_bak/widgets/blurred_progress_indicator.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';
import 'package:provider/provider.dart';

class PaymentScreenReal extends StatefulWidget {
  const PaymentScreenReal(
      {Key? key,
      required this.reservation,
      this.fromReservationScreen = true,
      required this.hsPaymentId})
      : super(key: key);

  final Reservation reservation;
  final bool fromReservationScreen;
  final String hsPaymentId;

  @override
  State<PaymentScreenReal> createState() => _PaymentScreenRealState();
}

class _PaymentScreenRealState extends State<PaymentScreenReal> {
  late InAppWebViewController controller;
  String cardNumber =  kDebugMode ? '5487930300650198':'';
  String expiryDate = kDebugMode ?'01/30':'';
  String cardHolderName = kDebugMode ?'papara':'';
  String cvvCode = kDebugMode ?'935':'';
  bool isCvvFocused = false;
  bool useGlassMorphism = true;
  bool useBackgroundImage = true;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool loading = false;
 bool  sozlesmeOnay=false;
 bool mesafeliSozlesmeOnay=false;
  @override
  void initState() {
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
    super.initState();
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();

//
  @override
  Widget build(BuildContext context) {
    // UserReservationsProvider userReservationsProvider = Provider.of<UserReservationsProvider>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);
    HsUserModel hsUserModel = widget.reservation.haliSaha.hsUser;
    UserModel userModel = userProvider.userModel!;
    return Stack(
      children: [
        Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text('Ödeme Bilgileri'),
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: !useBackgroundImage
                      ? const DecorationImage(
                          image: ExactAssetImage('assets/images/bg.png'),
                          fit: BoxFit.fill,
                        )
                      : null,
                ),
                child: SafeArea(
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 30,
                      ),
                       CreditCardWidget(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
                obscureCardNumber: true,
                obscureCardCvv: true,
                isHolderNameVisible: true,
                height: 200,
                textStyle: TextStyle(color: Colors.white),
                width: MediaQuery.of(context).size.width,
                isChipVisible: true,
                isSwipeGestureEnabled: true,
                cardBgColor: MyColors.red,
                animationDuration: Duration(milliseconds: 1000),
                onCreditCardWidgetChange: (CreditCardBrand) {},
                 
              ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              CreditCardForm(
                                formKey: formKey,
                                obscureCvv: true,
                                obscureNumber: false,
                                cardNumber: cardNumber,
                                cvvCode: cvvCode,
                                isHolderNameVisible: true,
                                isCardNumberVisible: true,
                                isExpiryDateVisible: true,
                                cardHolderName: cardHolderName,
                                expiryDate: expiryDate,
                                themeColor: Colors.blue,
                                textColor:
                                    Theme.of(context).listTileTheme.textColor!,
                                cvvValidationMessage:
                                    'CVV kodu 3 karakter olmalıdır',
                                numberValidationMessage:
                                    'Kart numarası 16 karakter olmalıdır',
                                dateValidationMessage:
                                    'Geçerli bir tarih giriniz',
                                cardNumberDecoration: InputDecoration(
                                  labelText: 'Kart Numarası',
                                  hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .listTileTheme
                                          .textColor),
                                  labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .listTileTheme
                                          .textColor),
                                  focusedBorder: border,
                                  enabledBorder: border,
                                ),
                                expiryDateDecoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .listTileTheme
                                          .textColor),
                                  labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .listTileTheme
                                          .textColor),
                                  focusedBorder: border,
                                  enabledBorder: border,
                                  labelText: 'Bitiş Tarihi',
                                ),
                                cvvCodeDecoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .listTileTheme
                                          .textColor),
                                  labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .listTileTheme
                                          .textColor),
                                  focusedBorder: border,
                                  enabledBorder: border,
                                  labelText: 'Güvenlik Kodu',
                                ),
                                cardHolderDecoration: InputDecoration(
                                  hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .listTileTheme
                                          .textColor),
                                  labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .listTileTheme
                                          .textColor),
                                  focusedBorder: border,
                                  enabledBorder: border,
                                  labelText: 'Kart Sahibi Adı',
                                ),
                                onCreditCardModelChange:
                                    onCreditCardModelChange,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              CheckboxListTile(
                                dense: true,
                                controlAffinity: ListTileControlAffinity.leading,
                                value: sozlesmeOnay,
                                activeColor: Colors.red,
                                onChanged: (degis) {
                                  setState(() {
                                    sozlesmeOnay = degis!;
                                    print('Hotmail Degis:${degis}');
                                  }); // //servisSecildi==widget.servisVarmi;
                                },
                                title: Text(
                                  'Kullanıcı Sözleşmesini Kabul Ediyorum',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                          if(sozlesmeOnay!=true)...[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 70,
                                width: double.infinity,

                                decoration: BoxDecoration(
                                    color: Colors.white60,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.black38)

                                ),
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: sozlesme(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                             /* CheckboxListTile(
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                value: mesafeliSozlesmeOnay,
                                onChanged: (val) {
                                  mesafeliSozlesmeOnay=val!;
                                },
                                title: Text(
                                  'Mesafeli satış sözleşmesini okudum ve kabul ediyorum.',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),*/
                              SizedBox(height: 25,),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: MyButton(
                                  text: 'ÖDE',
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()&&sozlesmeOnay==true) {
                                      FocusScope.of(context).unfocus();

                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Uyarı'),
                                          content: Text(
                                              'Ödeme sayfasına yönlendiriliyorsunuz. Beyaz ekran kapanmadan çıkış yapmayınız.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                setState(() {
                                                  loading = true;
                                                });
                                                print(
                                                    'hsUserModel.hsPaymentId: ${hsUserModel.hsPaymentId}');
                                                dynamic message =await ApiService().payment(
                                                  cardName: cardHolderName,
                                                  cardNumber: cardNumber,
                                                  cardMonth:
                                                      expiryDate.split('/')[0],
                                                  cardYear:
                                                      expiryDate.split('/')[1],
                                                  cardCvc: cvvCode,
                                                  customerName:
                                                      userModel.fullName,
                                                  customerSurname:
                                                      userModel.fullName,
                                                  customerPhone:
                                                      userModel.phone,
                                                  customerEmail:
                                                      userModel.email,
                                                  customerAdress:
                                                      '${userModel.city}, ${userModel.district}',
                                                  customerCity: userModel.city,
                                                  sellerCode:
                                                      hsUserModel.hsPaymentId!,
                                                  price:
                                                      widget.reservation.kapora,
                                                  commission: widget.reservation
                                                      .haliSaha.iyzicoComission
                                                      .round(),
                                                  customerId:
                                                      userModel.fullName,
                                                );

                                                setState(() {
                                                  loading = false;
                                                });

                                                if (message['status'] ==
                                                    'error') {
                                                  return;
                                                } else {
                                                  print('els  e');
                                                  String html =
                                                      message['response'];
                                                  print('html: $html');
                                                  Navigator.pushReplacement(
                                                    scaffoldKey.currentContext!,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ThreeDScreen(
                                                        html: html,
                                                        reservation:
                                                            widget.reservation,
                                                      ),
                                                    ),
                                                  );
                                                }

                                                // await userReservationsProvider.createReservation(reservation: widget.reservation);
                                                // MySnackbar.show(context, message: 'Rezervasyon başarılı bir şekilde oluşturuldu');
                                                // if (widget.fromReservationScreen) {
                                                //   Navigator.pop(context);
                                                //   Navigator.pop(context);
                                                // }
                                              },
                                              child: Text('Tamam'),
                                            ),
                                          ],
                                        ),
                                      );
                                    } if(sozlesmeOnay!=true) {

                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Hata'),
                                          content: Text(
                                              'Lütfen Kullanıcı Sözleşmesini Okuyunuz'),
                                          actions: [
                                            TextButton(
                                              child: Text('Tamam'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            )
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 25,),
                              SizedBox(
                                height: 200,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        BlurredProgressIndicator(show: loading)
      ],
    );
  }
Widget sozlesme(){
    return Column(
      children: [
        Text('\t\t\nHALISAHABAK Kullanıcı Sözleşmesi',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
        Text( """ 
  
"HALISAHABAK ve mobil internet sitesi", Türkiye Yasalarınca şirketleşmiş ve kayıtlı adresi Çarşı Mah.Boğaz Sokak olan Merkez, Elazığ olan HALISAHABAK anlamında kullanılmaktadır.

"Hizmet", HALISAHABAK ve mobil internet sitesi üzerinde Tesisler tarafından zaman zaman sunulan çeşitli ürün ve hizmetlerin online rezervasyon hizmeti (ödemelerin sağlanması dahil) anlamında kullanılmaktadır.

"Tesis", Platform üzerinde rezervasyon için sunulan spor alanı sağlayan/online olarak bireysel ya da grup kullanıcılarına yönelik sportif aktivite sunan gerçek ya da tüzel kişi (örn. Halısaha kiralayıcısı ) anlamında kullanılmaktadır.
Hizmetin Kapsamı
HALISAHABAK ve mobil internet sitesi, Tesislerin ürün ve hizmetlerini rezervasyon için ilan edebilecekleri ve HALISAHABAK ve mobil internet sitesi ziyaretçilerinin benzeri rezervasyonlar yapabileceği çevrimiçi bir ortam (diğer bir ifadeyle rezervasyon hizmeti) sağlamaktadır. HALISAHABAK ve mobil internet sitesi aracılığıyla bir rezervasyon yapmak suretiyle, rezervasyonu yaptığınız veya (geçerli olduğunda) bir hizmet satın aldığınız Tesis’le doğrudan (kanunen bağlayıcı) bir sözleşme ilişkisine girmiş̧ olacaksınız. Rezervasyonunuzu yaptığınız andan itibaren, rezervasyonunuzun ayrıntılarını ilgili Tesis/Tesislere iletmek ve Tesis adına size bir teyit SMS’i göndermek suretiyle siz ve Tesisin arasında münhasıran bir aracı ehliyetiyle hareket edeceğiz.

Hizmetlerimizi yerine getirirken tebliğ ettiğimiz bilgiler Tesisler tarafından bize sağlanan malumatı esas almaktadır. Esasen Tesislere bir harici ağa erişim imkânı tanınması neticesinde bütün fiyatları, kontenjanı ve HALISAHABAK ve mobil internet sitesinde görüntülenen diğer bilgileri güncellemekten bizzat Tesislerin sorumlu olması temin edilmektedir. Hizmetlerimizi yerine getirirken makul ölçülerde kabiliyet ve itina gösteriyor olmamıza rağmen, bütün bilgilerin hatasızlığını, eksiksizliğini ve doğruluğunu tahkik ve taahhüt edemediğimiz gibi (bariz kusurlar ve dizgi yanlışları dahil) herhangi bir hatadan; (HALISAHABAK ve mobil internet sitesindeki muhtemel (geçici ve/veya kısmi) arıza, onarım, iyileştirme veya bakım çalışmaları ya da diğerlerinden kaynaklanan) herhangi bir kesintiden; kusurlu, yanıltıcı veya gerçek dışı bilgilerden veya bilgilerin iletilmemesinden sorumlu tutulmamız mümkün değildir. Bütün tesisler HALISAHABAK ve mobil internet sitesinde görüntülenen (tasviri) bilgilerin (fiyatlar ve kontenjan dahil) hatasızlığından, eksiksizliğinden ve doğruluğundan her daim sorumludur. HALISAHABAK ve mobil internet sitesi, sağlanan herhangi bir Tesisin (veya olanaklarının, mekânın, ürünlerinin ya da hizmetlerinin) servis kalitesini, hizmet düzeyini veya puanını tavsiye ve tasdik etmediği gibi, bu şekilde de değerlendirilmemelidir.

Hizmetimiz sadece kişisel ve gayri ticari kullanıma açıktır. Bu nedenle HALISAHABAK ve mobil internet sitesinde sunulan içeriğin veya bilginin, yazılımın, rezervasyonların, biletlerin, ürün ve hizmetlerin herhangi bir ticari veya rekabetçi faaliyet ya da amaçla tekrar satılması, derin bağlantıyla işaret edilmesi, kullanılması, kopyalanması, izlenmesi, görüntülenmesi, indirilmesi veya çoğaltılması yasaktır.
Fiyat Politikası
HALISAHABAK ve mobil internet sitesindeki fiyatlar Tesisler tarafından belirlenir.

HALISAHABAK ve mobil internet sitesinde belirli bir ürün veya hizmet için daha düşük fiyatlar verilmesi söz konusu olmaktadır; ancak Tesisler tarafından verilen bu fiyatlar, örneğin iptal ve iade olmayan durumlarda, belirli kısıtlama ve koşullara tabi olabilir. Lütfen rezervasyonunuzu yapmadan önce ilgili ürün, hizmet ve rezervasyon koşullarını ve bilgilerini derinlemesine kontrol etmek suretiyle benzer koşullar olup olmadığını tespit ediniz.
Ön Ödeme, İptal, Kullanılmayan Rezervasyon ve Ek Bilgiler
Bir Tesisten rezervasyon yapmak suretiyle, ilgili Tesisin iptal ve rezervasyonu kullanmama durumlarında uygulanan koşullarına (Tesisin HALISAHABAK ve mobil internet sitesinde sunulan ek bilgileri ve Tesisin ilgili tesis kuralları dahil) ve tesis tarafından sunulan hizmet ve/veya mallar dahil alınan hizmet süresince rezervasyonunuza uygulanabilecek, (temin ile ilgili) ilave koşul ve şartlara tabi olduğunuzu teslim ve tasdik edersiniz. Tesisler sizlerle paylaşılan ödeme koşulları kapsamında rezervasyon anında rezervasyon bedelinin bir miktarını kapora olarak kredi kartınızdan tahsil etmektedir.

Tesislerin iptal ve rezervasyon kullanılmaması durumunda uyguladıkları genel koşullar, HALISAHABAK ve mobil internet sitesindeki Tesis bilgi sayfalarında ve teyit için gönderilen SMS iletisinde yer aldığı gibi rezervasyon işlemi sırasında da tekrar edilmektedir. Belirli fiyat ve özel fırsatların iptal veya değişikliğe elvermediğine dikkat ediniz. Kullanılmayan rezervasyon veya ücretli iptal olması durumunda Tesis tarafından kapora alınabilmektedir. Lütfen rezervasyonunuzu yapmadan önce tesis ayrıntılarını derinlemesine kontrol etmek suretiyle böyle koşullar olup olmadığını tespit ediniz. Ön ödeme veya (tamamen ya da kısmen) ön ödeme gerektiren bir rezervasyonun (önceden uyarı veya haber verilmeden) ilgili (kalan) miktar(lar)ının, Tesis ve rezervasyona ait ilgili ödeme koşulu uyarınca belirtilen ilgili ödeme tarihinde tam olarak ödenememesi durumunda iptal edilebileceğini lütfen unutmayın. İptal ve ön ödeme koşulları Tesise göre değişiklik gösterebilir. Tesis tarafından uygulanabilecek herhangi bir ek koşul (örn. yaş gereksinimi, gibi) için lütfen ek bilgileri (HALISAHABAK ve mobil internet sitesindeki tesis bilgilerinde) ve rezervasyon onayınızdaki önemli bilgileri dikkatlice okuyunuz. Geç ödeme, yanlış̧ banka, kredi kartı veya para kart bilgileri, geçersiz kredi kartı/para kart veya yetersiz bakiye sizin tedbirinizdedir ve Tesis kabul etmediği veya (ön) ödeme ve iptal koşullarına göre aksini kabul etmediği sürece herhangi (iadesiz) ön ödemeli miktar için bir geri ödeme talep edemeyeceksiniz.

Tesisin iptal ve rezervasyon kullanmama koşulları, (ön) ödeme uyarınca iptaliniz için sizden cezai ücret tahsil edilebileceğini veya (ön) ödemesi yapılmış̧ miktarlar için geri ödeme alamayabileceğinizi dikkate alın. Rezervasyonunuzu yapmadan önce Tesisin iptal, (ön) ödeme ve rezervasyon kullanmama koşullarını dikkatle okumanızı ve ilgili rezervasyon uyarınca kalan ödemelerinizi zamanında yapmayı unutmamanızı tavsiye ederiz.

Tesise geç varışınız veya Tesis tarafından rezervasyonunuzun iptali ya da kullanılmayan rezervasyon ücretinin uygulanmasıyla ilgili olarak HALISAHABAK ve mobil internet sitesi hiçbir sorumluluk kabul etmez.

HALISAHABAK ve mobil sitesi üzerinden herhangi bir sahada rezervasyon işlemi gerçekleştirmiş olmanız, rezervasyonun onaylandığına dair SMS tarafınıza ulaşmadığı müddetçe rezervasyonunuzun kesinleştiği anlamına gelmez. HALISAHABAK ve mobil sitesi veya Tesislerin ilgili saatin müsaitlik durumuna ya da yaşanabilecek herhangi bir güncelleme koşuluna bağlı olarak ilgili rezervasyon talebini reddetme hakkı saklıdır.Bu durumda kullanıcı, ödemiş olduğu tutarın iadesi dışında herhangi bir talep hakkının bulunmadığını gayri kabili rücu kabul eder.
Fikri mülkiyet hakları
Aksi belirtilmediği sürece hizmetlerimiz için gereken, HALISAHABAK ve mobil internet sitesinde sunulan veya HALISAHABAK ve mobil internet sitesi tarafından kullanılan yazılımlar ve internet sitemizdeki içeriğin ve bilgilerin ve malzemenin fikri mülkiyet hakları (telif hakları dahil) HALISAHABAK ve mobil internet sitesine aittir.

HALISAHABAK ve mobil internet sitesi; hizmetin sunulduğu HALISAHABAK ve mobil internet sitesinin (ziyaretçi değerlendirmeleri ve çevirisi yapılmış içerik de dahil) tüm hakları, ismi ve (tüm fikri mülkiyet haklarıyla) (altyapı da dahil olmak üzere görüntü ve tarzı gibi) siteyle ilgili her şeyde hak sahibidir ve bunların hiçbiri kopyalanamaz, alınamaz, (hyper/deep) bağlantı verilemez, yayınlanamaz, promosyonu yapılamaz, pazarlanamaz, entegre edilemez, faydalanılamaz, başka bir şeyle birleştirilemez veya içeriği (çeviriler ve ziyaretçi değerlendirmeleri de dahil) veya markası yazılı iznimiz olmadan başka şekillerde kullanılamaz. (Çevirisi yapılmış) İçeriğimizi (ziyaretçi değerlendirmeleri de dahil) kullanmanız (tamamını veya bir kısmını) veya başka şeylerle birleştirmeniz ya da HALISAHABAK ve mobil internet sitesinde veya (çevirisi yapılmış) içerik veya ziyaretçi değerlendirmeleri üzerinde fikri mülkiyet hakkı üstlenmeniz halinde tüm bu fikri mülkiyet haklarını işbu yazıda belirtildiğince HALISAHABAK’a ve mobil internet sitesine devretmek, aktarmak ve vermeyi kabul edersiniz. Kanunsuz bir kullanım veya yukarıda bahsedilen fiil ve davranışların gerçekleştirilmesi fikri mülkiyet haklarımızın (telif ve veritabanı hakları dahil) önemli ölçüde ihlali anlamına gelir.

ABD Dijital Milenyum Telif Hakkı Yasası (“DMCA”) kapsamında belirlenen süreç uyarınca, bize bildirdiğiniz telif hakkı iddialarını yanıtlar ve ihlalleri tekrarlayanların hesaplarını feshederiz.

Telif hakkı sahiplerinin fikri mülkiyetlerini çevrimiçi ortamda yönetebilmelerine yardımcı olacak bilgileri sağlarız.
HALISAHABAK ve Mobil İnternet Sitesi Hesabı
Bazı hizmetlerimizi kullanabilmeniz için bir HALISAHABAK ve mobil internet sitesi hesabınızın olması gerekebilir. HALISAHABAK ve mobil internet sitesi hesabınızı kendiniz oluşturabilirsiniz. HALISAHABAK ve mobil internet sitesi hesabınızı korumak için şifrenizi gizli tutun. HALISAHABAK ve mobil internet sitesi hesabınızda ya da HALISAHABAK ve mobil internet sitesi hesabınız üzerinden yapılan etkinliklerin sorumluluğu size aittir. HALISAHABAK ve mobil internet sitesi hesabınızın şifresini üçüncü taraf uygulamalarında kullanmamaya çalışın.

Müşteri (son kullanıcı), ödeme yöntemine, üyeliğine ve siparişine ilişkin bilgilerin, ödemenin gerçekleştirilebilmesi ve ödeme usulsüzlüklerinin önlenmesi, araştırılması ve tespit edilmesini temin amacıyla iyzico Ödeme Hizmetleri A.Ş.’ye aktarılmasına ve iyzico tarafından https://www.iyzico.com/gizlilik-politikasi/ adresindeki Gizlilik Politikası’nın en güncel halinde açıklandığı şekilde işlenmesine ve saklanmasına rıza göstermektedir.
Uygulanacak Hukuk, Yetkili Mahkeme ve İcra Daireleri
İşbu Hizmet Şartları, Türkiye Cumhuriyeti kanunlarına tabidir. Hizmet Şartlarının uygulanmasından doğabilecek her türlü uyuşmazlığın çözümünde, Elazığ Adliyesi  Mahkeme ve İcra Daireleri yetkilidir.
Yürürlülük
İşbu Sözleşme taraflar arasında kullanıcının, kullanıcı kayıt formunu doldurmasından itibaren süresiz olarak yürürlüğe girer.
Fesih
Taraflar işbu Sözleşme’yi diledikleri zaman sona erdirebileceklerdir. Sözleşme’nin feshi anında tarafların birbirlerinden olan alacak hakları etkilenmez.

        """,style:TextStyle(color: ThemeMode==ThemeMode.dark?Colors.white:Colors.black,fontSize: 10),),
      ],
    );
}
  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
