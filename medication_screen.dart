import 'package:flutter/material.dart';

class MedicationScreen extends StatefulWidget {
  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  List<Map<String, dynamic>> medications = [
    {"name": "Paracetamol", "time": "8:00 AM"},
    {"name": "Vitamin D", "time": "12:00 PM"},
    {"name": "Antibiotics", "time": "6:00 PM"},
  ];

  void _addMedication() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        medications.add({
          "name": "New Medication",
          "time": pickedTime.format(context),
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Medication Tracker")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: medications.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.medication, color: Colors.blue),
                title: Text(medications[index]["name"]),
                subtitle: Text("Take at: ${medications[index]["time"]}"),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      medications.removeAt(index);
                    });
                  },
                ),
              ),
            );
          },
        ),
      ),

      // Floating Button to Add Medication Reminder
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedication,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
