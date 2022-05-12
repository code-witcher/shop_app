import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product_provider.dart';
import 'package:shop_app/screens/edit_product.dart';
import 'package:shop_app/widgets/app_drawer.dart';

class UserProducts extends StatelessWidget {
  const UserProducts({Key? key}) : super(key: key);

  static const routeName = '/user-products';

  Future<void> _refresh(BuildContext context) async {
    try {
      await Provider.of<ProductProvider>(
        context,
        listen: false,
      ).fetchProducts(
        filter: true,
      );
    } catch (e) {
      print('Error in manage_user_products $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // final authData = Provider.of<Auth>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refresh(context),
        builder: (ctx, snapShot) =>
            snapShot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refresh(context),
                    // using consumer instead of provider to avoid infinite loop of rebuilding
                    child: Consumer<ProductProvider>(
                      builder: (ctx, products, child) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: products.items.length,
                          itemBuilder: (ctx, i) => UserProductWidget(
                            products.items[i].title,
                            products.items[i].imageUrl,
                            products.items[i].id,
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}

class UserProductWidget extends StatelessWidget {
  const UserProductWidget(this.title, this.imageUrl, this.id, {Key? key})
      : super(key: key);

  final String imageUrl;
  final String title;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl),
          ),
          title: Text(title),
          trailing: Container(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(EditProductScreen.routeName, arguments: id);
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).accentColor,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    try {
                      await Provider.of<ProductProvider>(context, listen: false)
                          .deleteProduct(id);
                      Fluttertoast.showToast(
                          msg: 'Product deleted successfully');
                    } catch (e) {
                      Fluttertoast.showToast(msg: 'Failed to delete');
                    }
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).errorColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(
          indent: 20,
        ),
      ],
    );
  }
}
