import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:electronics_shop_app/models/product.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';

  Future<Map<String, dynamic>> getProducts({int limit = 10, int skip = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products?limit=$limit&skip=$skip'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> productsJson = data['products'] as List<dynamic>? ?? [];
        final List<Product> products = productsJson
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();

        return {
          'products': products,
          'total': data['total'] as int? ?? 0,
          'skip': data['skip'] as int? ?? 0,
          'limit': data['limit'] as int? ?? 10,
        };
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<Product> getProductById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        return Product.fromJson(data);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load product: $e');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/search?q=$query'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> productsJson = data['products'] as List<dynamic>? ?? [];
        return productsJson
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }
   Future<List<Product>> getTopRatedProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products?sort=rating'),  // Example endpoint, adjust as needed
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> productsJson = data['products'] as List<dynamic>? ?? [];
        return productsJson
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load top-rated products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load top-rated products: $e');
    }
  }
}