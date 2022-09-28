import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:admin_app/route/route_constants.dart';
import 'package:admin_app/screens/history/components/order_detail_manage.dart';
import 'package:admin_app/widgets/button.dart';
import '../../widgets/list/order_list.dart';
import '/models/order.dart';
import 'package:provider/provider.dart';

import '../../providers/orders.dart';
import '../../utilities/styles.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future _ordersFuture;
  var isInit = false;

  Future _obtainOrdersFuture() async {
    var data = Provider.of<OrdersNotifier>(context, listen: true);
    await data.fetchAndSetOrders();
    return data;
  }

  @override
  void didChangeDependencies() {
    if (!isInit) {
      _ordersFuture = _obtainOrdersFuture();
      showOrderDetailFromArgs();
      isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0.0,
          iconTheme: const IconThemeData(
            size: 32,
            color: Colors.white,
          ),
          title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(
              'history.title'.tr(),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              iconSize: 36,
              onPressed: () {
                Navigator.pushNamed(context, menuRoute);
              },
              icon: const Icon(
                Icons.home,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10)
          ]),
      body: SafeArea(
        child: FutureBuilder(
          future: _ordersFuture,
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapshot.error != null) {
                if (kDebugMode) {
                  print("Error: ${dataSnapshot.error.toString()}");
                }
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "history.technical_problems".tr(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else {
                return SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 40),
                    child: Consumer<OrdersNotifier>(
                        builder: (ctx, ordersData, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            ActiveOrdersDisplay(ordersData.activeOrders!),
                            CompletedOrdersDisplay(
                                ordersData.latestCompletedOrders!),
                          ],
                        ),
                      );
                    }),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  void showOrderDetail(OrderData order) async {
    await showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (ctx) => ChangeNotifierProvider.value(
        value: order,
        child: const OrderDetailManageDialog(),
      ),
    );
  }

  void showOrderDetailFromArgs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg != null) {
      showOrderDetail(arg as OrderData);
    }
  }
}

class OrderListTitle extends StatelessWidget {
  final String text;
  const OrderListTitle(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.roboto(
          color: AppColors.secondaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 18),
    );
  }
}

class CompletedOrdersDisplay extends StatelessWidget {
  final List<OrderData> orders;
  const CompletedOrdersDisplay(this.orders, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return orders.isEmpty
        ? Container()
        : Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                OrderListTitle('history.completed_orders'.tr()),
                const SizedBox(height: 10),
                Center(
                  child: Opacity(
                    opacity: 0.7,
                    child: OrderList(
                      orders,
                      onPressed: (OrderData orderData) => showDialog(
                        barrierColor: Colors.transparent,
                        context: context,
                        builder: (ctx) => ChangeNotifierProvider.value(
                          value: orderData,
                          child: const OrderDetailManageDialog(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

class ActiveOrdersDisplay extends StatelessWidget {
  final List<OrderData> orders;
  const ActiveOrdersDisplay(this.orders, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ordersQuantity = orders.length;
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ordersQuantity != 0) OrderListTitle('history.active_orders'.tr()),
          const SizedBox(height: 20),
          if (ordersQuantity == 0) const NoOrdersWidget(),
          if (ordersQuantity == 1)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ChangeNotifierProvider.value(
                  value: orders.first,
                  child: const OrderDetailManageWidget(),
                ),
              ),
            ),
          if (ordersQuantity > 1)
            Center(
              child: OrderList(
                orders,
                onPressed: (OrderData orderData) => showDialog(
                  barrierColor: Colors.transparent,
                  context: context,
                  builder: (ctx) => ChangeNotifierProvider.value(
                    value: orderData,
                    child: const OrderDetailManageDialog(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NoOrdersWidget extends StatelessWidget {
  const NoOrdersWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Image.asset(
            'assets/images/waiting.png',
            fit: BoxFit.fitWidth,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'history.no_order'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedDefaultButton(
            borderRadius: 12,
            onPressed: () => Navigator.pushNamed(context, menuRoute),
            child: Text(
              'acl.service_acl_action'.tr(),
              style: const TextStyle(fontSize: 16),
            )),
      ],
    );
  }
}
