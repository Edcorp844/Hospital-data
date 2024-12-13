import 'dart:async';
import 'dart:convert';
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
        final response = await http.get(Uri.parse(
            'https://api.telegram.org/bot$botToken/getUpdates?offset=${lastUpdateId + 1}&timeout=10'));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['result'] != null && data['result'] is List) {
            final updates = data['result'];
            final newMessages = updates
                .where((update) =>
                    update.containsKey('message') &&
                    update['message']['chat']['id'].toString() == chatId)
                .map((update) => update['message'] as Map<String, dynamic>)
                .toList();

            if (newMessages.isNotEmpty) {
              _streamController.add(newMessages);
              lastUpdateId = updates.last['update_id'];
            }
          }
        } else {
          print('Error: ${response.statusCode}, ${response.body}');
        }
      } catch (e) {
        print('Error fetching messages: $e');
      }

      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void dispose() {
    _streamController.close();
  }
}
