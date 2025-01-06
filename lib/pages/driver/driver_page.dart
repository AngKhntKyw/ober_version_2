import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/auth_gate.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key});

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver"),
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
