import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ChatService {
  final String baseUrl = "https://ricemart.sandbox.pk/api";

  String get _token => GetStorage().read("token") ?? "";

  Map<String, String> get _headers => {
    "Authorization": "Bearer $_token",
    "Accept": "application/json",
    "Content-Type": "application/json",
  };

  // =============================================
  // Start or get existing conversation with shop
  // Returns { conversation_id, shop_id }
  // =============================================
  Future<Map<String, dynamic>> startConversation({required int shopId}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/conversations/start"),
      headers: _headers,
      body: jsonEncode({"shop_id": shopId}),
    );

    return jsonDecode(response.body);
  }

  // =============================================
  // Fetch all conversations for current user
  // =============================================
  Future<List<Map<String, dynamic>>> fetchConversations() async {
    final response = await http.get(
      Uri.parse("$baseUrl/conversations"),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    return [];
  }

  // =============================================
  // Fetch messages for a conversation
  // =============================================
  Future<List<Map<String, dynamic>>> fetchMessages({
    required int conversationId,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/conversations/$conversationId/messages"),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }

    return [];
  }

  // =============================================
  // Send a message
  // =============================================
  Future<Map<String, dynamic>?> sendMessage({
    required int conversationId,
    required String body,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/conversations/$conversationId/messages"),
      headers: _headers,
      body: jsonEncode({"body": body}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    return null;
  }
}
