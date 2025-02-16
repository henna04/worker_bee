import 'package:flutter/material.dart';

class CustomTextformField extends StatelessWidget {
  const CustomTextformField({
    super.key,
    this.controller,
    required this.fieldText,
    this.validator,
    this.prefixText,
    this.maxLine,
    this.keyboardType,
    this.maxLength,
    this.obscureText = false,
    this.prefixIcon,
  });
  final TextEditingController? controller;
  final String fieldText;
  final String? Function(String?)? validator;
  final String? prefixText;
  final int? maxLine;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool obscureText;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: fieldText,
        prefixText: prefixText,
        prefixIcon: prefixIcon,
      ),
      maxLines: obscureText ? 1 : maxLine,
    );
  }
}
