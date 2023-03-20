import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/providers/guest_provider.dart';
import 'package:provider/provider.dart';

import '../../widgets/hali_saha_widget.dart';

class GuestHome extends StatefulWidget {
  const GuestHome({Key? key}) : super(key: key);

  @override
  State<GuestHome> createState() => _GuestHomeState();
}

class _GuestHomeState extends State<GuestHome> {
  @override
  Widget build(BuildContext context) {
    GuestProvider guestProvider = Provider.of<GuestProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halı Sahalar'),
      ),
      body: Builder(builder: (context) {
        if (!guestProvider.haliSahasGet) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: ListView.builder(
            itemCount: guestProvider.haliSahaList.length,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              HaliSaha haliSaha = guestProvider.haliSahaList[index];
              return HaliSahaWidget(
                haliSaha: haliSaha,
                isHaliSaha: false,
                isGuest: true,
              );
            },
          ),
        );
      }),
    );
  }
}
