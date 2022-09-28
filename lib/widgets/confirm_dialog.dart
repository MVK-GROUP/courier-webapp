import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../utilities/styles.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final Color titleColor;
  final String? text;
  final Widget? content;
  final double maxHeight;

  const ConfirmDialog({
    required this.title,
    this.text,
    this.content,
    this.titleColor = AppColors.secondaryColor,
    this.maxHeight = 360,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: 10, right: 10, bottom: 0),
                    child: IconButton(
                        iconSize: 32,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close))),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: titleColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: text != null
                    ? Text(
                        text ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      )
                    : content,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Text(
                        "cancel".tr(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Text(
                        "confirm".tr(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ));
  }
}

class InformationDialog extends StatelessWidget {
  final String title;
  final Color titleColor;
  final String text;
  final double maxHeight;

  const InformationDialog({
    required this.title,
    required this.text,
    this.titleColor = AppColors.secondaryColor,
    this.maxHeight = 360,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 10, left: 10, right: 10, bottom: 0),
                    child: IconButton(
                        iconSize: 32,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close))),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: titleColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Text(
                          "Ок",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ));
  }
}
