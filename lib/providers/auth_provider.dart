import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/modal/http_exeption.dart';

class Auth with ChangeNotifier {
  String? _token;
  String? _userId;
  DateTime? _expiryDate;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authMethod(
    String? email,
    String? password,
    String urlSegment,
  ) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?'
        'key=AIzaSyCz6UDubG9NBK89mh1MsCaPGWVtMvDlGWU');
    final response = await http.post(
      url,
      body: json.encode(
        {
          "email": email,
          "password": password,
          "returnSecureToken": true,
        },
      ),
    );
    if (json.decode(response.body)['error'] != null) {
      throw HttpException(msg: json.decode(response.body)['error']['message']);
    }
    _token = json.decode(response.body)['idToken'];
    _userId = json.decode(response.body)['localId'];
    _expiryDate = DateTime.now().add(
      Duration(
        seconds: int.parse(
          json.decode(response.body)['expiresIn'],
        ),
      ),
    );
    // autoLogout();
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'userData',
      json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate?.toIso8601String(),
        },
      ),
    );
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final userData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(userData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = userData['token'];
    _userId = userData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    // autoLogout();
    return true;
  }

  Future<void> signup(String? email, String? password) async {
    return _authMethod(email, password, 'signUp');
  }

  Future<void> login(String? email, String? password) async {
    return _authMethod(email, password, 'signInWithPassword');
  }

  Future<void> logout() async {
    _userId = null;
    _token = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void autoLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }
    final exDuration = _expiryDate?.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: exDuration!), logout);
  }
}
