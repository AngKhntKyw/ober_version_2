import 'package:action_slider/action_slider.dart';
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
                                markers: findFoodController.currentRide.value ==
                                        null
                                    ? {
                                        ...findFoodController
                                            .ridesWithin1km.value
                                            .map(
                                              (e) => Marker(
                                                markerId: MarkerId(e.id),
                                                position: LatLng(
                                                  e.pick_up.latitude,
                                                  e.pick_up.longitude,
                                                ),
                                                icon: BitmapDescriptor
                                                    .defaultMarker,
                                              ),
                                            )
                                            .toSet(),
                                      }
                                    : {
                                        if (findFoodController
                                                .currentRide.value!.status ==
                                            "goingToPickUp")
                                          Marker(
                                            markerId: const MarkerId('pick up'),
                                            position: LatLng(
                                                findFoodController.currentRide
                                                    .value!.pick_up.latitude,
                                                findFoodController.currentRide
                                                    .value!.pick_up.longitude),
                                            icon:
                                                BitmapDescriptor.defaultMarker,
                                          ),
                                        if (findFoodController
                                                .currentRide.value!.status ==
                                            "goingToDestination")
                                          Marker(
                                            markerId:
                                                const MarkerId('destination'),
                                            position: LatLng(
                                                findFoodController
                                                    .currentRide
                                                    .value!
                                                    .destination
                                                    .latitude,
                                                findFoodController
                                                    .currentRide
                                                    .value!
                                                    .destination
                                                    .longitude),
                                            icon:
                                                BitmapDescriptor.defaultMarker,
                                          ),
                                      },

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
                              AnimatedRotation(
                                turns: Tween<double>(
                                  begin: 0,
                                  end: findFoodController.heading.value /
                                      (2 * math.pi),
                                ).evaluate(const AlwaysStoppedAnimation(1.0)),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.linear,
                                alignment: Alignment.center,
                                child: Opacity(
                                  opacity: 1,
                                  child: Image.asset(
                                    'assets/images/car.png',
                                    height: 40,
                                    width: 40,
                                    filterQuality: FilterQuality.high,
                                  ),
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
                          child: findFoodController.currentRide.value == null

                              // no active ride
                              ? BookingStateWidget(
                                  scrollController: scrollController,
                                  findFoodController: findFoodController,
                                )

                              // current ride
                              : CurrentRideCard(
                                  ride: findFoodController.currentRide.value!,
                                  findFoodController: findFoodController,
                                  scrollController: scrollController,
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
  final FindFoodController findFoodController;
  const BookingStateWidget({
    super.key,
    required this.scrollController,
    required this.findFoodController,
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
              'Total Bookings : ${widget.findFoodController.ridesWithin1km.value.length}'),
          SizedBox(height: size.height / 40),
          const Divider(),
          ListView.builder(
            controller: widget.scrollController,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.findFoodController.ridesWithin1km.value.length,
            itemBuilder: (context, index) {
              final ride =
                  widget.findFoodController.ridesWithin1km.value[index];
              return RideCard(
                ride: ride,
                findFoodController: widget.findFoodController,
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
  final FindFoodController findFoodController;

  const RideCard({
    super.key,
    required this.ride,
    required this.findFoodController,
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
          onPressed: () {
            findFoodController.acceptBooking(ride: ride);
          },
          child: const Text("Accept booking"),
        ),
        SizedBox(height: size.height / 40),
        const Divider(),
      ],
    );
  }
}

class CurrentRideCard extends StatelessWidget {
  final RideModel ride;
  final FindFoodController findFoodController;
  final ScrollController scrollController;

  const CurrentRideCard({
    super.key,
    required this.ride,
    required this.findFoodController,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
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
          Center(
            child: ActionSlider.standard(
              sliderBehavior: SliderBehavior.move,
              rolling: false,
              loadingIcon: const LoadingIndicators(),
              loadingAnimationCurve: Curves.easeIn,
              backgroundColor: AppPallete.black,
              toggleColor: AppPallete.white,
              iconAlignment: Alignment.center,
              child: Text(
                findFoodController.currentRide.value!.status,
                //  == "goingToPickUp"
                //     ? 'Slide to pick up passenger'
                //     : 'Slide to drop off passenger',
                style: const TextStyle(color: AppPallete.white),
              ),
              action: (controller) async {
                controller.loading();
                await Future.delayed(const Duration(seconds: 3));
                controller.success();
                findFoodController.currentRide.value!.status == "goingToPickUp"
                    ? findFoodController.pickUpPassenger()
                    : findFoodController.dropOffPassenger();
                controller.reset();
              },
            ),
          ),
          SizedBox(height: size.height / 40),
          const Divider(),
        ],
      ),
    );
  }
}
