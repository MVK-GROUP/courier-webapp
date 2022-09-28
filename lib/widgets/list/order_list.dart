import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../models/order.dart';
import '../cards/order_tile.dart';

class OrderList extends StatelessWidget {
  final List<OrderData> orders;
  final Function(OrderData)? onPressed;
  final double maxWidth;
  const OrderList(this.orders, {this.onPressed, this.maxWidth = 400, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: orders.length,
          itemBuilder: (ctx, i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: OrderTile(
                title: "history.order_number"
                    .tr(namedArgs: {"id": orders[i].id.toString()}),
                place: orders[i].place ?? "unknown".tr(),
                containerColor: Colors.white,
                date: orders[i].humanDate,
                onPressed:
                    onPressed == null ? null : () => onPressed!(orders[i]),
              ),
            );
          }),
    );
  }
}
