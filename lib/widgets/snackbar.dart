import 'package:flutter/material.dart';

import '../utilities/styles.dart';

SnackBar buildSnackBar(String text, {IconData? icon}) {
  return SnackBar(
    backgroundColor: AppColors.secondaryColor,
    content: Row(
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    ),
  );
}
