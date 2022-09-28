import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/orders.dart';
import '../models/lockers.dart';
import '../models/order.dart';
import '../providers/auth.dart';
import '../providers/orders.dart';
import '../route/route_constants.dart';
import 'success_order_screen.dart';
import 'history/history_screen.dart';
import 'information_screen.dart';

enum PaymentType {
  successPayment,
  successDebtPayment,
  errorPayment,
  errorDebtPayment,
  unknown,
}

class CheckPaymentScreen extends StatefulWidget {
  final PaymentType type;
  final int orderId;

  const CheckPaymentScreen(
      {required this.type, required this.orderId, Key? key})
      : super(key: key);

  @override
  State<CheckPaymentScreen> createState() => _CheckPaymentScreenState();
}

class _CheckPaymentScreenState extends State<CheckPaymentScreen> {
  bool isInit = false;
  String? token;
  Future? _initFuture;
  late OrderData orderData;

  @override
  void didChangeDependencies() {
    if (!isInit) {
      _initFuture = _obtainInitFuture();
      isInit = true;
    }
    super.didChangeDependencies();
  }

  Future<int> _obtainInitFuture() async {
    token = Provider.of<Auth>(context).token;
    try {
      await Provider.of<OrdersNotifier>(context, listen: false)
          .fetchAndSetOrders();
      await Provider.of<LockerNotifier>(context, listen: false)
          .setLockerByOrderId(widget.orderId);
    } catch (e) {}

    if (widget.type == PaymentType.successPayment) {
      try {
        orderData = await OrderApi.checkPaymentByOrderId(widget.orderId, token);
        String? title;
        if (orderData.status == OrderStatus.hold) {
          title = "create_order.you_can_open_cell".tr();
        } else {
          title = "create_order.wait_for_able_to_open_cell".tr();
        }
        Navigator.pushNamed(context, successOrderRoute,
            arguments: {"order": orderData, "title": title});
        return 1;
      } catch (e) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => ErrorPaymentScreen(title: e.toString())),
            (route) => false);
        return -1;
      }
    } else if (widget.type == PaymentType.successDebtPayment) {
      try {
        orderData = await OrderApi.checkPaymentByOrderId(widget.orderId, token,
            isDebt: true);
        Navigator.pushReplacementNamed(context, historyRoute,
            arguments: orderData);
        return 1;
      } catch (e) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => ErrorPaymentScreen(title: e.toString())),
            (route) => false);
        return -1;
      }
    } else if (widget.type == PaymentType.errorPayment ||
        widget.type == PaymentType.errorDebtPayment) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => ErrorPaymentScreen(
                    title: "create_order.payment_failed".tr(),
                    nextPage: widget.type == PaymentType.errorPayment
                        ? ErrorNextPage.mainScreen
                        : ErrorNextPage.historyScreen,
                  )),
          (route) => false);
      return -1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 24),
                    child: Text(
                      "create_order.order_creating".tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center();
          }
        },
      ),
    );
  }
}
