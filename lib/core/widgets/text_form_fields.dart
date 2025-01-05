import 'package:flutter/material.dart';

class TextFormFields extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isObscureText;
  final FocusNode? focusNode;

  const TextFormFields({
    super.key,
    required this.hintText,
    required this.controller,
    required this.isObscureText,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      minLines: 1,
      // maxLines: 8,
      obscureText: isObscureText,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hintText,
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return '$hintText is missing';
        }
        return null;
      },
    );
  }
}
