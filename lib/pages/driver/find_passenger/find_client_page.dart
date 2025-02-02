import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_client_controller.dart';

class FindClientPage extends StatefulWidget {
  const FindClientPage({super.key});

  @override
  State<FindClientPage> createState() => _FindClientPageState();
}

class _FindClientPageState extends State<FindClientPage> {
  final findClientController = Get.put(FindClientController());

  @override
  Widget build(BuildContext context) {
    log("rebuild");
    return SafeArea(
      child: Scaffold(
        body: Obx(() {
          return findClientController.currentLocation.value == null
              ? const LoadingIndicators()
              : Column(
                  children: [
                    Center(
                      child: Text(
                        findClientController.currentLocation.value!.toString(),
                      ),
                    ),
                    Expanded(
                      child: GoogleMap(
                        compassEnabled: false,
                        zoomControlsEnabled: false,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            findClientController
                                .currentLocation.value!.latitude!,
                            findClientController
                                .currentLocation.value!.longitude!,
                          ),
                          zoom: 15,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          findClientController.mapController
                              .complete(controller);
                        },
                        onCameraMove: (position) {
                          findClientController.onCameraMoved(
                              position: position);
                        },
                        // markers: {
                        //   findClientController.myLocationMaker.value!,
                        // },
                      ),
                    ),
                  ],
                );
        }),
      ),
    );
  }
}
