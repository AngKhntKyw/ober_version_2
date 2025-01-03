import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/driver/driver_page.dart';
import 'package:ober_version_2/passenger/confirm_destination_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Image.asset(
              "assets/images/wallpaper.jpg",
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.xor,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Get.to(
                      () => const DriverPage(),
                      curve: const ElasticInCurve(),
                    );
                  },
                  child: const Text("Driver"),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Get.to(
                      () => const ConfirmDestinationPage(),
                      curve: const ElasticInCurve(),
                    );
                  },
                  child: const Text("Passenger"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
