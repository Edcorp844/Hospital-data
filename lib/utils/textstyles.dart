import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/utils/mycolors.dart';

TextStyle appTextStyle = GoogleFonts.poppins(
    textStyle: const TextStyle(
  color: CupertinoDynamicColor.withBrightness(
    color: Color.fromARGB(255, 17, 5, 44),
    darkColor: CupertinoColors.white,
  ),
));

TextStyle actionsTextStyle = const TextStyle(
  inherit: false,
  color: primaryColor,
  decoration: TextDecoration.none,
  letterSpacing: -0.41,
  fontSize: 17.0, // Match primaryColor
);
