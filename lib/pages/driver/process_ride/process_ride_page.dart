import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/driver/process_ride/process_ride.dart';

class ProcessRidePage extends StatefulWidget {
  const ProcessRidePage({super.key});

  @override
  State<ProcessRidePage> createState() => _ProcessRidePageState();
}

class _ProcessRidePageState extends State<ProcessRidePage> {
  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.sizeOf(context);
    final processRideController = Get.put(ProcessRideController());
    return Scaffold(
      body: Obx(
        () {
          return processRideController.currentLocation.value == null
              ? const LoadingIndicators()
              : Stack(
                  children: [
                    GoogleMap(
                      rotateGesturesEnabled: true,
                      fortyFiveDegreeImageryEnabled: true,
                      compassEnabled: true,
                      buildingsEnabled: false,
                      initialCameraPosition: CameraPosition(
                        zoom: 12,
                        target: LatLng(
                          processRideController
                              .currentLocation.value!.latitude!,
                          processRideController
                              .currentLocation.value!.longitude!,
                        ),
                      ),
                      onMapCreated: (controller) {
                        processRideController.mapController
                            .complete(controller);
                      },
                      onCameraMove: (position) {
                        processRideController.onCameraMove(position);
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('current location'),
                          position: LatLng(
                            processRideController
                                .currentLocation.value!.latitude!,
                            processRideController
                                .currentLocation.value!.longitude!,
                          ),
                          icon: processRideController.driverMarkerIcon,
                          rotation: processRideController.markerRotation.value,
                          anchor: const Offset(0.5, 0.5),
                        ),
                        Marker(
                          markerId: MarkerId(
                              processRideController.acceptedRide.value!.id),
                          position: LatLng(
                              processRideController
                                  .acceptedRide.value!.pick_up.latitude,
                              processRideController
                                  .acceptedRide.value!.pick_up.longitude),
                          icon: processRideController.passengersMarkerIcon,
                        ),
                      },
                      polylines: {
                        if (processRideController.acceptedRide.value != null)
                          Polyline(
                            polylineId: PolylineId(
                                processRideController.acceptedRide.value!.id),
                            color: AppPallete.black,
                            points: processRideController.routeToPickUp.value,
                            width: 6,
                          ),
                      },
                    ),
                    DraggableScrollableSheet(
                      initialChildSize: 0.4,
                      maxChildSize: 1,
                      minChildSize: 0.2,
                      snapAnimationDuration: const Duration(milliseconds: 500),
                      builder: (context, scrollController) {
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            color: AppPallete.white,
                            border: Border.all(color: AppPallete.black),
                          ),
                          child: Column(
                            children: [
                              Text(processRideController
                                  .acceptedRide.value!.status),
                              ElevatedButton(
                                onPressed: () {
                                  processRideController.pickUpPassenger();
                                },
                                child: const Text("Pick UP"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
        },
      ),
    );
  }
}
