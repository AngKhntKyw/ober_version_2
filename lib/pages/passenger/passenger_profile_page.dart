import 'package:flutter/material.dart';

class PassengerProfilePage extends StatefulWidget {
  const PassengerProfilePage({super.key});

  @override
  State<PassengerProfilePage> createState() => _PassengerProfilePageState();
}

class _PassengerProfilePageState extends State<PassengerProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
    );
  }
}
