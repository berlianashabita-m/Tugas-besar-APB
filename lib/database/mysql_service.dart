import 'dart:convert';
import 'package:http/http.dart' as http;

class MySqlService {
  static const String baseUrl = "http://192.168.1.7/solestore_api";

  static String? currentUserEmail;
  static String? currentUserRole;

  static List<Map<String, dynamic>> cartList = [];

  // ==========================
  // AUTH
  // ==========================

  static Future<Map<String, dynamic>> registerUser(
    String email,
    String password,
    String name,
    String phone,
    String role,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth.php?action=register"),
        body: {
          "email": email,
          "password": password,
          "name": name,
          "phone": phone,
          "role": role,
        },
      );

      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        "status": "error",
        "message": e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth.php?action=login"),
        body: {
          "email": email,
          "password": password,
        },
      );

      final data = json.decode(response.body) as Map<String, dynamic>;

      if (data['status'] == 'success') {
        currentUserEmail = data['email'];
        currentUserRole = data['role'];
      }

      return data;
    } catch (e) {
      return {
        "status": "error",
        "message": e.toString(),
      };
    }
  }

  // ==========================
  // PRODUCT
  // ==========================

  static Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/products.php"),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        return data
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<int?> addProductMaster(
    String name,
    int price,
    String imagePath,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/products.php"),
      );

      request.fields['name'] = name;
      request.fields['price'] = price.toString();

      if (imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imagePath,
          ),
        );
      }

      var stream = await request.send();
      var response = await http.Response.fromStream(stream);

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        return data['product_id'];
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> editProductMaster(
    int id,
    String name,
    int price,
    String imagePath,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          "$baseUrl/products.php?action=edit_product",
        ),
      );

      request.fields['id'] = id.toString();
      request.fields['name'] = name;
      request.fields['price'] = price.toString();

      if (imagePath.isNotEmpty &&
          !imagePath.startsWith('http')) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imagePath,
          ),
        );
      }

      var stream = await request.send();
      var response = await http.Response.fromStream(stream);

      return json.decode(response.body)['status'] ==
          'success';
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/products.php?id=$id"),
      );

      return json.decode(response.body)['status'] ==
          'success';
    } catch (e) {
      return false;
    }
  }

  // ==========================
  // PRODUCT SIZE
  // ==========================

  static Future<bool> addSizeToProduct(
    int productId,
    int size,
    int stock,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          "$baseUrl/products.php?action=add_size",
        ),
        body: {
          "product_id": productId.toString(),
          "size": size.toString(),
          "stock": stock.toString(),
        },
      );

      return json.decode(response.body)['status'] ==
          'success';
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateSizeStock(
    int sizeId,
    int newStock,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          "$baseUrl/products.php?action=update_stock",
        ),
        body: {
          "size_id": sizeId.toString(),
          "stock": newStock.toString(),
        },
      );

      return json.decode(response.body)['status'] ==
          'success';
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteProductSize(
    int sizeId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          "$baseUrl/products.php?action=delete_size",
        ),
        body: {
          "size_id": sizeId.toString(),
        },
      );

      return json.decode(response.body)['status'] ==
          'success';
    } catch (e) {
      return false;
    }
  }

  // ==========================
  // ORDER
  // ==========================

  static Future<List<Map<String, dynamic>>> getOrders(
    String email,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/orders.php?email=$email",
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        return data
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> checkoutOrderComplex(
    Map<String, dynamic> checkoutPayload,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          "$baseUrl/orders.php?action=checkout",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(checkoutPayload),
      );

      return json.decode(response.body)['status'] ==
          'success';
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateOrderStatus(
    int orderId,
    String newStatus,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          "$baseUrl/orders.php?action=update_status",
        ),
        body: {
          "order_id": orderId.toString(),
          "status": newStatus,
        },
      );

      return json.decode(response.body)['status'] ==
          'success';
    } catch (e) {
      return false;
    }
  }
}