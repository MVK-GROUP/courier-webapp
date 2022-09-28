import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import '../api/http_exceptions.dart';
import '/api/auth.dart';

class Auth with ChangeNotifier {
  String? _token;
  String? _phone;

  bool get isAuth {
    return _token != null;
  }

  String? get token {
    return _token;
  }

  String? get phone {
    return _phone;
  }

  Future<void> confirmOtp(String? phone, String otpCode) async {
    try {
      _token = await AuthApi.confirmOtpAndObtainToken(phone ?? "", otpCode);
      _phone = phone;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        "token": _token,
        "phone": _phone,
      });
      prefs.setString("userData", userData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> testConfirmOtp(String? phone, String otpCode) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (otpCode == '1234') {
        throw HttpException('incorrect_otp', statusCode: 400);
      }
      _token = '93c714ab2454392be924da69ba6afad0fa868044';
      _phone = phone;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        "token": _token,
        "phone": _phone,
      });
      prefs.setString("userData", userData);
    } catch (e) {
      rethrow;
    }
  }

  void logout() async {
    _token = null;
    _phone = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData') ?? "{}")
        as Map<String, dynamic>;

    _token = extractedUserData['token'] as String;
    _phone = extractedUserData['phone'] as String;

    notifyListeners();

    return true;
  }
}
