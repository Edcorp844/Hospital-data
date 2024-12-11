import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ErrorScreen extends StatefulWidget {
  final String message;
  final Future<void> Function() onRetry;

  const ErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  late final Connectivity _connectivity;
  late final Stream<List<ConnectivityResult>> _connectivityStream;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivityStream.listen((result) async {
      if (result[0] != ConnectivityResult.none) {
        // Automatically retry when internet is restored
        await widget.onRetry();
      }
    });
  }

  @override
  void dispose() {
    _connectivityStream.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: CupertinoPageScaffold(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  SvgPicture.asset('assets/svg/errorConnection.svg'),
                  const SizedBox(height: 10),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 251, 13, 0),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Spacer(),
                  const CupertinoActivityIndicator(), // Progress indicator
                  const SizedBox(height: 10),
                  const Text(
                    "Retrying automatically when connection is restored...",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: CupertinoColors.inactiveGray),
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
