import 'package:flutter/material.dart';
import '../utilities/styles.dart';

class PhotoTile extends StatelessWidget {
  final String? imageUrl;
  final Color? backgroundColor;
  final String title;
  final double height;
  final VoidCallback onTap;

  const PhotoTile(
      {required this.title,
      required this.onTap,
      this.imageUrl,
      this.backgroundColor = AppColors.mainColor,
      this.height = 100,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(bottom: 20),
        height: height,
        child: Stack(
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
                ),
              ),
            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
