import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_food_controller.dart';
import 'dart:math' as math;

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
                                        .currentLocation.value!.longitude!,
                                  ),
                                  zoom: 10,
                                ),
                                onMapCreated: (controller) async {
                                  findFoodController.mapController
                                      .complete(controller);

                                  await Future.delayed(
                                      const Duration(seconds: 2));

                                  findFoodController.updateUI(zoom: 16);

                                  await Future.delayed(
                                      const Duration(seconds: 2));

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
                        const Expanded(
                          flex: 2,
                          child: Text('sadf'),
                        ),
                      ],
                    ),

                    //
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
                          child: BookingStateWidget(
                            scrollController: scrollController,
                            findFoodControllers: findFoodController,
                          ),
                        );
                      },
                    ),
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
  final FindFoodController findFoodControllers;
  const BookingStateWidget({
    super.key,
    required this.scrollController,
    required this.findFoodControllers,
  });

  @override
  State<BookingStateWidget> createState() => _BookingStateWidgetState();
}

class _BookingStateWidgetState extends State<BookingStateWidget> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height / 40),
          Text(
              'Total Bookings : ${widget.findFoodControllers.ridesWithin1km.value.length}'),
          SizedBox(height: size.height / 40),
          const Divider(),
          ListView.builder(
            controller: widget.scrollController,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.findFoodControllers.ridesWithin1km.value.length,
            itemBuilder: (context, index) {
              final ride =
                  widget.findFoodControllers.ridesWithin1km.value[index];
              return RideCard(
                ride: ride,
                findFoodControllers: widget.findFoodControllers,
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
  final FindFoodController findFoodControllers;

  const RideCard({
    super.key,
    required this.ride,
    required this.findFoodControllers,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppPallete.black,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppPallete.black,
                    backgroundImage: CachedNetworkImageProvider(
                        ride.passenger.profile_image),
                  ),
                ),
                SizedBox(width: size.width / 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ride.passenger.name),
                    Text(ride.passenger.email),
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
