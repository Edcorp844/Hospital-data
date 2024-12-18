import 'package:http/http.dart';
import 'package:myapp/screens/access_screen.dart';
import 'package:myapp/screens/others/error_screen.dart';
import 'package:myapp/screens/tab_controller.dart';
import 'package:myapp/services/data_service.dart';
import 'package:myapp/utils/mycolors.dart';
import 'package:myapp/utils/textstyles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';

class MyApp {
  const MyApp();
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
      runApp(ErrorScreen(
          onRetry: retryInitialization,
          message: "No internet connection. Please check your network."));
    } on ClientException catch (e) {
      debugPrint(e.toString());
      runApp(ErrorScreen(
          onRetry: retryInitialization,
          message: "Failed to connect to Google Sheets service."));
    } catch (e) {
      debugPrint("Unexpected error: $e");
      runApp(ErrorScreen(
          onRetry: retryInitialization,
          message: "An unexpected error occurred. Please try again later."));
    }
  }
}
