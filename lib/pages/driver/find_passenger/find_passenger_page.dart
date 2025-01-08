import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_passenger_controller.dart';

class FindPassengerPage extends StatefulWidget {
  const FindPassengerPage({super.key});

  @override
  State<FindPassengerPage> createState() => _FindPassengerPageState();
}

class _FindPassengerPageState extends State<FindPassengerPage> {
  final location = Location();
  final Completer<GoogleMapController> mapController = Completer();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: FindPassengerController(),
      builder: (findPassengerController) {
        return Scaffold(
          body: StreamBuilder(
            stream: location.onLocationChanged,
            builder: (context, locationSnapshot) {
              if (locationSnapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicators();
              }
              if (locationSnapshot.hasError) {
                return const Center(
                  child: Text("Location error occurred"),
                );
              }

              findPassengerController.currentLocation = locationSnapshot.data!;

              mapController.future.then((mapController) {
                mapController.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(
                      findPassengerController.currentLocation!.latitude!,
                      findPassengerController.currentLocation!.longitude!,
                    ),
                  ),
                );
              });
              return GoogleMap(
                initialCameraPosition:
                    const CameraPosition(target: LatLng(0, 0)),
                rotateGesturesEnabled: true,
                compassEnabled: true,
                buildingsEnabled: false,
                onMapCreated: (controller) {
                  mapController.complete(controller);
                  mapController.future.then((mapController) {
                    mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                            findPassengerController.currentLocation!.latitude!,
                            findPassengerController.currentLocation!.longitude!,
                          ),
                          zoom: 18,
                        ),
                      ),
                    );
                  });
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('current location'),
                    position: LatLng(
                      findPassengerController.currentLocation!.latitude!,
                      findPassengerController.currentLocation!.longitude!,
                    ),
                    icon: findPassengerController.markerIcon,
                    rotation: findPassengerController.markerRotation,
                    anchor: const Offset(0.5, 0.5),
                  ),
                },
              );
            },
          ),
        );
      },
    );
  }
}
