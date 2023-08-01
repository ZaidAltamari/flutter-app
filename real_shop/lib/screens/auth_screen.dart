import "dart:io";
import "dart:math";

import "package:flutter/material.dart";
// import "package:provider/provider.dart";
// import 'package:firebase_auth/firebase_auth.dart';
import "package:provider/provider.dart";
import 'package:firebase_auth/firebase_auth.dart';

import "../providers/auth.dart";

class AuthScreen extends StatelessWidget {
  static const routeName = "/auth";

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
            colors: [
              Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
              Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, 1],
          ))),
          SingleChildScrollView(
              child: Container(
                  height: deviceSize.height,
                  width: deviceSize.width,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                            child: Container(
                          margin: EdgeInsets.only(bottom: 20.0),
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 94.0),
                          transform: Matrix4.rotationZ(-8 * pi / 180)
                            ..translate(-10.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.deepOrange.shade900,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 8,
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                )
                              ]),
                          child: Text("My Shop",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                fontFamily: 'Anton',
                                fontWeight: FontWeight.bold,
                              )),
                        )),
                        Flexible(
                          flex: deviceSize.width > 600 ? 2 : 1,
                          child: AuthCard(),
                        )
                      ])))
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  State<AuthCard> createState() => _AuthCardState();
}

enum AuthMode { signUp, Login }

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    "email": "",
    "password": "",
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController _controller;

  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _isMounted = false;

    super.dispose();
  }

  var errorMessage = 'Authentication failed';

  Future<void> submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false)
            .login(_authData['email'], _authData['password']);
      } else {
        print("zaid");
        // Provider.of<Auth>(context, listen: false).sendEmailVerification();
        // Check if the email is verified
        // User user = FirebaseAuth.instance.currentUser;
        // if (user != null && user.emailVerified) {
        await Provider.of<Auth>(context, listen: false)
            .signUp(_authData['email'], _authData['password']);
        // } else {
        //   // Show some message to tell user to verify email first
        //   _showErrorDialog('Please verify your email before signing up.');
        // }
      }
    } on HttpException catch (error) {
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password';
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      // For other types of exceptions
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      print('The error is $e');
      _showErrorDialog(errorMessage);
    }

    if (_isMounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.signUp;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
          height: _authMode == AuthMode.signUp ? 320 : 360,
          width: deviceSize.width * 0.75,
          constraints: BoxConstraints(
            minHeight: _authMode == AuthMode.signUp ? 320 : 360,
          ),
          padding: EdgeInsets.all(16.0),
          child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: "E-Mail"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty || !value.contains("@")) {
                        return "Invalid email!";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      _authData['email'] = val;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: "Password"),
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value.isEmpty || value.length < 5) {
                        return "Password is too short!";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      _authData['password'] = val;
                    },
                  ),
                  AnimatedContainer(
                    constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.Login ? 60 : 60,
                      maxHeight: _authMode == AuthMode.Login ? 120 : 120,
                    ),
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: TextFormField(
                          enabled: _authMode == AuthMode.signUp,
                          decoration:
                              InputDecoration(labelText: "Confirm Password"),
                          obscureText: true,
                          validator: _authMode == AuthMode.signUp
                              ? (value) {
                                  if (value != _passwordController.text) {
                                    return "Passwords do not match!";
                                  }
                                  return null;
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : Column(
                          children: <Widget>[
                            ElevatedButton(
                              child: Text(_authMode == AuthMode.Login
                                  ? "LOGIN"
                                  : "SIGN UP"),
                              onPressed: submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .primaryColor, // Set the background color
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30.0, vertical: 8.0),
                              ),
                            ),
                            TextButton(
                                child: Text(
                                  '${_authMode == AuthMode.Login ? "signUp" : "LOGIN"} INSTEAD',
                                ),
                                onPressed: _switchAuthMode,
                                style: TextButton.styleFrom(
                                  // backgroundColor: Theme.of(context)
                                  //     .primaryColor, // Set the background color
                                  foregroundColor:
                                      Theme.of(context).primaryColor,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30.0, vertical: 4),
                                )),
                          ],
                        ),
                ],
              )))),
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
          title: Text('An Error Occurred!'),
          content: Text(errorMessage),
          actions: [
            TextButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                }),
          ]),
    );
  }
}
