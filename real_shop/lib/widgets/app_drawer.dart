import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:real_shop/providers/auth.dart";
import "package:real_shop/screens/user_products_screen.dart";
import "package:real_shop/screens/orders_screen.dart";

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(children: [
      AppBar(
        title: Text("Hello"),
        automaticallyImplyLeading: false,
      ),
      Divider(),
      ListTile(
        leading: Icon(Icons.shop),
        title: Text("shop"),
        onTap: () => Navigator.of(context).pushReplacementNamed('/'),
      ),
      Divider(),
      ListTile(
        leading: Icon(Icons.payment),
        title: Text("Order"),
        onTap: () =>
            Navigator.of(context).pushReplacementNamed(OrderScreen.routeName),
      ),
      Divider(),
      ListTile(
        leading: Icon(Icons.edit),
        title: Text("Manage Products"),
        onTap: () => Navigator.of(context)
            .pushReplacementNamed(UserProductsScreen.routeName),
      ),
      Divider(),
      ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text("Logout"),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/');
            Provider.of<Auth>(context, listen: false).logout();
          }),
    ]));
  }
}
