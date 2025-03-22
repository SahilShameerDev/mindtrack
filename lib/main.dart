import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindtrack/pages/home_pages.dart';
import 'package:mindtrack/pages/screen_time.dart';
import 'package:mindtrack/pages/unlock_count.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      routes: {
        '/screen-time': (context) =>  ScreenTimePage(platform: const MethodChannel('com.example.screen_time_tracker/screen_time'),),
        '/unlock-count': (context) => UnlockCountPage(platform: const MethodChannel('com.example.screen_time_tracker/screen_time'),),
      },
    );
  }
}