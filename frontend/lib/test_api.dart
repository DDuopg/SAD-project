import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Database Write Test',
      home: DatabaseTestScreen(),
    );
  }
}

class DatabaseTestScreen extends StatefulWidget {
  @override
  _DatabaseTestScreenState createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  String responseMessage = '';

  // Function to test backend database write
  Future<void> writeToDatabase() async {
    try {
      final url = Uri.parse('http://10.0.2.2:8080/api/firebase/add'); // Replace with your backend endpoint
      final body = jsonEncode({
        "name": "Jn Doe",
        "email": "johndoe@example.com",
      });

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        setState(() {
          responseMessage = 'Success: ${response.body}';
        });
      } else {
        setState(() {
          responseMessage = 'Error: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        responseMessage = 'Exception: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database Write Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: writeToDatabase,
              child: Text('Send Data to Backend'),
            ),
            SizedBox(height: 20),
            Text(
              responseMessage,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
