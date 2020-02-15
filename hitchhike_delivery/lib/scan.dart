import 'package:flutter/widgets.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class ScanWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanState();
}

class _ScanState extends State<ScanWidget> {
  String text = "hi";
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: QrCamera(qrCodeCallback: (code) {
            setState(() {
              text = code;
            });
          }),
        ),
        Text(text)
      ]
    );
  }
  
}
