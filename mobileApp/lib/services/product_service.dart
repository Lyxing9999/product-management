import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../utils/api_response.dart';
import '../utils/api_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show File;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:html' as html;
class ProductService {
  final baseUrl = kIsWeb
      ? dotenv.env['API_BASE_URL_WEB']!
      : dotenv.env['API_BASE_URL_MOBILE']!;

  ApiResponse<T> _wrapResponse<T>(
      http.Response response, T Function(dynamic json) fromJson) {
    return ApiHelper.parseResponse(response, fromJson);
  }

  Future<ApiResponse<List<Product>>> getAllProducts() async {
    final response = await http.get(Uri.parse(baseUrl));
    return _wrapResponse<List<Product>>(response, (data) {
      final List<dynamic> list = data['products'] ?? [];
      return list.map((json) => Product.fromJson(json)).toList();
    });
  }

  Future<ApiResponse<Map<String, dynamic>>> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    return _wrapResponse<Map<String, dynamic>>(response, (data) => data['product']);
  }

  Future<ApiResponse<Map<String, dynamic>>> updateProduct(String id, Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    return _wrapResponse<Map<String, dynamic>>(response, (data) => data['product']);
  }

  Future<ApiResponse<void>> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return _wrapResponse<void>(response, (data) => null);
  }


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
    if (name != null && name.isNotEmpty) queryParameters['name'] = name;
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
    return _wrapResponse<Map<String, dynamic>>(response, (data) => data);
  }


  /// Export CSV
  Future<void> exportCSV({Map<String, String>? filters}) async {
    final uri = Uri.parse('$baseUrl/export/csv').replace(queryParameters: filters);

    if (kIsWeb) {
      // Web: open in new tab
      html.window.open(uri.toString(), '_blank');
    } else {
      // Mobile: download file
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/products.csv');
        await file.writeAsBytes(response.bodyBytes);
        await OpenFile.open(file.path);
      } else {
        throw Exception('Failed to download CSV');
      }
    }
  }

  /// Export PDF
  Future<void> exportPDF({Map<String, String>? filters}) async {
    final uri = Uri.parse('$baseUrl/export/pdf').replace(queryParameters: filters);

    if (kIsWeb) {
      html.window.open(uri.toString(), '_blank');
    } else {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/products.pdf');
        await file.writeAsBytes(response.bodyBytes);
        await OpenFile.open(file.path);
      } else {
        throw Exception('Failed to download PDF');
      }
    }
  }
}