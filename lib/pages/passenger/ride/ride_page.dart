import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ober_version_2/core/models/ride_model.dart';
import 'package:ober_version_2/core/widgets/loading_indicators.dart';
import 'package:ober_version_2/pages/passenger/ride/ride_controller.dart';

class RidePage extends StatefulWidget {
  const RidePage({super.key});

  @override
  State<RidePage> createState() => _RidePageState();
}

class _RidePageState extends State<RidePage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: RideController(),
      builder: (rideController) {
        return Scaffold(
          body: StreamBuilder(
            stream: rideController.getRideDetail(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingIndicators();
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text("An error occurred"),
                );
              }
              Map<String, dynamic> snapshotData = snapshot.data!.data()!;
              RideModel ride = RideModel.fromJson(snapshotData);
              return Center(
                child: Text(ride.status),
              );
            },
          ),
        );
      },
    );
  }
}
