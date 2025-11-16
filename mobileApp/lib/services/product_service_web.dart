// lib/services/product_service_web.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import '../models/product.dart';
import '../utils/api_helper.dart';
import '../utils/api_response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProductService {
    final String baseUrl = 'YOUR_API_BASE_URL_WEB';

  ApiResponse<T> _wrapResponse<T>(http.Response response, T Function(dynamic json) fromJson) {
    return ApiHelper.parseResponse(response, fromJson);
  }

  // READ all products
  Future<ApiResponse<List<Product>>> getAllProducts() async {
    final response = await http.get(Uri.parse(baseUrl));
    return _wrapResponse(response, (data) {
      final list = data['products'] ?? [];
      return (list as List).map((p) => Product.fromJson(p)).toList();
    });
  }

  // CREATE product
  Future<ApiResponse<Map<String, dynamic>>> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    return _wrapResponse(response, (data) => data['product']);
  }

  // UPDATE product
  Future<ApiResponse<Map<String, dynamic>>> updateProduct(String id, Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    return _wrapResponse(response, (data) => data['product']);
  }

  // DELETE product
Future<ApiResponse<void>> deleteProduct(dynamic id) async {
  final response = await http.delete(Uri.parse('$baseUrl/$id'));
  return _wrapResponse(response, (data) => null);
}

  // SEARCH products
  Future<ApiResponse<Map<String, dynamic>>> searchProducts({
    String? name,
    double? minPrice,
    double? maxPrice,
    int? minStock,
    int? maxStock,
    int page = 1,
    int limit = 10,
    String? sortBy,
    String? sortDirection,
  }) async {
    final queryParameters = <String, String>{};
    if (name != null) queryParameters['name'] = name;
    if (minPrice != null) queryParameters['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParameters['maxPrice'] = maxPrice.toString();
    if (minStock != null) queryParameters['minStock'] = minStock.toString();
    if (maxStock != null) queryParameters['maxStock'] = maxStock.toString();
    queryParameters['page'] = page.toString();
    queryParameters['limit'] = limit.toString();
    if (sortBy != null) queryParameters['sortBy'] = sortBy;
    if (sortDirection != null) queryParameters['sortDirection'] = sortDirection;

    final uri = Uri.parse('$baseUrl/search').replace(queryParameters: queryParameters);
    final response = await http.get(uri);
    return _wrapResponse(response, (data) => data);
  }

  // EXPORT CSV
  Future<void> exportCSV({Map<String, String>? filters}) async {
    final uri = Uri.parse('$baseUrl/export/csv').replace(queryParameters: filters);
    html.window.open(uri.toString(), '_blank');
  }

  // EXPORT PDF
  Future<void> exportPDF({Map<String, String>? filters}) async {
    final uri = Uri.parse('$baseUrl/export/pdf').replace(queryParameters: filters);
    html.window.open(uri.toString(), '_blank');
  }
}