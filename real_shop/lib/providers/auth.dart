import "dart:convert";
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import '../screens/verify.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  // bool get isEmailVerified {
  //   return true;
  // }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAgxjGMH8T9Ltgb8xGpxUi84xVC0h5jEd4';

    try {
      final res = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(res.body);
      if (responseData['error'] != null) {
        // throw HttpException(responseData['error']['message']);
        return throw HttpException(responseData['error']['message']);
        // print(HttpException(responseData['error']['message']));
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(Duration(
          seconds: int.parse(
        responseData['expiresIn'],
      )));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signUp(String email, String password, context) async {
    await _authenticate(email, password, 'signUp');
    await sendEmailVerification();

    // Navigate to verification screen
    Navigator.of(context).pushReplacementNamed(VerificationScreen.routeName);

    return null;
    // await sendEmailVerification();
    // await deleteUser();
  }

  Future<void> sendEmailVerification() async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=AIzaSyAgxjGMH8T9Ltgb8xGpxUi84xVC0h5jEd4';
    try {
      final res = await http.post(
        url,
        body: json.encode(
          {
            'requestType': 'VERIFY_EMAIL',
            'idToken': _token,
          },
        ),
      );
      final responseData = json.decode(res.body);
      print(responseData); // After final responseData = json.decode(res.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  bool _emailVerified = false;

  bool get isEmailVerified {
    return _emailVerified;
  }

// This method should be called any time you want to check if the email has been verified
  Future<void> fetchEmailVerificationStatus() async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=AIzaSyAgxjGMH8T9Ltgb8xGpxUi84xVC0h5jEd4';

    final response = await http.post(
      url,
      body: json.encode({
        'idToken': _token,
      }),
    );

    final responseData = json.decode(response.body);
    if (responseData['users'] != null) {
      final user = responseData['users'][0];
      _emailVerified = user['emailVerified'];
      notifyListeners(); // to rebuild widgets using this provider
    } else {
      _emailVerified = false;
      notifyListeners(); // to rebuild widgets using this provider
    }
  }

  Future<void> deleteUser() async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:delete?key=AIzaSyAgxjGMH8T9Ltgb8xGpxUi84xVC0h5jEd4';
    try {
      final res = await http.post(
        url,
        body: json.encode(
          {
            'idToken': _token,
          },
        ),
      );
      final responseData = json.decode(res.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
