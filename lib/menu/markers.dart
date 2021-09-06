import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class TrackMarkers extends StatefulWidget {
  const TrackMarkers({Key? key}) : super(key: key);

  @override
  _TrackMarkersState createState() => _TrackMarkersState();
}

class _TrackMarkersState extends State<TrackMarkers> {
  String? selected = 'hole';
  void selectmarker(String? marker) {
    setState(() {
      selected = marker;
    });
    print(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DropdownSearch<String>(
          mode: Mode.BOTTOM_SHEET,
          items: [
            "hole",
            "pole",
            "power",
          ],
          label: "Selected Marker",
          onChanged: selectmarker,
          selectedItem: selected,
          showSearchBox: true,
          showClearButton: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
              labelText: "Search Icon",
            ),
          ),
          popupTitle: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorDark,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          popupShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
        ),
      ],
    );
  }
}
