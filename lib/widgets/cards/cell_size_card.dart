import 'package:flutter/material.dart';
import '../../utilities/styles.dart';

class CellSizeCard extends StatelessWidget {
  final double size;
  final String? symbol;
  final IconData? icon;
  final String title;
  final String? cellSize;
  const CellSizeCard({
    this.size = 220,
    this.icon,
    this.symbol,
    required this.title,
    this.cellSize,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppShadows.getShadow200()],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (icon != null) Icon(icon, size: 80),
            if (symbol != null)
              Text(
                symbol!,
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (cellSize != null)
              Text(
                cellSize!,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
