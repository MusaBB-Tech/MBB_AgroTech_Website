import 'package:flutter/material.dart';
import 'navigation/main_navigation.dart';
import 'utils/theme/theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hm_seamsnstone',
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      home: const MainNavigationWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
