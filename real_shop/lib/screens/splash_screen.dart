import "package:flutter/material.dart";

class SplashScreen extends StatelessWidget {
  static const routeName = "/SplashScreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Loading...")),
    );
  }
}
