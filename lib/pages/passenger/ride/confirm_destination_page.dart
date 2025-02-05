import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
      body: Obx(
        () {
          return rideController.currentLocation.value == null
              ? const LoadingIndicators()
              : PlacePicker(
                  apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
                  onPlacePicked: (LocationResult result) {
                    rideController.destination.value = AddressModel(
                      name: result.formattedAddress!,
                      latitude: result.latLng!.latitude,
                      longitude: result.latLng!.longitude,
                      rotation: 0,
                      speed: 0,
                    );
                    Get.to(() => const ConfirmPickUpPage());
                  },
                  onMapCreated: (controller) {
                    mapController.complete(controller);
                    mapController.future.then((mapController) {
                      mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(
                              rideController.currentLocation.value!.latitude!,
                              rideController.currentLocation.value!.longitude!,
                            ),
                            zoom: 18,
                            bearing:
                                rideController.currentLocation.value!.heading!,
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
                  searchInputDecorationConfig:
                      const SearchInputDecorationConfig(
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
                  selectedActionButtonChild: const Text("Confirm destination"),
                );
        },
      ),
    );
  }
}
