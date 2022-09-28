import 'package:flutter/material.dart';
import '../utilities/styles.dart';

class ScreenTitle extends StatelessWidget {
  final String title;
  final String? subTitle;
  final double height;

  const ScreenTitle(this.title, {this.subTitle, this.height = 160, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline2,
            ),
            if (subTitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  subTitle!,
                  textAlign: TextAlign.center,
                  style: AppStyles.subtitleTextStyle,
                ),
              )
          ]),
    );
  }
}
