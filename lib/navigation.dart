import 'package:fiberapp/main.dart';
import 'package:fiberapp/menu/trackdatabase.dart';
import 'package:flutter/material.dart';
import 'package:fiberapp/screenrendring.dart';

class Navigationpage extends StatefulWidget {
  const Navigationpage({Key? key}) : super(key: key);

  @override
  _NavigationpageState createState() => _NavigationpageState();
}

class _NavigationpageState extends State<Navigationpage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 32.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.6,
            heightFactor: 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 128.0,
                  height: 128.0,
                  margin: const EdgeInsets.only(
                    top: 24.0,
                    bottom: 64.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  // child: Image.asset(
                  //   'assets/images/flutter_logo.png',
                  // ),
                ),
                ListTile(
                  onTap: () {
                    switchscreen!.screensfunction('homescreen');
                    mainaccess!.statecontrol();
                  },
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                ),
                ListTile(
                  onTap: () {
                    switchscreen!.screensfunction('tracks');
                    mainaccess!.statecontrol();
                  },
                  leading: Icon(Icons.track_changes),
                  title: Text('Trakcs'),
                ),
                ListTile(
                  onTap: () {
                    DatabaseHelper.instance.initDatabase();
                    mainaccess!.statecontrol();
                  },
                  leading: Icon(Icons.track_changes),
                  title: Text('DB'),
                ),
                Spacer(),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 16.0,
                    ),
                    child: Text('Terms of Service | Privacy Policy'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
