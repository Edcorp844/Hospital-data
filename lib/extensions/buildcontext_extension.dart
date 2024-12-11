import 'package:flutter/cupertino.dart';

import 'package:rive/rive.dart';

extension UIExtension on BuildContext {
  get primaryColor => CupertinoTheme.of(this).primaryColor;
  get transparentColor => const Color(0x00000000);
  get containerColor => const Color.fromARGB(248, 1, 14, 22);
  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.width;

  static late SMITrigger check;
  static late SMITrigger error;
  static late SMITrigger reset;
  static late SMITrigger confetti;

  StateMachineController getRiveController(Artboard artboard) {
    StateMachineController? controller =
        StateMachineController.fromArtboard(artboard, "State Machine 1");
    artboard.addController(controller!);
    return controller;
  }

  void showLoadingDialog(Function() trigger, void Function()? onSuccess) {
    showCupertinoDialog(
      context: this,
      builder: (context) {
        return Center(
          child: Stack(
            children: [
              SizedBox(
                height: 100,
                width: 100,
                child: RiveAnimation.asset(
                  'assets/rive/check.riv',
                  onInit: (artboard) {
                    StateMachineController controller =
                        getRiveController(artboard);
                    check = controller.findSMI('Check') as SMITrigger;
                    error = controller.findSMI('Error') as SMITrigger;
                    reset = controller.findSMI('Reset') as SMITrigger;
                  },
                ),
              ),
              SizedBox(
                height: 100,
                width: 100,
                child: Transform.scale(
                  scale: 7,
                  child: RiveAnimation.asset(
                    'assets/rive/confetti.riv',
                    onInit: (artboard) {
                      StateMachineController controller =
                          getRiveController(artboard);
                      confetti = controller.findInput<bool>("Trigger explosion")
                          as SMITrigger;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
      barrierDismissible: false,
    );

    Future.delayed(const Duration(seconds: 1), () async {
      try {
        await trigger();
        check.fire();
        confetti.fire();
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(this).pop();

          if (onSuccess != null) onSuccess();
        });
      } catch (e) {
        error.fire();
        debugPrint('Error: ${e.toString()}');
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(this).pop();
          showerror(e.toString());
        });
      }
    });
  }

  void showerror(String error) {
    buildDialog(
      title: const Text('Error'),
      content: Text(error),
      actions: [
        CupertinoButton(
            child: const Text('ok'),
            onPressed: () {
              Navigator.of(this).pop();
            })
      ],
    );
  }

  void buildDialog({
    Widget? title,
    Widget? content,
    List<Widget>? actions,
  }) {
    showGeneralDialog(
      context: this,
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, a1, a2, widget) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
            child: CupertinoAlertDialog(
              title: title,
              content: content,
              actions: actions ?? [],
            ),
          ),
        );
      },
    );
  }

  void push(Widget screen) {
    Navigator.push(this, CupertinoPageRoute(builder: (context) => screen));
  }

  void pop() {
    Navigator.of(this).pop();
  }
}
