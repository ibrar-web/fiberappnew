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
    markerposition
        ?.add({'$markercurrenttype/$currentmarker': position, 'id': id});
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
          onMarkerTapped(markerId, detail, positionid, position);
        },
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: position);

    id = id + 1;
    setState(() {
      icondetails = TextEditingController(text: '');
      markers[markerId] = marker;
    });
  }

  void onMarkerTapped(
      MarkerId markerId, String? detail, int id, LatLng position) async {
    print(markerposition);
    print(markerposition!.length);
    print(id);
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
            height: 400,
            margin: EdgeInsets.only(bottom: 50, left: 20, right: 20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(40),
            ),
            child: SizedBox.expand(
              child: Column(
                children: [
                  Text(detail.toString()),
                  ElevatedButton(
                      onPressed: () {
                        markerposition!.removeAt(id);
                        setState(() => markers.remove(markerId));
                        Navigator.of(context).pop();
                      },
                      child: Text('Delete')),
                  ElevatedButton(
                      onPressed: () {
                        markerposition!.removeAt(id);
                        setState(() => markers.remove(markerId));
                      },
                      child: Text('Update')),
                  UpdateMarker(markerposition: position),
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
