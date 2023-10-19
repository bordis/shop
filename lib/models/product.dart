import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/utils/constants.dart';

class Product with ChangeNotifier {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  final _baseUrl = Constants.USER_FAVORITES_URL;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  _toglefavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  Future<void> toggleFavorite(String token, String userId) async {
    try {
      _toglefavorite();

      final response = await http.put(
        Uri.parse('$_baseUrl/$userId/$id.json?auth=$token'),
        body: json.encode(isFavorite),
      );
      if (response.statusCode >= 400) {
        _toglefavorite();
      }
    } catch (_) {
      _toglefavorite();
    }
  }
}
