import 'package:changan_seat_heat/automotive_store.dart';
import 'package:changan_seat_heat/home_page.dart';
import 'package:flutter/material.dart';

import 'accessibility_service.dart';
import 'background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeBackgroundService();
  await initializeAccessibilityService();

  final store = AutomotiveStore();
  runApp(MyApp(store: store));
}

class MyApp extends StatefulWidget {
  final AutomotiveStore store;
  const MyApp({super.key, required this.store});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.dark,
      home: HomePage(store: widget.store),
    );
  }
}