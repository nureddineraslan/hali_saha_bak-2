// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:hali_saha_bak/models/hali_saha.dart';
// import 'package:hali_saha_bak/models/reservation.dart';
// import 'package:hali_saha_bak/providers/user_provider.dart';
// import 'package:hali_saha_bak/services/firestore_service.dart';
// import 'package:hali_saha_bak/utilities/extensions.dart';
// import 'package:hali_saha_bak/utilities/my_snackbar.dart';
// import 'package:hali_saha_bak/widgets/my_button.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:random_string/random_string.dart';

// import '../../../providers/user_hali_saha_provider.dart';
// import '../Payment/payment_real.dart';
// import 'components/reservations_table.dart';

// class ReservationScreen extends StatefulWidget {
//   const ReservationScreen({Key? key, required this.haliSaha}) : super(key: key);

//   final HaliSaha haliSaha;

//   @override
//   State<ReservationScreen> createState() => _ReservationScreenState();
// }

// class _ReservationScreenState extends State<ReservationScreen> {
//   DateTime selectedDate = DateTime.now();
//   int? selectedHour;
//   String price = '';

//   void reservation() {
//     if (selectedHour != null) {
//       UserHaliSahaProvider userHaliSahaProvider = Provider.of<UserHaliSahaProvider>(context, listen: false);
//       UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
//       HaliSaha haliSaha = userHaliSahaProvider.haliSahas[userHaliSahaProvider.haliSahas.indexWhere((element) => element.id == widget.haliSaha.id)];
//       if (selectedHour != null && haliSaha.priceRanges.any((element) => isBetween(start: element['start'], end: element['end'], value: selectedHour!))) {
//         price =
//             haliSaha.priceRanges.where((element) => isBetween(start: element['start'], end: element['end'], value: selectedHour!)).first['price'].toString();
//       } else {
//         price = haliSaha.price.toString();
//       }

//       int? priceNum = int.tryParse(price);
//       if (priceNum == null) {
//         MySnackbar.show(context, message: 'Fiyat bilgisinde bir hata oluştu');
//         return;
//       }

//       String date = DateFormat.yMMMMd('tr').format(selectedDate);

//       String hours = '${selectedHour.toString().padLeft(2, '0')}:00 - ${(selectedHour! + 1).toString().padLeft(2, '0')}:00';

//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Uyarı'),
//           content: Text(
//             '$date tarihinde saat $hours için $price ₺\'ye rezervasyon oluşturmak istediğinize emin misiniz?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text('İptal'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => PaymentScreenReal(
//                       hsPaymentId: haliSaha.hsUser.hsPaymentId!,
//                       reservation: Reservation(
//                         id: int.parse(randomNumeric(6)),
//                         date: selectedDate,
//                         createdDate: DateTime.now(),
//                         startHour: selectedHour!,
//                         endHour: selectedHour! + 1,
//                         price: priceNum.toDouble(),
//                         haliSaha: haliSaha,
//                         user: userProvider.userModel!,
//                         paid: false,
//                         status: 0,
//                         selectedPlace: '',
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               child: const Text('Oluştur'),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     UserHaliSahaProvider userHaliSahaProvider = Provider.of<UserHaliSahaProvider>(context);
//     HaliSaha haliSaha = userHaliSahaProvider.haliSahas[userHaliSahaProvider.haliSahas.indexWhere((element) => element.id == widget.haliSaha.id)];
//     if (selectedHour != null && haliSaha.priceRanges.any((element) => isBetween(start: element['start'], end: element['end'], value: selectedHour!))) {
//       price = haliSaha.priceRanges.where((element) => isBetween(start: element['start'], end: element['end'], value: selectedHour!)).first['price'].toString();
//     } else {
//       price = haliSaha.price.toString();
//     }

//     return Scaffold(
//       appBar: AppBar(title: Text(haliSaha.name)),
//       body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//           stream: FirestoreService().haliSahaStream(haliSaha),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return const Center(
//                 child: Text('Beklenmedik bir hata oluştu'),
//               );
//             }

//             if (!snapshot.hasData) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }

//             if (snapshot.data == null) {
//               return const Center(
//                 child: Text('Beklenmedik bir hata oluştu'),
//               );
//             }

//             List<Reservation> reservations = snapshot.data!.docs.map((doc) => Reservation.fromJson(doc.data())).toList();

//             return Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const SizedBox(width: double.infinity),
//                     ReservationsTable(
//                       decreaseDate: () {
//                         selectedDate = selectedDate.subtract(const Duration(days: 1));
//                         selectedHour = -1;
//                         setState(() {});
//                       },
//                       increaseDate: () {
//                         selectedDate = selectedDate.add(const Duration(days: 1));
//                         selectedHour = -1;
//                         setState(() {});
//                       },
//                       selectedDate: selectedDate,
//                       selectedHour: selectedHour,
//                       reservations: reservations,
//                       onHourSelected: (val) {
//                         setState(() {
//                           selectedHour = val;
//                         });
//                       },
//                       haliSaha: haliSaha,
//                     ),
//                     Center(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [CircleAvatar(radius: 6, backgroundColor: Theme.of(context).colorScheme.primary), SizedBox(width: 6), Text('Abonelik')],
//                           ),
//                           Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               CircleAvatar(radius: 6, backgroundColor: Colors.green),
//                               SizedBox(width: 6),
//                               Text('Boş'),
//                             ],
//                           ),
//                           Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               CircleAvatar(radius: 6, backgroundColor: Colors.red),
//                               SizedBox(width: 6),
//                               Text('Dolu'),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Row(
//                       children: [
//                         Expanded(
//                             child: Column(children: [
//                           Text(
//                             selectedHour != null ? '${int.parse(price) / 5}₺' : '-',
//                             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                           ),
//                           const Text('Kapora')
//                         ])),
//                         Expanded(
//                             child: Column(children: [
//                           Text(
//                             selectedHour != null ? '$price₺' : '-',
//                             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                           ),
//                           const Text('Toplam Ücret')
//                         ])),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     MyButton(
//                       text: 'Onayla',
//                       onPressed: reservation,
//                     )
//                   ],
//                 ),
//               ),
//             );
//           }),
//     );
//   }
// }
