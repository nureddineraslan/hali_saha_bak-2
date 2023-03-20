import 'dart:ui';
import 'package:flutter/material.dart';

class BlurredProgressIndicator extends StatelessWidget {
  const BlurredProgressIndicator({Key? key, required this.show, this.text}) : super(key: key);
  final String? text;
  final bool show;

  @override
  Widget build(BuildContext context) {
    return show
        ? Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.transparent,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5, tileMode: TileMode.decal),
              child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  if (text != null) Container(margin: const EdgeInsets.all(20), child: Text(text!)) else const SizedBox(),
                ]),
              ),
            ),
          )
        : const SizedBox();
  }
}
