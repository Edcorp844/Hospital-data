import 'dart:async';
import 'dart:convert';
//import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class TelegramService {
  final String botToken;
  final String chatId;
  final StreamController<List<Map<String, dynamic>>> _streamController =
      StreamController.broadcast();

  TelegramService({required this.botToken, required this.chatId});

  Stream<List<Map<String, dynamic>>> get messageStream =>
      _streamController.stream;

  Future<void> startPolling() async {
    int lastUpdateId = 0;
    while (true) {
      try {
        // debugPrint('Fetching updates...');
        final response = await http.get(Uri.parse(
            'https://api.telegram.org/bot$botToken/getUpdates?offset=${lastUpdateId + 1}&timeout=30'));

        // debugPrint('Response status: ${response.statusCode}');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          //debugPrint('Response data: $data');

          if (data['result'] != null && data['result'].length > 0) {
            final newMessages = data['result']
                .where((update) =>
                    update.containsKey('message') &&
                    update['message']['chat']['id'].toString() == chatId)
                .map((update) => update['message'] as Map<String, dynamic>)
                .toList();

            if (newMessages.isNotEmpty) {
              //debugPrint('New messages: $newMessages');
              _streamController.add(newMessages);
              lastUpdateId = data['result'].last['update_id'];
            }
          }
        } else {
          //debugPrint('Failed to load messages: ${response.statusCode}');
        }
      } catch (e) {
        //debugPrint('Error fetching messages: $e');
      }

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void dispose() {
    _streamController.close();
  }
}
