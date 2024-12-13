import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myapp/services/data_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For ListTile widget

class Settings extends StatefulWidget {
  final String email;
  const Settings({super.key, required this.email});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late Stream<Map<String, dynamic>> profileStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream to fetch profile data
    profileStream = _fetchProfileData(widget.email);
  }

  // Fetch profile data using the email
  Stream<Map<String, dynamic>> _fetchProfileData(String email) async* {
    try {
      // Simulate fetching data (replace this with actual data fetching logic)
      await Future.delayed(const Duration(seconds: 2)); // Simulate delay
      final data = await GoogleSheetsService()
          .getMinisters(); // Assuming this is your data fetching service
      final Map<String, dynamic> ministers = jsonDecode(data);

      // Check if the email exists in the data
      if (ministers.containsKey(email)) {
        yield ministers[email]!;
      } else {
        yield {}; // If email not found, return an empty map
      }
    } catch (e) {
      // In case of an error, yield an empty map
      debugPrint('Error fetching profile data: $e');
      yield {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<Map<String, dynamic>>(
            stream: profileStream,
            builder: (context, snapshot) {
              // Show loading spinner while fetching data
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator());
              }

              // Show error if something went wrong
              if (snapshot.hasError) {
                return Center(
                    child: Row(
                  children: [
                    Text('Error: ${snapshot.error}'),
                  ],
                ));
              }

              // If no data is found
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No profile data available"));
              }

              // Now you can safely access the profile data
              final profileData = snapshot.data!;

              return Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      decoration: BoxDecoration(
                          color: CupertinoTheme.of(context).barBackgroundColor,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: CupertinoColors.systemGrey,
                            width: 1.0,
                          )),
                      child: SvgPicture.asset(
                        'assets/svg/account-pic.svg',
                        height: 100,
                        width: 100,
                      )),
                  const SizedBox(height: 16),

                  // Displaying user details from profileData
                  Text(
                    "${profileData["first_name"]} ${profileData["last_name"]}",
                    style:
                        CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                  ),

                  const SizedBox(height: 8),
                  Text(
                    profileData["phone"] ?? "Phone not available",
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),

                  const SizedBox(height: 16),

                  CupertinoListSection.insetGrouped(children: [
                    CupertinoListTile(
                      title: const Text('Position'),
                      trailing: Text(
                        profileData["position"] ?? "Position not available",
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                    ),
                    CupertinoListTile(
                      title: const Text('Address'),
                      trailing: Text(
                        profileData["address"] ?? "Position not available",
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                    ),
                    CupertinoListTile(
                      title: const Text('Date of Birth'),
                      trailing: Text(
                        profileData["date_of_birth"] ?? "DOB not available",
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                    ),
                  ]),

                  const Spacer(),
                  CupertinoButton(
                    child: const Text(
                      'Get Accessed out',
                      style: TextStyle(color: CupertinoColors.systemRed),
                    ),
                    onPressed: () async {
                      // Remove user_email from shared preferences
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.remove('user_email');

                      // Restart the app by popping the current screen
                      SystemNavigator.pop();
                    },
                  )
                ],
              ));
            },
          ),
        ),
      ),
    );
  }
}
