import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/passenger_ride_process_controller.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/widgets/draggable_scroll_sheet.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/widgets/indicator_icons_widget.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/widgets/map_markers_widget.dart';

class PassengerRideProcessPage extends StatelessWidget {
  const PassengerRideProcessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final passengerRideProcessController =
        Get.put(PassengerRideProcessController());

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

                                // on Map created
                                onMapCreated: (controller) async {
                                  onMapCreated(
                                    passengerRideProcessController:
                                        passengerRideProcessController,
                                    controller: controller,
                                  );
                                },

                                // on Camera moved
                                onCameraMove: (position) {
                                  passengerRideProcessController.onCameraMoved(
                                      position: position);
                                },

                                // markers
                                markers: MapMarkers.createMarkers(
                                  passengerRideProcessController,
                                ),

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

                              // Indicator Icons
                              IndicatorIconsWidget(
                                passengerRideProcessController:
                                    passengerRideProcessController,
                              ),

                              //
                            ],
                          ),
                        ),
                        const Expanded(
                          flex: 2,
                          child: Center(
                            child: Text("OK"),
                          ),
                        ),
                      ],
                    ),

                    // scroll sheet
                    DraggableScrollSheet(
                      passengerRideProcessController:
                          passengerRideProcessController,
                    ),
                  ],
                );
        },
      ),
    );
  }
}

void onMapCreated({
  required PassengerRideProcessController passengerRideProcessController,
  required GoogleMapController controller,
}) async {
  passengerRideProcessController.mapController.complete(controller);

  await Future.delayed(const Duration(seconds: 2));

  await passengerRideProcessController.updateUI(
      location: LatLng(
          passengerRideProcessController.currentLocation.value!.latitude,
          passengerRideProcessController.currentLocation.value!.longitude),
      zoom: 16);

  await Future.delayed(const Duration(seconds: 2));

  await passengerRideProcessController.getCurrentLocationOnUpdate();

  await passengerRideProcessController.getDestinationPolyPoints(
    origin: PointLatLng(
        passengerRideProcessController.currentRide.value!.pick_up.latitude,
        passengerRideProcessController.currentRide.value!.pick_up.longitude),
    destination: PointLatLng(
        passengerRideProcessController.currentRide.value!.destination.latitude,
        passengerRideProcessController
            .currentRide.value!.destination.longitude),
  );
}
