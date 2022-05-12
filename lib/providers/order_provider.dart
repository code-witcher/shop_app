import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/providers/cart_provider.dart';

class Order {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime date;

  Order({
    required this.id,
    required this.amount,
    required this.date,
    required this.products,
  });
}

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  String? _token;
  String? _userId;

  void update(String? token, String? userId, List<Order> orders) {
    _orders = orders;
    _token = token;
    _userId = userId;
  }

  List<Order> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    final url = Uri.parse(
        'https://shop-app-c5530-default-rtdb.firebaseio.com/orders/$_userId.json?'
        'auth=$_token');
    try {
      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) return;
      final List<Order> _loadedOrders = [];
      data.forEach(
        (orderId, value) {
          _loadedOrders.insert(
            0,
            Order(
              id: orderId,
              amount: value['amount'],
              date: DateTime.parse(value['date']),
              products: (value['carts'] as List<dynamic>).map(
                (item) {
                  return CartItem(
                    id: item['id'],
                    price: item['price'],
                    title: item['title'],
                    quantity: item['quantity'],
                  );
                },
              ).toList(),
            ),
          );
        },
      );
      _orders = _loadedOrders;
    } catch (e) {
      print('error fetching data on OrderProvider file: $e');
      rethrow;
    }
  }

  Future<void> addOrder(
      {required double amount, required List<CartItem> carts}) async {
    final url = Uri.parse(
        'https://shop-app-c5530-default-rtdb.firebaseio.com/orders/$_userId.json?'
        'auth=$_token');

    try {
      final response = await http.post(url,
          body: json.encode(<String, dynamic>{
            'amount': amount,
            'carts': carts
                .map((cartItem) => {
                      'id': cartItem.id,
                      'title': cartItem.title,
                      'price': cartItem.price,
                      'quantity': cartItem.quantity,
                    })
                .toList(),
            'date': DateTime.now().toIso8601String(),
          }));

      _orders.insert(
        0,
        Order(
          id: json.decode(response.body)['name'],
          amount: amount,
          date: DateTime.now(),
          products: carts,
        ),
      );
      notifyListeners();
    } catch (e) {
      print('Error adding an order on OrderProvider: $e');
      rethrow;
    }
  }
}
