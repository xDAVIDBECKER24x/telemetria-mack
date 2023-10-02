import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';
import 'package:intl/intl.dart';
import 'package:telemetria_mack/history.dart';

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
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  List<Position> positionsRace = [];
  List<double> speedRace = [];
  List<String> timeRace = [];

  @override
  void initState() {
    super.initState();
    _startCurrentPosition();
  }

  void _startCounter() {
    _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      _getCurrentPosition();
    });
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
    print("Register Race Length :" + positionsRace.length.toString());
    print(positionsRace);
    print(speedRace);
    print(timeRace);
    positionsRace.clear();
    speedRace.clear();
    timeRace.clear();
  }

  void _startCurrentPosition() async {
    Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      position = newPosition;
      speed = 0;
    });
  }

  void _getCurrentPosition() async {
    Position newPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    speed = newPosition.speed * 3.6;
    position = newPosition;

    positionsRace.add(position!);
    speedRace.add(speed!);
    timeRace.add(stopwatch.elapsed.toString());

    setState(() {
      position;
      speed;
      stopwatch;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    String miliseconds = twoDigits(duration.inMilliseconds.remainder(1000));
    return "${twoDigits(duration.inHours)}:$minutes:$seconds:$miliseconds";
  }

  String _formatSpeed(speed) {
    speed = speed.toStringAsFixed(1);
    return speed;
  }
  String _formatCordenate(cordenate) {
    cordenate = cordenate.toStringAsFixed(5);
    return cordenate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [
        Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => History()),
                );
              },
              child: Icon(
                Icons.history,
                size: 26.0,
              ),
            )),
      ]),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Tempo',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                _formatDuration(stopwatch.elapsed),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              //-23,5516 -> 4 casas decimais / 1.10^-4 casa =  10 metros
              Text(
                "Posição",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                position != null ? "Latitude: " + _formatCordenate(position!.latitude) : "Calculando",
                style: Theme.of(context).textTheme.headlineMedium,
              ),Text(
                position != null ? "Longitude: " + _formatCordenate(position!.longitude) : "Calculando",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                "Velocidade (km/h)",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                position != null ? _formatSpeed(speed) : "Calculando",
                style: Theme.of(context).textTheme.headlineMedium,
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
      ),
    );
  }
}
