import 'package:flutter/services.dart';

FilteringTextInputFormatter denyNumbers = FilteringTextInputFormatter.deny(RegExp(r'^[0-9]+$'));
TextInputFormatter allowNumbers = FilteringTextInputFormatter.digitsOnly;
FilteringTextInputFormatter denyCharacters = FilteringTextInputFormatter.deny(RegExp(r'^[a-zA-Z]+$'));
