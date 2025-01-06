import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/auth_gate.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/pages/passenger/ride/confirm_destination_page.dart';

class PassengerHomePage extends StatefulWidget {
  const PassengerHomePage({super.key});

  @override
  State<PassengerHomePage> createState() => _PassengerHomePageState();
}

class _PassengerHomePageState extends State<PassengerHomePage> {
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
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: size.width,
            height: size.width / 3,
            child: GridView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4),
              children: [
                IconCard(
                  icon: Icons.local_taxi,
                  label: "Ober Taxi",
                  onPressed: () {
                    Get.to(() => const ConfirmDestinationPage());
                  },
                ),
                IconCard(
                  icon: Icons.local_pizza,
                  label: "Ober Food",
                  onPressed: () {},
                ),
                IconCard(
                  icon: Icons.checkroom_outlined,
                  label: "Ober Clothing",
                  onPressed: () {},
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("90"),
                            Icon(Icons.workspace_premium),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
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
