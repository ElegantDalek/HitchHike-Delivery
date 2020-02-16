import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:hitchhike_delivery/navigate.dart';
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

  _ScanState(this.toggleCooler);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: 440,
        height: 672,
        child: QrCamera(
            child: FloatingActionButton(
                child: Icon(Icons.bluetooth), onPressed: toggleCooler),
            qrCodeCallback: (code) {
              var now = DateTime.now();
              if (now.difference(lastScan).inMilliseconds > 1000) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => NavigateWidget()));
              }
              lastScan = now;
            }),
      ),
    ]);
  }
}
