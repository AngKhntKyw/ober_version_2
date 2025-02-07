import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/passenger_ride_process_page.dart';
import 'package:ober_version_2/pages/passenger/ride/ride_controller.dart';

class ConfrimRidePage extends StatelessWidget {
  const ConfrimRidePage({super.key});

  @override
  Widget build(BuildContext context) {
    Completer<GoogleMapController> mapController = Completer();
    final rideController = Get.put(RideController());
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Obx(
        () {
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: GoogleMap(
                      style: rideController.mapStyle,
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
                          rideController.pickUp.value!.latitude,
                          rideController.pickUp.value!.longitude,
                        ),
                        zoom: 10,
                      ),
                      onMapCreated: (controller) async {
                        mapController.complete(controller);

                        await Future.delayed(const Duration(seconds: 2));

                        mapController.future.then((controller) {
                          controller.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                    rideController.pickUp.value!.latitude,
                                    rideController.pickUp.value!.longitude),
                                zoom: 12,
                              ),
                            ),
                          );
                        });
                      },

                      // markers
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

                      // polylines
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId('route'),
                          points: rideController.polylineCoordinates.value,
                          color: AppPallete.black,
                          width: 4,
                        ),
                      },
                    ),
                  ),

                  //

                  const Expanded(
                    flex: 2,
                    child: Text('ok'),
                  ),
                ],
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.3,
                maxChildSize: 1,
                minChildSize: 0.3,
                snapAnimationDuration: const Duration(milliseconds: 300),
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
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: size.height / 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${rideController.fare.value ?? 0} MMKs"),
                              Text(rideController.distance.value ?? "...."),
                            ],
                          ),
                          Text(rideController.duration.value ?? '....'),
                          SizedBox(height: size.height / 40),
                          const Text("Destination"),
                          SizedBox(height: size.height / 80),
                          Text(rideController.destination.value!.name),
                          SizedBox(height: size.height / 40),
                          const Text("Pick up"),
                          SizedBox(height: size.height / 80),
                          Text(rideController.pickUp.value!.name),
                          SizedBox(height: size.height / 40),
                          ElevatedButton(
                            onPressed: () async {
                              await rideController.bookRide();
                              Get.to(() => const PassengerRideProcessPage());
                              // await Get.offUntil(
                              //   MaterialPageRoute(
                              //       builder: (context) =>
                              //           const PassengerRideProcessPage()),
                              //   (route) =>
                              //       route.settings.name ==
                              //       '/PassengerNavBarPage',
                              // );
                            },
                            child: const Text("Book ride"),
                          ),
                        ],
                      ),
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
