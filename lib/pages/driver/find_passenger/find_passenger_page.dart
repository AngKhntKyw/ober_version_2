import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_passenger_controller.dart';
import 'package:ober_version_2/pages/driver/process_ride/process_ride_page.dart';

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
                          icon: findPassengerController.driverMarkerIcon,
                          rotation:
                              findPassengerController.markerRotation.value,
                          anchor: const Offset(0.5, 0.5),
                        ),

                        //
                        // if (findPassengerController.acceptedRide.value == null)
                        ...findPassengerController.ridesWithin1km.value
                            .map(
                              (e) => Marker(
                                markerId: MarkerId(e.id),
                                position: LatLng(
                                    e.pick_up.latitude, e.pick_up.longitude),
                                icon: findPassengerController
                                    .passengersMarkerIcon,
                              ),
                            )
                            .toSet(),

                        // if (findPassengerController.acceptedRide.value != null)
                        //   Marker(
                        //     markerId: MarkerId(
                        //         findPassengerController.acceptedRide.value!.id),
                        //     position: LatLng(
                        //       findPassengerController
                        //           .acceptedRide.value!.pick_up.latitude,
                        //       findPassengerController
                        //           .acceptedRide.value!.pick_up.longitude,
                        //     ),
                        //     icon: findPassengerController.passengersMarkerIcon,
                        //   ),
                      },
                      circles: {
                        // if (findPassengerController.acceptedRide.value == null)
                        ...findPassengerController.ridesWithin1km.value
                            .map(
                              (e) => Circle(
                                circleId: CircleId(e.id),
                                center: LatLng(
                                    e.pick_up.latitude, e.pick_up.longitude),
                                radius: 1000,
                                fillColor: Colors.blue.withOpacity(0.2),
                                strokeColor: Colors.blue,
                                strokeWidth: 1,
                              ),
                            )
                            .toSet(),
                      },
                      // polylines: {
                      //   if (findPassengerController.acceptedRide.value != null)
                      //     Polyline(
                      //       polylineId: PolylineId(
                      //           findPassengerController.acceptedRide.value!.id),
                      //       color: AppPallete.black,
                      //       points: findPassengerController.routeToPickUp.value,
                      //       width: 6,
                      //     ),
                      // },
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
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: findPassengerController
                                .ridesWithin1km.value.length,
                            itemBuilder: (context, index) {
                              final ride = findPassengerController
                                  .ridesWithin1km.value[index];
                              return RideCard(
                                ride: ride,
                                size: size,
                                findPassengerController:
                                    findPassengerController,
                              );
                            },
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

class RideCard extends StatelessWidget {
  final RideModel ride;
  final Size size;
  final FindPassengerController findPassengerController;

  const RideCard({
    super.key,
    required this.ride,
    required this.size,
    required this.findPassengerController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${ride.fare} MMKs"),
            Text(ride.distance),
          ],
        ),
        Text(ride.duration),
        SizedBox(height: size.height / 40),
        const Text("Destination"),
        Text(ride.destination.name),
        SizedBox(height: size.height / 40),
        const Text("Pick up"),
        Text(ride.pick_up.name),
        SizedBox(height: size.height / 40),
        ElevatedButton(
          onPressed: () {
            findPassengerController.acceptRide(ride: ride);
            Get.to(() => const ProcessRidePage());
          },
          child: const Text("Accept booking"),
        ),
        SizedBox(height: size.height / 40),
        const Divider(),
      ],
    );
  }
}
