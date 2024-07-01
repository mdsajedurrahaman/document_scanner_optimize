import 'package:flutter/material.dart';
import 'cutout_screen.dart';


class CustomCutoutShapeBorder extends ShapeBorder {
  final CutoutScreenArea cutoutScreenArea;

  const CustomCutoutShapeBorder(this.cutoutScreenArea);

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path.combine(
      PathOperation.difference,
      Path()..addRect(rect),
      cutoutScreenArea.getOuterPath(rect, textDirection: textDirection),
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    cutoutScreenArea.paint(canvas, rect, textDirection: textDirection);
  }

  @override
  ShapeBorder scale(double t) {
    return CustomCutoutShapeBorder(
      CutoutScreenArea(
        borderColor: cutoutScreenArea.borderColor,
        borderWidth: cutoutScreenArea.borderWidth,
        overlayColor: cutoutScreenArea.overlayColor,
        borderRadius: cutoutScreenArea.borderRadius,
        borderLength: cutoutScreenArea.borderLength,
        cutOutWidth: cutoutScreenArea.cutOutWidth * t,
        cutOutHeight: cutoutScreenArea.cutOutHeight * t,
      ),
    );
  }
}