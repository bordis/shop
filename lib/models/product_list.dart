import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:shop/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:shop/utils/constants.dart';

class ProductList with ChangeNotifier {
  final String _token;
  final String _userId;
  List<Product> _itens = [];

  final _baseUrl = Constants.PRODUCT_BASE_URL;
  final _baseUrlFavorites = Constants.USER_FAVORITES_URL;

  List<Product> get itens => [..._itens];

  List<Product> get favoriteItens {
    return _itens.where((prod) => prod.isFavorite).toList();
  }

  ProductList([this._token = '', this._userId = '', this._itens = const []]);

  Future<void> saveProductFromForm(Map<String, Object> formData) {
    bool hasId = formData.containsKey('id');
    final newProduct = Product(
      id: hasId ? formData['id'] as String : Random().nextDouble().toString(),
      name: formData['name'] as String,
      price: formData['price'] as double,
      description: formData['description'] as String,
      imageUrl: formData['imageUrl'] as String,
    );
    if (hasId) {
      return updateProduct(newProduct);
    } else {
      return addProduct(newProduct);
    }
  }

  Future<void> updateProduct(Product product) async {
    if (product.id.trim().isNotEmpty) {
      final index = _itens.indexWhere((prod) => prod.id == product.id);
      if (index >= 0) {
        await http.patch(
          Uri.parse('$_baseUrl/${product.id}.json?auth=$_token'),
          body: json.encode({
            'name': product.name,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
          }),
        );
        _itens[index] = product;
        notifyListeners();
      }
    }
    return Future.value();
  }

  Future<void> deleteProduct(Product product) async {
    final index = _itens.indexWhere((prod) => prod.id == product.id);

    if (index >= 0) {
      final product = _itens[index];
      _itens.removeWhere((prod) => prod.id == product.id);
      notifyListeners();
      final resposta = await http.delete(
        Uri.parse('$_baseUrl/${product.id}.json?auth=$_token'),
      );
      if (resposta.statusCode >= 400) {
        _itens.insert(index, product);
        notifyListeners();
        throw HttpException('Ocorreu um erro na exclusão do produto.');
      }
    }
  }

  Future<void> addProduct(Product product) async {
    await http.post(
      Uri.parse('$_baseUrl.json?auth=$_token'),
      body: json.encode({
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'imageUrl': product.imageUrl,
      }),
    );
    _itens.add(product);
    notifyListeners();
  }

  Future<void> loadProducts() async {
    _itens.clear();
    final response = await http.get(
      Uri.parse('$_baseUrl.json?auth=$_token'),
    );
    if (response.body == 'null') {
      return Future.value();
    } else {
      final favResponse = await http.get(
        Uri.parse('$_baseUrlFavorites/$_userId.json?auth=$_token'),
      );
      Map<String, dynamic> favData =
          favResponse.body == 'null' ? {} : json.decode(favResponse.body);
      Map<String, dynamic> data = json.decode(response.body);
      data.forEach((productId, productData) {
        final isFavorite = favData[productId] ?? false;
        _itens.add(Product(
          id: productId,
          name: productData['name'],
          price: productData['price'],
          description: productData['description'],
          imageUrl: productData['imageUrl'],
          isFavorite: isFavorite,
        ));
      });
      notifyListeners();
      return Future.value();
    }
  }

  int itensCount() {
    return _itens.length;
  }
}
