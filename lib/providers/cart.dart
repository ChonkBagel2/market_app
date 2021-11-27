import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.quantity,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  List<CartItem> _itemsAsList = [];

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var amount = 0.0;
    _items.forEach((key, item) {
      amount += item.price * item.quantity;
    });
    return amount;
  }

  void addItem(String productId, String title, double price) {
    if (_items.containsKey(productId)) {
      // add with quantity more
      _items.update(
        productId,
        (existingCartItem) => CartItem(
            id: existingCartItem.id,
            title: existingCartItem.title,
            price: existingCartItem.price,
            quantity: existingCartItem.quantity + 1),
      );
    } else {
      // add with quantity 1
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }

    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (_items[productId].quantity > 1) {
      _items.update(
        productId,
        (prod) => CartItem(
            id: prod.id,
            title: prod.title,
            price: prod.price,
            quantity: prod.quantity - 1),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }
}
