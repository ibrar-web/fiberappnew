import 'package:fiberapp/database/trackdatabase.dart';
import 'package:fiberapp/menu/viewtrack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
  final SlidableController slidableController = SlidableController();
  @override
  void initState() {
    super.initState();
  }

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
                                child: Slidable(
                              controller: slidableController,
                              actionPane: SlidableDrawerActionPane(),
                              actionExtentRatio: 0.25,
                              child: Container(
                                color: selectedId == data.id
                                    ? Colors.white70
                                    : Colors.black,
                                child: ListTile(
                                  title: Text(
                                      '${data.name}  Track time: ${data.time}'),
                                  subtitle: Text('Slide right for action'),
                                ),
                              ),
                              actions: <Widget>[
                                IconSlideAction(
                                  caption: 'View',
                                  color: Colors.blue,
                                  icon: Icons.watch,
                                  onTap: () {
                                    {
                                      setState(() {
                                        selectedId = data.id;
                                      });
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              content: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .7,
                                                width: double.infinity,
                                                child: Column(
                                                  children: [
                                                    ViewTrack(
                                                        track: data.track,
                                                        markerposition: data
                                                            .markerposition),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('Hide'))
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                    }
                                  },
                                ),
                                IconSlideAction(
                                  caption: 'Upload',
                                  color: Colors.indigo,
                                  icon: Icons.cloud,
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: Container(
                                              height: 130,
                                              child: Column(
                                                children: [
                                                  Text(
                                                      "Uploading to server will delete from App"),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Row(
                                                    children: [
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              DatabaseHelper
                                                                  .instance
                                                                  .uploadtrack(
                                                                      data.id!);
                                                            });

                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },

                                                          ///sdfsdfsdfsdf
                                                          //onPressed: null,
                                                          child:
                                                              Text('Upload')),
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text('Cancel'))
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                ),
                                IconSlideAction(
                                  caption: 'Delete',
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () {
                                    setState(() {
                                      selectedId = data.id;
                                    });
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: Container(
                                              height: 130,
                                              child: Column(
                                                children: [
                                                  Text(
                                                      "Are you sure you want to delete Delete"),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Row(
                                                    children: [
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              DatabaseHelper
                                                                  .instance
                                                                  .removetrack(
                                                                      data.id!);
                                                            });

                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          //onPressed: null,
                                                          child:
                                                              Text('Delete')),
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text('Cancel'))
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                ),
                              ],
                            ));
                          }).toList(),
                        );
                }),
          ),
        ),
      ],
    );
  }
}
