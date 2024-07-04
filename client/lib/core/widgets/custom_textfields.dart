import 'package:flutter/material.dart';

class CustomTextfields extends StatelessWidget {
  const CustomTextfields({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.suffix,
    this.readOnly = false,
    this.onTap,
  });
  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final Widget? suffix;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        onTap: onTap,
        readOnly: readOnly,
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          suffixIcon: suffix,
        ),
        validator: (value) {
          if (value!.trim().isEmpty) {
            return "$hintText is missing!";
          }
          return null;
        });
  }
}
