import 'package:flutter/material.dart';

class SetACLDateTimeScreen extends StatefulWidget {
  const SetACLDateTimeScreen({Key? key}) : super(key: key);

  @override
  State<SetACLDateTimeScreen> createState() => _SetACLDateTimeScreenState();
}

class _SetACLDateTimeScreenState extends State<SetACLDateTimeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text("Set date time widget"),
        ),
      ),
    );
  }
}
