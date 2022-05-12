import 'package:flutter/cupertino.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.price,
    required this.title,
    required this.quantity,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _carts = {};

  String? _token;

  void update(String? token, Map<String, CartItem> carts) {
    _carts = carts;
    _token = token;
  }

  Map<String, CartItem> get items {
    return {..._carts};
  }

  void addItem({
    required String productId,
    required String title,
    required double price,
  }) {
    if (_carts.containsKey(productId)) {
      // Increase the quantity
      _carts.update(
          productId,
          (oldValue) => CartItem(
                id: oldValue.id,
                price: oldValue.price,
                title: oldValue.title,
                quantity: oldValue.quantity + 1,
              ));
    } else {
      _carts.putIfAbsent(
          productId,
          () => CartItem(
                id: DateTime.now().toString(),
                price: price,
                title: title,
                quantity: 1,
              ));
    }
    notifyListeners();
  }

  int get itemCount {
    int count = 0;
    _carts.forEach((key, value) {
      count += value.quantity;
    });
    return count;
  }

  double get totalPrice {
    double total = 0;
    _carts.forEach((key, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  void removeItem(String? productId) {
    _carts.remove(productId);
    notifyListeners();
  }

  void removeOneItem(String productId) {
    if (!_carts.containsKey(productId)) {
      return;
    }
    if (_carts[productId]!.quantity > 1) {
      _carts.update(
        productId,
        (currentValue) => CartItem(
          id: currentValue.id,
          price: currentValue.price,
          title: currentValue.title,
          quantity: currentValue.quantity - 1,
        ),
      );
    } else {
      _carts.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _carts = {};
    notifyListeners();
  }
}
