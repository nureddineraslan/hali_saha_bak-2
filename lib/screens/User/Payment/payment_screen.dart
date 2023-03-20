import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:hali_saha_bak/providers/user_reservations_provider.dart';
import 'package:hali_saha_bak/utilities/my_snackbar.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';
import 'package:provider/provider.dart';
import 'form.dart' as f;

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key, required this.reservation, this.fromReservationScreen = true}) : super(key: key);

  final Reservation reservation;
  final bool fromReservationScreen;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String url = '';

  void generateUrl() {
    Reservation reservation = widget.reservation;
    url =
        "https://halisahabak.com/payment.php?price=${reservation.price}&name=${reservation.user.fullName.split(' ').first}&surname=${reservation.user.fullName.split(' ').last}&email=${reservation.user.email}&phone=${reservation.user.phone}";
  }

  void readJS(html, userReservationsProvider) async {
    if (html.contains('"status":"success"')) {
      print('it contains');
      await userReservationsProvider.createReservation(reservation: widget.reservation);
      MySnackbar.show(context, message: 'Rezervasyon başarılı bir şekilde oluşturuldu');
      if (widget.fromReservationScreen) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
      Navigator.pop(context);
    }
  }

  late InAppWebViewController controller;
  String cardNumber = '5105105105105100';
  String expiryDate = '07/27';
  String cardHolderName = 'HALISAHABAK';
  String cvvCode = '171';
  bool isCvvFocused = false;
  bool useGlassMorphism = true;
  bool useBackgroundImage = true;
  OutlineInputBorder? border;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    UserReservationsProvider userReservationsProvider = Provider.of<UserReservationsProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: !useBackgroundImage
              ? const DecorationImage(
                  image: ExactAssetImage('assets/images/bg.png'),
                  fit: BoxFit.fill,
                )
              : null,
          color: Colors.white,
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              CreditCardWidget(
                glassmorphismConfig: useGlassMorphism ? Glassmorphism.defaultConfig() : null,
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
                obscureCardNumber: true,
                obscureCardCvv: true,
                isHolderNameVisible: true,
                cardBgColor: Colors.green,
                backgroundImage: useBackgroundImage ? 'assets/images/card_bg.png' : null,
                isSwipeGestureEnabled: true,
                onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
                customCardTypeIcons: <CustomCardTypeIcon>[
                  CustomCardTypeIcon(
                    cardType: CardType.mastercard,
                    cardImage: Image.asset(
                      'assets/images/mastercard.png',
                      height: 48,
                      width: 48,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      f.CreditCardForm(
                        formKey: formKey,
                        obscureCvv: true,
                        obscureNumber: true,
                        cardNumber: cardNumber,
                        cvvCode: cvvCode,
                        isHolderNameVisible: true,
                        isCardNumberVisible: true,
                        isExpiryDateVisible: true,
                        cardHolderName: cardHolderName,
                        expiryDate: expiryDate,
                        themeColor: Colors.blue,
                        textColor: Colors.black,
                        cvvValidationMessage: 'CVV kodu 3 karakter olmalıdır',
                        numberValidationMessage: 'Kart numarası 16 karakter olmalıdır',
                        dateValidationMessage: 'Geçerli bir tarih giriniz',
                        cardNumberDecoration: InputDecoration(
                          labelText: 'Kart Numarası',
                          hintText: 'XXXX XXXX XXXX XXXX',
                          hintStyle: const TextStyle(color: Colors.black),
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: border,
                          enabledBorder: border,
                        ),
                        expiryDateDecoration: InputDecoration(
                          hintStyle: const TextStyle(color: Colors.black),
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: border,
                          enabledBorder: border,
                          labelText: 'Bitiş Tarihi',
                          hintText: 'XX/XX',
                        ),
                        cvvCodeDecoration: InputDecoration(
                          hintStyle: const TextStyle(color: Colors.black),
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: border,
                          enabledBorder: border,
                          labelText: 'Güvenlik Kodu',
                          hintText: 'XXX',
                        ),
                        cardHolderDecoration: InputDecoration(
                          hintStyle: const TextStyle(color: Colors.black),
                          labelStyle: const TextStyle(color: Colors.black),
                          focusedBorder: border,
                          enabledBorder: border,
                          labelText: 'Kart Sahibi Adı',
                        ),
                        onCreditCardModelChange: onCreditCardModelChange,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: MyButton(
                          text: 'ÖDE',
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              await userReservationsProvider.createReservation(reservation: widget.reservation);
                              MySnackbar.show(context, message: 'Rezervasyon başarılı bir şekilde oluşturuldu');
                              if (widget.fromReservationScreen) {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                              Navigator.pop(context);
                            } else {
                              print('invalid!');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
