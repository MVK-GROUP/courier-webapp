import 'dart:math';

import 'package:flutter/foundation.dart';
import '../models/lockers.dart';
import '../models/order.dart';
import '../api/orders.dart';

class OrdersNotifier with ChangeNotifier {
  List<OrderData>? _activeOrders;
  List<OrderData>? _latestCompletedOrders;
  DateTime? _activeOrdersLastUpdate;
  DateTime? _completedOrdersLastUpdate;
  var _lastUpdate = 0;

  final String? authToken;

  OrdersNotifier(
      this.authToken, this._activeOrders, this._latestCompletedOrders);

  bool get isTimeToUpdate {
    if (_activeOrdersLastUpdate == null ||
        _completedOrdersLastUpdate == null ||
        _activeOrders == null ||
        _latestCompletedOrders == null) {
      return true;
    }
    var diff1 = DateTime.now().difference(_activeOrdersLastUpdate!).inSeconds;
    var diff2 =
        DateTime.now().difference(_completedOrdersLastUpdate!).inSeconds;
    return (max(diff1, diff2) > 30);
  }

  List<OrderData>? get activeOrders {
    if (_activeOrders == null) {
      return null;
    }
    return [...?_activeOrders];
  }

  List<OrderData>? get latestCompletedOrders {
    if (_latestCompletedOrders == null) {
      return null;
    }
    return [...?_latestCompletedOrders];
  }

  List<OrderData> get allOrders {
    List<OrderData> orders = [];
    if (_activeOrders != null) {
      orders.addAll(_activeOrders!);
    }
    if (_latestCompletedOrders != null) {
      orders.addAll(_latestCompletedOrders!);
    }
    return orders;
  }

  void setLastUpdateTime(time) {
    _lastUpdate = time;
  }

  int get lastUpdateTime {
    return _lastUpdate;
  }

  bool? isExistOrdersWithStatus(List<OrderStatus> statuses) {
    return _activeOrders?.any((element) => statuses.contains(element.status));
  }

  List<OrderData> getActiveAclsOrders() {
    List<OrderData> orders = [];
    var foundOrders = _activeOrders?.where((order) =>
        [OrderStatus.hold, OrderStatus.active].contains(order.status) &&
        [
          ServiceCategory.acl,
          ServiceCategory.phoneCharging,
          ServiceCategory.powerbank
        ].contains(order.service) &&
        order.timeLeftInSeconds > -3600);
    if (foundOrders != null) {
      orders.addAll(foundOrders);
    }
    return orders;
  }

  List<OrderData> getActiveAclsOrdersByLockerId(int lockerId) {
    List<OrderData> orders = [];
    var foundOrders =
        _activeOrders?.where((order) => order.lockerId == lockerId);
    if (foundOrders != null) {
      orders.addAll(foundOrders);
    }
    return orders;
  }

  Future<void> fetchAndSetOrders() async {
    try {
      final dateTimeNow = DateTime.now();
      _activeOrders =
          await OrderApi.fetchOrders(token: authToken, status: 'active');
      _activeOrdersLastUpdate = dateTimeNow;
      _latestCompletedOrders = await OrderApi.fetchOrders(
          token: authToken, status: 'completed', quantity: 3);
      _completedOrdersLastUpdate = dateTimeNow;
      notifyListeners();
    } catch (e) {
      _activeOrders = null;
      _activeOrdersLastUpdate = null;
      _latestCompletedOrders = null;
      _completedOrdersLastUpdate = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<List<OrderData>?> fetchAndSetActiveOrders() async {
    try {
      _activeOrders =
          await OrderApi.fetchOrders(token: authToken, status: 'active');
      _activeOrdersLastUpdate = DateTime.now();
      notifyListeners();
      return _activeOrders;
    } catch (e) {
      _activeOrders = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<List<OrderData>?> fetchAndSetCompletedOrders(
      {int quantity = 3}) async {
    try {
      _latestCompletedOrders = await OrderApi.fetchOrders(
          token: authToken, status: 'active', quantity: quantity);
      _completedOrdersLastUpdate = DateTime.now();
      notifyListeners();
      return _latestCompletedOrders;
    } catch (e) {
      _latestCompletedOrders = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<OrderData> addOrder(
    int lockerId,
    String title, {
    Map<String, Object>? data,
    required String lang,
    required String customerPhone,
    required String service,
  }) async {
    try {
      var order = await OrderApi.createServiceOrder(
          lockerId, title, data, authToken,
          lang: lang, customerPhone: customerPhone, service: service);
      _activeOrders?.insert(0, order);
      notifyListeners();
      return order;
    } catch (e) {
      rethrow;
    }
  }

  Future<OrderData> checkOrder(int orderId) async {
    try {
      var order = await OrderApi.fetchOrderById(orderId, authToken);
      int? index =
          _activeOrders?.indexWhere((element) => element.id == orderId);
      if (index != null && index != -1) {
        _activeOrders?[index] = order;
        notifyListeners();
        return order;
      } else {
        throw Exception("error");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<OrderData> checkOrderWithoutNotify(int orderId) async {
    try {
      var order = await OrderApi.fetchOrderById(orderId, authToken);
      return order;
    } catch (e) {
      rethrow;
    }
  }

  void resetOrders() {
    _activeOrders = null;
    _activeOrdersLastUpdate = null;
    _latestCompletedOrders = null;
    _completedOrdersLastUpdate = null;
    notifyListeners();
  }
}
