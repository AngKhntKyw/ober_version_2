import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_food_controller.dart';

class FindFoodPage extends StatelessWidget {
  const FindFoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    final findFoodController = Get.put(FindFoodController());

    return Scaffold(
      body: Obx(
        () {
          return findFoodController.currentLocation.value == null
              ? const LoadingIndicators()
              : Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          GoogleMap(
                            style: findFoodController.mapStyle.value,
                            compassEnabled: false,
                            zoomControlsEnabled: false,
                            myLocationEnabled: true,
                            trafficEnabled: false,
                            buildingsEnabled: false,
                            liteModeEnabled: false,
                            scrollGesturesEnabled: true,
                            zoomGesturesEnabled: true,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                  findFoodController
                                      .currentLocation.value!.latitude!,
                                  findFoodController
                                      .currentLocation.value!.longitude!),
                              zoom: 10,
                              bearing: 10,
                            ),
                            onMapCreated: (controller) async {
                              findFoodController.mapController
                                  .complete(controller);

                              await Future.delayed(const Duration(seconds: 2));
                              controller.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: LatLng(
                                      findFoodController
                                          .currentLocation.value!.latitude!,
                                      findFoodController
                                          .currentLocation.value!.longitude!,
                                    ),
                                    zoom: 16,
                                    bearing: findFoodController
                                        .currentLocation.value!.heading!,
                                  ),
                                ),
                              );
                              await Future.delayed(const Duration(seconds: 2));
                              await findFoodController
                                  .getCurrentLocationOnUpdate();
                            },
                            onCameraMove: (position) {
                              findFoodController.onCameraMoved(
                                  position: position);
                            },
                          ),
                          if (findFoodController.zooming.value == false)
                            Image.asset(
                              'assets/images/car.png',
                              height: 40,
                              width: 40,
                              filterQuality: FilterQuality.high,
                            ),
                        ],
                      ),
                    ),
                    // const Expanded(
                    //   flex: 3,
                    //   child: Center(
                    //     child: Text("hello"),
                    //   ),
                    // ),
                  ],
                );
          //
        },
      ),
    );
  }
}
