import 'dart:typed_data';
import 'package:fiberapp/menu/updatemarker.dart';
import 'package:fiberapp/screens/homescreen.dart';
import 'package:fiberapp/screens/setting.dart';
import 'package:fiberapp/screens/tracks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:background_location/background_location.dart';
import 'package:shared_preferences/shared_preferences.dart';

_ScreenrendringState? switchscreen;

class Screenrendring extends StatefulWidget {
  const Screenrendring({Key? key}) : super(key: key);

  @override
  _ScreenrendringState createState() {
    switchscreen = _ScreenrendringState();
    return switchscreen!;
  }
}

class _ScreenrendringState extends State<Screenrendring> {
  TextEditingController icondetails = TextEditingController(text: '');
  TextEditingController markercontroltime = TextEditingController(text: '');
  //use for setting time interval for adding marker
  int? time;
  //use for check how to add marker
  int? markercontrol;
  String? screenname;
  bool startstop = false;
  MapType currentMapType = MapType.normal;
  int? mapnumber = 1;
  String? markercurrenttype = "category1";
  String? currentmarker = '';
  List<String> markertypelist = ["category1"];
  List<String> currentmarkerslist = [];
  var markerlist = [
    [
      'FDH',
      'Fiber-Interconnaction',
      'Guy',
      'Handhde',
      'Junction-Blockv',
      'ONT',
      'Optical-Cross-Connect',
      'Optical-Distribution-Frame',
      'Optical-Line-Terminal',
      'Optical-Repeator',
      'Patch-Pannel'
    ]
  ];
  Map<PolylineId, Polyline> mapPolylines = {};
  int _polylineIdCounter = 1;
  List<LatLng> linepoints = <LatLng>[];
  List? uploadtrack = [];
  List? markerposition = [];
  Map<MarkerId, Marker> markers = {};
  int id = 0;
  BitmapDescriptor? myIcon;
  Future addMarker(LatLng position, String? detail, int positionid) async {
    markerposition?.add({
      '$markercurrenttype/$currentmarker': position,
      'id': id,
      "detail": detail
    });
    ByteData data = await rootBundle
        .load('asset/images/$markercurrenttype/$currentmarker.png');
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: 80);
    ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List markerIcon =
        (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List();
    MarkerId markerId = MarkerId(id.toString());
    Marker marker = Marker(
        markerId: markerId,
        onTap: () {
          onMarkerTapped(markerId, positionid, position);
        },
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: position);

    id = id + 1;
    setState(() {
      icondetails = TextEditingController(text: '');
      markers[markerId] = marker;
    });
  }

  void onMarkerTapped(MarkerId markerId, int id, LatLng position) async {
    String info = '';
    for (int i = 0; i < markerposition!.length; i++) {
      if (markerposition![i]['id'] == id) {
        setState(() {
          info = markerposition![i]['detail'];
        });
      }
    }
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 500),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 250,
            margin: EdgeInsets.only(bottom: 100, left: 20, right: 20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(40),
            ),
            child: SizedBox.expand(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black38,
                    ),
                    height: 50,
                    child: Text(info.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 20)),
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              for (int i = 0; i < markerposition!.length; i++) {
                                if (markerposition![i]['id'] == id) {
                                  markerposition!.removeAt(i);
                                }
                              }
                              setState(() => markers.remove(markerId));
                              Navigator.of(context).pop();
                            },
                            child: Text('Delete')),
                        ElevatedButton(
                            onPressed: () {
                              switchscreen?.icondetails.text = '';
                              Navigator.of(context).pop();

                              infoUpdate(id, info);
                            },
                            child: Text('Update Marker Info')),

                        ///update marker using update marker widget passing param for conditio if user update or cancel
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              showModalBottomSheet<void>(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter state) {
                                      return Container(
                                        height: 220,
                                        child: SingleChildScrollView(
                                          child: UpdateMarker(
                                              markerposition: position,
                                              id: id,
                                              markerid: markerId),
                                        ),
                                      );
                                    });
                                  });
                            },
                            child: Text('Update Marker')),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Close'))
                      ])
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }

  void infoUpdate(int id, String info) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Old Info : $info"),
        content: TextField(
          controller: switchscreen?.icondetails,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), hintText: 'Enter Icon Details'),
        ),
        actions: <Widget>[
          ElevatedButton(
              onPressed: () {
                for (int i = 0; i < markerposition!.length; i++) {
                  if (markerposition![i]['id'] == id) {
                    setState(() {
                      markerposition![i]['detail'] = icondetails.text;
                    });
                    print(icondetails.text);
                    print(markerposition![i]['detail']);
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text('Update'))
        ],
      ),
    );
  }

  Future<int?> findlocation() async {
    final GoogleMapController controller =
        await homescreenvar!.controller1.future;
    BackgroundLocation.getLocationUpdates((currentLocation) async {
      final service = FlutterBackgroundService();
      if (startstop) {
        service.setForegroundMode(true);
        if (await (service.isServiceRunning())) {
          service.setNotificationInfo(
            title: "My App Service",
            content: "Updated at ",
          );
        }

        setState(() {
          uploadtrack?.add({
            'lat': currentLocation.latitude!,
            'lng': currentLocation.longitude!
          });
        });
        drawpolyline(currentLocation.latitude!, currentLocation.longitude!);
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(
                    currentLocation.latitude!, currentLocation.longitude!),
                zoom: 15),
          ),
        );
      }
    });
  }

  void drawpolyline(first, second) {
    linepoints.add(LatLng(first, second));
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);
    final Polyline polyline = Polyline(
      patterns: [PatternItem.dash(15), PatternItem.gap(10)],
      polylineId: polylineId,
      consumeTapEvents: true,
      color: Colors.red,
      width: 7,
      points: linepoints,
    );

    setState(() {
      mapPolylines[polylineId] = polyline;
    });
  }

  void clearmap() {
    setState(() {
      linepoints = [];
      mapPolylines = {};
      markers = {};
      markerposition = [];
      uploadtrack = [];
    });
  }

  Future<int?> getvalues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var num = prefs.getInt('markercontrol');
    var tim = prefs.getInt('markercontrolinterval');
    setState(() {
      markercontrol = num;
      markercontroltime = TextEditingController(text: tim.toString());
    });
  }

  Widget? screensfunction(String? name) {
    setState(() {
      screenname = name;
    });
    switch (name) {
      case 'homescreen':
        print('home');
        return MapHomeScreen();
        // ignore: dead_code
        break;
      case 'tracks':
        print('track');
        return Trackspage();
        // ignore: dead_code
        break;
      case 'setting':
        print('track');
        return Setting();
        // ignore: dead_code
        break;
      default:
        return MapHomeScreen();
    }
  }

  @override
  void initState() {
    currentmarkerslist = markerlist[0];
    currentmarker = currentmarkerslist[0];
    getvalues();
    super.initState();
  }

  String text = "Stop Service";
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Container(
        child: screensfunction(screenname),
      ),
    );
  }
}

void onStart() {
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
  Timer.periodic(Duration(seconds: 1), (timer) async {
    if (!(await service.isServiceRunning())) timer.cancel();
    // service.setNotificationInfo(
    //   title: "My App Service",
    //   content: "Updated at ",
    // );

    service.sendData(
      {"current_date": DateTime.now().toIso8601String()},
    );
  });
}
