import 'package:fiberapp/menu/maptypes.dart';
import 'package:fiberapp/menu/markertypes.dart';
import 'package:fiberapp/database/trackdatabase.dart';
import 'package:fiberapp/screenrendring.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';

_MapHomeScreenState? homescreenvar;

class MapHomeScreen extends StatefulWidget {
  const MapHomeScreen({Key? key}) : super(key: key);

  @override
  _MapHomeScreenState createState() {
    homescreenvar = _MapHomeScreenState();
    return homescreenvar!;
  }
}

class _MapHomeScreenState extends State<MapHomeScreen> {
  TextEditingController textcontroller = TextEditingController();
  Completer<GoogleMapController> controller1 = Completer();
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(33.42796133580664, 73.085749655962),
    zoom: 14.4746,
  );
  Future<int?> onMapTypeButtonPressed(int? num) async {
    setState(() {
      // Navigator.of(context).pop();
      switch (num) {
        case 1:
          switchscreen!.currentMapType = MapType.normal;
          switchscreen!.mapnumber = 1;
          break;
        case 2:
          switchscreen!.currentMapType = MapType.satellite;
          switchscreen!.mapnumber = 2;
          break;
        case 3:
          switchscreen!.currentMapType = MapType.hybrid;
          switchscreen!.mapnumber = 3;
          break;
        case 4:
          switchscreen!.currentMapType = MapType.terrain;
          switchscreen!.mapnumber = 4;
          break;
        case 4:
          switchscreen!.currentMapType = MapType.none;
          break;
        default:
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * .8,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                mapType: switchscreen!.currentMapType,
                zoomControlsEnabled: true,
                scrollGesturesEnabled: true,
                myLocationEnabled: true,
                compassEnabled: true,
                rotateGesturesEnabled: true,
                mapToolbarEnabled: true,
                tiltGesturesEnabled: true,
                markers: Set<Marker>.of(switchscreen!.markers.values),
                polylines: Set<Polyline>.of(switchscreen!.mapPolylines.values),
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  controller1.complete(controller);
                },
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(40, 20, 20, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              children: <Widget>[
                                FloatingActionButton(
                                  onPressed: () {
                                    setState(() {
                                      if (!switchscreen!.startstop) {
                                        switchscreen!.startstop = true;

                                        // locationSubscription!.resume();
                                        print(switchscreen?.startstop);
                                      } else {
                                        switchscreen!.startstop = false;
                                      }
                                    });
                                    switchscreen?.findlocation();
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.padded,
                                  backgroundColor:
                                      switchscreen!.startstop == true
                                          ? Colors.green
                                          : Colors.black,
                                  child: Text(
                                    switchscreen!.startstop == true
                                        ? 'Stop'
                                        : 'Start',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              children: <Widget>[
                                FloatingActionButton(
                                  onPressed: () {
                                    switchscreen?.clearmap();
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.padded,
                                  backgroundColor: Colors.black,
                                  child: Text(
                                    'Clear',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Column(
                              children: <Widget>[
                                FloatingActionButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Maptypes();
                                        });
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.padded,
                                  backgroundColor: Colors.black,
                                  child: Text(
                                    'Map',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              children: <Widget>[
                                FloatingActionButton(
                                  onPressed: () async {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: Container(
                                              height: 200,
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.all(15),
                                                    child: TextField(
                                                      controller:
                                                          textcontroller,
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            OutlineInputBorder(),
                                                        labelText: 'Track Name',
                                                        hintText:
                                                            'Enter Name Here',
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        DatabaseHelper.instance
                                                            .addtrack(
                                                                textcontroller
                                                                    .text);
                                                      },
                                                      child: Text('Save'))
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.padded,
                                  backgroundColor: Colors.black,
                                  child: Text(
                                    'Save',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              children: <Widget>[
                                FloatingActionButton(
                                  onPressed: () {},
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.padded,
                                  backgroundColor: Colors.black,
                                  child: Text(
                                    'Pic',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Column(
                              children: <Widget>[
                                FloatingActionButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            scrollable: true,
                                            title: Text('Login'),
                                            content: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Form(
                                                child: Column(
                                                  children: <Widget>[
                                                    TextFormField(
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: 'Name',
                                                        icon: Icon(
                                                            Icons.account_box),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            actions: [
                                              RaisedButton(
                                                  child: Text("Submit"),
                                                  onPressed: () {
                                                    // your code
                                                  })
                                            ],
                                          );
                                        });
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.padded,
                                  backgroundColor: Colors.black,
                                  child: Text(
                                    'Video',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                )),
          ],
        ),
        ElevatedButton(
            onPressed: () {
              showModalBottomSheet<void>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                        builder: (BuildContext context, StateSetter state) {
                      return Column(children: <Widget>[
                        SizedBox(height: 20),
                        Markertypes(),
                        SizedBox(height: 30),
                      ]);
                    });
                  });
            },
            child: Text('Icons')),
        ElevatedButton(
          child: Text("Foreground Mode"),
          onPressed: () {
            FlutterBackgroundService().sendData({"action": "setAsForeground"});
          },
        ),
        ElevatedButton(
          child: Text("Background Mode"),
          onPressed: () {
            FlutterBackgroundService().sendData({"action": "setAsBackground"});
          },
        ),
        ElevatedButton(
          child: Text(switchscreen!.text),
          onPressed: () async {
            var isRunning = await FlutterBackgroundService().isServiceRunning();
            if (isRunning) {
              FlutterBackgroundService().sendData(
                {"action": "stopService"},
              );
            } else {
              FlutterBackgroundService.initialize(switchscreen!.onStart);
            }
            if (!isRunning) {
              switchscreen!.text = 'Stop Service';
            } else {
              switchscreen!.text = 'Start Service';
            }
            setState(() {});
          },
        ),
      ],
    );
  }
}
