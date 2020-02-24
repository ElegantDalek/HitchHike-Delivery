import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class ScanWidget extends StatefulWidget {
  final VoidCallback toggleCooler;
  ScanWidget(this.toggleCooler);

  @override
  State<StatefulWidget> createState() => _ScanState(toggleCooler);
}

class _ScanState extends State<ScanWidget> {
  DateTime lastScan = DateTime.now();
  final VoidCallback toggleCooler;
  MapboxNavigation _directions;

  _ScanState(this.toggleCooler);

  @override
  void initState() {
    super.initState();
    _directions = MapboxNavigation(onRouteProgress: (arrived) async {
      if (arrived) await _directions.finishNavigation();
    });
  }

  void startNavigation() async {
    final cityhall =
        Location(name: "City Hall", latitude:41.79972, longitude: -87.58968);
    final downtown = Location(
        name: "destination", latitude: 41.79052, longitude: -87.60285);
    await _directions.startNavigation(
        origin: cityhall,
        destination: downtown,
        mode: NavigationMode.drivingWithTraffic,
        simulateRoute: false,
        );
  }
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: 440,
        height: 672,
        child: QrCamera(
            child: FloatingActionButton(
                child: Icon(Icons.lock), backgroundColor: Colors.white10, onPressed: toggleCooler),
            qrCodeCallback: (code) {
              var now = DateTime.now();
              if (now.difference(lastScan).inMilliseconds > 1000) {
                startNavigation();
              }
              lastScan = now;
            }),
      ),
    ]);
  }
}
