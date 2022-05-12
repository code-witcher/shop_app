import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './product_item.dart';
import '../providers/product_provider.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid(this.showFavorites, {Key? key}) : super(key: key);
  final bool showFavorites;

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductProvider>(context);
    final productsData =
        showFavorites ? productsProvider.favorites : productsProvider.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: productsData[i],
        child: const ProductItem(),
      ),
      itemCount: productsData.length,
    );
  }
}
