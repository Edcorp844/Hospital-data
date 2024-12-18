import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myapp/extensions/buildcontext_extension.dart';
import 'package:myapp/screens/data.dart';
import 'package:myapp/screens/home.dart';
import 'package:myapp/screens/settings.dart';

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
