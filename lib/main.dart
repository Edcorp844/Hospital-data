import 'package:flutter/cupertino.dart';
import 'package:myapp/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const MyApp().retryInitialization();
}
