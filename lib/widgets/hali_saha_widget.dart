import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:hali_saha_bak/models/users/user_model.dart';
import 'package:hali_saha_bak/providers/user_favorites_provider.dart';
import 'package:hali_saha_bak/screens/Guest/guest_hali_saha_detail.dart';
import 'package:hali_saha_bak/screens/Hs/EditHaliSaha/edit_hali_saha.dart';
import 'package:hali_saha_bak/screens/User/HaliSahaDetail/hali_saha_detail.dart';
import 'package:hali_saha_bak/services/firestore_service.dart';
import 'package:provider/provider.dart';

import '../constants/my_icons.dart';
import '../models/hali_saha.dart';
import '../providers/user_provider.dart';
import '../screens/Hs/HaliSahaDetail/hali_saha_detail.dart';

class HaliSahaWidget extends StatelessWidget {
  const HaliSahaWidget({
    Key? key,
    required this.haliSaha,
    required this.isHaliSaha,
    this.isGuest = false,
  }) : super(key: key);

  final HaliSaha haliSaha;
  final bool isHaliSaha;
  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    UserFavoritesProvider userFavoritesProvider = Provider.of<UserFavoritesProvider>(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => isGuest
                ? GuestHaliSahaDetail(haliSaha: haliSaha)
                : isHaliSaha
                    ? EditHaliSaha(haliSaha: haliSaha)
                    : UserHaliSahaDetail(
                        haliSaha: haliSaha,
                      ),
          ),
        );
      },
      child: Container(
       height: 100,
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: (Theme.of(context).colorScheme.onSurface == Colors.black)
              ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ]
              : null,
        ),
        child: Wrap(
          children: [
            Row(
              children: [
                SizedBox(width: 6),
                Container(
                  width: 80,
                  height: 80,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ClipRRect(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(haliSaha.images.first, fit: BoxFit.cover),
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        haliSaha.similarHaliSahas.isNotEmpty ? haliSaha.hsUser.businessName : haliSaha.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                      ),
                      Text(
                        '${haliSaha.city}/${haliSaha.district}',
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              children: haliSaha.features
                                  .map(
                                    (feature) => Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                      height: 12,
                                      child: Image.asset(
                                        'assets/images/features/' + features.where((element) => element.name == feature).first.image,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          haliSaha.averageRating != null
                              ? RatingStars(
                                  value: haliSaha.averageRating!,
                                  starSize: 12,
                                  // starColor: haliSaha.averageRating! < 3 ? Colors.red : Colors.yellow,
                                  valueLabelVisibility: true,
                                  valueLabelColor: haliSaha.averageRating! < 3 ? Colors.red : Colors.green,
                                )
                              : const SizedBox(),
                          isHaliSaha
                              ? const SizedBox()
                              : Builder(builder: (context) {
                                  if (isGuest) {
                                    return SizedBox();
                                  }
                                  UserModel userModel = userProvider.userModel!;
                                  List favorites = userModel.favorites;
                                  bool liked = favorites.contains(haliSaha.id);

                                  return IconButton(
                                    onPressed: () async {
                                      if (liked) {
                                        userFavoritesProvider.removeHaliSaha(haliSaha);
                                        userModel.favorites.remove(haliSaha.id);
                                      } else {
                                        userFavoritesProvider.addHaliSaha(haliSaha);
                                        userModel.favorites.add(haliSaha.id);
                                      }

                                      await FirestoreService().updateUserModel(userModel: userModel);
                                      userProvider.setUserModel(userModel);
                                    },
                                    icon: Icon(
                                      liked ? Icons.favorite : Icons.favorite_outline,
                                      color: liked ? Colors.red : null,
                                    ),
                                  );
                                }),
                        ],
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
