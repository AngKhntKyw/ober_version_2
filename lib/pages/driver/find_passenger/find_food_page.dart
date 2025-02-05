import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_food_controller.dart';
import 'dart:math' as math;

class FindFoodPage extends StatelessWidget {
  const FindFoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    final findFoodController = Get.put(FindFoodController());
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Obx(
        () {
          return findFoodController.currentLocation.value == null
              ? const LoadingIndicators()
              : Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          GoogleMap(
                            style: findFoodController.mapStyle.value,
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
                                  findFoodController
                                      .currentLocation.value!.latitude!,
                                  findFoodController
                                      .currentLocation.value!.longitude!),
                              zoom: 10,
                              bearing: 10,
                            ),
                            onMapCreated: (controller) async {
                              findFoodController.mapController
                                  .complete(controller);

                              await Future.delayed(const Duration(seconds: 2));
                              controller.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: LatLng(
                                      findFoodController
                                          .currentLocation.value!.latitude!,
                                      findFoodController
                                          .currentLocation.value!.longitude!,
                                    ),
                                    zoom: 16,
                                    bearing: findFoodController
                                        .currentLocation.value!.heading!,
                                  ),
                                ),
                              );
                              await Future.delayed(const Duration(seconds: 2));
                              await findFoodController
                                  .getCurrentLocationOnUpdate();
                            },
                            onCameraMove: (position) {
                              findFoodController.onCameraMoved(
                                  position: position);
                            },

                            // markers
                            markers: {
                              ...findFoodController.ridesWithin1km.value
                                  .map(
                                    (e) => Marker(
                                      markerId: MarkerId(e.id),
                                      position: LatLng(
                                        e.pick_up.latitude,
                                        e.pick_up.longitude,
                                      ),
                                      icon: BitmapDescriptor.defaultMarker,
                                    ),
                                  )
                                  .toSet(),
                            },

                            // circles
                            circles: {
                              ...findFoodController.ridesWithin1km.value
                                  .map(
                                    (e) => Circle(
                                      circleId: CircleId(e.id),
                                      center: LatLng(e.pick_up.latitude,
                                          e.pick_up.longitude),
                                      radius: 1000,
                                      fillColor: const Color.fromARGB(
                                          91, 33, 149, 243),
                                      strokeColor: Colors.blue,
                                      strokeWidth: 1,
                                    ),
                                  )
                                  .toSet(),
                            },
                          ),
                          if (findFoodController.zooming.value == false)
                            AnimatedRotation(
                              turns: findFoodController.heading.value /
                                  (2 * math.pi),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.linear,
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/images/car.png',
                                height: 40,
                                width: 40,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Expanded(
                    //   flex: 3,
                    //   child: BookingStateWidget(
                    //       scrollController: scrollController,
                    //       size: size,
                    //       findPassengerController: findFoodController),
                    // ),
                  ],
                );
          //
        },
      ),
    );
  }
}

class BookingStateWidget extends StatefulWidget {
  final ScrollController scrollController;
  final Size size;
  final FindFoodController findPassengerController;
  const BookingStateWidget({
    super.key,
    required this.scrollController,
    required this.size,
    required this.findPassengerController,
  });

  @override
  State<BookingStateWidget> createState() => _BookingStateWidgetState();
}

class _BookingStateWidgetState extends State<BookingStateWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: widget.size.height / 40),
          Text(
              'Total Bookings : ${widget.findPassengerController.ridesWithin1km.value.length}'),
          SizedBox(height: widget.size.height / 40),
          const Divider(),
          ListView.builder(
            controller: widget.scrollController,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                widget.findPassengerController.ridesWithin1km.value.length,
            itemBuilder: (context, index) {
              final ride =
                  widget.findPassengerController.ridesWithin1km.value[index];
              return RideCard(
                ride: ride,
                size: widget.size,
                findPassengerController: widget.findPassengerController,
              );
            },
          ),
        ],
      ),
    );
  }
}

class RideCard extends StatelessWidget {
  final RideModel ride;
  final Size size;
  final FindFoodController findPassengerController;

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
          onPressed: () {},
          child: const Text("Accept booking"),
        ),
        SizedBox(height: size.height / 40),
        const Divider(),
      ],
    );
  }
}
