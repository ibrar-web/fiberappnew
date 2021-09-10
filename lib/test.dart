import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:background_location/background_location.dart';

Future<void>? onStart() {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();
  service.onDataReceived.listen((event) {
    if (event!["action"] == "setAsForeground") {
      service.setForegroundMode(true);
      return;
    }

    if (event["action"] == "setAsBackground") {
      service.setForegroundMode(false);
    }

    if (event["action"] == "stopService") {
      service.stopBackgroundService();
    }
  });

  // bring to foreground
  service.setForegroundMode(true);
  Timer.periodic(Duration(seconds: 60), (timer) async {
    if (!(await service.isServiceRunning())) timer.cancel();
    service.setNotificationInfo(
      title: "My App Service",
      content: "Updated at {DateTime.now()}",
    );

    backfetch("ss");
    service.sendData(
      {"current_date": DateTime.now().toIso8601String()},
    );
  });
}

void backfetch(String arguments) async {
  final service = FlutterBackgroundService();
  await BackgroundLocation.startLocationService(distanceFilter: 1);
  BackgroundLocation.getLocationUpdates((location) {
    service.setNotificationInfo(
      title: "FberApp",
      content: "${location.latitude}",
    );
  });
}

_TestState? test;

class Test extends StatefulWidget {
  @override
  _TestState createState() {
    test = _TestState();
    return test!;
  }
}

class _TestState extends State<Test> {
  String text = "Stop Service";
  String latitude = 'waiting...';
  String longitude = 'waiting...';
  String altitude = 'waiting...';
  String accuracy = 'waiting...';
  String bearing = 'waiting...';
  String speed = 'waiting...';
  String time = 'waiting...';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Service App'),
        ),
        body: Column(
          children: [
            StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().onDataReceived,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data!;
                DateTime? date = DateTime.tryParse(data["current_date"]);
                return Text(date.toString());
              },
            ),
            ElevatedButton(
              child: Text("Foreground Mode"),
              onPressed: () {
                FlutterBackgroundService()
                    .sendData({"action": "setAsForeground"});
              },
            ),
            ElevatedButton(
              child: Text("Background Mode"),
              onPressed: () {
                FlutterBackgroundService()
                    .sendData({"action": "setAsBackground"});
              },
            ),
            ElevatedButton(
              child: Text(text),
              onPressed: () async {
                var isRunning =
                    await FlutterBackgroundService().isServiceRunning();
                if (isRunning) {
                  FlutterBackgroundService().sendData(
                    {"action": "stopService"},
                  );
                } else {
                  FlutterBackgroundService.initialize(onStart);
                }
                if (!isRunning) {
                  text = 'Stop Service';
                } else {
                  text = 'Start Service';
                }
                setState(() {});
              },
            ),
            locationData('Latitude: ' + latitude),
            locationData('Longitude: ' + longitude),
            locationData('Altitude: ' + altitude),
            locationData('Accuracy: ' + accuracy),
            locationData('Bearing: ' + bearing),
            locationData('Speed: ' + speed),
            locationData('Time: ' + time),
            ElevatedButton(
                onPressed: () async {
                  BackgroundLocation.getLocationUpdates((location) {
                    setState(() {
                      latitude = location.latitude.toString();
                      longitude = location.longitude.toString();
                      accuracy = location.accuracy.toString();
                      altitude = location.altitude.toString();
                      bearing = location.bearing.toString();
                      speed = location.speed.toString();
                      time = DateTime.fromMillisecondsSinceEpoch(
                              location.time!.toInt())
                          .toString();
                    });
                  });
                },
                child: Text('Start Location Service')),
            ElevatedButton(
                onPressed: () {
                  BackgroundLocation.stopLocationService();
                },
                child: Text('Stop Location Service')),
            ElevatedButton(
                onPressed: () {
                  getCurrentLocation();
                },
                child: Text('Get Current Location')),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            FlutterBackgroundService().sendData({
              "hello": "world",
            });
          },
          child: Icon(Icons.play_arrow),
        ),
      ),
    );
  }

  Widget locationData(String data) {
    return Text(
      data,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }

  void getCurrentLocation() {
    BackgroundLocation().getCurrentLocation().then((location) {
      print('This is current Location ' + location.toMap().toString());
    });
  }
}
