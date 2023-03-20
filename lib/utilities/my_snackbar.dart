import 'package:flutter/material.dart';

mixin MySnackbar {
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    EdgeInsets margin = const EdgeInsets.all(14),
    Color backgroundColor = Colors.green,
    double radius = 14,
  }) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title ?? 'Uyarı'),
              content: Text(message),
            ));
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static void clear(BuildContext context) => ScaffoldMessenger.of(context).clearSnackBars();

  // Flushbar(
  //   title: title,
  //   message: message,
  //   duration: duration,
  //   backgroundColor: backgroundColor,
  //   margin: margin,
  //   borderRadius: BorderRadius.circular(radius),
  // ).show(context);
}
