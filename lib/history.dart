import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:telemetria_mack/telemetry.dart';
import 'file_storage.dart';

class History extends StatefulWidget {
  History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  String text = "Nothing";
  List<dynamic> telemetry = [];
  List<FlSpot> dataChart = [];

  @override
  void initState() {
    super.initState();
    _printHistory();
  }

  Future<void> _printHistory() async {
    var content = await FileStorage.readCounter("test.txt");
    text = content.toString();
    telemetry = jsonDecode(text);
    for (var i = 0; i < telemetry.length; i++) {
      double timestamp = double.parse(telemetry[i]['miliseconds']);
      double speed = telemetry[i]['speed'];

      dataChart.add(FlSpot(timestamp / 1000, speed));
    }
    setState(() {
      text;
      dataChart;
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
          actions: [
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
          ]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                "Gráfico Velocidade",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Center(
                child: Container(
                    height: 350,
                    width: MediaQuery.of(context).size.width,
                    child: LineChart(
                      LineChartData(
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          // The red line
                          LineChartBarData(
                            spots: dataChart,
                            isCurved: true,
                            barWidth: 3,
                            color: Colors.redAccent,
                            dotData: FlDotData(
                              show: false,
                            ),
                          ),
                        ],
                      ),
                      swapAnimationDuration: Duration(milliseconds: 150),
                      // Optional
                      swapAnimationCurve: Curves.linear, // Optional
                    ))),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                "Raw Data",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Text(text),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
