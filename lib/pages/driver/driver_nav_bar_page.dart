import 'package:flutter/material.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/pages/driver/home/driver_home_page.dart';
import 'package:ober_version_2/pages/driver/profile/driver_profile_page.dart';

class DriverNavBarPage extends StatefulWidget {
  const DriverNavBarPage({super.key});

  @override
  State<DriverNavBarPage> createState() => _DriverNavBarPageState();
}

class _DriverNavBarPageState extends State<DriverNavBarPage> {
  int currentIndex = 0;
  final pages = [
    const DriverHomePage(),
    const DriverProfilePage(),
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
