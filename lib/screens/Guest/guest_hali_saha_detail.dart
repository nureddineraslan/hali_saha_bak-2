import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/constants/my_icons.dart';
import 'package:hali_saha_bak/models/comment.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/screens/Global/image_view.dart';
import 'package:hali_saha_bak/screens/User/AllComments/all_comments.dart';
import 'package:hali_saha_bak/screens/User/Login/user_login_screen.dart';
import 'package:hali_saha_bak/screens/User/Register/user_register_screen.dart';
import 'package:hali_saha_bak/utilities/enums.dart';
import 'package:hali_saha_bak/widgets/my_button.dart';
import 'package:hali_saha_bak/widgets/my_textfield_underline.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../models/reservation.dart';
import '../../../models/users/user_model.dart';
import '../../../providers/user_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../utilities/extensions.dart';
import '../../../utilities/my_snackbar.dart';
import '../../../widgets/comment_widget.dart';
import '../User/Reservation/components/reservations_table.dart';

class GuestHaliSahaDetail extends StatefulWidget {
  final HaliSaha haliSaha;
  const GuestHaliSahaDetail({Key? key, required this.haliSaha}) : super(key: key);

  @override
  State<GuestHaliSahaDetail> createState() => _GuestHaliSahaDetailState();
}

class _GuestHaliSahaDetailState extends State<GuestHaliSahaDetail> {
  PageController controller = PageController();
  TextEditingController commentController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  double? rating;

  bool commentsLoaded = false;
  List<Comment> comments = [];

  DateTime selectedDate = DateTime.now();
  int? selectedHour;
  String price = '';

  Future<void> sendComment() async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    UserModel userModel = userProvider.userModel!;

