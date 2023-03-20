import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  const MyListTile({
    Key? key,
    required this.child,
    this.padding = 10,
    this.color = Colors.white,
    this.onTap,
    this.gradient,
  }) : super(key: key);

  final Widget child;
  final double padding;
  final Color color;
  final void Function()? onTap;
  final LinearGradient? gradient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: gradient,
          color: color,
        ),
        padding: EdgeInsets.all(padding),
        child: child,
      ),
    );
  }
}
