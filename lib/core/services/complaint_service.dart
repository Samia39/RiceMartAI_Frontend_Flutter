import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/app_icons.dart';

String attachmentUrl(String path) {
  final storageBase = BaseUrl.url.replaceAll(RegExp(r'/api/?$'), '');
  return '$storageBase/storage/$path';
}

// =========================
// MODELS (kept in this file — no separate models folder)
// =========================

class ComplaintMessage {
  final int id;
  final int senderId;
  final String senderRole; // 'complainant' | 'super_admin'
  final String message;
  final String? attachmentPath;
  final String createdAt;

  ComplaintMessage({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.message,
    this.attachmentPath,
    required this.createdAt,
  });

  factory ComplaintMessage.fromJson(Map<String, dynamic> json) {
    return ComplaintMessage(
      id: json['id'],
      senderId: json['sender_id'],
      senderRole: json['sender_role'],
      message: json['message'],
      attachmentPath: json['attachment_path'] != null
          ? attachmentUrl(json['attachment_path'])
          : null,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class Complaint {
  final int id;
  final int userId;
  final String role; // 'customer' | 'seller'
  final String category;
  final String subject;
  final String status; // 'open' | 'in_progress' | 'resolved'
  final String createdAt;
  final String? userName;
  final String? userEmail;
  final List<ComplaintMessage> messages;

  Complaint({
    required this.id,
    required this.userId,
    required this.role,
    required this.category,
    required this.subject,
    required this.status,
    required this.createdAt,
    this.userName,
    this.userEmail,
    this.messages = const [],
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      role: json['role'] ?? '',
      category: json['category'] ?? 'other',
      subject: json['subject'] ?? '',
      status: json['status'] ?? 'open',
      createdAt: json['created_at'] ?? '',
      userName: json['user'] != null ? json['user']['name'] : null,
      userEmail: json['user'] != null ? json['user']['email'] : null,
      messages: json['messages'] != null
          ? (json['messages'] as List)
                .map((m) => ComplaintMessage.fromJson(m))
                .toList()
          : [],
    );
  }
}

// =========================
// SERVICE
// =========================

class ComplaintService {
  final box = GetStorage();
  final String baseUrl = BaseUrl.url;

  // Every GET/PATCH response goes through this before we touch it, so a
  // non-200 or non-JSON reply (an HTML error page, an empty body, a
  // dropped connection) never throws an uncaught exception into a screen
  // that's awaiting us without a try/catch — that's what was leaving
  // "My Complaints" stuck on its loading spinner forever.
  dynamic _safeDecode(http.Response response) {
    if (response.body.isEmpty) {
      throw Exception(
        'Empty response from server (status ${response.statusCode})',
      );
    }
    try {
      return jsonDecode(response.body);
    } catch (e) {
      print(
        '⚠️ Non-JSON response (status ${response.statusCode}): ${response.body}',
      );
      throw Exception(
        'Server returned an invalid response (status ${response.statusCode})',
      );
    }
  }

  // CREATE COMPLAINT (with optional attachment)
  Future<Map<String, dynamic>> createComplaint({
    required String category,
    required String subject,
    required String message,
    List<int>? imageBytes,
    String? fileName,
  }) async {
    try {
      final token = box.read("token");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/complaints"),
      );

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      request.fields['category'] = category;
      request.fields['subject'] = subject;
      request.fields['message'] = message;

      if (imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'attachment',
            imageBytes,
            filename: fileName ?? "attachment.jpg",
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = _safeDecode(
        http.Response(responseBody, response.statusCode),
      );

      if (response.statusCode == 201) {
        return {"success": true, "complaint": Complaint.fromJson(data)};
      } else {
        return {
          "success": false,
          "message": data['message'] ?? 'Failed to submit complaint',
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }

  // MY COMPLAINTS (customer/seller)
  Future<List<Complaint>> getMyComplaints() async {
    try {
      final token = box.read("token");

      final response = await http.get(
        Uri.parse("$baseUrl/complaints/my"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List data = _safeDecode(response);
        return data.map((c) => Complaint.fromJson(c)).toList();
      }
      return [];
    } catch (e) {
      print('⚠️ getMyComplaints failed: $e');
      return [];
    }
  }

  // ALL COMPLAINTS (super admin)
  Future<List<Complaint>> getAllComplaints({String? status}) async {
    try {
      final token = box.read("token");

      final uri = status != null
          ? Uri.parse("$baseUrl/complaints?status=$status")
          : Uri.parse("$baseUrl/complaints");

      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List data = _safeDecode(response);
        return data.map((c) => Complaint.fromJson(c)).toList();
      }
      return [];
    } catch (e) {
      print('⚠️ getAllComplaints failed: $e');
      return [];
    }
  }

  // COMPLAINT DETAIL (thread)
  Future<Complaint> getComplaintDetail(int id) async {
    final token = box.read("token");

    final response = await http.get(
      Uri.parse("$baseUrl/complaints/$id"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      return Complaint.fromJson(_safeDecode(response));
    }
    throw Exception("Complaint not found");
  }

  // ADD MESSAGE (reply — complainant or super admin)
  Future<Map<String, dynamic>> addMessage({
    required int complaintId,
    required String message,
    List<int>? imageBytes,
    String? fileName,
  }) async {
    try {
      final token = box.read("token");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/complaints/$complaintId/messages"),
      );

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      request.fields['message'] = message;

      if (imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'attachment',
            imageBytes,
            filename: fileName ?? "attachment.jpg",
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = _safeDecode(
        http.Response(responseBody, response.statusCode),
      );

      if (response.statusCode == 201) {
        return {
          "success": true,
          "message_data": ComplaintMessage.fromJson(data),
        };
      } else {
        return {
          "success": false,
          "message": data['message'] ?? 'Failed to send reply',
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }

  // UPDATE STATUS (super admin)
  Future<Map<String, dynamic>> updateStatus({
    required int complaintId,
    required String status,
  }) async {
    try {
      final token = box.read("token");

      final response = await http.patch(
        Uri.parse("$baseUrl/complaints/$complaintId/status"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"status": status}),
      );

      return _safeDecode(response);
    } catch (e) {
      return {
        "success": false,
        "message": e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }

  // EMERGENCY CONTACT (settings)
  Future<Map<String, String>> getEmergencyContact() async {
    try {
      final token = box.read("token");

      final response = await http.get(
        Uri.parse("$baseUrl/settings/emergency-contact"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = _safeDecode(response);
        return {"email": data['email'] ?? '', "phone": data['phone'] ?? ''};
      }
      return {"email": "", "phone": ""};
    } catch (e) {
      print('⚠️ getEmergencyContact failed: $e');
      return {"email": "", "phone": ""};
    }
  }
}
