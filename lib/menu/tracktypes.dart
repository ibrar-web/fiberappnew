import 'package:fiberapp/screenrendring.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class Tracktypes extends StatefulWidget {
  const Tracktypes({Key? key}) : super(key: key);

  @override
  _TracktypesState createState() => _TracktypesState();
}

class _TracktypesState extends State<Tracktypes> {
  Future<int?> onTrackTypeButtonPressed(String? num) async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String? selected = 'hole';
    void val(String? marker) {
      setState(() {
        selected = marker;
      });
      print(selected);
    }

    return Container(
      child: DropdownSearch<String>(
        mode: Mode.BOTTOM_SHEET,
        items: [
          "hole",
          "pole",
          "power",
        ],
        label: "Selected Icon Type",
        onChanged: val,
        selectedItem: selected,
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
    );
  }
}
