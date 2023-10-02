import 'package:flutter/material.dart';
import 'dart:io';
import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:path_provider/path_provider.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String text = "Nothing";

  @override
  void initState() {
    super.initState();
    setState(() {
      text;
    });
  }

  Future<String> _readFile() async {
    String text = "";
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/test.txt');
      text = await file.readAsString();
    } catch (e) {
      print("Couldn't read file");
    }
    return text;
  }

  Future<void> _printHistory() async {
    text = await _readFile();
    setState(() {
      text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(onPressed: _printHistory, child: Text("Print History")),
            Text(text)
          ],
        ),
      ),
    );
  }
}
