import 'package:flutter/material.dart';

class CustomTextformField extends StatelessWidget {
  const CustomTextformField({
    super.key,
    this.controller,
    required this.fieldText,
    this.validator,
    this.prefixText, this.maxLine,
  });
  final TextEditingController? controller;
  final String fieldText;
  final String? Function(String?)? validator;
  final String? prefixText;
  final int? maxLine;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: fieldText,
        prefixText: prefixText,
      ),
      maxLines: maxLine,
    );
  }
}
