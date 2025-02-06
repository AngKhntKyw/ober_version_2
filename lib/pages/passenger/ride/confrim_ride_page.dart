import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/passenger/ride/ride_controller.dart';

class ConfrimRidePage extends StatelessWidget {
  const ConfrimRidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final rideController = Get.put(RideController());

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   rideController.getDestinationPolyPoints();
    // });s
    // final size = MediaQuery.sizeOf(context);

    //
    return Scaffold(
      body: Obx(
        () {
          return rideController.currentLocation.value == null
              ? const LoadingIndicators()
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      rideController.currentLocation.value!.latitude!,
                      rideController.currentLocation.value!.longitude!,
                    ),
                    zoom: 10,
                  ),
                  onMapCreated: (controller) async {
                    rideController.mapController = controller;
                  },
                  markers: {
                    Marker(
                      icon: BitmapDescriptor.defaultMarker,
                      markerId: const MarkerId('pick up'),
                      position: LatLng(
                        rideController.pickUp.value!.latitude,
                        rideController.pickUp.value!.longitude,
                      ),
                      infoWindow: InfoWindow(
                        title: rideController.pickUp.value!.name,
                        snippet: "pick up",
                      ),
                    ),
                    Marker(
                      icon: BitmapDescriptor.defaultMarker,
                      markerId: const MarkerId('destination'),
                      position: LatLng(
                        rideController.destination.value!.latitude,
                        rideController.destination.value!.longitude,
                      ),
                      infoWindow: InfoWindow(
                        title: rideController.destination.value!.name,
                        snippet: "destination",
                      ),
                    ),
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: rideController.polylineCoordinates.value,
                      color: AppPallete.black,
                      width: 4,
                    ),
                  },
                );
        },
      ),
    );
  }
}

// DraggableScrollableSheet(
//                     initialChildSize: 0.4,
//                     maxChildSize: 0.4,
//                     minChildSize: 0.2,
//                     snapAnimationDuration: const Duration(milliseconds: 500),
//                     builder: (context, scrollController) {
//                       return Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(20),
//                             topRight: Radius.circular(20),
//                           ),
//                           color: AppPallete.white,
//                           border: Border.all(color: AppPallete.black),
//                         ),
//                         child: SingleChildScrollView(
//                           controller: scrollController,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               SizedBox(height: size.height / 40),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                       "${rideController.fare.value ?? 0} MMKs"),
//                                   Text(rideController.distance.value ?? "...."),
//                                 ],
//                               ),
//                               Text(rideController.duration.value ?? '....'),
//                               SizedBox(height: size.height / 40),
//                               const Text("Destination"),
//                               SizedBox(height: size.height / 80),
//                               Text(rideController.destination.value!.name),
//                               SizedBox(height: size.height / 40),
//                               const Text("Pick up"),
//                               SizedBox(height: size.height / 80),
//                               Text(rideController.pickUp.value!.name),
//                               SizedBox(height: size.height / 40),
//                               ElevatedButton(
//                                 onPressed: () async {
//                                   await rideController.bookRide();
//                                   // Get.to(() => const RidePage());
//                                   Get.to(
//                                       () => const PassengerProcessRidePage());
//                                 },
//                                 child: const Text("Book ride"),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
