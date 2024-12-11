import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myapp/screens/others/devotionscreen.dart';
import 'package:myapp/screens/others/materail_list_screen.dart';
import 'package:myapp/services/data_service.dart';

class HomeScreen extends StatefulWidget {
  final String email;
  const HomeScreen({super.key, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? name;
  Map<String, dynamic>? devotion;
  Map<String, dynamic>? events;
  Map<String, dynamic>? material;
  @override
  void initState() {
    getLastNameByEmail(widget.email).then((value) {
      setState(() {
        name = value;
      });
    });
    GoogleSheetsService().getDevotion().then((value) {
      setState(() {
        devotion = value;
      });
    });
    GoogleSheetsService().getEvents().then((value) {
      setState(() {
        events = value;
      });
    });
    GoogleSheetsService().getMaterial().then((value) {
      setState(() {
        material = value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> getLastNameByEmail(String email) async {
    try {
      final data = await GoogleSheetsService().getMinisters();
      final Map<String, dynamic> ministers = jsonDecode(data);
      if (ministers.containsKey(email)) {
        final minister = ministers[email];
        return minister["last_name"] ?? "";
      } else {
        return "Email not found";
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello Minister $name 👋🏾",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: CupertinoTheme.of(context).barBackgroundColor,
                        boxShadow: const [
                          BoxShadow(
                              blurRadius: 10,
                              spreadRadius: 2,
                              color: Color.fromARGB(87, 0, 0, 0))
                        ]),
                    child: SvgPicture.asset(
                      'assets/svg/profile.svg',
                      height: 25,
                      width: 25,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                  "As Hospital ministry we are Proud to be Apostle Grace's sons who have been equipped to heal"),
              const SizedBox(height: 16),
              if (devotion != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: CupertinoTheme.of(context).barBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'Devotion',
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: CupertinoColors.white,
                                    borderRadius: BorderRadius.circular(50)),
                                child: Image.asset(
                                  'assets/png/phanerooLogo.png',
                                  width: 25,
                                  height: 25,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text('Daily devotion'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromARGB(34, 52, 199, 89)),
                          child: Hero(
                            tag: 'Date',
                            child: Text(
                              devotion?['Date']?.toString() ?? "",
                              style: const TextStyle(
                                  color: CupertinoColors.activeGreen),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Hero(
                          tag: 'Heading',
                          child: Text(devotion?['heading']?.toString() ?? "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        const SizedBox(height: 10),
                        Hero(
                          tag: 'Scripture',
                          child: Text(devotion?['Scripture']?.toString() ?? "",
                              style: const TextStyle(fontSize: 15)),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CupertinoButton.filled(
                                // borderRadius: BorderRadius.circular(),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 1),
                                child: const Text('Read'),
                                onPressed: () {
                                  Navigator.push(context,
                                      CupertinoPageRoute(builder: (context) {
                                    return DevotionScreen(
                                      devotion: devotion!,
                                    );
                                  }));
                                })
                          ],
                        )
                      ]),
                ),
              const SizedBox(height: 10),
              if (events != null)
                Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: CupertinoTheme.of(context).barBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: CupertinoTheme.of(context)
                                        .barBackgroundColor,
                                    boxShadow: const [
                                      BoxShadow(
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                          color: Color.fromARGB(87, 0, 0, 0))
                                    ]),
                                child: SvgPicture.asset(
                                  'assets/svg/calendar.svg',
                                  height: 25,
                                  width: 25,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text('UpComing Events',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18))
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: CupertinoColors.systemRed),
                                    color:
                                        const Color.fromARGB(31, 255, 58, 48),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  events?.keys.first ?? "",
                                  style: const TextStyle(
                                      color: CupertinoColors.systemRed),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 5),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: CupertinoColors.activeGreen),
                                    color:
                                        const Color.fromARGB(31, 52, 199, 89),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  events?.keys.last ?? "",
                                  style: const TextStyle(
                                      color: CupertinoColors.activeGreen),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text('Our Calender'),
                          const SizedBox(height: 10),
                          Text('⦿ ${events?.values.first}',
                              style: const TextStyle(
                                  color: CupertinoColors.systemRed)),
                          const SizedBox(height: 10),
                          Text('⦿ ${events?.values.last}',
                              style: const TextStyle(
                                  color: CupertinoColors.activeGreen)),
                        ])),
              const SizedBox(height: 10),
              if (material != null)
                Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: CupertinoTheme.of(context).barBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/svg/material.svg',
                                height: 30,
                                width: 30,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text('Reading Material',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          for (String key in material!.keys) ...[
                            if (key != '') Text('📖 $key'),
                            const SizedBox(height: 10),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CupertinoButton.filled(
                                borderRadius: BorderRadius.circular(20),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 1),
                                child: const Text('Read'),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              MaterailListScreen(
                                                  material: material!)));
                                },
                              ),
                            ],
                          )
                        ])),
            ],
          ),
        ),
      ),
    ));
  }
}
