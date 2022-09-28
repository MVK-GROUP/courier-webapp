import 'package:flutter/material.dart';
import '../utilities/styles.dart';

class OrderElementWidget extends StatelessWidget {
  final IconData iconData;
  final String text;
  final double iconSize;
  final TextStyle textStyle;

  const OrderElementWidget({
    required this.iconData,
    required this.text,
    this.iconSize = 20,
    this.textStyle = AppStyles.bodySmallText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          iconData,
          size: iconSize,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        ),
      ],
    );
  }
}
