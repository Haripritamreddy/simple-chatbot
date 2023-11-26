import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'second_main.dart'; // Import your SecondMainScreen
import 'chat_screen.dart'; // Import your ChatScreen
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(this.context as BuildContext).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyAppBody(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'LLM Chat', // Replace with your app name
              style: GoogleFonts.martianMono(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Created by Haripritam',
              style: GoogleFonts.montserrat(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyAppBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getApiKey(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final apiKey = snapshot.data;
          if (apiKey != null && apiKey.isNotEmpty) {
            return ChatScreen(apiKey: apiKey);
          } else {
            return SecondMainScreen();
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Future<String> getApiKey() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'api_keys.db'),
      version: 1,
    );

    await database.execute(
      'CREATE TABLE IF NOT EXISTS api_keys (api_key TEXT PRIMARY KEY)',
    );

    final List<Map<String, dynamic>> result = await database.query('api_keys');

    return result.isNotEmpty ? result.first['api_key'] : '';
  }
}
