import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_map_marker_animation/core/ripple_marker.dart';
import 'package:google_map_marker_animation/widgets/animarker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
    return Scaffold(
      body: Obx(() {
        return findPassengerController.currentLocation.value == null
            ? const LoadingIndicators()
            : SafeArea(
                child: Animarker(
                  mapId: findPassengerController.mapController.future
                      .then((value) => value.mapId),
                  curve: Curves.linearToEaseOut,
                  angleThreshold: 0,
                  duration: const Duration(milliseconds: 1000),
                  runExpressAfter: 20,
                  isActiveTrip: true,
                  useRotation: true,
                  shouldAnimateCamera: true,
                  onMarkerAnimationListener: (p0) {},
                  markers: {
                    RippleMarker(
                      ripple: false,
                      markerId: const MarkerId("my location marker"),
                      position: LatLng(
                        findPassengerController
                            .currentLocation.value!.latitude!,
                        findPassengerController
                            .currentLocation.value!.longitude!,
                      ),
                      icon: findPassengerController.myLocationMarker.value,
                      anchor: const Offset(0.5, 0.5),
                      // rotation: findPassengerController.heading.value,
                    ),
                  },
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        findPassengerController
                            .currentLocation.value!.latitude!,
                        findPassengerController
                            .currentLocation.value!.longitude!,
                      ),
                      zoom: 10,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    onMapCreated: (controller) {
                      // findPassengerController.mapController = controller;
                      findPassengerController.mapController
                          .complete(controller);
                    },
                    // onCameraMove: (position) => findPassengerController
                    //     .onCameraMoved(position: position),
                    markers: const {
                      // Marker(
                      //   markerId: const MarkerId("my location marker"),
                      //   position: LatLng(
                      //     findPassengerController
                      //         .currentLocation.value!.latitude!,
                      //     findPassengerController
                      //         .currentLocation.value!.longitude!,
                      //   ),
                      //   icon: findPassengerController.myLocationMarker.value,
                      //   anchor: const Offset(0.5, 0.5),
                      //   rotation: findPassengerController.heading.value,
                      // ),
                      // RippleMarker(
                      //   markerId: const MarkerId("my location marker"),
                      //   position: LatLng(
                      //     findPassengerController
                      //         .currentLocation.value!.latitude!,
                      //     findPassengerController
                      //         .currentLocation.value!.longitude!,
                      //   ),
                      //   icon: findPassengerController.myLocationMarker.value,
                      //   anchor: const Offset(0.5, 0.5),
                      //   rotation: findPassengerController.heading.value,
                      // ),
                    },
                  ),
                ),
              );
      }),
    );

    // final size = MediaQuery.sizeOf(context);
    // final findPassengerController = Get.put(FindPassengerController());

    // return Scaffold(
    //   body: Obx(
    //     () {
    //       return findPassengerController.currentLocation.value == null
    //           ? const LoadingIndicators()
    //           : Stack(
    //               children: [
    //                 GoogleMap(
    //                   rotateGesturesEnabled: true,
    //                   fortyFiveDegreeImageryEnabled: true,
    //                   compassEnabled: true,
    //                   buildingsEnabled: false,
    //                   initialCameraPosition: CameraPosition(
    //                     zoom: 12,
    //                     target: LatLng(
    //                       findPassengerController
    //                           .currentLocation.value!.latitude!,
    //                       findPassengerController
    //                           .currentLocation.value!.longitude!,
    //                     ),
    //                   ),
    //                   onMapCreated: (controller) {
    //                     findPassengerController.mapController
    //                         .complete(controller);
    //                   },
    //                   onCameraMove: (position) {
    //                     findPassengerController.onCameraMove(position);
    //                   },
    //                   markers: {
    //                     Marker(
    //                       markerId: const MarkerId('current location'),
    //                       position: LatLng(
    //                         findPassengerController
    //                             .currentLocation.value!.latitude!,
    //                         findPassengerController
    //                             .currentLocation.value!.longitude!,
    //                       ),
    //                       icon: findPassengerController.driverMarkerIcon,
    //                       rotation:
    //                           findPassengerController.markerRotation.value,
    //                       anchor: const Offset(0.5, 0.5),
    //                     ),

    //                     //
    //                     // if (findPassengerController.acceptedRide.value == null)
    //                     ...findPassengerController.ridesWithin1km.value
    //                         .map(
    //                           (e) => Marker(
    //                             markerId: MarkerId(e.id),
    //                             position: LatLng(
    //                                 e.pick_up.latitude, e.pick_up.longitude),
    //                             icon: findPassengerController
    //                                 .passengersMarkerIcon,
    //                           ),
    //                         )
    //                         .toSet(),

    //                     // if (findPassengerController.acceptedRide.value != null)
    //                     //   Marker(
    //                     //     markerId: MarkerId(
    //                     //         findPassengerController.acceptedRide.value!.id),
    //                     //     position: LatLng(
    //                     //       findPassengerController
    //                     //           .acceptedRide.value!.pick_up.latitude,
    //                     //       findPassengerController
    //                     //           .acceptedRide.value!.pick_up.longitude,
    //                     //     ),
    //                     //     icon: findPassengerController.passengersMarkerIcon,
    //                     //   ),
    //                   },
    //                   circles: {
    //                     // if (findPassengerController.acceptedRide.value == null)
    //                     ...findPassengerController.ridesWithin1km.value
    //                         .map(
    //                           (e) => Circle(
    //                             circleId: CircleId(e.id),
    //                             center: LatLng(
    //                                 e.pick_up.latitude, e.pick_up.longitude),
    //                             radius: 1000,
    //                             fillColor: Colors.blue.withOpacity(0.2),
    //                             strokeColor: Colors.blue,
    //                             strokeWidth: 1,
    //                           ),
    //                         )
    //                         .toSet(),
    //                   },
    //                   // polylines: {
    //                   //   if (findPassengerController.acceptedRide.value != null)
    //                   //     Polyline(
    //                   //       polylineId: PolylineId(
    //                   //           findPassengerController.acceptedRide.value!.id),
    //                   //       color: AppPallete.black,
    //                   //       points: findPassengerController.routeToPickUp.value,
    //                   //       width: 6,
    //                   //     ),
    //                   // },
    //                 ),
    //                 DraggableScrollableSheet(
    //                   initialChildSize: 0.4,
    //                   maxChildSize: 1,
    //                   minChildSize: 0.2,
    //                   snapAnimationDuration: const Duration(milliseconds: 500),
    //                   builder: (context, scrollController) {
    //                     return Container(
    //                       padding: const EdgeInsets.all(10),
    //                       decoration: BoxDecoration(
    //                         borderRadius: const BorderRadius.only(
    //                           topLeft: Radius.circular(20),
    //                           topRight: Radius.circular(20),
    //                         ),
    //                         color: AppPallete.white,
    //                         border: Border.all(color: AppPallete.black),
    //                       ),
    //                       child: ListView.builder(
    //                         controller: scrollController,
    //                         itemCount: findPassengerController
    //                             .ridesWithin1km.value.length,
    //                         itemBuilder: (context, index) {
    //                           final ride = findPassengerController
    //                               .ridesWithin1km.value[index];
    //                           return RideCard(
    //                             ride: ride,
    //                             size: size,
    //                             findPassengerController:
    //                                 findPassengerController,
    //                           );
    //                         },
    //                       ),
    //                     );
    //                   },
    //                 ),
    //               ],
    //             );
    //     },
    //   ),
    // );
  }
}

// class RideCard extends StatelessWidget {
//   final RideModel ride;
//   final Size size;
//   final FindPassengerController findPassengerController;

//   const RideCard({
//     super.key,
//     required this.ride,
//     required this.size,
//     required this.findPassengerController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text("${ride.fare} MMKs"),
//             Text(ride.distance),
//           ],
//         ),
//         Text(ride.duration),
//         SizedBox(height: size.height / 40),
//         const Text("Destination"),
//         Text(ride.destination.name),
//         SizedBox(height: size.height / 40),
//         const Text("Pick up"),
//         Text(ride.pick_up.name),
//         SizedBox(height: size.height / 40),
//         ElevatedButton(
//           onPressed: () {
//             findPassengerController.acceptRide(ride: ride);
//             Get.to(() => const ProcessRidePage());
//           },
//           child: const Text("Accept booking"),
//         ),
//         SizedBox(height: size.height / 40),
//         const Divider(),
//       ],
//     );
//   }
// }
