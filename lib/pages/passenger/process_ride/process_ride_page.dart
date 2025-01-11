import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/passenger/process_ride/process_ride_controller.dart';

class ProcessRidePage extends StatefulWidget {
  const ProcessRidePage({super.key});

  @override
  State<ProcessRidePage> createState() => _ProcessRidePageState();
}

class _ProcessRidePageState extends State<ProcessRidePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final processRideController = Get.put(ProcessRideController());
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   processRideController.getDestinationPolyPoints();
    // });
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
                          icon: processRideController.passengersMarkerIcon,
                          rotation: processRideController.markerRotation.value,
                          anchor: const Offset(0.5, 0.5),
                        ),
                        Marker(
                          markerId: const MarkerId('driver location'),
                          position: LatLng(
                            processRideController.currentRide.value!.driver!
                                .current_address!.latitude,
                            processRideController.currentRide.value!.driver!
                                .current_address!.longitude,
                          ),
                          icon: processRideController.driverMarkerIcon,
                          rotation: processRideController.currentRide.value!
                              .driver!.current_address!.rotation,
                          anchor: const Offset(0.5, 0.5),
                        ),
                        Marker(
                          markerId: const MarkerId('pick up'),
                          position: LatLng(
                            processRideController
                                .currentRide.value!.pick_up.latitude,
                            processRideController
                                .currentRide.value!.pick_up.longitude,
                          ),
                          icon: BitmapDescriptor.defaultMarker,
                          anchor: const Offset(0.5, 0.5),
                        ),
                      },
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId('route to destination'),
                          points: processRideController.polylineCoordinates,
                          color: AppPallete.black,
                          width: 6,
                        ),
                      },
                    ),
                    // DraggableScrollableSheet(
                    //   initialChildSize: 0.4,
                    //   maxChildSize: 1,
                    //   minChildSize: 0.2,
                    //   snapAnimationDuration: const Duration(milliseconds: 500),
                    //   builder: (context, scrollController) {
                    //     return Container(
                    //       padding: const EdgeInsets.all(10),
                    //       decoration: BoxDecoration(
                    //         borderRadius: const BorderRadius.only(
                    //           topLeft: Radius.circular(20),
                    //           topRight: Radius.circular(20),
                    //         ),
                    //         color: AppPallete.white,
                    //         border: Border.all(color: AppPallete.black),
                    //       ),
                    //       child: processRideController.currentRide.value == null
                    //           ? const LoadingIndicators()
                    //           : Text(
                    //               processRideController.currentRide.value!
                    //                   .driver!.current_address!
                    //                   .toString(),
                    //             ),
                    //     );
                    //   },
                    // ),
                  ],
                );
        },
      ),
    );
  }
}
