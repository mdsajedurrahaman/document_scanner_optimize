import 'package:flutter/material.dart';

class ColorButton extends StatelessWidget {
  final Color? color;
  final Function(Color) onTap;
  final bool isSelected;
  final Gradient? gradient;

  const ColorButton({
    super.key,
    this.color,
    required this.onTap,
    this.isSelected = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(color!);
      },
      child: Container(
        height: 30,
        width: 30,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 23),
        decoration: BoxDecoration(
          gradient: gradient,
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}