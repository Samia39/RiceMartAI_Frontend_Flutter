import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../models/conversation_model.dart';
import '../../models/message_model.dart';

class ChatService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static final _box = GetStorage();
  static String? _getToken() => _box.read('token');

  static Map<String, String> get _headers => {
    'Authorization': 'Bearer ${_getToken()}',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Start or get conversation
  static Future<ConversationModel?> startConversation(int shopId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/chat/start'),
        headers: _headers,
        body: jsonEncode({'shop_id': shopId}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return ConversationModel.fromJson(data['conversation']);
      }
    } catch (e) {
      print('startConversation error: $e');
    }
    return null;
  }

  // Get all conversations
  static Future<List<ConversationModel>> getConversations() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/chat/conversations'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['conversations'] as List)
            .map((e) => ConversationModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('getConversations error: $e');
    }
    return [];
  }

  // Get messages
  static Future<List<MessageModel>> getMessages(int conversationId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/chat/messages/$conversationId'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['messages'] as List)
            .map((e) => MessageModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('getMessages error: $e');
    }
    return [];
  }

  // Send message
  static Future<MessageModel?> sendMessage(
      int conversationId, String message) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/chat/send'),
        headers: _headers,
        body: jsonEncode({
          'conversation_id': conversationId,
          'message': message,
        }),
      );
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return MessageModel.fromJson(data['message']);
      }
    } catch (e) {
      print('sendMessage error: $e');
    }
    return null;
  }
}