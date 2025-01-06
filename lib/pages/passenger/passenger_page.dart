import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/auth_gate.dart';

class PassengerPage extends StatefulWidget {
  const PassengerPage({super.key});

  @override
  State<PassengerPage> createState() => _PassengerPageState();
}

class _PassengerPageState extends State<PassengerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Passenger"),
        actions: [
          IconButton(
              onPressed: () async {
                FirebaseAuth.instance.signOut();
                Get.offAll(() => const AuthGate());
              },
              icon: const Icon(Icons.logout))
        ],
      ),
    );
  }
}
