// appointment booking
//Frontend Implementation 
// login form starts
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    final response = await http.post(
      Uri.parse('http://your-backend-url/login/'),
      body: jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Token: ${data['access']}');
    } else {
      print('Login failed!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
// login form ends



//Appointment Booking Screen starts
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppointmentBookingScreen extends StatefulWidget {
  @override
  _AppointmentBookingScreenState createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  String? selectedDoctor; // Holds the selected doctor's ID
  DateTime? selectedDate; // Holds the selected appointment date and time
  final List<Map<String, String>> doctors = []; // Will be populated dynamically
  final String backendUrl = 'http://your-backend-url'; // Replace with your backend URL

  // Fetch available doctors from the backend
  Future<void> fetchDoctors() async {
    final response = await http.get(Uri.parse('$backendUrl/doctors/')); // Backend endpoint for doctors
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        doctors.clear();
        doctors.addAll(data.map((doc) => {'id': doc['id'], 'name': doc['username']}));
      });
    } else {
      print('Failed to fetch doctors.');
    }
  }

  // Send appointment booking request to the backend
  Future<void> bookAppointment() async {
    if (selectedDoctor == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a doctor and date/time!')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('$backendUrl/appointments/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'doctor': selectedDoctor,
        'patient': '1', // Replace with the logged-in user's ID (you can fetch this dynamically)
        'date': selectedDate!.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
        'time': selectedDate!.toIso8601String().split('T')[1].split('.')[0], // Format as HH:MM:SS
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment booked successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book appointment.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDoctors(); // Fetch available doctors when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown to select a doctor
            DropdownButtonFormField<String>(
              value: selectedDoctor,
              onChanged: (value) => setState(() => selectedDoctor = value),
              items: doctors.map((doc) {
                return DropdownMenuItem(
                  value: doc['id'],
                  child: Text(doc['name']!),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Select Doctor'),
            ),
            SizedBox(height: 20),

            // Button to select date and time
            Text('Select Date and Time', style: TextStyle(fontSize: 16)),
            ElevatedButton(
              onPressed: () {
                DatePicker.showDateTimePicker(
                  context,
                  showTitleActions: true,
                  onConfirm: (date) => setState(() => selectedDate = date),
                  currentTime: DateTime.now(),
                );
              },
              child: Text(selectedDate == null
                  ? 'Pick Date & Time'
                  : '${selectedDate!.toLocal()}'),
            ),
            SizedBox(height: 20),

            // Submit button
            Center(
              child: ElevatedButton(
                onPressed: bookAppointment,
                child: Text('Book Appointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//Appointment Booking Screen ends


//Real-Time Updates
//real-time update listenner begins
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AppointmentUpdates extends StatefulWidget {
  @override
  _AppointmentUpdatesState createState() => _AppointmentUpdatesState();
}

class _AppointmentUpdatesState extends State<AppointmentUpdates> {
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://your-backend-url/ws/appointments/'),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Appointment Updates')),
      body: StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Text(
                '${snapshot.data}',
                style: TextStyle(fontSize: 18),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
//real-time update listenner ends

//Notifications
//widget for notification listening and testing:
//starts
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationListener extends StatefulWidget {
  @override
  _NotificationListenerState createState() => _NotificationListenerState();
}

class _NotificationListenerState extends State<NotificationListener> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    // Request permissions for iOS
    _firebaseMessaging.requestPermission();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Notification Title: ${message.notification!.title}');
        print('Notification Body: ${message.notification!.body}');
      }
    });

    // Print the device token (for testing)
    _firebaseMessaging.getToken().then((token) {
      print('Device Token: $token');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Push Notifications')),
      body: Center(child: Text('Listening for notifications...')),
    );
  }
}

//ends


//Scheduling Notifications
//starts
//ends