import 'package:myapp/extensions/buildcontext_extension.dart';
import 'package:myapp/main.dart';
import 'package:myapp/services/data_service.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  QRScannerScreenState createState() => QRScannerScreenState();
}

class QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedText;

  // Animation controller for scanning line
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Repeat the animation
  }

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overlaySize = MediaQuery.of(context).size.width * 0.5;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('QR Access'),
        backgroundColor: Color.fromARGB(0, 60, 60, 67),
        previousPageTitle: "Back",
        border: Border(),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 4,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: CupertinoColors.activeBlue,
                    borderRadius: 20,
                    borderWidth: 10,
                    cutOutSize: overlaySize,
                  ),
                ),
              ),
            ],
          ),
          // Animated scanning line
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: MediaQuery.of(context).size.width * 0.25,
            child: SizedBox(
              width: overlaySize - 10,
              height: overlaySize,
              child: AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        top: animationController.value * overlaySize,
                        left: 10,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(106, 0, 123, 255),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromARGB(106, 0, 123, 255),
                                    spreadRadius: 5,
                                    blurRadius: 5,
                                    offset: Offset(0, 2)),
                              ]),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          // Rounded Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(41, 0, 0, 0),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: CupertinoColors.inactiveGray,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  scannedText == null
                      ? const Text(
                          'Scan the QR code to access',
                          style: TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.inactiveGray,
                          ),
                        )
                      : Text(
                          scannedText!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoButton(
                        child: const Icon(
                          CupertinoIcons.bolt,
                          color: CupertinoColors.activeBlue,
                        ),
                        onPressed: () {
                          controller?.toggleFlash();
                        },
                      ),
                      CupertinoButton(
                        child: const Icon(
                          CupertinoIcons.switch_camera,
                          color: CupertinoColors.activeBlue,
                        ),
                        onPressed: () {
                          controller?.flipCamera();
                        },
                      ),
                      CupertinoButton.filled(
                        child: const Text('Scan Again'),
                        onPressed: () {
                          setState(() {
                            scannedText = null;
                          });
                          controller?.resumeCamera();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    // Automatically resume scanning
    controller.scannedDataStream.listen((scanData) {
      if (scannedText == null) {
        setState(() {
          scannedText = scanData.code; // Capture the scanned QR code
        });

        // ignore: use_build_context_synchronously
        context.showLoadingDialog(() async {
          await GoogleSheetsService()
              .hasAccess(scannedText!)
              .then((value) async {
            if (value != true) {
              throw AccessError(
                'This email has No access, please visit your leader to register or check your email and try again.',
              );
            }
            // Save the email if access is granted
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_email', scannedText!);
          });
        }, () {
          Navigator.pushReplacement(context,
              CupertinoPageRoute(builder: (context) {
            return TabController(
              email: scannedText!,
            );
          }));
        });
        // Perform any action you want after scanning
        controller
            .pauseCamera(); // Pause the camera if you want to stop scanning after one successful scan
      }
    });

    // Start the camera as soon as it's created
    controller.resumeCamera();
  }
}
