import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum SortOption { name, date }

class HealthRecordsScreen extends StatefulWidget {
  @override
  _HealthRecordsScreenState createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  List<Map<String, dynamic>> _files = [];
  String _selectedCategory = "All";
  SortOption _selectedSort = SortOption.name;

  final List<String> _categories = [
    "All",
    "Prescriptions",
    "Lab Reports",
    "Scans",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> fileList = appDir.listSync();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> savedCategories = Map<String, String>.from(
      jsonDecode(prefs.getString("file_categories") ?? "{}"),
    );

    List<Map<String, dynamic>> tempFiles = fileList.map((file) {
      FileStat stat = file.statSync();
      String fileName = file.uri.pathSegments.last;
      return {
        "name": fileName,
        "path": file.path,
        "category": savedCategories[fileName] ?? "Other",
        "date": stat.modified,
      };
    }).toList();

    setState(() {
      _files = tempFiles;
    });
  }

  Future<void> _saveCategory(String fileName, String category) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> savedCategories = Map<String, String>.from(
      jsonDecode(prefs.getString("file_categories") ?? "{}"),
    );

    savedCategories[fileName] = category;
    await prefs.setString("file_categories", jsonEncode(savedCategories));
  }

  void _changeCategory(int index) {
    showDialog(
      context: context,
      builder: (context) {
        String newCategory = _files[index]["category"];
        return AlertDialog(
          title: Text("Change Category"),
          content: DropdownButton<String>(
            value: newCategory,
            onChanged: (value) {
              setState(() {
                _files[index]["category"] = value!;
              });
            },
            items: _categories
                .where((cat) => cat != "All")
                .map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                })
                .toList(),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Save"),
              onPressed: () {
                setState(() {
                  _saveCategory(_files[index]["name"], _files[index]["category"]);
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredFiles = _selectedCategory == "All"
        ? _files
        : _files.where((file) => file["category"] == _selectedCategory).toList();

    if (_selectedSort == SortOption.name) {
      filteredFiles.sort((a, b) => a["name"].compareTo(b["name"]));
    } else {
      filteredFiles.sort((a, b) => b["date"].compareTo(a["date"]));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Health Records"),
        actions: [
          DropdownButton<String>(
            value: _selectedCategory,
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
            items: _categories.map((category) {
              return DropdownMenuItem(value: category, child: Text(category));
            }).toList(),
          ),
          PopupMenuButton<SortOption>(
            onSelected: (SortOption option) {
              setState(() {
                _selectedSort = option;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              PopupMenuItem(value: SortOption.name, child: Text("Sort by Name")),
              PopupMenuItem(value: SortOption.date, child: Text("Sort by Date")),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: filteredFiles.length,
          itemBuilder: (context, index) {
            return Card(
                child: ListTile(
                  leading: _getFileThumbnail(filteredFiles[index]['path']),
                  title: Text(filteredFiles[index]['name']),
                  subtitle: Text("Category: ${filteredFiles[index]['category']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _changeCategory(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(index),
                      ),
                    ],
                  ),
                  onTap: () => _openFile(filteredFiles[index]['path']),
                ),
              );

          },
        ),
      ),
    );
  }
}

// Thumbnail helper function
Widget _getFileThumbnail(String path) {
  if (path.endsWith('.pdf')) {
    return Icon(Icons.picture_as_pdf, color: Colors.red, size: 40);
  } else if (path.endsWith('.jpg') || path.endsWith('.png')) {
    return Image.file(File(path), width: 40, height: 40, fit: BoxFit.cover);
  } else {
    return Icon(Icons.insert_drive_file, size: 40);
  }
}

//Add a delete function and update the UI:
Future<void> _deleteFile(int index) async {
  File fileToDelete = File(_files[index]["path"]);
  
  if (await fileToDelete.exists()) {
    await fileToDelete.delete();

    // Remove from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> savedCategories = Map<String, String>.from(
      jsonDecode(prefs.getString("file_categories") ?? "{}"),
    );

    savedCategories.remove(_files[index]["name"]);
    await prefs.setString("file_categories", jsonEncode(savedCategories));

    setState(() {
      _files.removeAt(index);
    });
  }
}

void _confirmDelete(int index) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Delete File?"),
        content: Text("Are you sure you want to delete this health record?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              _deleteFile(index);
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}


// adding a floating action button
floatingActionButton: FloatingActionButton(
  onPressed: _pickFile,
  child: Icon(Icons.upload_file),
  backgroundColor: Colors.blue,
),

// Implement File Selection & Saving
Future<void> _pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    File file = File(result.files.single.path!);
    String fileName = result.files.single.name;

    // Ask user for a category
    String? category = await _askForCategory(fileName);

    if (category != null) {
      _saveFile(file, category);
    }
  }
}

Future<String?> _askForCategory(String fileName) async {
  TextEditingController categoryController = TextEditingController();
  return await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Set Category for $fileName"),
        content: TextField(
          controller: categoryController,
          decoration: InputDecoration(labelText: "Category"),
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Save"),
            onPressed: () => Navigator.pop(context, categoryController.text),
          ),
        ],
      );
    },
  );
}

Future<void> _pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    File file = File(result.files.single.path!);
    String fileName = result.files.single.name;

    // Ask user for a category
    String? category = await _askForCategory(fileName);

    if (category != null) {
      _saveFile(file, category);
    }
  }
}

Future<String?> _askForCategory(String fileName) async {
  TextEditingController categoryController = TextEditingController();
  return await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Set Category for $fileName"),
        content: TextField(
          controller: categoryController,
          decoration: InputDecoration(labelText: "Category"),
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Save"),
            onPressed: () => Navigator.pop(context, categoryController.text),
          ),
        ],
      );
    },
  );
}

Future<void> _saveFile(File file, String category) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve existing files
  List<String> fileList = prefs.getStringList("health_records") ?? [];
  Map<String, String> fileCategories =
      Map<String, String>.from(jsonDecode(prefs.getString("file_categories") ?? "{}"));

  // Save new file
  fileList.add(file.path);
  fileCategories[file.path] = category;

  await prefs.setStringList("health_records", fileList);
  await prefs.setString("file_categories", jsonEncode(fileCategories));

  setState(() {
    _files.add({"name": file.path.split('/').last, "path": file.path, "category": category});
  });
}

