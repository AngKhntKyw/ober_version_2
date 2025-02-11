import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_food_controller.dart';
import 'package:ober_version_2/pages/driver/find_passenger/widgets/car_icon_widget.dart';
import 'package:ober_version_2/pages/driver/find_passenger/widgets/draggabel_scroll_sheet_widget.dart';
import 'package:ober_version_2/pages/driver/find_passenger/widgets/food_markers.dart';

class FindFoodPage extends StatelessWidget {
  const FindFoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    final findFoodController = Get.put(FindFoodController());

    return Scaffold(
      body: Obx(
        () {
          return findFoodController.currentLocation.value == null
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
                                style: findFoodController.mapStyle,
                                compassEnabled: false,
                                zoomControlsEnabled: true,
                                myLocationEnabled: true,

                                trafficEnabled: false,
                                buildingsEnabled: false,
                                liteModeEnabled: false,
                                scrollGesturesEnabled: true,
                                zoomGesturesEnabled: true,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    findFoodController
                                        .currentLocation.value!.latitude,
                                    findFoodController
                                        .currentLocation.value!.longitude,
                                  ),
                                  zoom: 10,
                                ),

                                // on Map created
                                onMapCreated: (controller) async {
                                  onMapCreated(
                                      findFoodController: findFoodController,
                                      controller: controller);
                                },

                                // on Camera moved
                                onCameraMove: (position) {
                                  findFoodController.onCameraMoved(
                                    position: position,
                                  );
                                },

                                // markers
                                markers: FoodMarkers.createMarkers(
                                  findFoodController,
                                ),

                                // circles
                                circles: findFoodController.currentRide.value ==
                                        null
                                    ? {
                                        ...findFoodController
                                            .ridesWithin1km.value
                                            .map(
                                              (e) => Circle(
                                                circleId: CircleId(e.id),
                                                center: LatLng(
                                                    e.pick_up.latitude,
                                                    e.pick_up.longitude),
                                                radius: 1000,
                                                fillColor: const Color.fromARGB(
                                                    91, 33, 149, 243),
                                                strokeColor: Colors.blue,
                                                strokeWidth: 1,
                                              ),
                                            )
                                            .toSet(),
                                      }
                                    : {},

                                // polylines
                                polylines: {
                                  Polyline(
                                    polylineId:
                                        const PolylineId('current ride route'),
                                    points: findFoodController
                                        .polylineCoordinates.value,
                                    color: AppPallete.black,
                                    width: 4,
                                  ),
                                },
                              ),

                              // car icon
                              CardIconWidget(
                                findFoodController: findFoodController,
                              ),
                            ],
                          ),
                        ),
                        const Expanded(
                          flex: 2,
                          child: Text('sadf'),
                        ),
                      ],
                    ),

                    //
                    DraggabelScrollSheetWidget(
                      findFoodController: findFoodController,
                    ),
                  ],
                );
          //
        },
      ),
    );
  }
}

void onMapCreated({
  required FindFoodController findFoodController,
  required GoogleMapController controller,
}) async {
  findFoodController.mapController.complete(controller);

  await Future.delayed(const Duration(seconds: 2));

  findFoodController.updateUI(zoom: 16);

  await Future.delayed(const Duration(seconds: 2));

  await findFoodController.getCurrentLocationOnUpdate();
}
