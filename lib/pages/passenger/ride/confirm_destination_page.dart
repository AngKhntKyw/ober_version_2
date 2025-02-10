import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
import 'package:ober_version_2/core/models/address_model.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/passenger/ride/confirm_pick_up_page.dart';
import 'package:ober_version_2/pages/passenger/ride/ride_controller.dart';
import 'package:place_picker_google/place_picker_google.dart';

class ConfirmDestinationPage extends StatelessWidget {
  const ConfirmDestinationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Completer<GoogleMapController> mapController = Completer();
    final rideController = Get.put(RideController());

    //
    return Scaffold(
      body: StreamBuilder<Position>(
        stream: Geolocator.getPositionStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicators();
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          final currentLocation = snapshot.data;

          return PlacePicker(
            apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
            onPlacePicked: (LocationResult result) {
              rideController.destination.value = AddressModel(
                name: result.formattedAddress!,
                latitude: result.latLng!.latitude,
                longitude: result.latLng!.longitude,
                rotation: 0,
                speed: 0,
              );
              log("Des: ${rideController.destination.value}");
              Get.to(() => const ConfirmPickUpPage());
            },
            onMapCreated: (controller) async {
              mapController.complete(controller);
              await Future.delayed(const Duration(seconds: 2));
              mapController.future.then((mapController) {
                mapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(
                        currentLocation.latitude,
                        currentLocation.longitude,
                      ),
                      zoom: 18,
                      bearing: currentLocation.heading,
                    ),
                  ),
                );
              });
            },
            initialLocation: LatLng(
              currentLocation!.latitude,
              currentLocation.longitude,
            ),
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
            minMaxZoomPreference: const MinMaxZoomPreference(1, 18),
            myLocationEnabled: true,
            showSearchInput: true,
            autoCompleteOverlayElevation: 10,
            autocompletePlacesSearchRadius: 10,
            pinPointingDebounceDuration: 0,
            selectedActionButtonChild: const Text("Confirm destination"),
          );
        },
      ),
    );
  }
}
