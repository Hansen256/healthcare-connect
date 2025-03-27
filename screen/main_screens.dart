import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospital Management App',
      debugShowCheckedModeBanner: false,
      home: MainUI(),
    );
  }
}

/// MainUI with Bottom Navigation Bar
class MainUI extends StatefulWidget {
  @override
  _MainUIState createState() => _MainUIState();
}

class _MainUIState extends State<MainUI> {
  int _selectedIndex = 0;

  // List of screens for navigation.
  final List<Widget> _screens = [
    HomeScreen(),
    AppointmentsScreen(),
    MedicationScreen(),
    ProfileScreen(),
    HealthRecordsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Appointments"),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: "Medication"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Records"),
        ],
      ),
    );
  }
}

/// Home Screen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hospital Management"),
      ),
      body: Center(
        child: Text(
          "Welcome to the Hospital Management App!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

/// Appointments Screen
class AppointmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Appointments"),
      ),
      body: Center(
        child: Text(
          "Appointments Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

/// Medication Tracker Screen
class MedicationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medication Tracker"),
      ),
      body: Center(
        child: Text(
          "Medication Tracker Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

/// Profile Screen
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Center(
        child: Text(
          "Profile Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

/// Health Records Screen
class HealthRecordsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Health Records"),
      ),
      body: Center(
        child: Text(
          "Health Records Screen",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

/// PDF Viewer Screen
class PDFViewerScreen extends StatelessWidget {
  final String pdfPath;
  PDFViewerScreen({required this.pdfPath});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Viewer"),
      ),
      body: Center(
        child: Text("Displaying PDF: $pdfPath"),
      ),
    );
  }
}

/// Image Viewer Screen
class ImageViewerScreen extends StatelessWidget {
  final String imagePath;
  ImageViewerScreen({required this.imagePath});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Viewer"),
      ),
      body: Center(
        child: Text("Displaying Image: $imagePath"),
      ),
    );
  }
}
