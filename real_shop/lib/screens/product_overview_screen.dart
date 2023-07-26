import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "package:real_shop/providers/cart.dart";
import "package:real_shop/providers/products.dart";
import "package:real_shop/widgets/app_drawer.dart";
// import "package:real_shop/widgets/badge.dart";
import 'package:real_shop/widgets/badge.dart' as myBadge;

import '../widgets/products_grid.dart';
import './cart_screen.dart';

enum FilterOptions { Favorites, All }

class ProductOverviewScreen extends StatefulWidget {
  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _isLoading = false;
  var _showOnlyFavorites = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _isLoading = true;
    });
    Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts()
        .then(
          (_) => setState(
            () => _isLoading = false,
          ),
        )
        .catchError((error) => setState(() => _isLoading = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My shop"), actions: [
        PopupMenuButton(
          onSelected: (FilterOptions selectedValue) {
            setState(() {
              if (selectedValue == FilterOptions.Favorites) {
                _showOnlyFavorites = true;
              } else {
                _showOnlyFavorites = false;
              }
            });
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
        Consumer<Cart>(
          child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              }),
          builder: (_, cart, ch) => myBadge.Badge(
            child: ch,
            value: cart.itemCount.toString(),
          ),
        )
      ]),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(_showOnlyFavorites),
      drawer: AppDrawer(),
    );
  }
}
