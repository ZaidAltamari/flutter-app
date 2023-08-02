// import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/screens/product_overview_screen.dart';

import '../providers/auth.dart';

// class VerificationScreen extends StatefulWidget {
//   static const routeName = '/verification';

//   @override
//   _VerificationScreenState createState() => _VerificationScreenState();
// }

// class _VerificationScreenState extends State<VerificationScreen> {
//   Timer _timer;

//   @override
//   void initState() {
//     super.initState();
//     // Check if the email is verified every 2 seconds
//     _timer = Timer.periodic(Duration(seconds: 2), (timer) async {
//       // Replace this with your actual method to check if the email is verified
//       if (await Provider.of<Auth>(context, listen: false).isEmailVerified) {
//         // Cancel the timer as we don't need to check email verification anymore
//         _timer.cancel();
//         // Wait for 5 seconds and then navigate to ProductOverviewScreen
//         await Future.delayed(Duration(seconds: 5));
//         Navigator.of(context)
//             .pushReplacementNamed(ProductOverviewScreen.routeName);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     if (_timer.isActive) {
//       _timer.cancel();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Center(
//           child: Text(
//         'An email has just been sent to you, Click the link provided to complete registration',
//         style: TextStyle(color: Colors.white, fontSize: 16),
//       )),
//     );
//   }
// }

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
