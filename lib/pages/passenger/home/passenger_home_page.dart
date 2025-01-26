import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/auth_gate.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/pages/passenger/home/passenger_home_controller.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/passenger_process_ride_page.dart';
import 'package:ober_version_2/pages/passenger/ride/confirm_destination_page.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:url_launcher/url_launcher.dart';

class PassengerHomePage extends StatefulWidget {
  const PassengerHomePage({super.key});

  @override
  State<PassengerHomePage> createState() => _PassengerHomePageState();
}

class _PassengerHomePageState extends State<PassengerHomePage> {
  final passengerHomeController = Get.put(PassengerHomeController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Ober Passenger"),
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
                        width: size.width,
                        height: size.width / 3,
                        child: GridView(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4),
                          children: [
                            IconCard(
                              icon: passengerHomeController.currentRide.value ==
                                      null
                                  ? Icons.local_taxi
                                  : Icons.timelapse,
                              label: "Ober Taxi",
                              onPressed: () {
                                passengerHomeController.currentRide.value ==
                                        null
                                    ? Get.to(
                                        () => const ConfirmDestinationPage())
                                    : toast("You have current ride.");
                              },
                            ),
                            IconCard(
                              icon: Icons.local_pizza,
                              label: "Ober Food",
                              onPressed: () async {
                                const url =
                                    "https://www.facebook.com/share/p/19n4q2StLt/";

                                final Uri webUri = Uri.parse(url);

                                if (await canLaunchUrl(webUri)) {
                                  await launchUrl(webUri,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  log("Could not launch $url");
                                }
                              },
                            ),
                            IconCard(
                              icon: Icons.checkroom_outlined,
                              label: "Ober Clothing",
                              onPressed: () {
                                FirebaseMessaging.instance
                                    .getToken()
                                    .then((value) => log(value.toString()));
                              },
                            ),
                            IconCard(
                              icon: Icons.girl,
                              label: "Ober prostitute",
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        width: size.width,
                        height: size.width / 3,
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
                            Container(
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Payments"),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("90"),
                                      Icon(Icons.credit_card),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("User points"),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("90"),
                                      Icon(Icons.workspace_premium),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                //

                passengerHomeController.currentRide.value == null
                    ? const SizedBox()
                    : InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          Get.to(() => const PassengerProcessRidePage());
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
                                  Text(passengerHomeController
                                      .currentRide.value!.id),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            );
          },
        ));
  }
}

class IconCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const IconCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: AppPallete.black,
            radius: 30,
            child: Icon(
              icon,
              color: AppPallete.white,
            ),
          ),
          Text(label),
        ],
      ),
    );
  }
}
