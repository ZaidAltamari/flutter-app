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
  static const routeName = '/';

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _isLoading = false;
  var _showOnlyFavorites = false;
  var _isProductLoading = false;
  var _isDisposed = false;

  void fetchAndSetProducts() async {
    if (_isDisposed) return;
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts()
        .then((_) {
      if (_isDisposed) return;

      setState(() {
        _isLoading = false;
        _isProductLoading = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAndSetProducts();
  }

  @override
  void dispose() {
    super.dispose();
    _isDisposed = true;
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
      body: _isLoading == true
          ? Center(child: CircularProgressIndicator())
          : _isProductLoading
              ? ProductsGrid(_showOnlyFavorites)
              : Center(child: Text("Loading...")),
      // body: Center(child: CircularProgressIndicator()),

      drawer: AppDrawer(),
    );
  }

  // void setState() {
  //   if (mounted) {
  //     super.setState();
  //   }
  // }
}
