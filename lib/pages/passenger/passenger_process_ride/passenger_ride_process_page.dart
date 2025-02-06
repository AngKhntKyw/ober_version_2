import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/elevated_buttons.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/passenger_ride_process_controller.dart';

class PassengerRideProcessPage extends StatefulWidget {
  const PassengerRideProcessPage({super.key});

  @override
  State<PassengerRideProcessPage> createState() =>
      _PassengerRideProcessPageState();
}

class _PassengerRideProcessPageState extends State<PassengerRideProcessPage> {
  @override
  Widget build(BuildContext context) {
    final passengerRideProcessController =
        Get.put(PassengerRideProcessController());

    return Scaffold(
      body: Obx(
        () {
          return passengerRideProcessController.currentLocation.value == null
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
                                myLocationEnabled: true,
                                trafficEnabled: false,
                                buildingsEnabled: false,
                                liteModeEnabled: false,
                                scrollGesturesEnabled: true,
                                zoomGesturesEnabled: true,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    passengerRideProcessController
                                        .currentLocation.value!.latitude!,
                                    passengerRideProcessController
                                        .currentLocation.value!.longitude!,
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
                                },
                                onCameraMove: (position) {
                                  passengerRideProcessController.onCameraMoved(
                                      position: position);
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Booking Status: ${passengerRideProcessController.currentRide.value!.status}"),
                              ElevatedButtons(
                                onPressed: () {},
                                buttonName: "Cancel booking",
                              ),
                            ],
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
