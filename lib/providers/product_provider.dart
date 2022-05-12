import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/modal/http_exeption.dart';

import 'product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [];
  String? _token;
  String? _userId;

  void update(String? token, String? userId, List<Product> items) {
    _items = items;
    _token = token;
    _userId = userId;
  }

  Future<void> fetchProducts({bool filter = false}) async {
    final filterSegment =
        filter ? 'orderBy="creatorId"&equalTo="$_userId"' : '';

    var url = Uri.parse('https://shop-app-c5530-default-rtdb.firebaseio.com/'
        'products.json?auth=$_token&$filterSegment');
    try {
      final response = await http.get(url);
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data == null) return;

      url = Uri.parse('https://shop-app-c5530-default-rtdb.firebaseio.com/'
          'user-favorites/$_userId.json?auth=$_token');
      final favResponse = await http.get(url);
      final favoritesData = json.decode(favResponse.body);

      final List<Product> _loadedProd = [];
      data.forEach((prodId, value) {
        _loadedProd.add(
          Product(
            id: prodId,
            description: value['description'],
            imageUrl: value['imageUrl'],
            price: value['price'],
            title: value['title'],
            isFavorite:
                favoritesData == null ? false : favoritesData[prodId] ?? false,
          ),
        );
      });
      _items = _loadedProd;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favorites {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shop-app-c5530-default-rtdb.firebaseio.com/products.json?'
        'auth=$_token');
    http
        .post(
      url,
      body: json.encode({
        'title': product.title,
        'price': product.price,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'creatorId': _userId,
      }),
    )
        .then((response) {
      _items.add(Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
      ));
      notifyListeners();
    });
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    int proIndex = _items.indexWhere((element) => element.id == id);
    if (proIndex >= 0) {
      final url = Uri.parse(
        'https://shop-app-c5530-default-rtdb.firebaseio.com/products/'
        '$id.json?auth=$_token',
      );
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));
      _items[proIndex] = newProduct;
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
      'https://shop-app-c5530-default-rtdb.firebaseio.com/products/$id.json?auth=$_token',
    );
    final excitingIndex = _items.indexWhere((product) => product.id == id);
    dynamic exciting = _items[excitingIndex];
    _items.removeAt(excitingIndex);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(excitingIndex, exciting);
      notifyListeners();
      throw HttpException(msg: 'Delete Failed');
    }
    exciting = null;
  }
}
