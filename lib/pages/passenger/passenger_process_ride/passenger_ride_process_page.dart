import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/elevated_buttons.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/passenger/passenger_nav_bar_page.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/passenger_ride_process_controller.dart';

class PassengerRideProcessPage extends StatelessWidget {
  const PassengerRideProcessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final passengerRideProcessController =
        Get.put(PassengerRideProcessController());
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Obx(
        () {
          return passengerRideProcessController.currentLocation.value == null ||
                  passengerRideProcessController.currentRide.value == null
              ? const LoadingIndicators()
              : Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              GoogleMap(
                                style: passengerRideProcessController.mapStyle,
                                compassEnabled: false,
                                zoomControlsEnabled: false,
                                myLocationEnabled: false,
                                trafficEnabled: false,
                                buildingsEnabled: false,
                                liteModeEnabled: false,
                                scrollGesturesEnabled: true,

                                zoomGesturesEnabled: true,
                                myLocationButtonEnabled: false,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    passengerRideProcessController
                                        .currentLocation.value!.latitude,
                                    passengerRideProcessController
                                        .currentLocation.value!.longitude,
                                  ),
                                  zoom: 10,
                                ),
                                onMapCreated: (controller) async {
                                  passengerRideProcessController.mapController
                                      .complete(controller);

                                  await Future.delayed(
                                      const Duration(seconds: 2));

                                  passengerRideProcessController.updateUI(
                                      zoom: 16);

                                  await Future.delayed(
                                      const Duration(seconds: 2));

                                  await passengerRideProcessController
                                      .getCurrentLocationOnUpdate();

                                  await passengerRideProcessController
                                      .getDestinationPolyPoints(
                                    origin: PointLatLng(
                                        passengerRideProcessController
                                            .currentRide
                                            .value!
                                            .pick_up
                                            .latitude,
                                        passengerRideProcessController
                                            .currentRide
                                            .value!
                                            .pick_up
                                            .longitude),
                                    destination: PointLatLng(
                                        passengerRideProcessController
                                            .currentRide
                                            .value!
                                            .destination
                                            .latitude,
                                        passengerRideProcessController
                                            .currentRide
                                            .value!
                                            .destination
                                            .longitude),
                                  );
                                },
                                onCameraMove: (position) {
                                  passengerRideProcessController.onCameraMoved(
                                      position: position);
                                },

                                // markers
                                markers: {
                                  Marker(
                                    icon: BitmapDescriptor.defaultMarker,
                                    markerId: const MarkerId('pick up'),
                                    position: LatLng(
                                      passengerRideProcessController
                                          .currentRide.value!.pick_up.latitude,
                                      passengerRideProcessController
                                          .currentRide.value!.pick_up.longitude,
                                    ),
                                    infoWindow: InfoWindow(
                                      title: passengerRideProcessController
                                          .currentRide.value!.pick_up.name,
                                      snippet: "pick up",
                                    ),
                                  ),
                                  Marker(
                                    icon: BitmapDescriptor.defaultMarker,
                                    markerId: const MarkerId('destination'),
                                    position: LatLng(
                                      passengerRideProcessController.currentRide
                                          .value!.destination.latitude,
                                      passengerRideProcessController.currentRide
                                          .value!.destination.longitude,
                                    ),
                                    infoWindow: InfoWindow(
                                      title: passengerRideProcessController
                                          .currentRide.value!.destination.name,
                                      snippet: "destination",
                                    ),
                                  ),

                                  // driver marker
                                  if (passengerRideProcessController
                                          .currentRide.value!.driver !=
                                      null)
                                    Marker(
                                      icon: passengerRideProcessController
                                          .driverLocationIcon.value,
                                      markerId: const MarkerId('driver'),
                                      position: LatLng(
                                        passengerRideProcessController
                                            .currentRide
                                            .value!
                                            .driver!
                                            .current_address!
                                            .latitude,
                                        passengerRideProcessController
                                            .currentRide
                                            .value!
                                            .driver!
                                            .current_address!
                                            .longitude,
                                      ),
                                      anchor: const Offset(0.5, 0.5),
                                      rotation: passengerRideProcessController
                                          .currentRide
                                          .value!
                                          .driver!
                                          .current_address!
                                          .rotation,
                                    ),
                                },

                                // polylines
                                polylines: {
                                  Polyline(
                                    polylineId: const PolylineId('route'),
                                    points: passengerRideProcessController
                                        .polylineCoordinates.value,
                                    color: AppPallete.black,
                                    width: 4,
                                  ),
                                },
                              ),

                              //
                              AnimatedRotation(
                                turns: passengerRideProcessController
                                    .compassHeading.value,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.linear,
                                alignment: Alignment.center,
                                child: Image.asset(
                                  'assets/images/navigation.png',
                                  height: 30,
                                  width: 30,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(passengerRideProcessController
                                        .currentRide.value !=
                                    null
                                ? passengerRideProcessController
                                    .currentRide.value!.status
                                : "OK"),
                          ),
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
                              children: [
                                Text(passengerRideProcessController
                                    .currentRide.value!.status),
                                SizedBox(height: size.height / 40),

                                //
                                if (passengerRideProcessController
                                        .currentRide.value!.status !=
                                    "booking")
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor: AppPallete.black,
                                            child: CircleAvatar(
                                              radius: 20,
                                              backgroundColor: AppPallete.black,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      passengerRideProcessController
                                                          .currentRide
                                                          .value!
                                                          .driver!
                                                          .profile_image),
                                            ),
                                          ),
                                          SizedBox(width: size.width / 20),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  passengerRideProcessController
                                                      .currentRide
                                                      .value!
                                                      .driver!
                                                      .name),
                                              Text(
                                                  passengerRideProcessController
                                                      .currentRide
                                                      .value!
                                                      .driver!
                                                      .email),
                                              Text(
                                                  "${passengerRideProcessController.currentRide.value!.driver!.car!.name}-${passengerRideProcessController.currentRide.value!.driver!.car!.color}"),
                                              Text(
                                                  passengerRideProcessController
                                                      .currentRide
                                                      .value!
                                                      .driver!
                                                      .car!
                                                      .plate_number),
                                            ],
                                          ),
                                        ],
                                      ),
                                      CircleAvatar(
                                        backgroundColor: AppPallete.black,
                                        child: IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.call,
                                            color: AppPallete.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                //

                                SizedBox(height: size.height / 40),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "${passengerRideProcessController.currentRide.value!.fare} MMKs"),
                                    Text(passengerRideProcessController
                                        .currentRide.value!.distance),
                                  ],
                                ),
                                Text(passengerRideProcessController
                                    .currentRide.value!.duration),
                                SizedBox(height: size.height / 40),
                                const Text("Destination"),
                                SizedBox(height: size.height / 80),
                                Text(passengerRideProcessController
                                    .currentRide.value!.destination.name),
                                SizedBox(height: size.height / 40),
                                const Text("Pick up"),
                                SizedBox(height: size.height / 80),
                                Text(passengerRideProcessController
                                    .currentRide.value!.pick_up.name),
                                SizedBox(height: size.height / 40),
                                ElevatedButtons(
                                  onPressed: () async {
                                    await passengerRideProcessController
                                        .cancelBooking();
                                    Get.offAll(const PassengerNavBarPage());
                                  },
                                  buttonName: "Cancel booking",
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  ],
                );
        },
      ),
    );
  }
}
