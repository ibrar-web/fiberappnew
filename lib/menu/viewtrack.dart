import 'package:fiberapp/screens/tracks.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:async';

class ViewTrack extends StatefulWidget {
  const ViewTrack({Key? key}) : super(key: key);

  @override
  _ViewTrackState createState() => _ViewTrackState();
}

class _ViewTrackState extends State<ViewTrack> {
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(33.42796133580664, 73.085749655962),
    zoom: 14.4746,
  );
  Completer<GoogleMapController> controller1 = Completer();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .6,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        zoomControlsEnabled: true,
        scrollGesturesEnabled: true,
        myLocationEnabled: true,
        compassEnabled: true,
        rotateGesturesEnabled: true,
        mapToolbarEnabled: true,
        tiltGesturesEnabled: true,
        // markers: Set<Marker>.of(switchscreen!.markers.values),
        polylines: Set<Polyline>.of(trackpage!.mapPolylines.values),
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          controller1.complete(controller);
        },
      ),
    );
  }
}
