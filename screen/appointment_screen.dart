import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentsScreen extends StatefulWidget {
  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<String> appointments = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      appointments = prefs.getStringList("appointments") ?? [];
    });
  }

  Future<void> _saveAppointments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("appointments", appointments);
  }

  void _cancelAppointment(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Cancel Appointment?"),
        content: Text("Are you sure you want to cancel this appointment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                appointments.removeAt(index);
                _saveAppointments(); // Save changes
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Yes, Cancel"),
          ),
        ],
      ),
    );
  }

  void _addAppointment(String newAppointment) {
    setState(() {
      appointments.add(newAppointment);
      _saveAppointments(); // Save after adding
    });
  }

  void _showAddAppointmentDialog() {
    TextEditingController appointmentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Appointment"),
        content: TextField(
          controller: appointmentController,
          decoration: InputDecoration(labelText: "Enter appointment details"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (appointmentController.text.isNotEmpty) {
                _addAppointment(appointmentController.text);
              }
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Appointments")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.event, color: Colors.blue),
                title: Text(appointments[index]),
                trailing: IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red),
                  onPressed: () => _cancelAppointment(index),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAppointmentDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
