import 'package:flutter/material.dart';
import 'appointments_screen.dart';
import 'medication_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hospital Management")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome Back!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            
            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(context, "Book Appointment", Icons.calendar_today, AppointmentsScreen()),
                _buildQuickAction(context, "Track Medication", Icons.medication, MedicationScreen()),
              ],
            ),
            SizedBox(height: 20),

            // Upcoming Appointments
            Text("Upcoming Appointments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.event, color: Colors.blue),
                title: Text("Doctor's Consultation"),
                subtitle: Text("March 20, 2025 - 10:00 AM"),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentsScreen()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String title, IconData icon, Widget screen) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
          },
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, size: 30, color: Colors.blue),
          ),
        ),
        SizedBox(height: 5),
        Text(title, textAlign: TextAlign.center),
      ],
    );
  }
}
