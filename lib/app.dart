import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: IAMTheme.lightTheme,
      darkTheme: IAMTheme.darkTheme,
    );
  }
}
