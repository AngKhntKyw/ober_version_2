import 'package:flutter/material.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_food_controller.dart';
import 'package:ober_version_2/pages/driver/find_passenger/widgets/booking_state_widget.dart';
import 'package:ober_version_2/pages/driver/find_passenger/widgets/current_ride_card.dart';

class DraggabelScrollSheetWidget extends StatelessWidget {
  final FindFoodController findFoodController;
  const DraggabelScrollSheetWidget({
    super.key,
    required this.findFoodController,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
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
    );
  }
}
