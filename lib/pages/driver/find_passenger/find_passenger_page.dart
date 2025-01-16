import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_passenger_controller.dart';

class FindPassengerPage extends StatefulWidget {
  const FindPassengerPage({super.key});

  @override
  State<FindPassengerPage> createState() => _FindPassengerPageState();
}

class _FindPassengerPageState extends State<FindPassengerPage> {
  final findPassengerController = Get.put(FindPassengerController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Obx(
        () {
          return findPassengerController.currentLocation.value == null
              ? const LoadingIndicators()
              : Stack(
                  children: [
                    GoogleMap(
                      tiltGesturesEnabled: true,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          findPassengerController
                              .currentLocation.value!.latitude!,
                          findPassengerController
                              .currentLocation.value!.longitude!,
                        ),
                        zoom: findPassengerController.zoomLevel.value,
                      ),
                      zoomControlsEnabled: false,
                      compassEnabled: true,
                      myLocationButtonEnabled: false,
                      myLocationEnabled: true,
                      onMapCreated: (controller) {
                        findPassengerController.mapController
                            .complete(controller);
                      },
                      onCameraMove: (position) => findPassengerController
                          .onCameraMoved(position: position),
                      markers: {
                        Marker(
                          markerId: const MarkerId("my location marker"),
                          position: LatLng(
                            findPassengerController
                                .currentLocation.value!.latitude!,
                            findPassengerController
                                .currentLocation.value!.longitude!,
                          ),
                          icon: findPassengerController.myLocationIcon.value,
                          anchor: const Offset(0.5, 0.5),
                          rotation: findPassengerController.heading.value,
                        ),

                        //
                        // booking
                        if (findPassengerController.acceptedRide.value == null)
                          ...findPassengerController.ridesWithin1km.value
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

                        //
                        // going to pick up
                        if (findPassengerController.acceptedRide.value !=
                                null &&
                            findPassengerController
                                    .acceptedRide.value!.status ==
                                "gointToPickUp")
                          Marker(
                            markerId: MarkerId(
                                findPassengerController.acceptedRide.value!.id),
                            position: LatLng(
                              findPassengerController
                                  .acceptedRide.value!.pick_up.latitude,
                              findPassengerController
                                  .acceptedRide.value!.pick_up.longitude,
                            ),
                            icon: BitmapDescriptor.defaultMarker,
                          ),

                        //
                        // going to destination
                        if (findPassengerController.acceptedRide.value !=
                                null &&
                            findPassengerController
                                    .acceptedRide.value!.status ==
                                "goingToDestination")
                          Marker(
                            markerId: MarkerId(
                                findPassengerController.acceptedRide.value!.id),
                            position: LatLng(
                              findPassengerController
                                  .acceptedRide.value!.destination.latitude,
                              findPassengerController
                                  .acceptedRide.value!.destination.longitude,
                            ),
                            icon: BitmapDescriptor.defaultMarker,
                          ),
                      },
                      circles: {
                        //
                        // booking
                        if (findPassengerController.acceptedRide.value == null)
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

                        //
                        // going to pick up
                        if (findPassengerController.acceptedRide.value !=
                                null &&
                            findPassengerController
                                    .acceptedRide.value!.status ==
                                "goingToPickUp")
                          Circle(
                            circleId: CircleId(
                                findPassengerController.acceptedRide.value!.id),
                            center: LatLng(
                                findPassengerController
                                    .acceptedRide.value!.pick_up.latitude,
                                findPassengerController
                                    .acceptedRide.value!.pick_up.longitude),
                            radius: 1000,
                            fillColor: Colors.blue.withOpacity(0.2),
                            strokeColor: Colors.blue,
                            strokeWidth: 1,
                          ),

                        //
                        // goint to destination
                        if (findPassengerController.acceptedRide.value !=
                                null &&
                            findPassengerController
                                    .acceptedRide.value!.status ==
                                "goingToDestination")
                          Circle(
                            circleId: CircleId(
                                findPassengerController.acceptedRide.value!.id),
                            center: LatLng(
                                findPassengerController
                                    .acceptedRide.value!.destination.latitude,
                                findPassengerController
                                    .acceptedRide.value!.destination.longitude),
                            radius: 1000,
                            fillColor: Colors.blue.withOpacity(0.2),
                            strokeColor: Colors.blue,
                            strokeWidth: 1,
                          ),
                      },
                      polylines: {
                        //
                        // going to pick up
                        if (findPassengerController.acceptedRide.value !=
                                null &&
                            findPassengerController
                                    .acceptedRide.value!.status ==
                                "goingToPickUp")
                          Polyline(
                            polylineId: const PolylineId('going to pick up'),
                            points: findPassengerController
                                .goingToPickUpPolylines.value,
                            color: AppPallete.black,
                            width: 6,
                          ),

                        //
                        // going to destination
                        if (findPassengerController.acceptedRide.value !=
                                null &&
                            findPassengerController
                                    .acceptedRide.value!.status ==
                                "goingToDestination")
                          Polyline(
                            polylineId:
                                const PolylineId('going to destination'),
                            points: findPassengerController
                                .goingToDestinationUpPolylines.value,
                            color: AppPallete.black,
                            width: 6,
                          ),
                      },
                    ),

                    // Status
                    findPassengerController.acceptedRide.value != null
                        ? Positioned(
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
                                findPassengerController
                                    .acceptedRide.value!.status,
                              ),
                            ),
                          )
                        : const SizedBox(),

                    //

                    findPassengerController.acceptedRide.value == null &&
                            findPassengerController.ridesWithin1km.value.isEmpty
                        ? const SizedBox()
                        : DraggableScrollableSheet(
                            initialChildSize: 0.2,
                            maxChildSize: 1,
                            minChildSize: 0.2,
                            snapAnimationDuration:
                                const Duration(milliseconds: 500),
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
                                child:
                                    // booking
                                    findPassengerController
                                                .acceptedRide.value ==
                                            null
                                        ? BookingStateWidget(
                                            scrollController: scrollController,
                                            size: size,
                                            findPassengerController:
                                                findPassengerController,
                                          )

                                        // going to pick up
                                        : findPassengerController
                                                        .acceptedRide.value !=
                                                    null &&
                                                findPassengerController
                                                        .acceptedRide
                                                        .value!
                                                        .status ==
                                                    "goingToPickUp"
                                            ? GoingToPickUpWidget(
                                                scrollController:
                                                    scrollController,
                                                size: size,
                                                findPassengerController:
                                                    findPassengerController,
                                              )

                                            // going to destination
                                            : GoingToDestinationWidget(
                                                scrollController:
                                                    scrollController,
                                                size: size,
                                                findPassengerController:
                                                    findPassengerController,
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

class BookingStateWidget extends StatefulWidget {
  final ScrollController scrollController;
  final Size size;
  final FindPassengerController findPassengerController;
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

class GoingToPickUpWidget extends StatefulWidget {
  final ScrollController scrollController;
  final Size size;
  final FindPassengerController findPassengerController;
  const GoingToPickUpWidget({
    super.key,
    required this.scrollController,
    required this.size,
    required this.findPassengerController,
  });

  @override
  State<GoingToPickUpWidget> createState() => _GoingToPickUpWidgetState();
}

class _GoingToPickUpWidgetState extends State<GoingToPickUpWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  "${widget.findPassengerController.acceptedRide.value!.fare} MMKs"),
              Text(widget.findPassengerController.acceptedRide.value!.distance),
            ],
          ),
          Text(widget.findPassengerController.acceptedRide.value!.duration),
          SizedBox(height: widget.size.height / 40),
          const Text("Destination"),
          Text(widget
              .findPassengerController.acceptedRide.value!.destination.name),
          SizedBox(height: widget.size.height / 40),
          const Text("Pick up"),
          Text(widget.findPassengerController.acceptedRide.value!.pick_up.name),
          SizedBox(height: widget.size.height / 40),
          Center(
            child: ActionSlider.standard(
              sliderBehavior: SliderBehavior.move,
              rolling: false,
              loadingIcon: const LoadingIndicators(),
              loadingAnimationCurve: Curves.easeIn,
              backgroundColor: AppPallete.black,
              toggleColor: AppPallete.white,
              iconAlignment: Alignment.center,
              child: const Text(
                'Slide to pickup  passenger',
                style: TextStyle(color: AppPallete.white),
              ),
              action: (controller) async {
                controller.loading();
                await Future.delayed(const Duration(seconds: 3));
                controller.success();
                widget.findPassengerController.goToDestination();
              },
            ),
          ),
          SizedBox(height: widget.size.height / 40),
          const Divider(),
        ],
      ),
    );
  }
}

