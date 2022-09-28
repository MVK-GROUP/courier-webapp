import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'settings.dart';
import '../models/order.dart';
import 'http_exceptions.dart';

class OrderApi {
  static const baseUrl = "$domain/api/v1";

  static Map<String, String>? _defaultHeader({String? token}) {
    var headers = {
      "content-type": "application/json",
      "accept": "application/json",
    };
    if (token != null) {
      headers["Authorization"] = "Token $token";
    }
    return headers;
  }

  static Future<List<OrderData>> fetchOrders(
      {String? token, String? status, int? quantity}) async {
    var apiUrl = "/couriers/orders/${status == null ? '' : '?status=$status'}";
    if (quantity != null && status != null) {
      apiUrl += '&quantity=$quantity';
    } else if (quantity != null) {
      apiUrl += '?quantity=$quantity';
    }
    try {
      var res = await http.get(
        Uri.parse(baseUrl + apiUrl),
        headers: _defaultHeader(token: token),
      );
      if (res.statusCode == 200) {
        List<OrderData> orders = [];
        var data = json.decode(utf8.decode(res.bodyBytes)) as List<dynamic>;
        for (var element in data) {
          orders.add(OrderData.fromJson(element));
        }
        return orders;
      } else {
        throw HttpException(res.reasonPhrase.toString(),
            statusCode: res.statusCode);
      }
    } on SocketException {
      throw HttpException("SocketException", statusCode: 500);
    } catch (e) {
      rethrow;
    }
  }

  static Future<OrderData> fetchOrderById(int orderId, String? token) async {
    var apiUrl = "/couriers/orders/$orderId/";
    try {
      var res = await http.get(
        Uri.parse(baseUrl + apiUrl),
        headers: _defaultHeader(token: token),
      );

      if (res.statusCode == 200) {
        var data =
            json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        return OrderData.fromJson(data);
      } else if (res.statusCode == 404) {
        throw HttpException("Такого замовлення не існує",
            statusCode: res.statusCode);
      } else {
        throw HttpException("Вибачте, в нас технічні несправності...",
            statusCode: res.statusCode);
      }
    } on SocketException {
      throw HttpException("Вибачте, в нас технічні несправності...",
          statusCode: 500);
    } catch (e) {
      rethrow;
    }
  }

  static Future<OrderData> checkPaymentByOrderId(int orderId, String? token,
      {isDebt = false}) async {
    var apiUrl =
        "/couriers/orders/$orderId/${isDebt ? "check-debt-payment/" : "check-payment/"}";
    try {
      var res = await http.get(
        Uri.parse(baseUrl + apiUrl),
        headers: _defaultHeader(token: token),
      );
      var data =
          json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      if (res.statusCode == 200) {
        return OrderData.fromJson(data);
      } else if (res.statusCode == 404) {
        if (data.containsKey('status')) {
          if (data['status'] == 'no_payment' ||
              data['status'] == 'not_successful') {
            throw HttpException(data['msg'], statusCode: res.statusCode);
          }
        }
        throw HttpException("Не коректний номер замовлення",
            statusCode: res.statusCode);
      } else {
        throw HttpException("Вибачте, в нас технічні несправності...",
            statusCode: res.statusCode);
      }
    } on SocketException {
      throw HttpException("Вибачте, в нас технічні несправності...",
          statusCode: 500);
    } catch (e) {
      rethrow;
    }
  }

