import 'package:fiberapp/screens/homescreen.dart';
import 'package:fiberapp/screens/tracks.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';

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
  Completer<GoogleMapController> controller1 = Completer();
  MapType currentMapType = MapType.normal;
  String? currentTrackType = '12 Core Fiber';
  int? mapnumber = 1;
  String? markertype = "hole";
  Location location = new Location();
  Map<PolylineId, Polyline> mapPolylines = {};
  int _polylineIdCounter = 1;
  List<LatLng> linepoints = <LatLng>[];
  List? uploadtrack = [];
  Map<MarkerId, Marker> markers = {};
  StreamSubscription<LocationData>? locationSubscription;

  addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
  }

  Future<Location?> findlocation() async {
    final GoogleMapController controller = await controller1.future;
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
