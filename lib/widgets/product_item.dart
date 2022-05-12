import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth_provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/screens/product_details_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentProduct = Provider.of<Product>(context);
    final cartData = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailsScreen.routeName,
              arguments: currentProduct.id,
            );
          },
          child: Image.network(
            currentProduct.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        header: Container(
          alignment: AlignmentDirectional.topEnd,
          // this widget is a replacement for Provider.
          // only it's child widget will be rebuilt whenever the data change.
          child: Consumer<Product>(
            builder: (ctx, product, child) => IconButton(
              icon: Icon(
                currentProduct.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () async {
                try {
                  await product.toggleFavorite(
                    authData.token,
                    authData.userId,
                  );
                  Fluttertoast.cancel();
                  Fluttertoast.showToast(
                      msg: currentProduct.isFavorite
                          ? 'Done added one product to favorites'
                          : 'Removed from favorites successfully');
                } catch (e) {
                  print(
                      'error adding product to favorites product item file $e');
                  Fluttertoast.cancel();
                  Fluttertoast.showToast(
                      msg: currentProduct.isFavorite
                          ? 'Fail to remove from favorites'
                          : 'Fail to add to favorites');
                }
              },
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: IconButton(
            icon: Icon(
              Icons.add_shopping_cart,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {
              cartData.addItem(
                productId: currentProduct.id,
                title: currentProduct.title,
                price: currentProduct.price,
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Add item to the Cart!'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      cartData.removeOneItem(currentProduct.id);
                    },
                  ),
                ),
              );
              // Scaffold.of(context).hideCurrentSnackBar();
              // Scaffold.of(context).showSnackBar(
              //   SnackBar(
              //     content: const Text('Add item to the Cart!'),
              //     duration: const Duration(seconds: 2),
              //     action: SnackBarAction(
              //       label: 'Undo',
              //       onPressed: () {
              //         cartData.removeOneItem(currentProduct.id);
              //       },
              //     ),
              //   ),
              // );
            },
          ),
          title: GestureDetector(
            child: Text(currentProduct.title),
            onTap: () {
              Navigator.of(context).pushNamed(
                ProductDetailsScreen.routeName,
                arguments: currentProduct.id,
              );
            },
          ),
          trailing: Text(
            '\$${currentProduct.price}',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
