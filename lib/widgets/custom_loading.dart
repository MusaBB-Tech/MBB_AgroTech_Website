import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../utils/constants/colors.dart';

class CustomLoadingWidget extends StatelessWidget {
  final Color color;
  final double size;

  const CustomLoadingWidget({
    super.key,
    this.color = TColors.primary, // Default color
    this.size = 50.0, // Default size
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.discreteCircle(color: color, size: size),
    );
  }
}
