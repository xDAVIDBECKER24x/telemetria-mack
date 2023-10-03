import 'package:flutter/material.dart';
import 'dart:io';
import 'package:geolocator_platform_interface/src/models/position.dart';
import 'package:path_provider/path_provider.dart';

import 'file_storage.dart';

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
    _printHistory();

  }

  Future<void> _printHistory() async {
    var content = await FileStorage.readCounter("test.txt");
    text = content.toString();
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
        ),actions: [
        Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                _printHistory();
              },
              child: Icon(
                Icons.restart_alt,
                size: 26.0,
              ),
            )),
      ]
      ),
      body: Center(
        child: Column(
          children: [
            // ElevatedButton(onPressed: _printHistory, child: Text("Print History")),
            Text(text)
          ],
        ),
      ),
    );
  }
}
