import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/http_exception.dart';
import 'product.dart';

class Products with ChangeNotifier {
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> _items = [];

  Product findById(String id) {
    return items.firstWhere((element) => element.id == id);
  }

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((element) => element.isFavorite == true).toList();
    // } else {
    return [..._items];
    // }
  }

  List<Product> get favoriteOnly {
    return _items.where((element) => element.isFavorite).toList();
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts( [bool filterByUser = false] ) async {
    final filter = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    try {
      var url = Uri.parse(
          'https://helloworld-a533b-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filter');
      final response = await http.get(url);
      final prodData = json.decode(response.body) as Map<String, dynamic>;

      if (prodData == null) {
        return;
      }

      url = Uri.parse(
        'https://helloworld-a533b-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
      
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      
      final List<Product> loadedProducts = [];
      prodData.forEach(
        (key, value) {
          loadedProducts.add(
            Product(
              id: key,
              title: value['title'],
              description: value['description'],
              price: value['price'],
              imageUrl: value['imageUrl'],
              isFavorite: favoriteData == null? false : favoriteData[key] ?? false,
            ),
          );
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://helloworld-a533b-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.post(url,
          body: json.encode(
            {
              'title': product.title,
              'description': product.description,
              'price': product.price,
              'imageUrl': product.imageUrl,
              'creatorId': userId,
            },
          ));
      final _newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
      );
      _items.add(_newProduct);

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    final url = Uri.parse(
        'https://helloworld-a533b-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    await http.patch(
      url,
      body: json.encode({
        'title': newProduct.title,
        'description': newProduct.description,
        'price': newProduct.price,
        'imageUrl': newProduct.imageUrl
      }),
    );

    _items[prodIndex] = newProduct;

    notifyListeners();
  }

  Future<void> removeProduct(String id) async {
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    final url = Uri.parse(
        'https://helloworld-a533b-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      HttpException('There was an error ');
      _items.insert(existingProductIndex, existingProduct);

      notifyListeners();
    }
    existingProduct = null;
  }
}
