import 'package:flutter/cupertino.dart';

class DevotionScreen extends StatefulWidget {
  final Map<String, dynamic> devotion;
  const DevotionScreen({super.key, required this.devotion});

  @override
  State<DevotionScreen> createState() => _DevotionScreenState();
}

class _DevotionScreenState extends State<DevotionScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'Home',
        transitionBetweenRoutes: false,
        heroTag: 'Devotion',
        middle: Text('Phaneroo Devotion'),
      ),
      child: SafeArea(
        child: CupertinoScrollbar(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                      tag: 'Date',
                      child: Text(widget.devotion['Date']?.toString() ?? "")),
                  const SizedBox(height: 5),
                  const Text('Apostle Grace Lubega',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Hero(
                    tag: 'Scripture',
                    child: Text(widget.devotion['Scripture']?.toString() ?? "",
                        style:
                            const TextStyle(color: CupertinoColors.systemGrey)),
                  ),
                  const SizedBox(height: 10),
                  Hero(
                    tag: 'Heading',
                    child: Text(widget.devotion['heading']?.toString() ?? "",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.devotion['body']?.toString() ?? "",
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.normal, // Normal text for the value
                        color: CupertinoColors.systemGrey,
                      )),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "FURTHER STUDY: ",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold, // Make "Further Study" bold
                            // Customize the color if needed
                          ),
                        ),
                        TextSpan(
                          text:
                              widget.devotion['FurtherStudy']?.toString() ?? '',
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.normal, // Normal text for the value
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "GOLDEN NUGGET: ",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold, // Make "Further Study" bold
                            // Customize the color if needed
                          ),
                        ),
                        TextSpan(
                          text:
                              widget.devotion['GoldenNugget']?.toString() ?? '',
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.normal, // Normal text for the value
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: "PRAYER: ",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold, // Make "Further Study" bold
                            // Customize the color if needed
                          ),
                        ),
                        TextSpan(
                          text: widget.devotion['Prayer']?.toString() ?? '',
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.normal, // Normal text for the value
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
