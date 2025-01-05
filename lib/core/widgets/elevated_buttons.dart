import 'package:flutter/material.dart';

class ElevatedButtons extends StatelessWidget {
  final String buttonName;
  final VoidCallback onPressed;
  const ElevatedButtons(
      {super.key, required this.buttonName, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(buttonName));
  }
}
