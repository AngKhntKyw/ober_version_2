import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_map_marker_animation/core/ripple_marker.dart';
import 'package:google_map_marker_animation/widgets/animarker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/driver/animated_marker/animated_marker_controller.dart';

class AnimatedMarkerPage extends StatefulWidget {
  const AnimatedMarkerPage({super.key});

  @override
  State<AnimatedMarkerPage> createState() => _AnimatedMarkerPageState();
}

class _AnimatedMarkerPageState extends State<AnimatedMarkerPage> {
  final animatedMarkerController = Get.put(AnimatedMarkerController());
  double heading = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return animatedMarkerController.currentLocation.value == null
            ? const LoadingIndicators()
            : Animarker(
                mapId: animatedMarkerController.mapController.future
                    .then((value) => value.mapId),
                curve: Curves.linear,
                angleThreshold: 1.5,
                runExpressAfter: 5,
                isActiveTrip: true,
                useRotation: true,
                shouldAnimateCamera: true,
                zoom: 18,
                markers: {
                  RippleMarker(
                    ripple: false,
                    markerId: const MarkerId("my location marker"),
                    position: LatLng(
                      animatedMarkerController.currentLocation.value!.latitude!,
                      animatedMarkerController
                          .currentLocation.value!.longitude!,
                    ),
                    icon: animatedMarkerController.myLocationIcon.value,
                    anchor: const Offset(0.5, 0.5),
                    // rotation: heading,
                  ),
                },
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      animatedMarkerController.currentLocation.value!.latitude!,
                      animatedMarkerController
                          .currentLocation.value!.longitude!,
                    ),
                    zoom: 10,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  onMapCreated: (controller) {
                    animatedMarkerController.mapController.complete(controller);
                  },
                ),
              );
        //
      }),
    );
  }
}
