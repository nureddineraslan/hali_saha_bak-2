import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/utilities/extensions.dart';
import 'package:hali_saha_bak/widgets/hs_reservation_table.dart';
import 'package:provider/provider.dart';
import 'package:quiver/time.dart';
import '../../../models/reservation.dart';
import '../../../providers/hali_saha_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/hs_reservations_tile.dart';
import '../HaliSahaAllReservations/hali_saha_all_reservations.dart';
import '../HsManuelNewReservation/hs_manuel_new_reservation.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({Key? key}) : super(key: key);

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> with SingleTickerProviderStateMixin<TableScreen> {
  DateTime selectedDate = DateTime.now();
  int? selectedHour;
  String price = '';

  TabController? tabController;

  void setTabController() {
    HaliSahaProvider haliSahaProvider = Provider.of<HaliSahaProvider>(context, listen: false);
    tabController = TabController(length: haliSahaProvider.myHaliSahas.length, vsync: this);
  }

  @override
  void initState() {
    super.initState();
    setTabController();
  }

  Map weekdayDataMap() {
    DateTime now = DateTime.now();
    int days = daysInMonth(2022, 08);
    Map weekdayData = {};
    for (var i = 1; i < days + 1; i++) {
      DateTime date = DateTime(now.year, now.month, i);
      if (date.isBefore(now)) {
        int weekday = date.weekday;
        if (weekdayData.containsKey(weekday)) {
          weekdayData[weekday]++;
        } else {
          weekdayData[weekday] = 1;
        }
      }
    }
    return weekdayData;
  }

  @override
  Widget build(BuildContext context) {
    HaliSahaProvider haliSahaProvider = Provider.of<HaliSahaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Çizelge'),
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          tabs: haliSahaProvider.myHaliSahas.map((e) => Tab(text: e.name)).toList(),
        ),
      ),
      body: TabBarView(
          controller: tabController,
          children: haliSahaProvider.myHaliSahas.map((e) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirestoreService().haliSahaStream(e),
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
                    return const Center(child: Text('Beklenmedik bir hata oluştu'));
                  }

                  Map weekday = weekdayDataMap();
                  HaliSaha haliSaha = haliSahaProvider.myHaliSahas[tabController!.index];

                  var subscribers = haliSaha.subscriberRanges.where((element) => element['days'] != null);

                  Map subscriberDays = {};

                  subscribers.forEach((element) {
                    if (!subscriberDays.containsKey(element['subscriber'])) {
                      subscriberDays[element['subscriber']] = 0;
                    }
                    List days = element['days'];
                    int hours = element['end'] - element['start'];

                    days.forEach((day) {
                      subscriberDays[element['subscriber']] = subscriberDays[element['subscriber']] + ((weekday[day] ?? 0) * hours);
                    });
                  });

                  List<Reservation> reservations = snapshot.data!.docs.map((doc) => Reservation.fromJson(doc.data())).toList();

                  reservations.sort((a, b) => b.date.compareTo(a.date));
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          HsReservationsTable(
                            haliSaha: e,
                            tableTitle: 'Rezervasyon Tablosu',
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
                              if (selectedHour != null &&
                                  e.priceRanges.any((element) => isBetween(start: element['start'], end: element['end'], value: selectedHour!))) {
                                price = e.priceRanges
                                    .where((element) => isBetween(start: element['start'], end: element['end'], value: selectedHour!))
                                    .first['price']
                                    .toString();
                              } else {
                                price = e.price.toString();
                              }

                              int? priceNum = int.tryParse(price);

                              setState(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HsManuelNewReservation(
                                      selectedDate: selectedDate,
                                      startHour: selectedHour!,
                                      endHour: selectedHour! + 1,
                                      price: priceNum!,
                                      haliSaha: e,
                                    ),
                                  ),
                                );
                                selectedHour = val;
                                // reservation();
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          Wrap(
                            direction: Axis.horizontal,
                            spacing: 16,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(radius: 6, backgroundColor: Theme.of(context).colorScheme.primary),
                                  SizedBox(width: 6),
                                  Text('Abonelik')
                                ],
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
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Son Rezervasyonlar',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HaliSahaAllReservations(
                                            haliSaha: haliSahaProvider.myHaliSahas[tabController!.index],
                                            reservations: reservations,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Tümü'))
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              children: [
                                if (reservations.length > 5)
                                  for (var i = 0; i < 5; i++) HsReservationTile(reservation: reservations[i])
                                else
                                  for (var reservation in reservations) HsReservationTile(reservation: reservation),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Abonelikler',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              children: [
                                for (var subscriber in subscriberDays.entries)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Card(
                                      elevation: 4,
                                      child: ListTile(
                                        leading: CircleAvatar(
                                            backgroundColor: Colors.grey[300],
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                            )),
                                        title: Text(
                                          subscriber.key,
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        trailing: Text(
                                          subscriber.value.toString() + ' saat',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.purple,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          }).toList()),
    );
  }
}
