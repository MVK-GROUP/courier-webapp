import 'dart:async';

import 'package:admin_app/models/lockers.dart';
import 'package:admin_app/screens/history/components/delivery_action_widget.dart';
import 'package:flutter/material.dart';
import 'package:admin_app/screens/history/components/order_detail.dart';
import '/providers/auth.dart';
import 'package:provider/provider.dart';

import '../../../models/order.dart';
import '../../../utilities/styles.dart';
import 'order_actions_widget.dart';

class _OrderDetailManageContent extends StatefulWidget {
  const _OrderDetailManageContent({Key? key}) : super(key: key);

  @override
  State<_OrderDetailManageContent> createState() =>
      _OrderDetailManageContentState();
}

class _OrderDetailManageContentState extends State<_OrderDetailManageContent> {
  late OrderData order;
  var _isInit = false;
  Timer? timer;
  var _isOrderLoading = false;
  String? token;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      token = Provider.of<Auth>(context, listen: false).token;
      order = Provider.of<OrderData>(context, listen: true);
      _isOrderLoading = false;
      if ([OrderStatus.created, OrderStatus.inProgress, OrderStatus.hold]
          .contains(order.status)) {
        setState(() {
          _isOrderLoading = true;
        });
        checkOrder();
        if (!order.isExpired) {
          timer = Timer.periodic(const Duration(seconds: 2, milliseconds: 500),
              (timer) {
            checkOrder();
            if (![OrderStatus.created, OrderStatus.inProgress]
                .contains(order.status)) {
              timer.cancel();
              setState(() {
                _isOrderLoading = false;
              });
            }
            // GET ORDER STATUS
          });
        } else {
          setState(() {
            _isOrderLoading = false;
          });
        }
      } else if (order.status == OrderStatus.error) {
        checkOrder();
        setState(() {
          _isOrderLoading = false;
        });
      }
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OrderInfo(order),
            if (order.service == ServiceCategory.acl)
              const OrderActionsWidget(),
            if (order.service == ServiceCategory.delivery)
              const DeliveryOrderActionsWidget(),
          ],
        ),
      ),
      if (_isOrderLoading)
        const Positioned.fill(
          child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  child: LinearProgressIndicator(
                    minHeight: 5,
                  ))),
        ),
    ]);
  }

  Future<bool> checkOrder() async {
    try {
      var updated = await order.checkOrder(token);
      return updated;
    } catch (e) {
      print("error: $e");
      return false;
    }
  }
}

class OrderDetailManageDialog extends StatelessWidget {
  const OrderDetailManageDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              iconSize: 32,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: _OrderDetailManageContent(),
          )
        ],
      ),
    );
  }
}

class OrderDetailManageWidget extends StatelessWidget {
  const OrderDetailManageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: [AppShadows.getShadow100()],
      ),
      child: const _OrderDetailManageContent(),
    );
  }
}
