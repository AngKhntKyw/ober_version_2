import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_map_marker_animation/core/ripple_marker.dart';
import 'package:google_map_marker_animation/widgets/animarker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/passenger_process_ride_controller.dart';

class PassengerProcessRidePage extends StatefulWidget {
  const PassengerProcessRidePage({super.key});

  @override
  State<PassengerProcessRidePage> createState() =>
      _PassengerProcessRidePageState();
}

class _PassengerProcessRidePageState extends State<PassengerProcessRidePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final passengerProcessRideController =
        Get.put(PassengerProcessRideController());

    return Scaffold(
      body: Obx(
        () {
          return passengerProcessRideController.currentRide.value == null ||
                  passengerProcessRideController.currentLocation.value == null
              ? const LoadingIndicators()
              : Stack(
                  children: [
                    Animarker(
                      mapId: passengerProcessRideController.mapController.future
                          .then((value) => value.mapId),
                      curve: Curves.linear,
                      angleThreshold: 1.5,
                      runExpressAfter: 5,
                      isActiveTrip: true,
                      useRotation: true,
                      shouldAnimateCamera: true,
                      zoom: 18,
                      markers: {
                        if (passengerProcessRideController
                                    .currentRide.value!.driver !=
                                null &&
                            passengerProcessRideController.currentRide.value!
                                    .driver!.current_address !=
                                null)
                          RippleMarker(
                            ripple: false,
                            markerId: const MarkerId("my location marker"),
                            position: LatLng(
                                passengerProcessRideController.currentRide
                                    .value!.driver!.current_address!.latitude,
                                passengerProcessRideController.currentRide
                                    .value!.driver!.current_address!.longitude),
                            icon: passengerProcessRideController
                                .driverLocationIcon.value,
                            anchor: const Offset(0.5, 0.5),
                            rotation: passengerProcessRideController
                                .driverMarkerRotation.value,
                            // rotation: heading,
                          ),
                      },
                      child: GoogleMap(
                        tiltGesturesEnabled: true,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            passengerProcessRideController
                                .currentLocation.value!.latitude!,
                            passengerProcessRideController
                                .currentLocation.value!.longitude!,
                          ),
                          zoom: passengerProcessRideController.zoomLevel.value,
                        ),
                        zoomControlsEnabled: false,
                        compassEnabled: true,
                        myLocationButtonEnabled: true,
                        myLocationEnabled: false,
                        onMapCreated: (controller) {
                          passengerProcessRideController.mapController
                              .complete(controller);
                        },
                        onCameraMove: (position) {
                          passengerProcessRideController
                                          .currentRide.value!.status ==
                                      "goingToPickUp" ||
                                  passengerProcessRideController
                                          .currentRide.value!.status ==
                                      "goingToDestination"
                              ? passengerProcessRideController
                                  .onDriverCameraMoved(position: position)
                              : passengerProcessRideController.onCameraMoved(
                                  position: position);
                        },
                        markers: {
                          if (passengerProcessRideController
                                  .currentRide.value!.status ==
                              "booking")
                            Marker(
                              markerId: const MarkerId("my location marker"),
                              position: LatLng(
                                passengerProcessRideController
                                    .currentLocation.value!.latitude!,
                                passengerProcessRideController
                                    .currentLocation.value!.longitude!,
                              ),
                              icon: passengerProcessRideController
                                  .myLocationIcon.value,
                              anchor: const Offset(0.5, 0.5),
                              rotation: passengerProcessRideController
                                  .markerRotation.value,
                            ),

                          // going to pick up
                          if (passengerProcessRideController
                                  .currentRide.value!.status ==
                              "goingToPickUp")
                            Marker(
                              markerId: MarkerId(passengerProcessRideController
                                  .currentRide.value!.pick_up.name),
                              position: LatLng(
                                  passengerProcessRideController
                                      .currentRide.value!.pick_up.latitude,
                                  passengerProcessRideController
                                      .currentRide.value!.pick_up.longitude),
                              icon: BitmapDescriptor.defaultMarker,
                            ),
                          // going to destination
                          if (passengerProcessRideController
                                  .currentRide.value!.status ==
                              "goingToDestination")
                            Marker(
                              markerId: MarkerId(passengerProcessRideController
                                  .currentRide.value!.destination.name),
                              position: LatLng(
                                  passengerProcessRideController
                                      .currentRide.value!.destination.latitude,
                                  passengerProcessRideController.currentRide
                                      .value!.destination.longitude),
                              icon: BitmapDescriptor.defaultMarker,
                            ),
                          // if (passengerProcessRideController
                          //             .currentRide.value!.driver !=
                          //         null &&
                          //     passengerProcessRideController.currentRide.value!
                          //             .driver!.current_address !=
                          //         null)
                          // Marker(
                          //   markerId: const MarkerId('driver locaiton'),
                          //   position: LatLng(
                          //       passengerProcessRideController.currentRide
                          //           .value!.driver!.current_address!.latitude,
                          //       passengerProcessRideController
                          //           .currentRide
                          //           .value!
                          //           .driver!
                          //           .current_address!
                          //           .longitude),
                          //   icon: passengerProcessRideController
                          //       .driverLocationIcon.value,
                          //   anchor: const Offset(0.5, 0.5),
                          //   rotation: passengerProcessRideController
                          //       .driverMarkerRotation.value,
                          // ),
                        },
                        circles: {
                          // going to pick up
                          if (passengerProcessRideController
                                  .currentRide.value!.status ==
                              "goingToPickUp")
                            Circle(
                              circleId: const CircleId('pick up'),
                              center: LatLng(
                                  passengerProcessRideController
                                      .currentRide.value!.pick_up.latitude,
                                  passengerProcessRideController
                                      .currentRide.value!.pick_up.longitude),
                              radius: 1000,
                              fillColor: Colors.blue.withOpacity(0.2),
                              strokeColor: Colors.blue,
                              strokeWidth: 1,
                            ),

                          // going to destination
                          if (passengerProcessRideController
                                  .currentRide.value!.status ==
                              "goingToDestination")
                            Circle(
                              circleId: const CircleId('pick up'),
                              center: LatLng(
                                  passengerProcessRideController
                                      .currentRide.value!.destination.latitude,
                                  passengerProcessRideController.currentRide
                                      .value!.destination.longitude),
                              radius: 1000,
                              fillColor: Colors.blue.withOpacity(0.2),
                              strokeColor: Colors.blue,
                              strokeWidth: 1,
                            ),
                        },
                        polylines: {
                          // going to pick up
                          if (passengerProcessRideController
                                  .currentRide.value!.status ==
                              "goingToPickUp")
                            Polyline(
                              polylineId: const PolylineId('going to pick up'),
                              color: AppPallete.black,
                              points: passengerProcessRideController
                                  .goingToPickUpPolylines.value,
                              width: 6,
                            ),

                          // going to destination
                          if (passengerProcessRideController
                                  .currentRide.value!.status ==
                              "goingToDestination")
                            Polyline(
                              polylineId:
                                  const PolylineId('going to destination'),
                              color: AppPallete.black,
                              points: passengerProcessRideController
                                  .goingToDestinationUpPolylines.value,
                              width: 6,
                            ),
                        },
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: 10,
                      right: 10,
                      child: Container(
                        alignment: Alignment.center,
                        width: size.width,
                        height: 80,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppPallete.white,
                          border: Border.all(color: AppPallete.black),
                        ),
                        child: Text(
                          passengerProcessRideController
                              .currentRide.value!.status,
                        ),
                      ),
                    ),
                    DraggableScrollableSheet(
                      initialChildSize: 0.2,
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
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("RIDE"),
                                SizedBox(height: size.height / 40),
                                Text(passengerProcessRideController
                                    .currentRide.value!.status),
                                SizedBox(height: size.height / 40),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "${passengerProcessRideController.currentRide.value!.fare} MMKs"),
                                    Text(passengerProcessRideController
                                        .currentRide.value!.distance),
                                  ],
                                ),
                                Text(passengerProcessRideController
                                    .currentRide.value!.duration),
                                SizedBox(height: size.height / 40),
                                const Text("Destination"),
                                Text(passengerProcessRideController
                                    .currentRide.value!.destination.name),
                                SizedBox(height: size.height / 40),
                                const Text("Pick up"),
                                Text(passengerProcessRideController
                                    .currentRide.value!.pick_up.name),
                                SizedBox(height: size.height / 40),
                                const Divider(),
                                SizedBox(height: size.height / 40),

                                //
                                const Text("DRIVER"),
                                SizedBox(height: size.height / 40),

                                passengerProcessRideController
                                            .currentRide.value!.driver !=
                                        null
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("name"),
                                          Text(passengerProcessRideController
                                              .currentRide.value!.driver!.name),
                                          SizedBox(height: size.height / 40),
                                          const Text("email"),
                                          Text(passengerProcessRideController
                                              .currentRide
                                              .value!
                                              .driver!
                                              .email),
                                          SizedBox(height: size.height / 40),
                                          passengerProcessRideController
                                                      .currentRide
                                                      .value!
                                                      .driver!
                                                      .current_address !=
                                                  null
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text("latitude"),
                                                    Text(
                                                        passengerProcessRideController
                                                            .currentRide
                                                            .value!
                                                            .driver!
                                                            .current_address!
                                                            .latitude
                                                            .toString()),
                                                    SizedBox(
                                                        height:
                                                            size.height / 40),
                                                    const Text("longitude"),
                                                    Text(
                                                        passengerProcessRideController
                                                            .currentRide
                                                            .value!
                                                            .driver!
                                                            .current_address!
                                                            .longitude
                                                            .toString()),
                                                    SizedBox(
                                                        height:
                                                            size.height / 40),
                                                    const Text("rotation"),
                                                    Text(
                                                        passengerProcessRideController
                                                            .currentRide
                                                            .value!
                                                            .driver!
                                                            .current_address!
                                                            .rotation
                                                            .toString()),
                                                  ],
                                                )
                                              : const Text(
                                                  "loading driver address....")
                                        ],
                                      )
                                    : const Text("booking..."),
                                SizedBox(height: size.height / 40),
                                const Divider(),
                                SizedBox(height: size.height / 40),

                                //
                                const Text("CAR"),
                                SizedBox(height: size.height / 40),

                                passengerProcessRideController
                                            .currentRide.value!.driver !=
                                        null
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(passengerProcessRideController
                                              .currentRide
                                              .value!
                                              .driver!
                                              .car!
                                              .name),
                                          Text(passengerProcessRideController
                                              .currentRide
                                              .value!
                                              .driver!
                                              .car!
                                              .plate_number),
                                          Text(passengerProcessRideController
                                              .currentRide
                                              .value!
                                              .driver!
                                              .car!
                                              .color),
                                        ],
                                      )
                                    : const Text("booking..."),
                                SizedBox(height: size.height / 40),

                                const Divider(),
                                SizedBox(height: size.height / 40),
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
