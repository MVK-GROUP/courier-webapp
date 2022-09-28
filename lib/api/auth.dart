import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'settings.dart';
import 'http_exceptions.dart';

class AuthApi {
  static const baseUrl = "$domain/api/v1/auth";

  static Future<bool> createOtp(String phone) async {
    var apiUrl = "/create-otp/";
    try {
      Map<String, Object> bodyData = {
        "phone": phone,
      };
      var res = await http.post(
        Uri.parse(baseUrl + apiUrl),
        body: json.encode(bodyData),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body["status"] == "success") {
          return true;
        } else {
          return false;
        }
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

  static Future<String> confirmOtpAndObtainToken(
      String phone, String otpCode) async {
    var apiUrl = "/confirm-otp/";
    try {
      Map<String, Object> bodyData = {"phone": phone, "otp": otpCode};
      var res = await http.post(
        Uri.parse(baseUrl + apiUrl),
        body: json.encode(bodyData),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        },
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        if (body["status"] == "success" && body.containsKey("token")) {
          return body["token"] as String;
        }
        throw HttpException(res.reasonPhrase.toString(),
            statusCode: res.statusCode);
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
