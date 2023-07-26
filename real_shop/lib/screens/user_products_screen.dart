import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = "/user-products";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Products"), actions: <Widget>[
        IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            }),
      ]),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future:
            Provider.of<Products>(context, listen: false).fetchAndSetProducts(),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        Provider.of<Products>(context, listen: false)
                            .fetchAndSetProducts(),
                    child: Consumer<Products>(
                      builder: (ctx, productsData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: productsData.items.length,
                          itemBuilder: (ctx, i) => Column(
                            children: [
                              UserProductItem(
                                productsData.items[i].id,
                                productsData.items[i].title,
                                productsData.items[i].imageUrl,
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
