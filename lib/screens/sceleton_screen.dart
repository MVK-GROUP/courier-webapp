import 'package:flutter/material.dart';

class SkeletonScreen extends StatelessWidget {
  final String title;
  final Widget body;

  const SkeletonScreen({required this.title, required this.body, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            title,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: body,
    );
  }
}
