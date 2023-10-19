import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/store.dart';
import 'package:shop/exceptions/auth_exceptions.dart';
import 'package:shop/utils/constants.dart';

class Auth with ChangeNotifier {
  static const _urlAuth = Constants.FIREBASE_AUTH_URL;
  static const _apiKey = Constants.FIREBASE_API_KEY;

  String? _token;
  String? _email;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _logoutTimer;

  bool get isAuth {
    final isValid = _expiryDate != null && _expiryDate!.isAfter(DateTime.now());
    return _token != null && isValid;
  }

  String? get token {
    if (isAuth) {
      return _token;
    } else {
      return null;
    }
  }

  String? get email {
    if (isAuth) {
      return _email;
    } else {
      return null;
    }
  }

  String? get userId {
    if (isAuth) {
      return _userId;
    } else {
      return null;
    }
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = '$_urlAuth:$urlSegment?key=$_apiKey';
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );

    final responseBody = jsonDecode(response.body);
    if (responseBody['error'] != null) {
      throw AuthExceptions(responseBody['error']['message']);
    } else {
      _token = responseBody['idToken'];
      _email = responseBody['email'];
      _userId = responseBody['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseBody['expiresIn'],
          ),
        ),
      );

      Store.saveMap(
        'userData',
        {
          'token': _token,
          'email': _email,
          'userId': _userId,
          'expiryDate': _expiryDate!.toIso8601String(),
        },
      );
      _autoLogout();
      notifyListeners();
    }
  }

  Future<void> tryAutoLogin() async {
    if (isAuth) {
      return Future.value();
    } else {
      final userData = await Store.getMap('userData');
      if (userData.isEmpty) {
        return Future.value();
      } else {
        final expiryDate = DateTime.parse(userData['expiryDate']);
        if (expiryDate.isBefore(DateTime.now())) {
          return Future.value();
        } else {
          _token = userData['token'];
          _email = userData['email'];
          _userId = userData['userId'];
          _expiryDate = expiryDate;
          _autoLogout();
          notifyListeners();
          return Future.value();
        }
      }
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  void logout() {
    _token = null;
    _email = null;
    _userId = null;
    _expiryDate = null;
    _clearLogoutTimer();
    Store.remove('userData').then((_) => notifyListeners());
  }

  _clearLogoutTimer() {
    if (_logoutTimer != null) {
      _logoutTimer!.cancel();
      _logoutTimer = null;
    }
  }

  void _autoLogout() {
    _clearLogoutTimer();
    if (isAuth) {
      final timeToLogout = _expiryDate!.difference(DateTime.now()).inSeconds;
      _logoutTimer = Timer(Duration(seconds: timeToLogout), logout);
    }
  }
}
