// import 'package:flutter/cupertino.dart';
// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_shop/screens/product_overview_screen.dart';

import '../providers/auth.dart';
import '../widgets/products_grid.dart';
// import 'package:provider/provider.dart';
// import 'package:real_shop/screens/product_overview_screen.dart';

// import '../providers/auth.dart';

class TestScreen extends StatelessWidget {
  // static const routeName = '/verify-email';
  static const routeName = '/testScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My shop"), actions: [
        PopupMenuButton(
          onSelected: (FilterOptions selectedValue) {
            // setState(() {
            //   if (selectedValue == FilterOptions.Favorites) {
            //     _showOnlyFavorites = true;
            //   } else {
            //     _showOnlyFavorites = false;
            //   }
            // });
          },
          icon: Icon(Icons.more_vert),
          itemBuilder: (_) => [
            PopupMenuItem(
              child: Text("Only Favorites"),
              value: FilterOptions.Favorites,
            ),
            PopupMenuItem(
              child: Text("Show All"),
              value: FilterOptions.All,
            ),
          ],
        ),
        // Consumer<Cart>(
        //   child: IconButton(
        //       icon: Icon(Icons.shopping_cart),
        //       onPressed: () {
        //         Navigator.of(context).pushNamed(CartScreen.routeName);
        //       }),
        //   builder: (_, cart, ch) => myBadge.Badge(
        //     child: ch,
        //     value: cart.itemCount.toString(),
        //   ),
        // )
      ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ProductsGrid(true),
            TextButton(
              child: Text('Click'),
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
