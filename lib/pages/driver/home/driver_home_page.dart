import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/auth_gate.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_client_page.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_food_page.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_passenger_page.dart';
import 'package:ober_version_2/pages/driver/home/driver_home_controller.dart';
import 'package:overlay_support/overlay_support.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final driverHomeController = Get.put(DriverHomeController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ober Driver"),
        actions: [
          IconButton(
            onPressed: () async {
              FirebaseAuth.instance.signOut();
              Get.offAll(() => const AuthGate());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Obx(
        () {
          return Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      width: size.width,
                      height: size.width / 2,
                      child: GridView(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        children: [
                          ItemCard(
                            icon: Icons.taxi_alert_rounded,
                            label: "Find passenger",
                            onPressed: () {
                              driverHomeController.currentRide.value == null
                                  ? Get.to(() => const FindPassengerPage())
                                  : toast("You have current ride.");
                            },
                          ),
                          ItemCard(
                            icon: Icons.local_taxi_sharp,
                            label: "Find Client",
                            onPressed: () {
                              Get.to(() => const FindClientPage());
                            },
                          ),
                          ItemCard(
                            icon: Icons.fastfood,
                            label: "Find Food",
                            onPressed: () {
                              Get.to(() => const FindFoodPage());
                            },
                          ),
                          ItemCard(
                            icon: Icons.share_location_outlined,
                            label: "Find Clothing",
                            onPressed: () async {
                              Geolocator.getPositionStream()
                                  .listen((Position position) {
                                log('Latitude: ${position.latitude}, Longitude: ${position.heading}');
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              driverHomeController.currentRide.value == null
                  ? const SizedBox()
                  : InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        // Get.to(() => const FindPassengerPage());

                        Get.to(() => const FindFoodPage());
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: size.width,
                        height: size.height / 10,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppPallete.white,
                          border: Border.all(color: AppPallete.black),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(4, 4),
                              blurRadius: 5,
                              blurStyle: BlurStyle.inner,
                              spreadRadius: 0.1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppPallete.black,
                              child: Icon(
                                Icons.local_taxi_rounded,
                                color: AppPallete.white,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Current Ride"),
                                Text(
                                    driverHomeController.currentRide.value!.id),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}

class ItemCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const ItemCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(label),
            Icon(icon),
          ],
        ),
      ),
    );
  }
}
