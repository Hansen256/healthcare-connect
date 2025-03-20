import 'package:flutter/material.dart';

class AppointmentScreen extends StatefulWidget {
  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final List<String> doctors = ["Dr. Smith", "Dr. Johnson", "Dr. Patel"];
  String? selectedDoctor;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Local storage for appointments
  List<Map<String, dynamic>> appointments = [];

  void bookAppointment() {
    if (selectedDoctor != null && selectedDate != null && selectedTime != null) {
      setState(() {
        appointments.add({
          'doctor': selectedDoctor,
          'date': "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
          'time': "${selectedTime!.hour}:${selectedTime!.minute}"
        });
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Appointment Booked Successfully!")),
      );

      // Reset fields
      setState(() {
        selectedDoctor = null;
        selectedDate = null;
        selectedTime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book an Appointment")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Doctor Dropdown
            Text("Select Doctor:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedDoctor,
              hint: Text("Choose a doctor"),
              isExpanded: true,
              items: doctors.map((String doctor) {
                return DropdownMenuItem<String>(
                  value: doctor,
                  child: Text(doctor),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDoctor = value;
                });
              },
            ),

            SizedBox(height: 20),

            // Select Date Button
            Text("Select Date:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Text(selectedDate == null
                  ? "Choose Date"
                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
            ),

            SizedBox(height: 20),

            // Select Time Button
            Text("Select Time:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    selectedTime = pickedTime;
                  });
                }
              },
              child: Text(selectedTime == null
                  ? "Choose Time"
                  : "${selectedTime!.hour}:${selectedTime!.minute}"),
            ),

            SizedBox(height: 30),

            // Book Appointment Button
            Center(
              child: ElevatedButton(
                onPressed: bookAppointment,
                child: Text("Book Appointment"),
              ),
            ),

            SizedBox(height: 30),

            // Display Appointments
            Text("Booked Appointments:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Expanded(
        child: ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
            return Card(
                child: ListTile(
                title: Text("Doctor: ${appointments[index]['doctor']}"),
                subtitle: Text("Date: ${appointments[index]['date']} at ${appointments[index]['time']}"),
                trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                    setState(() {
                        appointments.removeAt(index);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Appointment Cancelled")),
                    );
                    },
              ),
             ),
           );
         },
      ),
    ),             
  }
}
