import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:hitchhike_delivery/navigate.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class ScanWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanState();
}

class _ScanState extends State<ScanWidget> {
  DateTime lastScan = DateTime.now();
  bool locked = false;
  bool isConnecting = true;
  bool isDisconnecting = false;
  bool get isConnected => connection != null && connection.isConnected;
  final TextEditingController textEditingController = new TextEditingController();

  // Get the instance of the bluetooth
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  BluetoothConnection connection;

  void toggleCooler() {
    if (locked) {
      _sendMessage('u');
    } else {
      _sendMessage('l');
    }
    locked = !locked;
  }

  @override
  void initState() {
    super.initState();
    bluetoothConnectionState();
  }

  Future<void> bluetoothConnectionState() async {
    BluetoothConnection.toAddress('98:D3:32:10:F7:8B').then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
    });
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0)  {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;
      }
      catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

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
