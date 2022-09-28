import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:admin_app/route/route_constants.dart';
import 'history/history_screen.dart';

import '../utilities/styles.dart';
import '../widgets/button.dart';

enum ErrorNextPage {
  historyScreen,
  mainScreen,
}

class ErrorPaymentScreen extends StatelessWidget {
  static const routeName = '/error-payment/';

  final String? title;
  final ErrorNextPage nextPage;
  const ErrorPaymentScreen(
      {this.title, this.nextPage = ErrorNextPage.mainScreen, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "there_was_error".tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    ?.copyWith(color: AppColors.secondaryColor),
              ),
              const SizedBox(height: 25),
              SizedBox(
                height: 200,
                child: Image.asset("assets/images/error.png"),
              ),
              const SizedBox(height: 25),
              Text(
                title ?? "",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(height: 40),
              if (nextPage == ErrorNextPage.mainScreen)
                ElevatedIconButton(
                  icon: const Icon(Icons.home),
                  text: "to_main_menu".tr(),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, menuRoute);
                  },
                ),
              if (nextPage == ErrorNextPage.historyScreen)
                ElevatedIconButton(
                  icon: const Icon(Icons.history),
                  text: "go_back".tr(),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, historyRoute);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class InformationWidget extends StatelessWidget {
  final String title;
  const InformationWidget({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, menuRoute);
                },
                child: Text("to_main_menu".tr()))
          ]),
    );
  }
}
