import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/driver/driver_page.dart';
import 'package:ober_version_2/pages/home/home_controller.dart';
import 'package:ober_version_2/pages/passenger/passenger_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: HomeController(),
      builder: (homeController) {
        return homeController.userModel == null
            ? const Scaffold(body: LoadingIndicators())
            : homeController.userModel?.role == "driver"
                ? const DriverPage()
                : const PassengerPage();
      },
    );
  }
}
