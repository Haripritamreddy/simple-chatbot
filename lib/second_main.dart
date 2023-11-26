import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'chat_screen.dart';

void main() => runApp(SecondMain());

class SecondMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SecondMainScreen(),
    );
  }
}

class SecondMainScreen extends StatefulWidget {
  @override
  _SecondMainScreenState createState() => _SecondMainScreenState();
}

class _SecondMainScreenState extends State<SecondMainScreen> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set API Key'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(labelText: 'Enter API Key'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final apiKey = _apiKeyController.text;

                await saveApiKey(apiKey);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(apiKey: apiKey),
                  ),
                );
              },
              child: const Text('Save API Key'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveApiKey(String apiKey) async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'api_keys.db'),
      version: 1,
    );

    await database.execute(
      'CREATE TABLE IF NOT EXISTS api_keys (api_key TEXT PRIMARY KEY)',
    );

    await database.rawInsert(
      'INSERT OR REPLACE INTO api_keys (api_key) VALUES (?)',
      [apiKey],
    );
  }
}