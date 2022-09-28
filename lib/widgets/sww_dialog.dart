import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SomethingWentWrongDialog extends StatelessWidget {
  final String? title;
  final String? bodyMessage;
  const SomethingWentWrongDialog({this.title, this.bodyMessage, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? "something_went_wrong".tr()),
      content: Text(bodyMessage ?? "we_have_technical_problems".tr()),
      actionsPadding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      actionsOverflowButtonSpacing: 8,
      actionsOverflowDirection: VerticalDirection.up,
      actions: [
        TextButton(
          child: const Text('Ок'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        const SizedBox(width: 5),
      ],
    );
  }
}
