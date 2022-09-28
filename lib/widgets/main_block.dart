import 'package:flutter/material.dart';
import '../utilities/styles.dart';

class MainBlock extends StatelessWidget {
  final Widget child;
  final double hContentPadding;
  final double maxWidth;
  const MainBlock(
      {required this.child,
      this.maxWidth = 500,
      this.hContentPadding = 30,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          margin: const EdgeInsets.only(top: 20),
          decoration: const BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30))),
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  height: 8,
                  width: 80,
                ),
              ),
              Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(
                      top: 46, left: hContentPadding, right: hContentPadding),
                  child: child)
            ],
          )),
    );
  }
}