class GoingToDestinationWidget extends StatefulWidget {
  final ScrollController scrollController;
  final Size size;
  final FindPassengerController findPassengerController;
  const GoingToDestinationWidget({
    super.key,
    required this.scrollController,
    required this.size,
    required this.findPassengerController,
  });

  @override
  State<GoingToDestinationWidget> createState() =>
      _GoingToDestinationWidgetState();
}

class _GoingToDestinationWidgetState extends State<GoingToDestinationWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  "${widget.findPassengerController.acceptedRide.value!.fare} MMKs"),
              Text(widget.findPassengerController.acceptedRide.value!.distance),
            ],
          ),
          Text(widget.findPassengerController.acceptedRide.value!.duration),
          SizedBox(height: widget.size.height / 40),
          const Text("Destination"),
          Text(widget
              .findPassengerController.acceptedRide.value!.destination.name),
          SizedBox(height: widget.size.height / 40),
          const Text("Pick up"),
          Text(widget.findPassengerController.acceptedRide.value!.pick_up.name),
          SizedBox(height: widget.size.height / 40),
          Center(
            child: ActionSlider.standard(
              sliderBehavior: SliderBehavior.move,
              rolling: false,
              loadingIcon: const LoadingIndicators(),
              loadingAnimationCurve: Curves.easeIn,
              backgroundColor: AppPallete.black,
              toggleColor: AppPallete.white,
              iconAlignment: Alignment.center,
              child: const Text(
                'Slide to drop off passenger',
                style: TextStyle(color: AppPallete.white),
              ),
              action: (controller) async {
                controller.loading();
                await Future.delayed(const Duration(seconds: 3));
                controller.success();
                widget.findPassengerController.dropOffPassenger();
              },
            ),
          ),
          SizedBox(height: widget.size.height / 40),
          const Divider(),
        ],
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
          },
          child: const Text("Accept booking"),
        ),
        SizedBox(height: size.height / 40),
        const Divider(),
      ],
    );
  }
}
