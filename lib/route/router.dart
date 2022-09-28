import 'package:flutter/material.dart';
import 'package:admin_app/providers/auth.dart';
import '../screens/acl/set_datetime.dart';
import '../screens/acl/size_selection_screen.dart';
import '../screens/check_payment_screen.dart';
import '../screens/confirm_locker_screen.dart';
import '../screens/enter_lockerid_screen.dart';
import '../screens/feedback.dart';
import '../screens/history/history_screen.dart';
import '../screens/pay_screen.dart';
import '../screens/qr_scanner_screen.dart';
import '../screens/success_order_screen.dart';
import '../screens/waiting_splash.dart';
import '../screens/auth/welcome.dart';
import '../screens/menu.dart';
import 'screen_export.dart';

final Map<String, WidgetBuilder> routes = {
  enterLockerIdRoute: (ctx) => const EnterLockerIdScreen(),
  feedbackRoute: (ctx) => const FeedbackScreen(),
  menuRoute: (ctx) => const MenuScreen(),
  welcomeRoute: (ctx) => const WelcomeScreen(),
  sizeSelectionRoute: (ctx) => const SizeSelectionScreen(),
  scannerRoute: (ctx) => QrScannerScreen(),
  payWindowRoute: (ctx) => const PayScreen(),
  successOrderRoute: (ctx) => const SuccessOrderScreen(),
  historyRoute: (ctx) => const HistoryScreen(),
  datetimeSettingRoute: (ctx) => const SetACLDateTimeScreen(),
};

class RouteGenerator {
  static Route<dynamic>? generateRoute(
      RouteSettings settings, BuildContext context, Auth auth) {
    Map? queryParameters;
    var uriData = Uri.parse(settings.name!);
    queryParameters = uriData.queryParameters;
    if (queryParameters.containsKey("locker_id") &&
        int.tryParse(queryParameters["locker_id"]) != null) {
      return MaterialPageRoute(
        builder: (context) {
          return auth.isAuth
              ? ConfirmLockerScreen(queryParameters!["locker_id"])
              : WelcomeScreen(prevRouteName: uriData.toString());
        },
        settings: settings,
      );
    }
    if (queryParameters.containsKey("payment-status") &&
        queryParameters.containsKey("order_id") &&
        int.tryParse(queryParameters["order_id"]) != null) {
      int orderId = int.parse(queryParameters["order_id"]);

      var paymentType = PaymentType.unknown;
      var isDebt = false;
      if (queryParameters.containsKey("type") &&
          queryParameters['type'] == 'debt') {
        isDebt = true;
      }

      if (queryParameters["payment-status"] == 'success') {
        paymentType = isDebt
            ? PaymentType.successDebtPayment
            : PaymentType.successPayment;
      }
      if (queryParameters["payment-status"] == 'error') {
        paymentType =
            isDebt ? PaymentType.errorDebtPayment : PaymentType.errorPayment;
      }

      if (paymentType != PaymentType.unknown) {
        return MaterialPageRoute(
          builder: (context) {
            return auth.isAuth
                ? CheckPaymentScreen(
                    type: paymentType,
                    orderId: orderId,
                  )
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (context, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? const WaitingSplashScreen()
                            : const WelcomeScreen(),
                  );
          },
          settings: settings,
        );
      }
    }
    return MaterialPageRoute(
      builder: (context) {
        return auth.isAuth
            ? const MenuScreen()
            : WelcomeScreen(prevRouteName: uriData.toString());
      },
      settings: settings,
    );
  }
}
