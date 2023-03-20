import 'package:flutter/material.dart';
import 'package:hali_saha_bak/providers/user_favorites_provider.dart';
import 'package:hali_saha_bak/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../../../models/hali_saha.dart';
import '../../../widgets/hali_saha_widget.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  void getFavorites() {
    UserFavoritesProvider userFavoritesProvider = Provider.of<UserFavoritesProvider>(context, listen: false);
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    userFavoritesProvider.getfavoriteHaliSahas(haliSahaIds: userProvider.userModel!.favorites);
  }

  @override
  void initState() {
    super.initState();
    getFavorites();
  }

  @override
  Widget build(BuildContext context) {
    UserFavoritesProvider userFavoritesProvider = Provider.of<UserFavoritesProvider>(context);
    List favoriteHaliSahas = userFavoritesProvider.favoriteHaliSahas;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Favorilerim'),
        ),
        body: Builder(builder: ((context) {
          if (favoriteHaliSahas.isEmpty) {
            return Center(
              child: Text('Eklenmiş favori halı saha bulunmamaktadır'),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  ListView.builder(
                    itemCount: favoriteHaliSahas.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      HaliSaha haliSaha = favoriteHaliSahas[index];
                      return HaliSahaWidget(
                        haliSaha: haliSaha,
                        isHaliSaha: false,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        })));
  }
}
