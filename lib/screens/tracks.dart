import 'dart:convert';

import 'package:fiberapp/menu/trackdatabase.dart';
import 'package:fiberapp/menu/viewtrack.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

_TrackspageState? trackpage;

class Trackspage extends StatefulWidget {
  const Trackspage({Key? key}) : super(key: key);

  @override
  _TrackspageState createState() {
    trackpage = _TrackspageState();
    return trackpage!;
  }
}

class _TrackspageState extends State<Trackspage> {
  int? selectedId;
  Map<PolylineId, Polyline> mapPolylines = {};
  List? uploadtrack = [];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 400,
          child: Center(
            child: FutureBuilder<List<Data>>(
                future: DatabaseHelper.instance.gettrack(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Data>> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: Text('Loading...'));
                  }
                  return snapshot.data!.isEmpty
                      ? Center(child: Text('No Track in List.'))
                      : ListView(
                          children: snapshot.data!.map((data) {
                            return Center(
                              child: Card(
                                color: selectedId == data.id
                                    ? Colors.white70
                                    : Colors.black,
                                child: ListTile(
                                  title: Text(data.name),
                                  onTap: () {
                                    print('data.track');
                                    print(data.track);
                                    print(data.track.length);
                                    for (var i = 0;
                                        i < data.track.length;
                                        i++) {
                                      print(data.track.runtimeType);
                                    }
                                    setState(() {
                                      // mapPolylines = json.decode(data.polyline);
                                      // print(json.decode(data.polyline));
                                      // uploadtrack = data.track;
                                      selectedId = data.id;
                                    });
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: Column(
                                              children: [
                                                ViewTrack(),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(data.track),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text('Hide'))
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      DatabaseHelper.instance.remove(data.id!);
                                    });
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        );
                }),
          ),
        ),
      ],
    );
  }
}
