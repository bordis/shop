import 'package:flutter/material.dart';
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/product.dart';

class Cart with ChangeNotifier {
  Map<String, CartItem> _itens = {};

  Map<String, CartItem> get itens {
    return {..._itens}; //retorna uma cópia dos itens
  }

  void removeItem(String productId) {
    _itens.remove(productId);
    notifyListeners();
  }

  void clear() {
    _itens = {};
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_itens.containsKey(productId)) {
      return;
    }
    if (_itens[productId]!.quantity > 1) {
      _itens.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          productId: existingCartItem.productId,
          name: existingCartItem.name,
          quantity: existingCartItem.quantity - 1,
          price: existingCartItem.price,
        ),
      );
    } else {
      _itens.remove(productId);
    }
    notifyListeners();
  }

  int get itemCount {
    return _itens.length;
  }

  double get totalAmount {
    var total = 0.0;
    _itens.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(Product product) {
    if (_itens.containsKey(product.id)) {
      _itens.update(
        product.id,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          productId: product.id,
          name: existingCartItem.name,
          quantity: existingCartItem.quantity + 1,
          price: existingCartItem.price,
        ),
      );
    } else {
      _itens.putIfAbsent(
        product.id,
        () => CartItem(
          id: DateTime.now().toString(),
          productId: product.id,
          name: product.name,
          quantity: 1,
          price: product.price,
        ),
      );
    }
    notifyListeners();
  }
}
