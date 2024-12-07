import 'package:flutter/material.dart';

class CustomTextformField extends StatelessWidget {
  const CustomTextformField({
    super.key,
    this.controller,
    required this.fieldText,
    this.validator,
  });
  final TextEditingController? controller;
  final String fieldText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: fieldText,
      ),
    );
  }
}
