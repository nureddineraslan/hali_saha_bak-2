import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextfield extends StatelessWidget {
  const MyTextfield({
    Key? key,
    this.labelText,
    this.hintText,
    this.title,
    this.onTap,
    this.readOnly = false,
    this.controller,
    this.suffixText,
    this.validator,
    this.keyboardType,
    this.color,
    this.maxLength,
    this.maxLines,
    this.inputFormatters,
    this.obscureText = false,
    this.onChanged,
  }) : super(key: key);

  final String? hintText, title, labelText, suffixText;
  final Function()? onTap;
  final bool readOnly;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Color? color;
  final int? maxLines, maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    Color fieldColor = color ?? Theme.of(context).colorScheme.onPrimaryContainer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title != null
            ? Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  title!,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[600]!),
                ),
              )
            : const SizedBox(),
        TextFormField(
          onChanged: onChanged,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          validator: validator,
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines ?? 1,
          maxLength: maxLength,
          onTap: onTap,
          decoration: InputDecoration(
            suffixText: suffixText,
            labelText: labelText,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: fieldColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: fieldColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: fieldColor,
              ),
            ),
            filled: true,
            fillColor: fieldColor,
            hintText: hintText,
          ),
        ),
      ],
    );
  }
}
