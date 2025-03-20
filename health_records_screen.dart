import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class HealthRecordsScreen extends StatefulWidget {
  @override
  _HealthRecordsScreenState createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  List<String> filePaths = [];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      filePaths = prefs.getStringList("health_records") ?? [];
    });
  }

  Future<void> _saveFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("health_records", filePaths);
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        filePaths.add(result.files.single.path!);
        _saveFiles(); // Save file paths
      });
    }
  }

  void _removeFile(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete File?"),
        content: Text("Are you sure you want to delete this file?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                filePaths.removeAt(index);
                _saveFiles(); // Save changes
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Yes, Delete"),
          ),
        ],
      ),
    );
  }

  void _openFile(String filePath) {
    File file = File(filePath);
    if (file.existsSync()) {
      // In a real app, use a package like open_file to open the file
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Opening ${file.path}"),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("File not found!"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Health Records")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: filePaths.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.file_present, color: Colors.blue),
                title: Text(filePaths[index].split('/').last),
                subtitle: Text(filePaths[index]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.open_in_new, color: Colors.green),
                      onPressed: () => _openFile(filePaths[index]),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFile(index),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        child: Icon(Icons.upload_file),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
