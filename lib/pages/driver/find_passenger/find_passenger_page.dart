import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_passenger_controller.dart';

class FindPassengerPage extends StatelessWidget {
  const FindPassengerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final findPassengerController = Get.put(FindPassengerController());

    return Scaffold(
      body: Obx(
        () {
          return findPassengerController.currentLocation.value == null
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
                          findPassengerController
                              .currentLocation.value!.latitude!,
                          findPassengerController
                              .currentLocation.value!.longitude!,
                        ),
                      ),
                      onMapCreated: (controller) {
                        findPassengerController.mapController
                            .complete(controller);
                      },
                      onCameraMove: (position) {
                        findPassengerController.onCameraMove(position);
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('current location'),
                          position: LatLng(
                            findPassengerController
                                .currentLocation.value!.latitude!,
                            findPassengerController
                                .currentLocation.value!.longitude!,
                          ),
                          // position: findPassengerController
                          //     .currentMarkerPosition.value,
                          icon: findPassengerController.markerIcon,

                          rotation:
                              findPassengerController.markerRotation.value,

                          anchor: const Offset(0.5, 0.5),
                        ),
                      },
                    ),
                    // DraggableScrollableSheet(
                    //   initialChildSize: 0.4,
                    //   maxChildSize: 0.4,
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
                    //       child: SingleChildScrollView(
                    //         controller: scrollController,
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           mainAxisSize: MainAxisSize.min,
                    //           children: [
                    //             SizedBox(height: size.height / 40),
                    //             Text(findPassengerController.rides.value.length
                    //                 .toString()),
                    //           ],
                    //         ),
                    //       ),
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



  // if (rideSnapshot.connectionState ==
  //                                 ConnectionState.waiting) {
  //                               return const LoadingIndicators();
  //                             }
  //                             if (rideSnapshot.hasError) {
  //                               return const Center(
  //                                 child: Text("An error occurred"),
  //                               );
  //                             }
