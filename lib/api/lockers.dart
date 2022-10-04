import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'settings.dart';
import '../models/lockers.dart';
import 'http_exceptions.dart';

class LockerApi {
  static const baseUrl = "$domain/api/v1";

  static Future<Locker> fetchLockerById(String lockerId, String? token,
      {String lang = 'en'}) async {
    var apiUrl = "/couriers/lockers/$lockerId/";
    try {
      var res = await http.get(
        Uri.parse(baseUrl + apiUrl),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Accept-Language": lang,
          "Authorization": "Token $token",
        },
      );
      if (res.statusCode == 200) {
        var locker = Locker.fromJson(
            json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
            lang: lang);
        return locker;
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

  static Future<Locker> fetchLockerByOrderId(int orderId, String? token,
      {lang = 'en'}) async {
    var apiUrl = "/orders/$orderId/get-locker/";
    try {
      var res = await http.get(
        Uri.parse(baseUrl + apiUrl),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Accept-Language": lang,
          "Authorization": "Token $token",
        },
      );
      if (res.statusCode == 200) {
        var locker = Locker.fromJson(
            json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>,
            lang: lang);
        return locker;
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

  static Future<List<CellStatus>> getFreeCells(
    int lockerId, {
    String? service,
    int? typeId,
    String? token,
  }) async {
    var apiUrl = "/lockers/$lockerId/cells/free/";
    try {
      Map<String, Object> bodyData = {};
      if (service != null) {
        bodyData["service"] = service;
      }
      if (typeId != null) {
        bodyData["type_id"] = typeId.toString();
      }
      var headers = {
        "content-type": "application/json",
        "accept": "application/json",
        "Authorization": "Token $token",
      };
      var res = await http.post(
        Uri.parse(baseUrl + apiUrl),
        body: json.encode(bodyData),
        headers: headers,
      );
      if (res.statusCode == 200) {
        var response =
            json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final data = response["data"] as List<dynamic>;

        List<CellStatus> cells = [];
        for (var element in data) {
          cells.add(CellStatus.fromJson(element));
        }
        return cells;
      } else if (res.body.contains("error")) {
        throw HttpException("complex_offline".tr(), statusCode: 400);
      } else {
        throw HttpException(res.reasonPhrase.toString(), statusCode: 500);
      }
    } on SocketException {
      throw HttpException("SocketException", statusCode: 500);
    } catch (e) {
      if (e is HttpException && e.statusCode == 400) {
        rethrow;
      }
      throw HttpException(e.toString(), statusCode: 500);
    }
  }

  static Future<bool> isActive(String lockerId) async {
    var apiUrl = "/lockers/$lockerId/is-active/";
    try {
      var res = await http.get(Uri.parse(baseUrl + apiUrl));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body["is_active"];
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
}
