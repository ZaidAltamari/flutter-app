// import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/screens/product_overview_screen.dart';

import '../providers/auth.dart';

class VerificationScreen extends StatelessWidget {
  // static const routeName = '/verify-email';
  static const routeName = '/verification';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Your Email'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Please verify your email.'),
            TextButton(
              child: Text('I have verified my Email'),
              onPressed: () async {
                await Provider.of<Auth>(context, listen: false)
                    .fetchEmailVerificationStatus();
                if (Provider.of<Auth>(context, listen: false).isEmailVerified) {
                  Navigator.of(context)
                      .pushReplacementNamed(ProductOverviewScreen.routeName);
                } else {
                  // Show a message to the user that email verification is not complete.
                  // This could be a dialog, a Snackbar, or any other way you'd prefer.
                  print("zzzzzzzzzzzzzzzzzzzzzzzzzzzzz");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
