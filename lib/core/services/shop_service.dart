import 'dart:convert';
import 'dart:typed_data';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/app_icons.dart';

class ShopService {
  static const String baseUrl = BaseUrl.url;

  // =========================
  // CREATE SHOP
  // (multipart — required so the CNIC front/back images actually
  // reach the backend; a plain JSON POST can't carry files)
  // =========================
  Future<Map<String, dynamic>> createShop({
    required String token,
    required String cnic,
    required String shopName,
    required String ownerName,
    required String phone,
    required String city,
    required String address,
    required String description,
    required Uint8List cnicFrontImage,
    required Uint8List cnicBackImage,
    String? cnicFrontFileName,
    String? cnicBackFileName,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/shops"));

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      request.fields['cnic'] = cnic;
      request.fields['shop_name'] = shopName;
      request.fields['owner_name'] = ownerName;
      request.fields['phone'] = phone;
      request.fields['city'] = city;
      request.fields['address'] = address;
      request.fields['description'] = description;

      request.files.add(
        http.MultipartFile.fromBytes(
          'cnic_image',
          cnicFrontImage,
          filename: cnicFrontFileName ?? "cnic_front.jpg",
        ),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'cnic_back_image',
          cnicBackImage,
          filename: cnicBackFileName ?? "cnic_back.jpg",
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      return jsonDecode(responseBody);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // fetch pending shops for admin
  Future<List<Map<String, dynamic>>> fetchPendingShops({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/pending-shops"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    return [];
  }

  // approve shop
  Future approveShop({required String token, required int shopId}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/shops/$shopId/approve"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    print(response.statusCode);
    print(response.body);

    return jsonDecode(response.body);
  }

  // reject shops
  Future<List<Map<String, dynamic>>> fetchRejectedShops({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/rejected-shops"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    return [];
  }

  // fetch approved shops for customers
  Future<List<Map<String, dynamic>>> fetchApprovedShops() async {
    String token = GetStorage().read("token") ?? "";

    final response = await http.get(
      Uri.parse("$baseUrl/approved-shops"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    return [];
  }

  // reject shop
  Future rejectShop({
    required String token,
    required int shopId,
    required String reason,
  }) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/shops/$shopId"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"reason": reason}),
    );

    return jsonDecode(response.body);
  }

  // =========================
  // ADMIN REQUEST CORRECTION
  // =========================
  Future<Map<String, dynamic>> requestCorrection({
    required String token,
    required int shopId,
    required String reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/shops/$shopId/request-correction"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"reason": reason}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // =========================
  // UPDATE SHOP
  // (multipart — CNIC images are optional here; only attached if the
  // seller actually picks a replacement while resubmitting)
  // =========================
  Future<Map<String, dynamic>> updateShop({
    required String token,
    required int shopId,
    required String shopName,
    required String ownerName,
    required String phone,
    required String city,
    required String address,
    required String description,
    required String cnic,
    Uint8List? cnicFrontImage,
    Uint8List? cnicBackImage,
    String? cnicFrontFileName,
    String? cnicBackFileName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/shops/$shopId"),
      );

      // Laravel doesn't parse multipart bodies on native PUT requests,
      // so we POST with a _method override, which Laravel's built-in
      // method-spoofing middleware reads and treats as PUT.
      request.fields['_method'] = 'PUT';

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      request.fields['shop_name'] = shopName;
      request.fields['owner_name'] = ownerName;
      request.fields['phone'] = phone;
      request.fields['city'] = city;
      request.fields['address'] = address;
      request.fields['description'] = description;
      request.fields['cnic'] = cnic;

      if (cnicFrontImage != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'cnic_image',
            cnicFrontImage,
            filename: cnicFrontFileName ?? "cnic_front.jpg",
          ),
        );
      }

      if (cnicBackImage != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'cnic_back_image',
            cnicBackImage,
            filename: cnicBackFileName ?? "cnic_back.jpg",
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      return jsonDecode(responseBody);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // DELETE SHOP
  // =========================
  // SELLER — REQUEST SHOP DELETION (SEND OTP)
  // =========================
  Future<Map<String, dynamic>> requestShopDeletion({
    required String token,
    required int shopId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/shops/$shopId/delete/request"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // =========================
  // SELLER — CONFIRM SHOP DELETION (VERIFY OTP)
  // =========================
  Future<Map<String, dynamic>> confirmShopDeletion({
    required String token,
    required int shopId,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/shops/$shopId/delete/confirm"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"otp": otp}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // get my shop details
  Future<Map<String, dynamic>> getMyShop(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/my-shop"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "shop": data["shop"]};
      } else {
        return {"success": false, "message": data["message"]};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // Update payout details

  Future<Map<String, dynamic>> updatePayoutDetails({
    required String token,
    String? easypaisaNumber,
    String? easypaisaAccountName,
    String? jazzcashNumber,
    String? jazzcashAccountName,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/my-shop/payout-details"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "easypaisa_number": easypaisaNumber,
          "easypaisa_account_name": easypaisaAccountName,
          "jazzcash_number": jazzcashNumber,
          "jazzcash_account_name": jazzcashAccountName,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // =========================
  // ADMIN — PERMANENTLY REMOVE SELLER
  // =========================
  Future<Map<String, dynamic>> removeSeller({
    required String token,
    required int shopId,
    required String reason,
    required bool permanentlyBan,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/admin/shops/$shopId/remove-seller"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"reason": reason, "permanently_ban": permanentlyBan}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // =========================
  // ADMIN — FETCH REMOVED SHOPS (record)
  // =========================
  Future<List<Map<String, dynamic>>> fetchRemovedShops({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/removed-shops"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    return [];
  }
}
