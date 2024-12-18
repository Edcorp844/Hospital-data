
import 'package:flutter/cupertino.dart';
import 'package:myapp/extensions/buildcontext_extension.dart';
import 'package:myapp/screens/others/qr_access.dart';
import 'package:myapp/screens/tab_controller.dart';
import 'package:myapp/services/data_service.dart';
import 'package:myapp/utils/errors/acess_error.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          backgroundColor: context.transparentColor,
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
                        child: Icon(CupertinoIcons.mail, color: CupertinoColors.systemGrey),
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
                            style: TextStyle(color: CupertinoColors.white)),
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
