import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:myapp/extensions/buildcontext_extension.dart';
import 'package:myapp/screens/data.dart';
import 'package:myapp/screens/home.dart';
import 'package:myapp/screens/messages.dart';
import 'package:myapp/screens/others/error_screen.dart';
import 'package:myapp/screens/others/qr_access.dart';
import 'package:myapp/screens/settings.dart';
import 'package:myapp/services/data_service.dart';
import 'package:myapp/utils/mycolors.dart';
import 'package:myapp/utils/textstyles.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> retryInitialization() async {
  try {
    await googleSheetsinit();
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');

    runApp(
      CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: CupertinoThemeData(
          applyThemeToAll: true,
          primaryColor: primaryColor,
          textTheme: CupertinoTextThemeData(
              textStyle: appTextStyle,
              actionTextStyle: actionsTextStyle,
              navActionTextStyle: actionsTextStyle),
        ),
        home: savedEmail != null
            ? TabController(
                email: savedEmail,
              )
            : const AccessScreen(),
      ),
    );
  } on SocketException {
    runApp(const ErrorScreen(
        onRetry: retryInitialization,
        message: "No internet connection. Please check your network."));
  } on ClientException catch (e) {
    debugPrint(e.toString());
    runApp(const ErrorScreen(
        onRetry: retryInitialization,
        message: "Failed to connect to Google Sheets service."));
  } catch (e) {
    debugPrint("Unexpected error: $e");
    runApp(const ErrorScreen(
        onRetry: retryInitialization,
        message: "An unexpected error occurred. Please try again later."));
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  retryInitialization();
}

class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key});

  @override
  State<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    // emailController.text = "edsonchn6@gmail.com";
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          border: const Border(),
          backgroundColor: Colors.transparent,
          trailing: CupertinoButton(
              child: const Icon(
                CupertinoIcons.qrcode_viewfinder,
              ),
              onPressed: () {
                Navigator.push(context, CupertinoPageRoute(builder: (context) {
                  return const QRScannerScreen();
                }));
              }),
        ),
        child: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: CupertinoTheme.of(context).barBackgroundColor),
                child: Column(
                  children: [
                    const Text(
                      'Acsess Level',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CupertinoTextField(
                      padding: const EdgeInsets.all(10), //
                      controller: emailController,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: CupertinoDynamicColor.resolve(
                              const CupertinoDynamicColor.withBrightness(
                                  color: Color.fromARGB(15, 98, 96, 96),
                                  darkColor: Color.fromARGB(15, 255, 255, 255)),
                              context)),
                      placeholder: 'Email',
                      prefix: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(CupertinoIcons.mail, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (emailController.text.isNotEmpty) {
                          context.showLoadingDialog(() async {
                            await GoogleSheetsService()
                                .hasAccess(emailController.text.trim())
                                .then((value) async {
                              if (value != true) {
                                throw AccessError(
                                  'This email has No access, please visit your leader to register or check your email and try again.',
                                );
                              }
                              // Save the email if access is granted
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString(
                                  'user_email', emailController.text.trim());
                            });
                          }, () {
                            Navigator.pushReplacement(context,
                                CupertinoPageRoute(builder: (context) {
                              return TabController(
                                email: emailController.text.trim(),
                              );
                            }));
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                        decoration: BoxDecoration(
                          color: context.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Access',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        )));
  }
}

class AccessError extends Error {
  final String message;

  AccessError(this.message);

  @override
  String toString() {
    return message;
  }
}

class TabController extends StatefulWidget {
  final String email;
  const TabController({super.key, required this.email});

  @override
  State<TabController> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TabController> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
        tabBar:
            CupertinoTabBar(backgroundColor: context.transparentColor, items: [
          BottomNavigationBarItem(
              activeIcon: SvgPicture.asset(
                'assets/svg/homeIconactive.svg',
                colorFilter:
                    ColorFilter.mode(context.primaryColor, BlendMode.srcIn),
              ),
              icon: SvgPicture.asset(
                'assets/svg/homeIcon.svg',
                colorFilter: const ColorFilter.mode(
                    CupertinoColors.systemGrey, BlendMode.srcIn),
              ),
              label: "Home"),
          BottomNavigationBarItem(
              activeIcon: SvgPicture.asset(
                'assets/svg/data.svg',
                colorFilter:
                    ColorFilter.mode(context.primaryColor, BlendMode.srcIn),
              ),
              icon: SvgPicture.asset(
                'assets/svg/data.svg',
                colorFilter: const ColorFilter.mode(
                    CupertinoColors.systemGrey, BlendMode.srcIn),
              ),
              label: "Data"),
          BottomNavigationBarItem(
              activeIcon: SvgPicture.asset(
                'assets/svg/messagesIconactive.svg',
                colorFilter:
                    ColorFilter.mode(context.primaryColor, BlendMode.srcIn),
              ),
              icon: SvgPicture.asset(
                'assets/svg/messagesicon.svg',
                colorFilter: const ColorFilter.mode(
                    CupertinoColors.systemGrey, BlendMode.srcIn),
              ),
              label: "Messages"),
          BottomNavigationBarItem(
              activeIcon: SvgPicture.asset(
                'assets/svg/settingsIconactive.svg',
                colorFilter:
                    ColorFilter.mode(context.primaryColor, BlendMode.srcIn),
              ),
              icon: SvgPicture.asset(
                'assets/svg/settingsIcon.svg',
                colorFilter: const ColorFilter.mode(
                    CupertinoColors.systemGrey, BlendMode.srcIn),
              ),
              label: "Settings"),
        ]),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return HomeScreen(
                email: widget.email,
              );
            case 1:
              return const DataScreen();
            case 2:
              return const Messages();
            case 3:
              return Settings(
                email: widget.email,
              );
            default:
              return HomeScreen(
                email: widget.email,
              );
          }
        });
  }
}
