import 'package:flutter/material.dart';
import 'package:hali_saha_bak/providers/guest_provider.dart';
import 'package:hali_saha_bak/screens/Global/select_city_screen.dart';
import 'package:hali_saha_bak/screens/Guest/guest_home.dart';
import 'package:hali_saha_bak/utilities/my_snackbar.dart';
import 'package:provider/provider.dart';

import '../../models/il_ilce_model.dart';
import '../../widgets/my_button.dart';
import '../../widgets/my_textfield.dart';
import '../Global/select_district_screen.dart';

class SelectCityDistrict extends StatefulWidget {
  const SelectCityDistrict({Key? key}) : super(key: key);

  @override
  State<SelectCityDistrict> createState() => _SelectCityDistrictState();
}

class _SelectCityDistrictState extends State<SelectCityDistrict> {
  @override
  Widget build(BuildContext context) {
    GuestProvider guestProvider = Provider.of<GuestProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('İl / İlçe Seçimi'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSecondary, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'Bölgenizdeki halı sahaları görebilmek için lütfen il ve ilçe seçiniz.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    MyTextfield(
                      controller: guestProvider.ilController,
                      onTap: () async {
                        Il? newSelectedCity =
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => SelectCityScreen(selectedCity: guestProvider.selectedIl)));

                        if (newSelectedCity != null) {
                          if (guestProvider.selectedIl != null && newSelectedCity.ilAdi != guestProvider.selectedIl!.ilAdi) {
                            guestProvider.selectedIlce = null;
                            guestProvider.ilceController.clear();
                          }
                          setState(() {
                            guestProvider.selectedIl = newSelectedCity;
                            guestProvider.ilController.text = newSelectedCity.ilAdi;
                          });
                        }
                      },
                      readOnly: true,
                      title: 'Şehir',
                      hintText: 'Şehir seçiniz.',
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Lütfen geçerli bir şehir giriniz';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    MyTextfield(
                      controller: guestProvider.ilceController,
                      onTap: () async {
                        if (guestProvider.selectedIl == null) {
                          return;
                        }
                        Ilce? newSelectedDistrict = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectDistrictScreen(
                              selectedCity: guestProvider.selectedIl!,
                              selectedDistrict: guestProvider.selectedIlce,
                            ),
                          ),
                        );

                        if (newSelectedDistrict != null) {
                          setState(() {
                            guestProvider.selectedIlce = newSelectedDistrict;
                            guestProvider.ilceController.text = newSelectedDistrict.ilceAdi;
                          });
                        }
                      },
                      readOnly: true,
                      title: 'İlçe',
                      hintText: 'İlçe seçiniz.',
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Lütfen geçerli bir ilçe giriniz';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              MyButton(
                text: 'DEVAM ET',
                onPressed: () async {
                  if (guestProvider.selectedIl == null || guestProvider.selectedIlce == null) {
                    MySnackbar.show(context, message: 'Lütfen tüm alanları doldurunuz');
                    return;
                  }

                  guestProvider.getHaliSahaList();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GuestHome(),
                    ),
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).viewPadding.bottom * 2)
            ],
          ),
        ),
      ),
    );
  }
}
