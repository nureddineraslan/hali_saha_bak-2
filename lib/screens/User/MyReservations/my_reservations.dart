import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:hali_saha_bak/providers/user_provider.dart';
import 'package:hali_saha_bak/providers/user_reservations_provider.dart';
import 'package:hali_saha_bak/screens/User/ReservationDetail/reservation_detail.dart';
import 'package:provider/provider.dart';

class MyReservations extends StatefulWidget {
  const MyReservations({Key? key}) : super(key: key);

  @override
  State<MyReservations> createState() => _MyReservationsState();
}

class _MyReservationsState extends State<MyReservations> {
  void getMyReservations() {
    UserReservationsProvider userReservationsProvider =
        Provider.of<UserReservationsProvider>(context, listen: false);
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    userReservationsProvider.getMyReservations(
        userModel: userProvider.userModel!, all: true, force: false);
  }

  @override
  void initState() {
    super.initState();
    getMyReservations();
  }

  @override
  Widget build(BuildContext context) {
    UserReservationsProvider userReservationsProvider =
        Provider.of<UserReservationsProvider>(context);
    List<Reservation> reservations = userReservationsProvider.myReservations;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezervasyonlarım'),
      ),
      body: Builder(builder: (context) {
        if (!userReservationsProvider.myReservationsGet) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Yükleniyor... Bu işlem uzun sürebilir'),
              ],
            ),
          );
        }
        if (reservations.isEmpty) {
          return Center(
            child: Text('Rezervasyon bulunamadı'),
          );
        }
        return ListView.builder(
          itemCount: reservations.length > 5 ? 5 : reservations.length,
          itemBuilder: (context, index) {
            Reservation reservation = reservations[index];

            return Column(
              children: [
                Card(
                  color: Colors.transparent,
                  elevation: 0,
                  child: ListTile(
                    leading: Container(
                      width: 60,
                      height: 60,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(reservation.haliSaha.images.first,
                            fit: BoxFit.cover),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ReservationDetail(reservation: reservation),
                        ),
                      );
                    },
                    title: Text(
                        '${reservation.stringDate()} ${reservation.hourRange()}'),
                    subtitle: Text(reservation.haliSaha.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${reservation.kapora}₺',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          reservation.statusIcon(),
                          size: 20,
                          color: reservation.statusColor(),
                        )
                      ],
                    ),
                  ),
                ),
                const Divider(),
              ],
            );
          },
        );
      }),
    );
  }
}
