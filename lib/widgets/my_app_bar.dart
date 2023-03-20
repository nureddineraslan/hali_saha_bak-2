
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({
    Key? key,
    required this.title,
    required this.showBackButton,
    this.action,
    this.gradient,
  }) : super(key: key);

  final String title;
  final bool showBackButton;
  final Widget? action;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        gradient: gradient,
      ),
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          GestureDetector(
            onTap: showBackButton
                ? () {
                    Navigator.pop(context);
                  }
                : null,
            child: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: showBackButton == false ? Colors.transparent : MyColors.lightGrey),
              child: Center(
                child: showBackButton
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.arrow_back_ios),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
          Container(height: 36, width: 36, child: action),
        ],
      ),
    );
  }
}
