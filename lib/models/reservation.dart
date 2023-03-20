import 'package:flutter/material.dart';
import 'package:hali_saha_bak/models/hali_saha.dart';
import 'package:hali_saha_bak/models/users/user_model.dart';
import 'package:intl/intl.dart';

class Reservation {
  final int id;
  final DateTime date;
  final DateTime createdDate;
  final int startHour, endHour;
  final double price;
  final double kapora;
  final double servisUcreti;
  final HaliSaha haliSaha;
  final UserModel user;
  final bool paid;
  int status; // 0 = pending, 1 = accepted, 2 = rejected
  final String? notes;
  final String selectedPlace;
  String? paymentId;
  String? paymentTransactionId;
  bool? isManuel;
  bool? servisSecildi;

  Reservation({
    required this.id,
    required this.date,
    required this.createdDate,
    required this.startHour,
    required this.endHour,
    required this.price,
    required this.kapora,
    required this.haliSaha,
    required this.user,
    required this.paid,
    required this.status,
    required this.servisUcreti,
    this.notes,
    this.paymentId,
    this.paymentTransactionId,
    required this.selectedPlace,
    this.isManuel,
    this.servisSecildi,
  });

  String stringDate() {
    String date = DateFormat.yMMMMd('tr').format(this.date);
    return date;
  }

  String hourRange() {
    return '${startHour.toString().padLeft(2, '0')}:00-${endHour.toString().padLeft(2, '0')}:00';
  }

  String fullDate() {
    return '${stringDate()} ${hourRange()}';
  }

  String statusString() {
    if (this.status == 0) {
      return 'Bekliyor';
    } else if (this.status == 1) {
      if (date.isBefore(DateTime.now())) {
        return 'Tamamlandı';
      } else {
        return 'Yaklaşıyor';
      }
    } else if (this.status == 2) {
      return 'İptal Edildi';
    }

    return '';
  }

  Color statusColor() {
    if (this.status == 0) {
      return Colors.orange;
    } else if (this.status == 1) {
      return Colors.green;
    } else if (this.status == 2) {
      return Colors.red;
    }
    return Colors.black;
  }

  IconData statusIcon() {
    IconData iconData = this.status == 0
        ? Icons.more_horiz
        : this.status == 2
            ? Icons.cancel
            : this.status == 1 && date.isBefore(DateTime.now())
                ? Icons.done
                : Icons.more_horiz;
    DateTime reservationDate = DateTime(date.year, date.month, date.day, startHour);
    if (status == 2 && DateTime.now().isAfter(reservationDate)) {
      return Icons.close;
    }
    return iconData;
  }

  Duration difference() {
    DateTime reservationDate = DateTime(date.year, date.month, date.day, startHour);
    print(reservationDate.difference(DateTime.now()));
    return reservationDate.difference(DateTime.now());
  }

  factory Reservation.fromJson(Map json) {
    int status = json['status'];
    DateTime date = DateTime.parse(json['date']);
    DateTime reservationDate = DateTime(date.year, date.month, date.day, json['startHour']);
    if (DateTime.now().isAfter(reservationDate)) {
      if (status == 0) {
        status = 2;
      } else if (status == 1) {
        status = 1;
      }
    }
    return Reservation(
      id: json['id'],
      date: reservationDate,
      createdDate: DateTime.parse(json['createdDate']),
      startHour: json['startHour'],
      endHour: json['endHour'],
      price: json['price'].toDouble(),
      haliSaha: HaliSaha.fromJson(json['haliSaha']),
      kapora: json['kapora'] != null ? json['kapora'].toDouble() : 0.toDouble(),
      servisUcreti: json['servisUcreti'].toDouble()??'',
      user: UserModel.fromJson(json['user']),
      paid: json['paid'],
      status: status,
      notes: json['notes'],
      selectedPlace: json['selectedPlace'] ?? '',
      paymentId: json['paymentId'] ?? '',
      paymentTransactionId: json['paymentTransactionId'] ?? '',
      isManuel: json['isManuel'] ?? false,
      servisSecildi: json['servisSecildi'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toString(),
      'createdDate': createdDate.toString(),
      'startHour': startHour,
      'endHour': endHour,
      'price': price,
      'kapora': kapora,
      'haliSaha': haliSaha.toJson(withReservations: false),
      'user': user.toJson(
        withReservations: false,
        withFavorites: false,
      ),
      'paid': paid,
      'status': status,
      'notes': notes,
      'selectedPlace': selectedPlace,
      'paymentId': paymentId,
      'paymentTransactionId': paymentTransactionId,
      'isManuel': isManuel,
      'servisSecildi': servisSecildi,
      'servisUcreti': servisUcreti,
    };
  }
}
