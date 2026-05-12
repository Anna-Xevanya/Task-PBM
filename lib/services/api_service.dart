import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';

class ApiService {
  final String baseUrl = 'https://task.itprojects.web.id/api';
  final storage = const FlutterSecureStorage();

  Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check for common token field names (direct or nested)
        final token = data['token'] ??
            data['access_token'] ??
            (data['data'] != null ? data['data']['token'] : null);

        if (token == null) {
          throw Exception('Token not found in response');
        }

        await storage.write(key: 'token', value: token);
        return token;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<List<Product>> getProducts() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      List<dynamic> rawList = [];

      if (decodedData is List) {
        rawList = decodedData;
      } else if (decodedData is Map) {
        // Handle the specific structure: data -> products
        if (decodedData['data'] != null) {
          final dataContent = decodedData['data'];
          if (dataContent is List) {
            rawList = dataContent;
          } else if (dataContent is Map && dataContent['products'] is List) {
            rawList = dataContent['products'];
          } else if (dataContent is Map && dataContent['product'] is List) {
            rawList = dataContent['product'];
          } else if (dataContent is Map) {
            // Check if it's a single product or nested data
            rawList = [dataContent];
          }
        } else if (decodedData['products'] is List) {
          rawList = decodedData['products'];
        } else {
          // Fallback: search for ANY list
          for (var value in decodedData.values) {
            if (value is List) {
              rawList = value;
              break;
            }
          }
        }
      }

      return rawList
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      final errorBody = response.body;
      throw Exception(
          'Failed to load products (${response.statusCode}): $errorBody');
    }
  }

  Future<void> addProduct(String name, int price, String description) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to add product');
    }
  }

  Future<void> deleteProduct(int id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to delete product');
    }
  }

  Future<void> submitTask(
      String name, int price, String description, String githubUrl) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/products/submit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'github_url': githubUrl,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = 'Failed to submit task';
      try {
        final data = jsonDecode(response.body);
        errorMessage = data['message'] ?? errorMessage;
      } catch (_) {
        // If not JSON, use the status code or a generic message
        errorMessage = 'Error ${response.statusCode}: ${response.reasonPhrase}';
      }
      throw Exception(errorMessage);
    }
  }
}