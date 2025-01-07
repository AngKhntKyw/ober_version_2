import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/driver/profile/driver_profile_controller.dart';

class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return GetBuilder(
      init: DriverProfileController(),
      builder: (driverProfileController) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Profile"),
          ),
          body: driverProfileController.userModel == null
              ? const LoadingIndicators()
              : Column(
                  children: [
                    Container(
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
                                driverProfileController
                                    .userModel!.profile_image,
                              ),
                            ),
                          ),
                          Text(driverProfileController.userModel!.name),
                          Text(driverProfileController.userModel!.email),
                          Text(driverProfileController.userModel!.role),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      height: size.width / 2,
                      width: size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppPallete.black),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/frontal-taxi-cab.png",
                            width: 60,
                            height: 60,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                driverProfileController.userModel!.car!.name,
                              ),
                              Text(
                                driverProfileController
                                    .userModel!.car!.plate_number,
                              ),
                              Text(
                                driverProfileController.userModel!.car!.color,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
