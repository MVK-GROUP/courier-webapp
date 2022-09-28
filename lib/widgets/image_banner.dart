import 'package:flutter/material.dart';

class ImageBanner extends StatelessWidget {
  final String _assetPath;
  final double hConstraint;
  final BoxFit imageFit;

  const ImageBanner(this._assetPath,
      {Key? key, this.hConstraint = 200, this.imageFit = BoxFit.scaleDown})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.expand(height: hConstraint),
        child: Image.asset(_assetPath, fit: imageFit));
  }
}
