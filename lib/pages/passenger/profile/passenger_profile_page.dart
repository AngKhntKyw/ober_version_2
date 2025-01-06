import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/passenger/profile/passenger_profile_controller.dart';

class PassengerProfilePage extends StatefulWidget {
  const PassengerProfilePage({super.key});

  @override
  State<PassengerProfilePage> createState() => _PassengerProfilePageState();
}

class _PassengerProfilePageState extends State<PassengerProfilePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return GetBuilder(
      init: PassengerProfileController(),
      builder: (passengerProfileController) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Profile"),
          ),
          body: passengerProfileController.userModel == null
              ? const LoadingIndicators()
              : Container(
                  margin: const EdgeInsets.all(10),
                  height: size.width / 2,
                  width: size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppPallete.black),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: AppPallete.black,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: AppPallete.black,
                          foregroundImage: CachedNetworkImageProvider(
                            passengerProfileController.userModel!.profile_image,
                          ),
                        ),
                      ),
                      Text(passengerProfileController.userModel!.name),
                      Text(passengerProfileController.userModel!.email),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
