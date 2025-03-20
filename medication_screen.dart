import 'package:flutter/material.dart';

class MedicationScreen extends StatefulWidget {
  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final TextEditingController _medicationController = TextEditingController();
  List<String> medications = [];

  void addMedication() {
    if (_medicationController.text.isNotEmpty) {
      setState(() {
        medications.add(_medicationController.text);
        _medicationController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Medication Added")),
      );
    }
  }

  void removeMedication(int index) {
    setState(() {
      medications.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Medication Removed")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Medication Tracker")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _medicationController,
              decoration: InputDecoration(
                labelText: "Enter Medication Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: addMedication,
              child: Text("Add Medication"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: medications.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(medications[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeMedication(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
