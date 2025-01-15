import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/passenger_process_ride_page.dart';
import 'package:ober_version_2/pages/passenger/ride/ride_controller.dart';

class ConfrimRidePage extends StatefulWidget {
  const ConfrimRidePage({super.key});

  @override
  State<ConfrimRidePage> createState() => _ConfrimRidePageState();
}

class _ConfrimRidePageState extends State<ConfrimRidePage> {
  final location = Location();
  final Completer<GoogleMapController> mapController = Completer();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    //
    return GetBuilder(
      init: RideController(),
      builder: (rideController) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          rideController.getDestinationPolyPoints();
        });
        return Scaffold(
          body: StreamBuilder(
            stream: location.onLocationChanged,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicators();
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text("An error occurred"),
                );
              }

              final currentLocation = snapshot.data!;
              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(0, 0),
                    ),
                    onMapCreated: (controller) {
                      mapController.complete(controller);
                      mapController.future.then((mapController) async {
                        mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                currentLocation.latitude!,
                                currentLocation.longitude!,
                              ),
                              zoom: 12,
                            ),
                          ),
                        );

                        await mapController.showMarkerInfoWindow(
                            const MarkerId("destination"));
                      });
                    },
                    markers: {
                      Marker(
                        icon: BitmapDescriptor.defaultMarker,
                        markerId: const MarkerId('pick up'),
                        position: LatLng(
                          rideController.pickUp!.latitude,
                          rideController.pickUp!.longitude,
                        ),
                        infoWindow: InfoWindow(
                          title: rideController.pickUp!.name,
                          snippet: "pick up",
                        ),
                      ),
                      Marker(
                        icon: BitmapDescriptor.defaultMarker,
                        markerId: const MarkerId('destination'),
                        position: LatLng(
                          rideController.destination!.latitude,
                          rideController.destination!.longitude,
                        ),
                        infoWindow: InfoWindow(
                          title: rideController.destination!.name,
                          snippet: "destination",
                        ),
                      ),
                    },
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId('route'),
                        points: rideController.polylineCoordinates,
                        color: AppPallete.black,
                        width: 6,
                      ),
                    },
                  ),
                  DraggableScrollableSheet(
                    initialChildSize: 0.4,
                    maxChildSize: 0.4,
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
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: size.height / 40),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${rideController.fare ?? 0} MMKs"),
                                  Text(rideController.distance ?? "...."),
                                ],
                              ),
                              Text(rideController.duration ?? '....'),
                              SizedBox(height: size.height / 40),
                              const Text("Destination"),
                              SizedBox(height: size.height / 80),
                              Text(rideController.destination!.name),
                              SizedBox(height: size.height / 40),
                              const Text("Pick up"),
                              SizedBox(height: size.height / 80),
                              Text(rideController.pickUp!.name),
                              SizedBox(height: size.height / 40),
                              ElevatedButton(
                                onPressed: () async {
                                  await rideController.bookRide();
                                  // Get.to(() => const RidePage());
                                  Get.to(
                                      () => const PassengerProcessRidePage());
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
      },
    );
  }
}
