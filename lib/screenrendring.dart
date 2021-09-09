import 'dart:typed_data';
import 'package:fiberapp/screens/homescreen.dart';
import 'package:fiberapp/screens/tracks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'dart:ui' as ui;

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
  String? screenname;
  bool startstop = false;
  MapType currentMapType = MapType.normal;
  int? mapnumber = 1;
  String? markercurrenttype = "hole";
  String? currentmarker = '';
  List<String> markertypelist = ["hole", "pole", "power"];
  List<String> currentmarkerslist = ['handhole1', 'handhole2', 'manhole'];
  var markerlist = [
    ['handhole1', 'handhole2', 'manhole'],
    [
      'comms_pole',
      'concrete_pole',
      'drop_pole',
      'fiber_reinforced_pole',
      'joint_usage_pole',
      'pole to pole guy',
      'riser_pole',
      'telephone pole',
      'utility pole'
    ],
    [
      'utility pole',
      'joint usage with power trasnformer',
      'non sb power supply',
      'power pole',
      'power trasnformer platform',
      'power trasnformer platform',
      'power trasnformer',
      'sb power supply',
      'steel pole',
      'transmission line contact'
    ]
  ];
  Location location = new Location();
  Map<PolylineId, Polyline> mapPolylines = {};
  int _polylineIdCounter = 1;
  List<LatLng> linepoints = <LatLng>[];
  List? uploadtrack = [];
  List? markerposition = [];
  Map<MarkerId, Marker> markers = {};
  int id = 1;
  BitmapDescriptor? myIcon;
  StreamSubscription<LocationData>? locationSubscription;

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
        icon: BitmapDescriptor.fromBytes(markerIcon),
        position: position);

    id = id + 1;
    setState(() {
      markers[markerId] = marker;
    });
  }

  Future<Location?> findlocation() async {
    final GoogleMapController controller =
        await homescreenvar!.controller1.future;
    locationSubscription =
        location.onLocationChanged.listen((LocationData currentLocation) {
      if (switchscreen!.startstop) {
        print(linepoints);
        uploadtrack?.add({
          'lat': currentLocation.latitude!,
          'lng': currentLocation.longitude!
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
      default:
        return MapHomeScreen();
    }
  }

  @override
  void initState() {
    currentmarker = currentmarkerslist[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            child: screensfunction(screenname),
          )
        ],
      ),
    );
  }
}
