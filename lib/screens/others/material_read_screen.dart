import 'package:flutter/cupertino.dart';

class MaterialReadScreen extends StatefulWidget {
  final String title;
  final String content;
  const MaterialReadScreen(
      {super.key, required this.title, required this.content});

  @override
  State<MaterialReadScreen> createState() => _MaterilReadScreenState();
}

class _MaterilReadScreenState extends State<MaterialReadScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          previousPageTitle: 'Back',
          middle: Text(
            widget.title,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        child: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(widget.content,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.normal, // Normal text for the value
                      color: CupertinoColors.systemGrey,
                    )),
              )
            ],
          ),
        )));
  }
}
