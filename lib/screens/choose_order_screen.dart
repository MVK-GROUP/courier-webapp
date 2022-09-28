import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:admin_app/screens/history/components/order_detail_manage.dart';
import 'package:admin_app/screens/sceleton_screen.dart';
import '../models/order.dart';
import 'package:provider/provider.dart';

import '../utilities/styles.dart';
import '../widgets/list/order_list.dart';

class ChooseOrderScreen extends StatelessWidget {
  static const routeName = 'choose-order/';

  final List<OrderData> orders;

  const ChooseOrderScreen({required this.orders, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkeletonScreen(
      title: 'history.select_order'.tr(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Text(
                  "history.several_orders_select_you_want".tr(),
                  textAlign: TextAlign.center,
                  style: AppStyles.subtitleTextStyle,
                ),
              ),
              Center(
                child: OrderList(
                  orders,
                  onPressed: (OrderData orderData) =>
                      showOrderDetail(context, orderData),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showOrderDetail(BuildContext context, OrderData order) async {
    await showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (ctx) => ChangeNotifierProvider.value(
        value: order,
        child: const OrderDetailManageDialog(),
      ),
    );
  }
}
