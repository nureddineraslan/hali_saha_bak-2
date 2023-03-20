import 'package:flutter/material.dart';

import '../models/reservation.dart';
import '../screens/Hs/ReservationDetail/hs_reservation_detail.dart';

class HsReservationTile extends StatelessWidget {
  const HsReservationTile({
    Key? key,
    required this.reservation,
  }) : super(key: key);

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HsReservationDetail(
              reservation: reservation,
            ),
          ),
        );
      },
      isThreeLine: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          reservation.haliSaha.images.first,
          height: 60,
          width: 60,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        reservation.user.fullName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if(reservation.isManuel!=true)...[
Text(
                reservation.kapora.toString() + ' ₺',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              ],
              if(reservation.isManuel==true)...[
Text(
                'Manuel' + ' ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey
                ),
              ),
              ],
              Text(
                reservation.statusString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: reservation.statusColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${reservation.stringDate()}, ${reservation.hourRange()}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          )
        ],
      ),
    );
  }
}
