// import 'package:flutter/material.dart';
// import 'package:hali_saha_bak/models/reservation.dart';
// import 'package:hali_saha_bak/providers/user_provider.dart';
// import 'package:hali_saha_bak/services/firestore_service.dart';
// import 'package:provider/provider.dart';

// import '../../../widgets/my_button.dart';
// import '../Payment/payment_screen.dart';
// import '../ReservationDetail/reservation_detail.dart';

// class Bucket extends StatefulWidget {
//   const Bucket({Key? key}) : super(key: key);

//   @override
//   State<Bucket> createState() => _BucketState();
// }

// class _BucketState extends State<Bucket> {
//   List<Reservation> bucket = [];

//   Future<void> getBucket() async {
//     UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
//     bucket = await FirestoreService().getBucket(userProvider.userModel!);
//     setState(() {});
//   }

//   @override
//   void initState() {
//     super.initState();
//     getBucket();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Sepetim'),
//       ),
//       bottomNavigationBar: Padding(
//         padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).viewPadding.bottom, horizontal: 20),
//         child: MyButton(
//           text: 'Siparişi Tamamla',
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => PaymentScreen(
//                   fromReservationScreen: false,
//                   reservation: bucket.first,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//       body: ListView.builder(
//         itemCount: bucket.length,
//         itemBuilder: (context, index) {
//           Reservation reservation = bucket[index];

//           return Column(
//             children: [
//               Card(
//                 color: Colors.transparent,
//                 elevation: 0,
//                 child: ListTile(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ReservationDetail(reservation: reservation),
//                       ),
//                     );
//                   },
//                   title: Text('${reservation.stringDate()} ${reservation.hourRange()}'),
//                   subtitle: Text(reservation.haliSaha.name),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         margin: const EdgeInsets.all(4),
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(8),
//                           color: Colors.grey[100],
//                         ),
//                         child: Text(
//                           '${reservation.price}₺',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const Icon(
//                         Icons.arrow_forward_ios,
//                         size: 14,
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               const Divider(),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
