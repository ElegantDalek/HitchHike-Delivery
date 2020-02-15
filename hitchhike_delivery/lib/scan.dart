import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class ScanWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanState();
}

class _ScanState extends State<ScanWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: 440,
        height: 672,
        child: QrCamera(qrCodeCallback: (code) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(code),
            duration: Duration(seconds: 1),
          ));
        }),
      ),
    ]);
  }
}
