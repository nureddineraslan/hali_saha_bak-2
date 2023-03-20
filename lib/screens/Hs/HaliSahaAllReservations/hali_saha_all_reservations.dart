import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:hali_saha_bak/utilities/date_formatters.dart';

import '../../../widgets/hs_reservations_tile.dart';

// ignore: must_be_immutable
class HaliSahaAllReservations extends StatefulWidget {
  HaliSahaAllReservations({Key? key, required this.haliSaha, this.reservations = const <Reservation>[]}) : super(key: key);

  final HaliSaha haliSaha;
  List<Reservation> reservations;

  @override
  State<HaliSahaAllReservations> createState() => _HaliSahaAllReservationsState();
}

class _HaliSahaAllReservationsState extends State<HaliSahaAllReservations> {
  List<Reservation> allReservations = [];

  List<Reservation> dateRangeReservations = [];
  DateTimeRange? timeRange;
  bool rangeSelected = false;

  void setRangeReservations() {
    if (timeRange != null) {
      dateRangeReservations = widget.reservations
          .where((element) => element.date.isAfter(timeRange!.start) && element.date.isBefore(timeRange!.end.add(Duration(days: 1))))
          .toList();
      print('dateRangeReservations: ${dateRangeReservations.length}');
      print('rangeSelected: $rangeSelected');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.haliSaha.name),
        actions: [
          TextButton(
              onPressed: () async {
                DateTimeRange? resultTimeRange =
                    await showDateRangePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime.now().add(Duration(days: 365)));
                if (resultTimeRange != null) {
                  timeRange = resultTimeRange;
                  rangeSelected = true;
                  setRangeReservations();
                  setState(() {});
                }
              },
              child: Text(
                'Tarih aralığı',
                style: TextStyle(color: Colors.green),
              )),
          if (rangeSelected)
            IconButton(
                onPressed: () {
                  rangeSelected = false;
                  timeRange = null;
                  setState(() {});
                },
                icon: Icon(Icons.close)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Builder(builder: (context) {
          Map dates = {};

          widget.reservations.forEach((reservation) {
            if (dates[reservation.date.daysDate()] == null) {
              dates[reservation.date.daysDate()] = [];
            }
          });

          widget.reservations.forEach((element) {
            dates[element.date.daysDate()].add(element);
          });

          List sortedKeys = dates.keys.toList()..sort((a, b) => b.compareTo(a));

          if (rangeSelected) {
            print('rangeSelected: $rangeSelected');
            dates = {};
            dateRangeReservations.forEach((reservation) {
              if (dates[reservation.date.daysDate()] == null) {
                dates[reservation.date.daysDate()] = [];
              }
            });

            dateRangeReservations.forEach((element) {
              dates[element.date.daysDate()].add(element);
            });

            sortedKeys = dates.keys.toList()..sort((a, b) => b.compareTo(a));
          }

          return ListView.builder(
            itemCount: dates.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${(sortedKeys[index] as DateTime).toDateString()}', style: TextStyle(fontWeight: FontWeight.bold)),
                    Column(
                      children: [for (var item in dates[sortedKeys[index]]) HsReservationTile(reservation: item)],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
