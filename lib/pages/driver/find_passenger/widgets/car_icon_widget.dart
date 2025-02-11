import 'package:flutter/material.dart';
import 'package:ober_version_2/pages/driver/find_passenger/find_food_controller.dart';
import 'dart:math' as math;

class CardIconWidget extends StatelessWidget {
  final FindFoodController findFoodController;
  const CardIconWidget({super.key, required this.findFoodController});

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: Tween<double>(
        begin: 0,
        end: findFoodController.heading.value / (2 * math.pi),
      ).evaluate(const AlwaysStoppedAnimation(1.0)),
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
      alignment: Alignment.center,
      child: Opacity(
        opacity: 1,
        child: Image.asset(
          'assets/images/car.png',
          height: 40,
          width: 40,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
