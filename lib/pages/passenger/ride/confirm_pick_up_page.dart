import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:ober_version_2/core/models/address_model.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/passenger/ride/confrim_ride_page.dart';
import 'package:ober_version_2/pages/passenger/ride/ride_controller.dart';
import 'package:place_picker_google/place_picker_google.dart';

class ConfirmPickUpPage extends StatefulWidget {
  const ConfirmPickUpPage({super.key});

  @override
  State<ConfirmPickUpPage> createState() => _ConfirmPickUpPageState();
}

class _ConfirmPickUpPageState extends State<ConfirmPickUpPage> {
  final location = Location();
  final Completer<GoogleMapController> mapController = Completer();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: RideController(),
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

              return PlacePicker(
                apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
                onPlacePicked: (LocationResult result) {
                  rideController.pickUp = AddressModel(
                    name: result.formattedAddress!,
                    latitude: result.latLng!.latitude,
                    longitude: result.latLng!.longitude,
                    rotation: 0,
                  );

                  Get.to(() => const ConfrimRidePage());
                },
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
                          zoom: 18,
                          // bearing: 90,
                        ),
                      ),
                    );
                  });
                },
                initialLocation: const LatLng(0, 0),
                searchInputConfig: const SearchInputConfig(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  autofocus: false,
                  textDirection: TextDirection.ltr,
                ),
                searchInputDecorationConfig: const SearchInputDecorationConfig(
                  hintText: "Search for a building, street or ... ",
                ),
                enableNearbyPlaces: false,
                myLocationButtonEnabled: true,
                usePinPointingSearch: true,
                minMaxZoomPreference: const MinMaxZoomPreference(1, 20),
                myLocationEnabled: true,
                showSearchInput: true,
                autoCompleteOverlayElevation: 10,
                autocompletePlacesSearchRadius: 10,
                pinPointingDebounceDuration: 0,
                selectedActionButtonChild: const Text("Confirm pick up"),
              );
            },
          ),
        );
      },
    );
  }
}
