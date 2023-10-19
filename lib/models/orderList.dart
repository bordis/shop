import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/order.dart';
import 'package:http/http.dart' as http;
import 'package:shop/utils/constants.dart';
import '../models/cart_item.dart';

class OrderList with ChangeNotifier {
  final String? _token;
  final String? _userId;
  List<Order> _itens = [];

  OrderList([this._token = '', this._userId, this._itens = const []]);

  List<Order> get itens => [..._itens];

  final _baseUrl = Constants.ORDER_BASE_URL;

  int get itensCount {
    return _itens.length;
  }

  Future<void> loadOrders() async {
    List<Order> loadedItens = [];
    final response =
        await http.get(Uri.parse('$_baseUrl/$_userId.json?auth=$_token'));
    Map<String, dynamic>? data = json.decode(response.body);
    if (data != null) {
      data.forEach((orderId, orderData) {
        loadedItens.add(
          Order(
            id: orderId,
            date: DateTime.parse(orderData['date']),
            total: orderData['total'],
            products: (orderData['products'] as List<dynamic>).map((item) {
              return CartItem(
                id: item['id'],
                productId: item['productId'],
                name: item['name'],
                quantity: item['quantity'],
                price: item['price'],
              );
            }).toList(),
          ),
        );
      });
      _itens = loadedItens.reversed.toList();
      notifyListeners();
    }
    return Future.value();
  }

  Future<void> addOrder(Cart cart) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$_userId.json?auth=$_token'),
      body: json.encode({
        'total': cart.totalAmount,
        'date': DateTime.now().toIso8601String(),
        'products': cart.itens.values
            .map((cartItem) => {
                  'id': cartItem.id,
                  'productId': cartItem.productId,
                  'name': cartItem.name,
                  'quantity': cartItem.quantity,
                  'price': cartItem.price,
                })
            .toList(),
      }),
    );

    final id = json.decode(response.body)['name'];
    _itens.insert(
      0,
      Order(
        id: id,
        total: cart.totalAmount,
        products: cart.itens.values.toList(),
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
