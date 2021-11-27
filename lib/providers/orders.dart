import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime datetime;

  OrderItem({this.id, this.amount, this.products, this.datetime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://helloworld-a533b-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final response = await http.get(url);

    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if(extractedData == null){
      return;
    }

    extractedData.forEach(
      (orderId, orderData) {
        loadedOrders.add(
          OrderItem(
              id: orderId,
              amount: orderData['amount'],
              datetime: DateTime.parse(orderData['datetime']),
              products: (orderData['products'] as List<dynamic>)
                  .map((value) => CartItem(
                        id: value['id'],
                        price: value['price'],
                        quantity: value['quantity'],
                        title: value['title'],
                      ))
                  .toList()),
        );
      },
    );
    _orders = loadedOrders.reversed.toList();
    notifyListeners();


  }

  Future<void> addOrder(List<CartItem> products, double total) async {
    final url = Uri.parse(
        'https://helloworld-a533b-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final timestamp = DateTime.now();

    final response = await http.post(
      url,
      body: json.encode(
        {
          'amount': total,
          'datetime': timestamp.toIso8601String(),
          'products': products
              .map(
                (prod) => {
                  'id': prod.id,
                  'title': prod.title,
                  'price': prod.price,
                  'quantity': prod.quantity
                },
              )
              .toList()
        },
      ),
    );
    _orders.insert(
      0,
      OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          products: products,
          datetime: timestamp),
    );
    notifyListeners();
  }
}
