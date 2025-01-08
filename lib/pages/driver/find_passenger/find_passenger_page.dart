import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_passenger_controller.dart';

class FindPassengerPage extends StatefulWidget {
  const FindPassengerPage({super.key});

  @override
  State<FindPassengerPage> createState() => _FindPassengerPageState();
}

class _FindPassengerPageState extends State<FindPassengerPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: FindPassengerController(),
      builder: (findPassengerController) {
        return Scaffold(
          body: findPassengerController.currentLocation == null
              ? const LoadingIndicators()
              : GoogleMap(
                  rotateGesturesEnabled: true,
                  fortyFiveDegreeImageryEnabled: true,
                  compassEnabled: true,
                  buildingsEnabled: false,
                  initialCameraPosition: CameraPosition(
                    zoom: 12,
                    target: LatLng(
                      findPassengerController.currentLocation!.latitude!,
                      findPassengerController.currentLocation!.longitude!,
                    ),
                  ),
                  onMapCreated: (controller) {
                    findPassengerController.mapController.complete(controller);
                  },
                  onCameraMove: (position) {
                    findPassengerController.onCameraMove(position);
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
                ),
        );
      },
    );
  }
}
