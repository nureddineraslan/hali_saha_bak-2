import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:hali_saha_bak/providers/hali_saha_provider.dart';
import 'package:hali_saha_bak/providers/hali_saha_reservations_provider.dart';
import 'package:hali_saha_bak/services/firestore_service.dart';
import 'package:hali_saha_bak/utilities/date_formatters.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';
import '../../../widgets/hs_reservations_tile.dart';

class HsMyReservations extends StatefulWidget {
  const HsMyReservations({Key? key}) : super(key: key);

  @override
  State<HsMyReservations> createState() => _HsMyReservationsState();
}

class _HsMyReservationsState extends State<HsMyReservations> {
  void getMyReservations() {
    HaliSahaReservationsProvider haliSahaReservationsProvider = Provider.of<HaliSahaReservationsProvider>(context, listen: false);
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    haliSahaReservationsProvider.getMyReservations(hsUserModel: userProvider.hsUserModel!);
  }

  List<Reservation> dateRangeReservations = [];
  DateTimeRange? timeRange;
  bool rangeSelected = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getMyReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    HaliSahaProvider haliSahaProvider = Provider.of<HaliSahaProvider>(context);

    return DefaultTabController(
      length: haliSahaProvider.myHaliSahas.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rezervasyonlarım'),
          bottom: TabBar(
            isScrollable: true,
            tabs: haliSahaProvider.myHaliSahas.map((e) => Tab(text: e.name)).toList(),
          ),
        ),
        body: TabBarView(
            children: haliSahaProvider.myHaliSahas.map((e) {
          HaliSaha haliSaha = e;
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirestoreService().haliSahaStream(haliSaha),
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
                if (timeRange != null) {
                  dateRangeReservations = reservations
                      .where((element) => element.date.isAfter(timeRange!.start) && element.date.isBefore(timeRange!.end.add(Duration(days: 1))))
                      .toList();
                }

                if (reservations.isEmpty) {
                  return Center(
                    child: Text('Rezervasyon bulunamadı'),
                  );
                }
                reservations.sort((a, b) => b.date.compareTo(a.date));

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Builder(builder: (context) {
                      Map dates = {};

                      reservations.forEach((reservation) {
                        if (dates[reservation.date.daysDate()] == null) {
                          dates[reservation.date.daysDate()] = [];
                        }
                      });

                      reservations.forEach((element) {
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

                      return Column(
                        children: [
                          Align(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                    onPressed: () async {
                                      DateTimeRange? resultTimeRange = await showDateRangePicker(
                                        context: context,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now().add(
                                          Duration(days: 365),
                                        ),
                                        // builder: (BuildContext context, Widget? child) {
                                        //   return Theme(
                                        //     data: Theme.of(context).copyWith(
                                        //       colorScheme: Theme.of(context).colorScheme.copyWith(onPrimary: Colors.black, onSurface: Colors.white),
                                        //     ),
                                        //     child: child!,
                                        //   );
                                        // },
                                      );
                                      if (resultTimeRange != null) {
                                        timeRange = resultTimeRange;
                                        rangeSelected = true;

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
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: dates.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
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
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                );
              });
        }).toList()),
      ),
    );
  }
}
