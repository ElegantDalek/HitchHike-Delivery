import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hitchhike_delivery/navigate.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class ScanWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanState();
}

class _ScanState extends State<ScanWidget> {
  DateTime lastScan = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: 440,
        height: 672,
        child: QrCamera(qrCodeCallback: (code) {
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
