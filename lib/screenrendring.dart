import 'dart:typed_data';
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
  String? markercurrenttype = "fiber";
  String? currentmarker = '';
  List<String> markertypelist = ["fiber", "power"];
  List<String> currentmarkerslist = [];
  var markerlist = [
    [
      'comms_pole',
      'concrete_pole',
      'drop_pole',
      'fdh',
      'fiber_interconnect',
      'joint_usage_pole',
      'pole to pole guy',
      'riser_pole',
      'telephone pole',
      'utility pole',
      'handhole1',
      'manhole',
      'trafficcabinet',
      'optical cross connect',
      'optical repeater',
    ],
    [
      'utility pole',
      'joint usage with power trasnformer',
      'non sb power supply',
      'power pole',
      'power trasnformer platform',
      'power trasnformer',
      'sb power supply',
      'steel pole',
      'transmission line contact',
      'handhole1',
      'manhole',
      'ac power inserter',
      'centralized power supply',
      'comms_pole',
      'concrete_pole',
      'drop_pole',
    ]
  ];
  Map<PolylineId, Polyline> mapPolylines = {};
  int _polylineIdCounter = 1;
  List<LatLng> linepoints = <LatLng>[];
  List? uploadtrack = [];
  List? markerposition = [];
  Map<MarkerId, Marker> markers = {};
  int id = 1;
  BitmapDescriptor? myIcon;
  Future addMarker(LatLng position) async {
    markerposition?.add({'$markercurrenttype/$currentmarker': position});
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
        infoWindow: InfoWindow(
          title: icondetails.text,
        ),
        onTap: () {
          print('markerId asdasdasdasdasdasdasdasdas');
          print(markerId);
        },
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: position);

    id = id + 1;
    setState(() {
      icondetails = TextEditingController(text: '');
      markers[markerId] = marker;
    });
    GoogleMapController? controller;
    controller!.showMarkerInfoWindow(MarkerId('ID_MARKET'));
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
