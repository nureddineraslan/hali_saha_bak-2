import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import '../../../../models/hali_saha.dart';
import '../../../../utilities/my_snackbar.dart';

// ignore: must_be_immutable
class ReservationsTable extends StatefulWidget {
  ReservationsTable({
    Key? key,
    required this.decreaseDate,
    required this.increaseDate,
    required this.selectedDate,
    required this.selectedHour,
    this.onHourSelected,
    required this.reservations,
    required this.haliSaha,
    this.tableTitle = 'Rezervasyon Yap',
  }) : super(key: key);

  final void Function()? decreaseDate, increaseDate;
  DateTime selectedDate;
  int? selectedHour;
  final void Function(int val)? onHourSelected;
  final List<Reservation> reservations;
  final String tableTitle;
  final HaliSaha haliSaha;

  @override
  State<ReservationsTable> createState() => _ReservationsTableState();
}

class _ReservationsTableState extends State<ReservationsTable> {
  @override
  void initState() {
    super.initState();
    getLocalTime();
  }

  DateTime? localDate;

  Future<void> getLocalTime() async {
    Response response = await get(Uri.parse('https://timeapi.io/api/Time/current/zone?timeZone=Europe/Istanbul'));
    localDate = DateTime.parse(jsonDecode(response.body)['dateTime']);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.tableTitle,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            IconButton(
              onPressed: widget.decreaseDate,
              icon: const Icon(Icons.arrow_back_ios),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  DateTime? resultDate = await showDatePicker(
                    context: context,
                    initialDate: widget.selectedDate,
                    firstDate: DateTime.now().isAfter(widget.selectedDate) ? widget.selectedDate : DateTime.now(),
                    lastDate: DateTime.now().add(
                      const Duration(days: 30),
                    ),
                  );
                  if (resultDate != null) {
                    widget.selectedDate = resultDate;
                    setState(() {});
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: Text(
                      DateFormat.yMMMMd('tr').format(widget.selectedDate),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: widget.increaseDate,
              icon: const Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            mainAxisExtent: 50,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 24,
          itemBuilder: (context, index) {
            DateTime now = localDate ?? DateTime.now();
            bool isToday = widget.selectedDate.day == now.day && widget.selectedDate.month == now.month;

            bool past = false;
            bool subscriber = false;

            if ((isToday && now.hour >= index) && widget.selectedDate.isBefore(now)) {
              past = true;
            }

            if (!isToday && widget.selectedDate.isBefore(now)) {
              past = true;
            }

            if (widget.haliSaha.closedRanges.isNotEmpty) {
              for (var element in widget.haliSaha.closedRanges) {
                if (index >= element['start'] && index < element['end']) {
                  past = true;
                }
              }
            }

            if (widget.haliSaha.subscriberRanges.isNotEmpty) {
              for (var element in widget.haliSaha.subscriberRanges) {
                if ((element['days'] ?? []).contains(widget.selectedDate.weekday)) {
                  if (index >= element['start'] && index < element['end']) {
                    subscriber = true;
                  }
                }
              }
            }

            // if (index >= 3 && index <= 6) {
            //   past = true;
            // }

            Color textColor = past ? Colors.black54 : Colors.white;
            Color cardColor = past ? Colors.grey[300]! : Colors.green;

            if (index == widget.selectedHour) {
              cardColor = Colors.blue;
            }
            widget.reservations.forEach((element) {});

            bool debug = index == 10;

            if (widget.reservations.any((_element) =>
                _element.startHour == index && _element.date.day == widget.selectedDate.day && _element.date.month == widget.selectedDate.month)) {
              if (widget.reservations
                      .firstWhere((element) =>
                          element.startHour == index && element.date.day == widget.selectedDate.day && element.date.month == widget.selectedDate.month)
                      .status != 2) {
                cardColor = Colors.red;
              }
            }

            if (widget.reservations.any((_element) =>
                _element.startHour == index && _element.date.day == widget.selectedDate.day && _element.date.month == widget.selectedDate.month)) {
              if (widget.reservations
                      .firstWhere((element) =>
                          element.startHour == index && element.date.day == widget.selectedDate.day && element.date.month == widget.selectedDate.month)
                      .status ==
                  0) {
                cardColor = Colors.red;
              }
            }

            if (widget.reservations.any((_element) =>
                _element.startHour == index && _element.date.day == widget.selectedDate.day && _element.date.month == widget.selectedDate.month)) {
              if (debug) {
                Reservation reservation = widget.reservations.firstWhere(
                    (element) => element.startHour == index && element.date.day == widget.selectedDate.day && element.date.month == widget.selectedDate.month);

              }
              int sameCount = widget.reservations
                  .where((_element) =>
                      _element.startHour == index && _element.date.day == widget.selectedDate.day && _element.date.month == widget.selectedDate.month)
                  .length;

              Reservation reservation = widget.reservations.firstWhere(
                  (element) => element.startHour == index && element.date.day == widget.selectedDate.day && element.date.month == widget.selectedDate.month);
              if (sameCount > 1) {
                List<Reservation> reservations = widget.reservations
                    .where((_element) =>
                        _element.startHour == index && _element.date.day == widget.selectedDate.day && _element.date.month == widget.selectedDate.month)
                    .toList();
                reservations.sort((a, b) => b.createdDate.compareTo(a.createdDate));
                reservation = reservations.first;
                print('reservations.first.status: ${reservations.first.status}');
              }
              if (reservation.status == 2) {
                print('2 dedi');
                cardColor = Colors.green;
              }

              if (sameCount > 1) {
                print('sameCount: $sameCount');
                if (reservation.status == 0 || reservation.status == 1) {
                  cardColor = Colors.red;
                }
              }
            }

            if (localDate == null) {
              past = true;
            }

            if (past) {
              cardColor = Colors.grey[300]!;
              textColor = Colors.black54;
            }

            if (subscriber) {
              cardColor = Theme.of(context).colorScheme.primary;
              textColor = Colors.white;
            }

            return GestureDetector(
              onTap: () {
                if (subscriber && !past) {
                  widget.haliSaha.subscriberRanges.forEach((element) {
                    bool a = element['start'] == index;
                    bool b = index <= element['end'];
                    if (element['days'].any((element) => element == widget.selectedDate.weekday)) {
                      if (a && b) {
                        MySnackbar.show(
                          context,
                          message: '${element['subscriber']} tarafından abonelik alınmış',
                        );
                        return;
                      }
                    }
                  });
                } else {
                  if (cardColor == Colors.orange) {
                    MySnackbar.show(context, message: 'Seçilen saat dolu.');
                    return;
                  }
                  if (cardColor == Colors.red) {
                    MySnackbar.show(context, message: 'Seçilen saat dolu.');
                    return;
                  }
                  if (widget.selectedDate.day == now.day && widget.selectedDate.month == now.month && now.hour + 1 == index) {
                    if (now.minute > 5) {
                      MySnackbar.show(context, message: 'Rezervasyon saatine 55 dakikadan az kala rezervasyon yapılamıyor.');
                      return;
                    }
                  }
                  if (!past) {
                    setState(() {
                      widget.onHourSelected!(index);
                    });
                  }
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Builder(builder: (context) {
                  if (subscriber) {
                    var subscriber;
                    widget.haliSaha.subscriberRanges.forEach((element) {
                      bool a = element['start'] <= index;
                      bool b = index <= element['end'];
                      int weekday = widget.selectedDate.weekday;
                      if (element['days'].any((element) => element == weekday)) {
                        if (a && b) {
                          subscriber = element['subscriber'];
                        }
                      }
                    });
                    return Center(
                      child: Text(
                        subscriber,
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    );
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${index.toString().padLeft(2, '0')}:00',
                        style: TextStyle(fontSize: 12, color: textColor),
                      ),
                      Text(
                        '${(index + 1).toString().padLeft(2, '0')}:00',
                        style: TextStyle(fontSize: 12, color: textColor),
                      ),
                    ],
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }
}
