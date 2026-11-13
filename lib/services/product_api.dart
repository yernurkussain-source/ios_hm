import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';


class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class ProductApi {
  ProductApi({http.Client? client, this.timeout = const Duration(seconds: 10)})
    : _client = client ?? http.Client();

  static final url = Uri.parse('https://fakestoreapi.com/products');

  final http.Client _client;
  final Duration timeout;

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client.get(url).timeout(timeout);
      switch (response.statusCode) {
        case 200:
          final data = jsonDecode(response.body) as List<dynamic>;
          return data
              .map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList();
        case 404:
          throw const ApiException('Products not found (404).');
        case >= 500:
          throw ApiException(
            'Server error (${response.statusCode}). Try again later.',
          );
        default:
          throw ApiException('Unexpected response (${response.statusCode}).');
      }
    } on TimeoutException {
      throw const ApiException('The server took too long (10 s timeout).');
    } on http.ClientException {
      // Airplane mode / no Wi-Fi ends up here (SocketException is wrapped).
      throw const ApiException('No internet connection.');
    } on FormatException {
      throw const ApiException('The server sent invalid data.');
    } on TypeError {
      // JSON was valid but not the shape we expect (e.g. object, not list).
      throw const ApiException('The server sent invalid data.');
    }
  }
}
