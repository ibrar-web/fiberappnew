import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fiberapp/screenrendring.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Markertypes extends StatefulWidget {
  const Markertypes({Key? key}) : super(key: key);

  @override
  _MarkertypesState createState() => _MarkertypesState();
}

class _MarkertypesState extends State<Markertypes> {
  Location location = new Location();
  void selectmarker(String? marker) {
    setState(() {
      switchscreen!.currentmarker = marker;
    });
  }

  Future<String?> onMarkerType(String? marker) async {
    setState(() {
      switchscreen?.markercurrenttype = marker;
      int i = 0;
      bool condition = true;
      for (var item in switchscreen!.markertypelist) {
        if (marker == item && condition) {
          switchscreen!.currentmarkerslist = switchscreen!.markerlist[i];
          switchscreen!.currentmarker = switchscreen!.currentmarkerslist[0];
          condition = false;
        }
        i = i + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DropdownSearch<String>(
          mode: Mode.BOTTOM_SHEET,
          items: switchscreen!.markertypelist,
          label: "Selected Icon Type",
          onChanged: onMarkerType,
          selectedItem: switchscreen?.markercurrenttype,
          showSearchBox: true,
          showClearButton: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
              labelText: "Search Icon Type",
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
        SizedBox(height: 30),
        DropdownSearch<String>(
          mode: Mode.BOTTOM_SHEET,
          items: switchscreen?.currentmarkerslist,
          label: "Selected Marker",
          onChanged: selectmarker,
          selectedItem: switchscreen!.currentmarker,
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
        SizedBox(height: 10),
        InkWell(
          child: Image(
            image: AssetImage(
                'asset/images/${switchscreen?.markercurrenttype}/${switchscreen!.currentmarker}.png'),
            height: 80,
            width: 80,
          ),
          onTap: () async {
            var locationData = await location.getLocation();
            switchscreen?.addMarker(
                LatLng(locationData.latitude!, locationData.longitude!));
          },
        )
      ],
    );
  }
}
