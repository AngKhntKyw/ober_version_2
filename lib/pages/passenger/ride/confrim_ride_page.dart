import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/passenger/ride/ride_controller.dart';

class ConfrimRidePage extends StatefulWidget {
  const ConfrimRidePage({super.key});

  @override
  State<ConfrimRidePage> createState() => _ConfrimRidePageState();
}

class _ConfrimRidePageState extends State<ConfrimRidePage> {
  final location = Location();
  final Completer<GoogleMapController> mapController = Completer();
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: RideController()..getDestinationPolyPoints(),
      builder: (rideController) {
        return Scaffold(
            body: StreamBuilder(
          stream: location.onLocationChanged,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicators();
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text("An error occurred"),
              );
            }

            final currentLocation = snapshot.data!;
            return GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 0),
              ),
              onMapCreated: (controller) {
                mapController.complete(controller);
                mapController.future.then((mapController) {
                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          currentLocation.latitude!,
                          currentLocation.longitude!,
                        ),
                        zoom: 15,
                      ),
                    ),
                  );
                });
              },
              markers: {
                Marker(
                  icon: BitmapDescriptor.defaultMarker,
                  markerId: const MarkerId('pick up'),
                  position: LatLng(
                    rideController.pickUp!.latitude,
                    rideController.pickUp!.longitude,
                  ),
                ),
                Marker(
                  icon: BitmapDescriptor.defaultMarker,
                  markerId: const MarkerId('destination'),
                  position: LatLng(
                    rideController.destination!.latitude,
                    rideController.destination!.longitude,
                  ),
                ),
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: rideController.polylineCoordinates,
                  color: AppPallete.black,
                ),
              },
            );
          },
        ));
      },
    );
  }
}
