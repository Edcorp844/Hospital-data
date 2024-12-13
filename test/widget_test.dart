import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

Future<void> main() async {
  const String botToken = '7442014466:AAHDuTdM31lpMOIo_kbo0hyi-UjQfwsJzss';
  const int channelId = -1002155957161; // Replace with your channel ID

  var telegram = Telegram(botToken);
  var teledart = TeleDart(botToken, Event((await telegram.getMe()).username!));

  // Listen for new channel posts
  teledart.onChannelPost().listen((message) {
    print('New Channel Post: ${message.text}');
  });

  final chat = await telegram.getChat(channelId);
  print('Chat Info: ${chat.toJson()}');

  // Fetch recent messages manually
  try {
    final updates = await telegram.getUpdates(
      timeout: 30,
    );
    updates.forEach((update) {
      if (update.channelPost != null) {
        print('Fetched Channel Post: ${update.channelPost!.text}');
      }
    });
  } catch (e) {
    print('Failed to fetch previous messages: $e');
  }

  // Start the bot
  teledart.start();
}
