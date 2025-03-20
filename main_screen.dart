import 'package:flutter/material.dart';
import 'medication_screen.dart';  // Import the medication tracker screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospital Management App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),  // Define the home screen below
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MedicationScreen()),
                );
              },
              child: Text("Go to Medication Tracker"),
            ),
          ],
        ),
      ),
    );
  }
}
