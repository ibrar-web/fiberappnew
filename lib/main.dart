import 'package:fiberapp/navigation.dart';
import 'package:fiberapp/screenrendring.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

void main() => runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    themeMode: ThemeMode.dark,
    darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color.fromRGBO(32, 33, 36, 1.0),
        appBarTheme: AppBarTheme(),
        primarySwatch: Colors.blue,
        primaryColor: Color.fromRGBO(48, 49, 52, 1.0),
        accentColor: Color(int.parse('0xff2399CC')),
        iconTheme: IconThemeData(color: Colors.white)),
    home: MainScreen()));
_MainScreenState? mainaccess;

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() {
    mainaccess = _MainScreenState();
    return mainaccess!;
  }
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  bool isCollapsed = true;
  double? screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 500);
  AnimationController? _controller;
  double borderRadius = 0.0;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  Future statecontrol() async {
    setState(() {
      if (isCollapsed) {
        _controller!.forward();
        borderRadius = 16.0;
      } else {
        _controller!.reverse();
        borderRadius = 0.0;
      }
      isCollapsed = !isCollapsed;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: duration);
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _controller!.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
      print(_connectionStatus);
      print('_connectionStatus');
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;

    return WillPopScope(
      onWillPop: () async {
        if (!isCollapsed) {
          setState(() {
            _controller!.reverse();
            borderRadius = 0.0;
            isCollapsed = !isCollapsed;
          });
          return false;
        } else
          return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: <Widget>[
            menu(context),
            AnimatedPositioned(
                left: isCollapsed ? 0 : 0.6 * screenWidth!,
                right: isCollapsed ? 0 : -0.2 * screenWidth!,
                top: isCollapsed ? 0 : screenHeight! * 0.1,
                bottom: isCollapsed ? 0 : screenHeight! * 0.1,
                duration: duration,
                curve: Curves.fastOutSlowIn,
                child: dashboard(context)),
          ],
        ),
      ),
    );
  }

  Widget menu(context) {
    return Navigationpage();
  }

  Widget dashboard(context) {
    return SafeArea(
        child: Material(
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      type: MaterialType.card,
      animationDuration: duration,
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        child: Scaffold(
          appBar: AppBar(
            // ignore: unrelated_type_equality_checks
            title: Text(_connectionStatus != ConnectivityResult.none
                ? 'JoynDigital'
                : 'Please internet'),
            leading: IconButton(
                icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: _controller!,
                ),
                onPressed: () {
                  statecontrol();
                }),
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: ClampingScrollPhysics(),
            child: Screenrendring(),
          ),
        ),
      ),
    ));
  }
}
