import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/order_provider.dart';

class CartItemScreen extends StatelessWidget {
  const CartItemScreen({Key? key}) : super(key: key);

  static const routeName = '/cart-item-screen';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final cartItem = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    backgroundColor: Theme.of(context).accentColor,
                    label: Text(
                      cart.totalPrice.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  OrderButton(cart),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (ctx, i) => Dismissible(
                  key: ValueKey(cartItem[i].id),
                  background: Container(
                    padding: const EdgeInsets.all(10),
                    color: Theme.of(context).errorColor,
                    child: const Text('remove'),
                    alignment: AlignmentDirectional.centerEnd,
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    cart.removeItem(cart.items.keys.toList()[i]);
                  },
                  child: Card(
                    elevation: 4,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: FittedBox(
                            child: Text('\$${cartItem[i].price}'),
                          ),
                        ),
                      ),
                      title: Text(cartItem[i].title),
                      subtitle: Text(
                        'Total: ${cartItem[i].quantity * cartItem[i].price}',
                      ),
                      trailing: Text('${cartItem[i].quantity}x'),
                    ),
                  ),
                  confirmDismiss: (dismissDirection) {
                    return showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Are you sure?!'),
                        content: const Text('Do you want to remove this item'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop(true);
                            },
                            child: const Text('Yes'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop(false);
                            },
                            child: const Text('No'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                itemCount: cartItem.length,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAboutDialog(
            context: context,
            children: [
              const Text('Hello in my secret world'),
            ],
          );
        },
        child: const Icon(Icons.info_outline),
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton(this.cart, {Key? key}) : super(key: key);
  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onLongPress: (widget.cart.totalPrice <= 0 || _isLoading)
          ? null
          : () {
              Fluttertoast.cancel();
              Fluttertoast.showToast(msg: 'Don\'t tab to long idiot');
            },
      onPressed: (widget.cart.totalPrice <= 0 || _isLoading)
          ? null
          : () async {
              try {
                if (widget.cart.totalPrice != 0) {
                  setState(() {
                    _isLoading = true;
                  });
                  await Provider.of<OrderProvider>(
                    context,
                    listen: false,
                  ).addOrder(
                    amount: widget.cart.totalPrice,
                    carts: widget.cart.items.values.toList(),
                  );
                  setState(() {
                    _isLoading = false;
                  });
                  widget.cart.clear();
                  Fluttertoast.cancel();
                  Fluttertoast.showToast(
                      msg: 'Items added to orders successfully');
                }
              } catch (e) {
                print('error occurred on adding order on CartItemScreen');
                Fluttertoast.cancel();
                Fluttertoast.showToast(msg: 'error adding order');
              }
            },
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text('ORDER NOW'),
    );
  }
}