  static Future<OrderData> createServiceOrder(
      int lockerId, String title, Map<String, Object>? data, String? token,
      {required String customerPhone,
      required String service,
      required String lang}) async {
    var apiUrl = "/couriers/orders/create-order/";
    try {
      final rawResponse = await http.post(
        Uri.parse(baseUrl + apiUrl),
        body: json.encode({
          'locker_id': lockerId,
          'title': title,
          'data': data,
          'service': service,
          'client_phone': customerPhone,
        }),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Authorization": "Token $token",
          "Accept-Language": lang,
        },
      );
      if (rawResponse.statusCode < 400) {
        final response = json.decode(utf8.decode(rawResponse.bodyBytes))
            as Map<String, dynamic>;
        return OrderData.fromJson(response);
      }
      throw HttpException(rawResponse.reasonPhrase ?? "error");
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  static Future<String?> openCell(int orderId, String? token) async {
    var apiUrl = "/orders/$orderId/open-cell/";
    try {
      final rawResponse = await http.post(
        Uri.parse(baseUrl + apiUrl),
        headers: _defaultHeader(token: token),
      );
      if (rawResponse.statusCode < 400) {
        final response = json.decode(utf8.decode(rawResponse.bodyBytes))
            as Map<String, dynamic>;
        return response["task_num"];
      }
      throw HttpException(rawResponse.reasonPhrase ?? "error");
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  static Future<String?> putThings(int orderId, String? token) async {
    var apiUrl = "/couriers/orders/$orderId/put-things/";
    try {
      final rawResponse = await http.post(
        Uri.parse(baseUrl + apiUrl),
        headers: _defaultHeader(token: token),
      );
      if (rawResponse.statusCode < 400) {
        final response = json.decode(utf8.decode(rawResponse.bodyBytes))
            as Map<String, dynamic>;
        return response["task_num"];
      }
      throw HttpException(rawResponse.reasonPhrase ?? "error");
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  static Future<String?> getThings(int orderId, String? token) async {
    var apiUrl = "/orders/$orderId/get-things/";
    try {
      final rawResponse = await http.post(
        Uri.parse(baseUrl + apiUrl),
        headers: _defaultHeader(token: token),
      );
      if (rawResponse.statusCode < 400) {
        final response = json.decode(utf8.decode(rawResponse.bodyBytes))
            as Map<String, dynamic>;
        return response["task_num"];
      }
      throw HttpException(rawResponse.reasonPhrase ?? "error");
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  static Future<int> checkOpenCellTask(
      int orderId, String numTask, String? token) async {
    var apiUrl = "/couriers/orders/$orderId/check-task/$numTask/";
    try {
      final rawResponse = await http.post(
        Uri.parse(baseUrl + apiUrl),
        headers: _defaultHeader(token: token),
      );
      if (rawResponse.statusCode < 400) {
        final response = json.decode(utf8.decode(rawResponse.bodyBytes))
            as Map<String, dynamic>;
        if (response['status'] == 'success' &&
            response.containsKey('task_status')) {
          return response["task_status"];
        }
      }
      throw HttpException(rawResponse.reasonPhrase ?? "error");
    } catch (e) {
      throw HttpException(e.toString());
    }
  }

  static Future<bool> isExistActiveOrders(String? token) async {
    var apiUrl = "/orders/active/";
    try {
      final rawResponse = await http.post(
        Uri.parse(baseUrl + apiUrl),
        headers: _defaultHeader(token: token),
      );
      if (rawResponse.statusCode < 400) {
        final response =
            json.decode(utf8.decode(rawResponse.bodyBytes)) as List<dynamic>;
        return response.isNotEmpty;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> payDebt(int orderId, String? token,
      {required String lang}) async {
    var apiUrl = "/orders/$orderId/pay-debt/";
    try {
      final rawResponse = await http.post(
        Uri.parse(baseUrl + apiUrl),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Authorization": "Token $token",
          "Accept-Language": lang,
        },
      );
      if (rawResponse.statusCode < 400) {
        final response = json.decode(utf8.decode(rawResponse.bodyBytes))
            as Map<String, dynamic>;
        var data = {
          "data": response['pay_data'],
          "signature": response['pay_signature']
        };
        return data;
      }
      throw HttpException("unknown error");
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> sendProblemReport(
      Map<String, Object> data, String? token) async {
    var apiUrl = "/orders/problem/";
    try {
      final rawResponse = await http.post(
        Uri.parse(baseUrl + apiUrl),
        body: json.encode(data),
        headers: {
          "Authorization": "Token $token",
        },
      );
      if (rawResponse.statusCode >= 400) {
        throw HttpException("unknown error");
      }
    } catch (e) {
      rethrow;
    }
  }
}
