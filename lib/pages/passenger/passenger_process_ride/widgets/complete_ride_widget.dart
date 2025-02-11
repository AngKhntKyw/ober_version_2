import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/core/widgets/elevated_buttons.dart';
import 'package:ober_version_2/pages/passenger/passenger_nav_bar_page.dart';
import 'package:ober_version_2/pages/passenger/passenger_process_ride/passenger_ride_process_controller.dart';

class CompleteRideWidget extends StatelessWidget {
  final PassengerRideProcessController passengerRideProcessController;
  final Size size;
  const CompleteRideWidget({
    super.key,
    required this.passengerRideProcessController,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Ride Complete"),
          SizedBox(height: size.height / 40),
          const Text("Please give us Five Stars"),
          SizedBox(height: size.height / 40),
          RatingBar.builder(
            initialRating: 3,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) =>
                const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (rating) {},
          ),
          SizedBox(height: size.height / 40),
          ElevatedButtons(
            onPressed: () async {
              await passengerRideProcessController.cancelBooking();
              Get.offAll(const PassengerNavBarPage());
            },
            buttonName: "Complete",
          ),
          SizedBox(height: size.height / 40),
        ],
      ),
    );
  }
}
