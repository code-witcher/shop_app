import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/order_provider.dart';
import 'package:shop_app/widgets/app_drawer.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({Key? key}) : super(key: key);

  static const routeName = '/order-screen';

  @override
  Widget build(BuildContext context) {
    // final authData = Provider.of<Auth>(context);
    // final orderData = Provider.of<OrderProvider>(context).orders;
    print('Order Builder');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<OrderProvider>(
          context,
          listen: false,
        ).fetchOrders(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              child: Consumer<OrderProvider>(
                builder: (ctx, orderData, child) => ListView.builder(
                  itemBuilder: (ctx, i) => CardOrder(i, orderData.orders),
                  itemCount: orderData.orders.length,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class CardOrder extends StatefulWidget {
  const CardOrder(this.i, this.orderData, {Key? key}) : super(key: key);

  final int i;
  final List<Order> orderData;

  @override
  State<CardOrder> createState() => _CardOrderState();
}

class _CardOrderState extends State<CardOrder> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('\$${widget.orderData[widget.i].amount}'),
            subtitle: Text(DateFormat('dd/MM/yyy - hh:mm a')
                .format(widget.orderData[widget.i].date)),
            trailing: IconButton(
              icon: expanded
                  ? const Icon(Icons.expand_less)
                  : const Icon(Icons.expand_more),
              onPressed: () {
                setState(() {
                  expanded = !expanded;
                });
              },
            ),
          ),
          if (expanded)
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),
              height: min(
                  widget.orderData[widget.i].products.length * 20.0 + 40, 150),
              child: ListView(
                children: widget.orderData[widget.i].products
                    .map(
                      (product) => ListTile(
                        title: Text(product.title),
                        trailing:
                            Text('${product.quantity}x  \$${product.price}'),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
