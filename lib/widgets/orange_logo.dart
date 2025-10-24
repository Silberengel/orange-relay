import 'package:flutter/material.dart';

class OrangeLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const OrangeLogo({
    super.key,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color ?? Colors.orange.shade300,
            color ?? Colors.orange.shade600,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.local_drink,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}

class OrangeLogoSmall extends StatelessWidget {
  const OrangeLogoSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.orange,
      ),
      child: const Icon(
        Icons.local_drink,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}