    if (commentController.text.isEmpty) {
      MySnackbar.show(context, message: 'Yorum yazınız');
      return;
    }
    if (rating == null) {
      MySnackbar.show(context, message: 'Puan seçiniz');
      return;
    }
    Comment comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch,
      rating: rating!,
      message: commentController.text,
      userUID: userModel.uid!,
      username: userModel.fullName,
      userProfilePicUrl: userModel.profilePicUrl,
      haliSahaId: widget.haliSaha.id,
      createdDate: DateTime.now(),
    );
    await FirestoreService().sendComment(comment);
    MySnackbar.show(context, message: 'Yorumunuz için teşekkür ederiz.');
    setState(() {
      comments.add(comment);
      rating = null;
      commentController.clear();
      FocusManager.instance.primaryFocus!.unfocus();
    });
  }

  Future<void> getComments() async {
    comments = await FirestoreService().getHaliSahaComments(widget.haliSaha);
    setState(() {
      commentsLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    getComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.haliSaha.name),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirestoreService().haliSahaStream(widget.haliSaha),
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
            reservations.sort((a, b) => a.date.compareTo(b.date));

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 240,
                    child: PageView.builder(
                      controller: controller,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageView(images: widget.haliSaha.images, index: index % widget.haliSaha.images.length),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.transparent,
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: SizedBox(
                              height: 280,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: widget.haliSaha.images[index % widget.haliSaha.images.length],
                                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: SmoothPageIndicator(
                      controller: controller,
                      count: widget.haliSaha.images.length,
                      effect: const ExpandingDotsEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ReservationsTable(
                      decreaseDate: () {
                        selectedDate = selectedDate.subtract(const Duration(days: 1));
                        selectedHour = -1;
                        setState(() {});
                      },
                      increaseDate: () {
                        selectedDate = selectedDate.add(const Duration(days: 1));
                        selectedHour = -1;
                        setState(() {});
                      },
                      selectedDate: selectedDate,
                      selectedHour: selectedHour,
                      reservations: reservations,
                      onHourSelected: (val) {
                        setState(() {
                          selectedHour = val;
                          if (selectedHour != null &&
                              widget.haliSaha.priceRanges.any((element) => isBetween(start: element['start'], end: element['end'], value: selectedHour!))) {
                            price = widget.haliSaha.priceRanges
                                .where((element) => isBetween(start: element['start'], end: element['end'], value: selectedHour!))
                                .first['price']
                                .toString();
                          } else {
                            price = widget.haliSaha.price.toString();
                          }
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Uyarı'),
                              content: Text('Rezervasyon oluşturabilmek için giriş yapmalısınız'),
                              actions: [
                                MyButton(
                                  text: 'Kayıt Ol',
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => UserRegisterScreen()));
                                  },
                                ),
                                SizedBox(height: 20),
                                MyButton(
                                  text: 'Giriş Yap',
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => UserLoginScreen()));
                                  },
                                ),
                              ],
                              actionsPadding: EdgeInsets.all(8),
                              actionsAlignment: MainAxisAlignment.spaceBetween,
                              actionsOverflowDirection: VerticalDirection.down,
                            ),
                          );
                        });
                      },
                      haliSaha: widget.haliSaha,
                    ),
                  ),
                  Center(
                    child: Wrap(
                      direction: Axis.horizontal,
                      spacing: 16,
                      children: [

                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                   Center(
                    child: Wrap(
                      direction: Axis.horizontal,
                      spacing: 16,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [CircleAvatar(radius: 6, backgroundColor: Theme.of(context).colorScheme.onTertiary), SizedBox(width: 6), Text('Abonelik')],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 6, backgroundColor: Colors.green),
                            SizedBox(width: 6),
                            Text('Boş'),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 6, backgroundColor: Colors.red),
                            SizedBox(width: 6),
                            Text('Dolu'),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 6, backgroundColor: Colors.orange),
                            SizedBox(width: 6),
                            Text('Bekliyor'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 10,
                          blurRadius: 20,
                          color: Colors.transparent,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildTitle('Halı Saha Açıklaması'),
                        const SizedBox(height: 10),
                        Text(widget.haliSaha.description),
                        buildDivider(),
                        buildTitle('Halı Saha Fiyatı'),
                        const SizedBox(height: 10),
                        Text(widget.haliSaha.price.toString() + '₺'),
                        buildDivider(),
                        buildTitle('Adres'),
                        const SizedBox(height: 10),
                        Text('${widget.haliSaha.city}, ${widget.haliSaha.district}, ${widget.haliSaha.fullAdress}'),
                        buildDivider(),
                        buildTitle('Halı Saha Tesis Özellikleri'),
                        const SizedBox(height: 10),
                        Wrap(
                          children: widget.haliSaha.features
                              .map(
                                (feature) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/features/' + features.where((element) => element.name == feature).first.image,
                                        color: Theme.of(context).colorScheme.onBackground,
                                        fit: BoxFit.contain,
                                        scale: 2.5,
                                      ),
                                      SizedBox(height: 8),
                                      Text(iconToTurkish[features.where((element) => element.name == feature).first.image.replaceAll('.png', '')] ?? '',
                                          style: TextStyle(fontSize: 12))
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 10,
                          blurRadius: 20,
                          color: Colors.white12,
                        ),
                      ],
                    ),
                    child: Builder(builder: (context) {
                      if (!commentsLoaded) {
                        return const SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(child: SizedBox()),
                              Expanded(
                                child: Center(child: buildTitle('Yorumlar')),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => AllComments(haliSaha: widget.haliSaha)));
                                      },
                                      child: const Text(
                                        'Tümü',
                                        style: TextStyle(color: Colors.blue),
                                      )),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          for (var comment in comments) CommentWidget(comment: comment),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          }),
    );
  }

  Text buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    );
  }

  Column buildDivider() {
    return Column(
      children: const [
        SizedBox(height: 10),
        Divider(),
        SizedBox(height: 10),
      ],
    );
  }
}

class ReservationAcceptBottomSheet extends StatelessWidget {
  const ReservationAcceptBottomSheet({
    Key? key,
    required this.price,
    required this.date,
    required this.hours,
    this.onAccept,
    required this.textEditingController,
  }) : super(key: key);

  final String price, date, hours;
  final void Function()? onAccept;
  final TextEditingController textEditingController;
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 500,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            MyTextfieldUnderline(
              hintText: 'Ek olarak eklemek istedikleriniz',
              maxLines: 3,
              controller: textEditingController,
            ),
            ListTile(title: Text('Tarih'), trailing: Text(date)),
            ListTile(title: Text('Saat'), trailing: Text(hours)),
            ListTile(title: Text('Fiyat'), trailing: Text(price + ' ₺')),
            const SizedBox(height: 20),
            MyButton(
              text: 'Ödemeye Geç',
              onPressed: onAccept,
            ),
          ],
        ),
      ),
    );
  }
}
