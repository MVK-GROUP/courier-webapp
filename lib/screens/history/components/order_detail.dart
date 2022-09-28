import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:admin_app/route/route_constants.dart';
import 'package:admin_app/screens/feedback.dart';

import '../../../models/order.dart';
import '../../../utilities/styles.dart';
import '../../../widgets/button.dart';
import '../../../widgets/order_element_widget.dart';

class OrderInfo extends StatelessWidget {
  final OrderData order;
  const OrderInfo(this.order, {Key? key}) : super(key: key);

  String get orderStatusText {
    var text = "history.order_status_title".tr();
    switch (order.status) {
      case OrderStatus.canceled:
        text += "history.order_status_canceled".tr();
        break;
      case OrderStatus.error:
        text += "history.order_status_error".tr();
        break;
      case OrderStatus.expired:
        text += "history.order_status_expired".tr();
        break;
      case OrderStatus.hold:
        text += "history.order_status_active".tr();
        break;
      case OrderStatus.active:
        text += "history.order_status_executed".tr();
        break;
      case OrderStatus.inProgress:
        text += "history.order_status_in_progress".tr();
        break;
      case OrderStatus.created:
        text += "history.order_status_created".tr();
        break;
      case OrderStatus.completed:
        text += "history.order_status_completed".tr();
        break;
      default:
    }
    if ([OrderStatus.created, OrderStatus.inProgress, OrderStatus.hold]
            .contains(order.status) &&
        order.isExpired) {
      text = "history.order_status_title".tr() +
          "history.order_status_expired".tr();
    }
    return text;
  }

  Color get orderStatusColor {
    if ([OrderStatus.created, OrderStatus.inProgress, OrderStatus.hold]
            .contains(order.status) &&
        order.isExpired) {
      return AppColors.dangerousColor;
    }
    if ([
      OrderStatus.hold,
      OrderStatus.inProgress,
      OrderStatus.created,
      OrderStatus.active,
      OrderStatus.completed
    ].contains(order.status)) {
      return AppColors.successColor;
    } else {
      return AppColors.dangerousColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "history.order_number".tr(namedArgs: {"id": order.id.toString()}),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: OrderElementWidget(
            iconData: Icons.title,
            text: order.title,
            iconSize: 26,
            textStyle: AppStyles.bodyText2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: OrderElementWidget(
            iconData: Icons.location_on,
            text: order.place ?? "unknown".tr(),
            iconSize: 26,
            textStyle: AppStyles.bodyText2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: OrderElementWidget(
            iconData: Icons.calendar_month,
            text: order.humanDate,
            iconSize: 26,
            textStyle: AppStyles.bodyText2,
          ),
        ),
        if (order.data!.containsKey("cell_number"))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: OrderElementWidget(
                iconData: Icons.clear_all,
                text: "cell_number".tr(
                    namedArgs: {"cell": order.data!["cell_number"].toString()}),
                iconSize: 26,
                textStyle: AppStyles.bodyText2),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: OrderElementWidget(
            iconData: Icons.playlist_add_check_circle_outlined,
            text: orderStatusText,
            iconSize: 26,
            textStyle: AppStyles.bodyText2.copyWith(color: orderStatusColor),
          ),
        ),
      ],
    );
  }
}

class _OrderDetailContent extends StatelessWidget {
  final OrderData order;
  const _OrderDetailContent(this.order, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OrderInfo(order),
        const SizedBox(height: 20),
        if (order.status != OrderStatus.completed)
          ElevatedDefaultButton(
            borderRadius: 12,
            onPressed: () async {
              Navigator.pushNamed(context, menuRoute);
            },
            child: Text(
              "history.manage_order".tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        if (order.status == OrderStatus.completed &&
            order.timeLeftInSeconds > -3600 * 24)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            child: TextButton(
                child: Text(
                  "report_problem".tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dangerousColor),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeedbackScreen(order: order),
                    ),
                  );
                }),
          ),
      ],
    );
  }
}

class OrderDetailDialog extends StatelessWidget {
  final OrderData order;
  const OrderDetailDialog(this.order, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
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
          Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 30),
            child: _OrderDetailContent(order),
          ),
        ],
      ),
    );
  }
}

class OrderDetail extends StatelessWidget {
  final OrderData order;
  const OrderDetail(this.order, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: [AppShadows.getShadow100()],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: _OrderDetailContent(order),
    );
  }
}
