import 'package:flutter/cupertino.dart';
import 'package:myapp/services/telegram_service.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  late TelegramService _telegramService;

  @override
  void initState() {
    super.initState();
    _telegramService = TelegramService(
      botToken: '7442014466:AAHDuTdM31lpMOIo_kbo0hyi-UjQfwsJzss',
      chatId: '-1002155957161',
    );
    _telegramService.startPolling();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text("Messages"),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _telegramService.messageStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SafeArea(child: CupertinoActivityIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SafeArea(
                    child: Center(child: Text('No messages')),
                  );
                } else {
                  final messages = snapshot.data!;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return CupertinoListTile(
                        title: Text(message['text'] ?? 'No Text'),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
