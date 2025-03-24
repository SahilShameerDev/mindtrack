import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mindtrack/pages/home_pages.dart';
import 'package:mindtrack/pages/screen_time.dart';
import 'package:mindtrack/pages/unlock_count.dart';
import 'package:mindtrack/pages/loading_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Hive.openBox<int>('moodBox'), // Open the Hive box
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('Error initializing Hive: ${snapshot.error}'),
                ),
              ),
            );
          } else {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: const LoadingPage(),
              routes: {
                '/screen-time': (context) => ScreenTimePage(
                      platform: const MethodChannel('com.example.screen_time_tracker/screen_time'),
                    ),
                '/unlock-count': (context) => UnlockCountPage(
                      platform: const MethodChannel('com.example.screen_time_tracker/screen_time'),
                    ),
              },
            );
          }
        } else {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: Color(0xC4FF4000),
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}