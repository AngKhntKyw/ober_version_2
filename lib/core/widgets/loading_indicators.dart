import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';

class LoadingIndicators extends StatelessWidget {
  const LoadingIndicators({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.dotsTriangle(
        color: AppPallete.black,
        size: 40,
      ),
    );
  }
}
