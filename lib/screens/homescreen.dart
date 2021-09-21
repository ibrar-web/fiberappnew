import 'package:fiberapp/menu/maptypes.dart';
import 'package:fiberapp/menu/markertypes.dart';
import 'package:fiberapp/database/trackdatabase.dart';
import 'package:fiberapp/screenrendring.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:background_location/background_location.dart';
import 'package:geolocator/geolocator.dart';

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
  ButtonStyle buttonstyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.black),
      padding: MaterialStateProperty.all(EdgeInsets.all(0)),
      textStyle: MaterialStateProperty.all(TextStyle(fontSize: 15)));
  TextEditingController textcontroller = TextEditingController();
  final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
  Completer<GoogleMapController> controller1 = Completer();
  CameraPosition kGooglePlex = CameraPosition(
    target: LatLng(33.42796133580664, 73.085749655962),
    zoom: 14.4746,
  );

  Future<void> getCurrentPosition() async {
    final GoogleMapController controller = await controller1.future;
    final position = await geolocatorPlatform.getCurrentPosition();
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 15),
      ),
    );
  }

  Future<int?> onMapTypeButtonPressed(int? num) async {
    setState(() {
      Navigator.of(context).pop();
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
    getCurrentPosition();
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
                initialCameraPosition: kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  controller1.complete(controller);
                },
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: 120,
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: switchscreen!.startstop == true
                              ? MaterialStateProperty.all(Colors.green)
                              : MaterialStateProperty.all(Colors.black),
                          padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                          textStyle: MaterialStateProperty.all(
                              TextStyle(fontSize: 15))),
                      onPressed: () async {
                        if (!switchscreen!.startstop) {
                          setState(() {
                            switchscreen!.startstop = true;
                          });
                          await BackgroundLocation.startLocationService(
                              distanceFilter: 0);
                        } else {
                          setState(() {
                            switchscreen!.startstop = false;
                          });

                          await BackgroundLocation.stopLocationService();
                        }

                        switchscreen?.findlocation();
                      },
                      child: Text(
                        switchscreen!.startstop == true ? 'Stop' : 'Start',
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
                Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      onPressed: () {
                        switchscreen?.clearmap();
                      },
                      style: buttonstyle,
                      child: Text(
                        'Clear',
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
                Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Maptypes();
                            });
                      },
                      style: buttonstyle,
                      child: Text(
                        'Map',
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
                Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      style: buttonstyle,
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
                                          controller: textcontroller,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Track Name',
                                            hintText: 'Enter Name Here',
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            DatabaseHelper.instance
                                                .addtrack(textcontroller.text);
                                            setState(() {
                                              switchscreen!.startstop = false;
                                              textcontroller.text = '';
                                            });
                                          },
                                          child: Text('Save'))
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
                Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: buttonstyle,
                      child: Text(
                        'Pic',
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
                Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      style: buttonstyle,
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                scrollable: true,
                                title: Text('Login'),
                                content: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Form(
                                    child: Column(
                                      children: <Widget>[
                                        TextFormField(
                                          decoration: InputDecoration(
                                            labelText: 'Name',
                                            icon: Icon(Icons.account_box),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        // your code
                                      },
                                      child: Text("Submit")),
                                ],
                              );
                            });
                      },
                      child: Text(
                        'Video',
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
              ],
            ),
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
                      return Container(
                        height: 210,
                        child: SingleChildScrollView(
                          child: Markertypes(),
                        ),
                      );
                    });
                  });
            },
            child: Text('Icons')),
      ],
    );
  }
}
