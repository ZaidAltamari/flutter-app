import "dart:convert";
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter/material.dart";
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import '../screens/product_overview_screen.dart';
import '../screens/verify.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  // String get userId2 {
  //   return _userId;
  // }

  void _setEmailVerified(bool value) {
    _emailVerified = value;
    notifyListeners();
  }

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
      print("zah zah");
      throw e;
    }
  }

  Future<void> signUp(String email, String password, context) async {
    // Authenticate the user
    await _authenticate(email, password, 'signUp');

    // Send the email verification
    await sendEmailVerification();

    // Fetch the latest email verification status
    await fetchEmailVerificationStatus();

    // Now navigate to the appropriate screen based on the fetched status
    if (isEmailVerified) {
      await Navigator.of(context)
          .pushReplacementNamed(ProductOverviewScreen.routeName);
    } else {
      await Navigator.of(context)
          .pushReplacementNamed(VerificationScreen.routeName);
    }
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
      print("allah allah");
      throw e;
    }
  }

  bool _emailVerified = false;

  bool get isEmailVerified {
    return _emailVerified;
  }

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
    // Add print statements before and after the assignment of _emailVerified
    if (responseData['users'] != null) {
      final user = responseData['users'][0];
      _emailVerified = user['emailVerified'];
      print('_emailVerified: $_emailVerified');
      notifyListeners(); // to rebuild widgets using this provider
    } else {
      _emailVerified = false;
      print('_emailVerified: $_emailVerified');
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

  Future<void> login(String email, String password, context) async {
    await _authenticate(email, password, 'signInWithPassword');
    await fetchEmailVerificationStatus();

    if (!_emailVerified) {
      return await Navigator.of(context)
          .pushReplacementNamed(VerificationScreen.routeName);
    } else {
      return await Navigator.of(context)
          .pushReplacementNamed(ProductOverviewScreen.routeName);
    }
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
