import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:admin_app/route/route_constants.dart';
import '../models/lockers.dart';
import '../providers/orders.dart';
import '../widgets/confirm_dialog.dart';
import 'package:provider/provider.dart';
import '../api/orders.dart';
import '../models/order.dart';
import '../providers/auth.dart';
import '../widgets/sww_dialog.dart';
import '../utilities/styles.dart';
import '../widgets/button.dart';

class SuccessOrderScreen extends StatefulWidget {
  const SuccessOrderScreen({Key? key}) : super(key: key);

  @override
  State<SuccessOrderScreen> createState() => _SuccessOrderScreenState();
}

class _SuccessOrderScreenState extends State<SuccessOrderScreen> {
  late OrderData order;
  String? token;
  late Locker? locker;
  String? text;
  Timer? timer;
  Timer? _cellOpeningTimer;
  var _isInit = false;
  var _isOrderStatusChecking = false;
  var _isCellOpening = false;
  int maxAttempts = 14;

  @override
  void dispose() {
    timer?.cancel();
    _cellOpeningTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      token = Provider.of<Auth>(context).token;
      locker = Provider.of<LockerNotifier>(context).locker;

      final existArgs = arg as Map<String, Object>;
      order = existArgs["order"] as OrderData;
      text = existArgs["title"] as String;

      int attempt = 0;
      attempt++;
      timer = Timer.periodic(const Duration(seconds: 1, milliseconds: 500),
          (timer) async {
        try {
          attempt++;
          var checkedOrder =
              await Provider.of<OrdersNotifier>(context, listen: false)
                  .checkOrder(order.id);
          if (![OrderStatus.created, OrderStatus.inProgress]
              .contains(checkedOrder.status)) {
            timer.cancel();
            setState(() {
              _isOrderStatusChecking = false;
            });
            if (checkedOrder.status == OrderStatus.error ||
                checkedOrder.timeLeftInSeconds < 1) {
              throw Exception("order error");
            }
          }
          if (attempt > maxAttempts) {
            timer.cancel();
            setState(() {
              _isOrderStatusChecking = false;
            });
            throw Exception("order error");
          }
        } catch (e) {
          timer.cancel();
          showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    content: Text(
                        "create_order.cant_check_status__go_to_detail".tr()),
                  ));
          Navigator.pushNamed(context, historyRoute);
          setState(() {
            _isOrderStatusChecking = false;
          });
        }
      });
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(size: 32),
            actions: [
              IconButton(
                iconSize: 36,
                onPressed: _isOrderStatusChecking
                    ? null
                    : () {
                        Navigator.pushNamed(context, menuRoute);
                      },
                icon: const Icon(Icons.home),
              ),
              const SizedBox(width: 10)
            ]),
        body: SafeArea(
          child: LayoutBuilder(builder:
              (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.only(left: 35, right: 35),
                constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                    minWidth: viewportConstraints.maxWidth),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            "great".tr(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.copyWith(color: AppColors.secondaryColor),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            text ?? "",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Lottie.asset('assets/lottiefiles/man-on-rocket.json',
                          height: 200),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          _isOrderStatusChecking || _isCellOpening
                              ? ElevatedWaitingButton(
                                  text: "acl.open_cell_and_put_stuff".tr(),
                                  iconSize: 20,
                                )
                              : ElevatedIconButton(
                                  icon: const Icon(
                                    Icons.clear_all_outlined,
                                    size: 24,
                                  ),
                                  text: "acl.open_cell_and_put_stuff".tr(),
                                  onPressed: () {
                                    openCell();
                                  },
                                ),
                          const SizedBox(height: 15),
                        ],
                      ),
                      const SizedBox(height: 15),
                    ]),
              ),
            );
          }),
        ));
  }

  void openCell() async {
    String? numTask;
    try {
      setState(() {
        _isCellOpening = true;
      });
      numTask = await OrderApi.putThings(order.id, token);
      if (numTask == null) {
        throw Exception();
      }
    } catch (e) {
      await showDialog(
          context: context,
          builder: (ctx) => SomethingWentWrongDialog(
                bodyMessage: "create_order.cant_open_cell".tr(),
              ));
      setState(() {
        _isCellOpening = false;
      });
      return;
    }

    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    await checkOpenCellTask(numTask);
    if (!mounted) return;
    showDialogByOpenCellTaskStatus(
        context, order.status == OrderStatus.active ? 1 : 2);
    setState(() {
      _isCellOpening = false;
    });
    Navigator.pushNamedAndRemoveUntil(
        context, historyRoute, ModalRoute.withName(menuRoute));
  }

  Future<void> checkOpenCellTask(String numTask,
      {attempts = 0, maxAttempts = 12}) async {
    try {
      var status = await OrderApi.checkOpenCellTask(order.id, numTask, token);

      if (status == 0 && maxAttempts > attempts) {
        attempts += 1;
        await Future.delayed(const Duration(seconds: 1, milliseconds: 200));
        await checkOpenCellTask(numTask, attempts: attempts);
      } else {
        await order.checkOrder(token);
      }
    } catch (e) {
      return;
    }
  }

  Future<void> checkChangingOrder({attempts = 0, maxAttempts = 10}) async {
    try {
      await order.checkOrder(token);
      if (order.status != OrderStatus.active && maxAttempts > attempts) {
        attempts += 1;
        await Future.delayed(const Duration(seconds: 2));
        await checkChangingOrder(attempts: attempts);
      }
    } catch (e) {
      return;
    }
  }

  void showDialogByOpenCellTaskStatus(BuildContext context, int status) async {
    String? message;
    if (status == 1) {
      message = "history.cell_opened_and_dont_forget".tr();
    } else if (status == 2) {
      message = "cell_didnt_open".tr();
    } else if (status == 3) {
      message = "create_order.cant_check_cell_opened__go_to_detail".tr();
    }
    if (message != null) {
      await showDialog(
          context: context,
          builder: (ctx) {
            return InformationDialog(
              title: "information".tr(),
              text: message ?? "unknown",
            );
          });
    }
  }
}
