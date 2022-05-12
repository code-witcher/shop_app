import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/modal/http_exeption.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final double price;
  final String description;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.description,
    required this.imageUrl,
    this.isFavorite = false,
    required this.price,
    required this.title,
  });

  Future<void> toggleFavorite(String? token, String? userId) async {
    final url = Uri.parse(
      'https://shop-app-c5530-default-rtdb.firebaseio.com/'
      'user-favorites/$userId/$id.json?auth=$token',
    );
    isFavorite = !isFavorite;
    notifyListeners();

    final response = await http.put(url, body: json.encode(isFavorite));

    if (response.statusCode >= 400) {
      isFavorite = !isFavorite;
      notifyListeners();
      throw HttpException(msg: 'Error adding product to favorites');
    }
  }
}
