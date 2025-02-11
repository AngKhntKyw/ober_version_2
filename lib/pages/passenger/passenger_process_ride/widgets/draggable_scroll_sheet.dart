import 'package:flutter/material.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/passenger_ride_process_controller.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/widgets/complete_ride_widget.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/widgets/current_ride_widget.dart';

class DraggableScrollSheet extends StatelessWidget {
  final PassengerRideProcessController passengerRideProcessController;
  const DraggableScrollSheet({
    super.key,
    required this.passengerRideProcessController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    //
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
          child: SingleChildScrollView(
            controller: scrollController,
            child: passengerRideProcessController.currentRide.value!.status !=
                    "completeRide"
                ? CurrentRideWidget(
                    passengerRideProcessController:
                        passengerRideProcessController,
                    size: size,
                  )
                //
                : CompleteRideWidget(
                    passengerRideProcessController:
                        passengerRideProcessController,
                    size: size,
                  ),
          ),
        );
      },
    );
  }
}
