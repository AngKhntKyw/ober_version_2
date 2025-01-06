import 'package:flutter/material.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/pages/passenger/passenger_home_page.dart';
import 'package:ober_version_2/pages/passenger/passenger_profile_page.dart';

class PassengerNavBarPage extends StatefulWidget {
  const PassengerNavBarPage({super.key});

  @override
  State<PassengerNavBarPage> createState() => _PassengerNavBarPageState();
}

class _PassengerNavBarPageState extends State<PassengerNavBarPage> {
  int currentIndex = 0;
  final pages = [
    const PassengerHomePage(),
    const PassengerProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        currentIndex: currentIndex,
        backgroundColor: AppPallete.white,
        selectedItemColor: AppPallete.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_3_outlined),
            activeIcon: Icon(Icons.person_3),
            label: 'profile',
          ),
        ],
      ),
    );
  }
}
