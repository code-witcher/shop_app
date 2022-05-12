import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/product_provider.dart';
import 'package:shop_app/screens/cart_items_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';

import '../widgets/product_grid.dart';

enum FilterOptions { all, favorite }

class ProductOverViewScreen extends StatefulWidget {
  const ProductOverViewScreen({Key? key}) : super(key: key);
  static const routeName = '/products_overview';

  @override
  State<ProductOverViewScreen> createState() => _ProductOverViewScreenState();
}

class _ProductOverViewScreenState extends State<ProductOverViewScreen> {
  var _showFavorite = false;
  var _isLoading = false;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });

    Provider.of<ProductProvider>(context, listen: false).fetchProducts().then(
          (_) => setState(() {
            _isLoading = false;
          }),
        );
    super.initState();
  }

  Future<void> _refresh() async {
    try {
      Provider.of<ProductProvider>(
        context,
        listen: false,
      ).fetchProducts();
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: const Text('My Shop'),
        actions: [
          PopupMenuButton(
            onSelected: (selectedValue) => setState(() {
              if (selectedValue == FilterOptions.favorite) {
                _showFavorite = true;
              } else {
                _showFavorite = false;
              }
            }),
            // icon: Icon(Icons.more_vert),
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                child: Text('All'),
                value: FilterOptions.all,
              ),
              const PopupMenuItem(
                child: Text('Favorites'),
                value: FilterOptions.favorite,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (ctx, cartData, ch) {
              return Badge(
                child: ch!,
                value: cartData.itemCount.toString(),
                color: Colors.cyan,
              );
            },
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartItemScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).accentColor,
              ),
            )
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ProductGrid(_showFavorite),
            ),
    );
  }
}
