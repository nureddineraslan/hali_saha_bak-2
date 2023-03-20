import 'package:flutter/material.dart';

class MyTextfieldUnderline extends StatelessWidget {
  const MyTextfieldUnderline({
    Key? key,
    this.hintText,
    this.title,
    this.onTap,
    this.readOnly = false,
    this.controller,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.suffixText,
  }) : super(key: key);

  final String? hintText, title, suffixText;
  final Function()? onTap;
  final bool readOnly;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final int? maxLines, maxLength;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? '',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        TextFormField(
          keyboardType: keyboardType,
          maxLines: maxLines,
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            suffixText: suffixText,
          ),
          maxLength: maxLength,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
