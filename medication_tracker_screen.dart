import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicationTrackerScreen extends StatefulWidget {
  @override
  _MedicationTrackerScreenState createState() => _MedicationTrackerScreenState();
}

class _MedicationTrackerScreenState extends State<MedicationTrackerScreen> {
  List<String> medications = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      medications = prefs.getStringList("medications") ?? [];
    });
  }

  Future<void> _saveMedications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("medications", medications);
  }

  void _addMedication() {
    TextEditingController nameController = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Medication"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Medication Name"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  selectedTime = time;
                }
              },
              child: Text("Select Time"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && selectedTime != null) {
                setState(() {
                  medications.add("${nameController.text} - ${selectedTime!.format(context)}");
                  _saveMedications();
                });
                Navigator.pop(context);
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _removeMedication(int index) {
    setState(() {
      medications.removeAt(index);
      _saveMedications();
    });
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
                title: Text(medications[index]),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeMedication(index),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedication,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
