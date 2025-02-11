import 'package:flutter/material.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/passenger_ride_process_controller.dart';

class IndicatorIconsWidget extends StatelessWidget {
  final PassengerRideProcessController passengerRideProcessController;
  const IndicatorIconsWidget({
    super.key,
    required this.passengerRideProcessController,
  });

  @override
  Widget build(BuildContext context) {
    // Check if currentRide is not null
    if (passengerRideProcessController.currentRide.value != null) {
      final currentRide = passengerRideProcessController.currentRide.value!;

      // If the status is not "goingToDestination"
      if (currentRide.status != "goingToDestination") {
        return AnimatedRotation(
          turns: passengerRideProcessController.compassHeading.value,
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/navigation.png',
            height: 30,
            width: 30,
            filterQuality: FilterQuality.high,
          ),
        );
      }

      // If the status is "goingToDestination"
      if (currentRide.status == "goingToDestination") {
        return AnimatedRotation(
          turns: passengerRideProcessController.driverRotation.value,
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/car.png',
            height: 40,
            width: 40,
            filterQuality: FilterQuality.high,
          ),
        );
      }
    }

    // Return an empty container if no ride is available
    return Container();
  }
}
