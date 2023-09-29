import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Telemetria Mack',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Telemetria Mack'),
      // home: VelocimeterWidget(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final stopwatch = Stopwatch();
  Position? position;
  double? speed;
  int laps = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _getCurrentPosition();
    });
  }

  void _startCounter() {
    stopwatch.start();
  }

  void _stopCounter() {
    _timer.cancel();
    setState(() {
      stopwatch.stop();
    });
  }

  void _resetCounter() {
    _timer.cancel();
    setState(() {
      stopwatch.reset();
    });
  }

  void _getCurrentPosition() async {
    Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      position = newPosition;
      speed = newPosition.speed * 3.6;
      stopwatch;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Tempo',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              stopwatch.elapsed.toString(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            // Text(
            //   "Voltas",
            //   style: Theme.of(context).textTheme.headlineSmall,
            // ),
            // Text(
            //   laps.toString(),
            //   style: Theme.of(context).textTheme.headlineMedium,
            // ),

            Text(
              "Posição",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              position != null ? position.toString() : "Calculando",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              "Velocidade",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Container(
              child: RadialGauge(
                track: RadialTrack(
                    color: Colors.grey,
                    start: 0,
                    end: 80,
                    trackStyle: TrackStyle(
                        showLastLabel: false,
                        secondaryRulerColor: Colors.grey,
                        secondaryRulerPerInterval: 2)),
                needlePointer: [
                  NeedlePointer(
                    value: speed != null ? speed! : 0,
                    color: Colors.red,
                    tailColor: Colors.black,
                    tailRadius: 0,
                    needleStyle: NeedleStyle.gaugeNeedle,
                    needleWidth: 8,
                  ),
                ],
              ),
            ),

            // Text(
            //   speed.toString(),
            //   style: Theme.of(context).textTheme.headlineMedium,
            // ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.all(12),
                  child: ElevatedButton(
                      onPressed: _resetCounter,
                      child: Text('Reset', style: TextStyle(fontSize: 24))),
                ),
                Container(
                  margin: EdgeInsets.all(12),
                  child: ElevatedButton(
                      onPressed: _stopCounter,
                      child: Text('Stop', style: TextStyle(fontSize: 24))),
                ),
                Container(
                  margin: EdgeInsets.all(12),
                  child: ElevatedButton(
                    onPressed: _startCounter,
                    child: Text(
                      'Start',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
