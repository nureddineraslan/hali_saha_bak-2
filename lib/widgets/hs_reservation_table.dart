import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/reservation.dart';
import 'package:hali_saha_bak/screens/Hs/ReservationDetail/hs_reservation_detail.dart';
import 'package:hali_saha_bak/utilities/enums.dart';
import 'package:hali_saha_bak/utilities/my_snackbar.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import '../models/hali_saha.dart';

// ignore: must_be_immutable
class HsReservationsTable extends StatefulWidget {
  HsReservationsTable({
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
  State<HsReservationsTable> createState() => _HsReservationsTableState();
}

class _HsReservationsTableState extends State<HsReservationsTable> {
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
            CardState cardState = CardState.available;

            DateTime now = localDate ?? DateTime.now();
            bool isToday = widget.selectedDate.day == now.day && widget.selectedDate.month == now.month;
            bool past = false;

            if (((isToday && now.hour >= index) && widget.selectedDate.isBefore(now)  )) {
              past = true;
              cardState = CardState.closed;
            }

            if (!isToday && widget.selectedDate.isBefore(now)) {
              past = true;
              cardState = CardState.closed;
            }

            if (widget.haliSaha.closedRanges.isNotEmpty) {
              for (var element in widget.haliSaha.closedRanges) {
                if (index >= element['start'] && index < element['end']) {
                  cardState = CardState.closed;
                }
              }
            }

            if (widget.haliSaha.subscriberRanges.isNotEmpty) {
              for (var element in widget.haliSaha.subscriberRanges) {
                if ((element['days'] ?? []).contains(widget.selectedDate.weekday)) {
                  if (index >= element['start'] && index < element['end']) {
                    cardState = CardState.subscriber;

                  }
                }

              }
            }

            if (widget.reservations.any((_element) =>
                _element.startHour == index && _element.date.day == widget.selectedDate.day && _element.date.month == widget.selectedDate.month)) {
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
              if (reservation.status == 2 && !past && !isToday) {
                cardState = CardState.available;
              }

              if (sameCount > 1) {
                if (reservation.status == 0) {
                  cardState = CardState.waiting;
                }
                if (reservation.status == 1) {
                  cardState = CardState.reserved;

                }
              }
              if (past && cardState == CardState.available) {
                cardState = CardState.reserved;
              }
             /* if (past && cardState == CardState.subscriber) {
                cardState = CardState.subscriber;
              }*/
              if (past && cardState != CardState.available && cardState!=CardState.subscriber ) {
                cardState = CardState.closed;
              }
            }
//same 


//benim eklediğim yer past
           
//buraya kadar

            if (widget.reservations.any((_element) =>
                _element.startHour == index && _element.date.day == widget.selectedDate.day && _element.date.month == widget.selectedDate.month)) {
              if (widget.reservations
                      .firstWhere((element) =>
                          element.endHour == index + 1 &&
                          element.startHour == index &&
                          element.date.day == widget.selectedDate.day &&
                          element.date.month == widget.selectedDate.month).status == 0) {
                cardState = CardState.waiting;
              }
            }

            if (widget.reservations.any((_element) =>
                _element.startHour == index && _element.date.day == widget.selectedDate.day && _element.date.month == widget.selectedDate.month)) {
              if (widget.reservations
                      .firstWhere((element) =>
                          element.endHour == index + 1 &&
                          element.startHour == index &&
                          element.date.day == widget.selectedDate.day &&
                          element.date.month == widget.selectedDate.month).status == 1) {
                cardState = CardState.reserved;
              }
            }

            Color cardColor = Colors.green;
            Color textColor = Colors.white;

            switch (cardState) {
              case CardState.available:
                cardColor = Colors.green;
                break;

              case CardState.waiting:
                cardColor = Colors.orange;
                break;

              case CardState.reserved:
                cardColor = Colors.red;
                break;

              case CardState.subscriber:
                cardColor = Theme.of(context).colorScheme.primary;
                break;

              case CardState.closed:
                cardColor = Colors.grey[300]!;

                break;
              default:
            }

            if (cardColor == Colors.grey[300]!) {
              textColor = Colors.black54;
            }

            if (localDate == null) {
              cardColor = Colors.grey[300]!;
              textColor = Colors.black54;
            }

            return GestureDetector(
              onTap: () {
                if (cardState == CardState.subscriber) {
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
                  if (cardState == CardState.reserved || cardState == CardState.waiting) {
                    int sameCount = widget.reservations
                        .where((_element) =>
                            _element.startHour == index && _element.date.day == widget.selectedDate.day && _element.date.month == widget.selectedDate.month)
                        .length;

                    Reservation reservation = widget.reservations.firstWhere((element) =>
                        element.startHour == index && element.date.day == widget.selectedDate.day && element.date.month == widget.selectedDate.month);

                    if (sameCount > 1) {
                      List<Reservation> reservations = widget.reservations
                          .where((_element) =>
                              _element.startHour == index && _element.date.day == widget.selectedDate.day && _element.date.month == widget.selectedDate.month)
                          .toList();
                      reservations.sort((a, b) => b.createdDate.compareTo(a.createdDate));
                      reservation = reservations.first;
                      print('reservations.first.status: ${reservations.first.status}');
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HsReservationDetail(reservation: reservation),
                      ),
                    );
                    return;
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
                  if (cardState == CardState.subscriber) {
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
