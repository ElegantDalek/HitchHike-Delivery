import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:hitchhike_delivery/profile.dart';
import 'package:hitchhike_delivery/scan.dart';

import 'explore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        accentColor: Color(0xFFFA0025),
        primaryColor: Color(0xFFCD001F)
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _pageIndex = 0;
  final List<Widget> _activities = [
    ExploreWidget(Colors.amber),
    ScanWidget(toggleCooler),
    ProfileWidget()
  ];

  static bool locked = false;
  static bool isConnecting = true;
  static bool isDisconnecting = false;
  static bool get isConnected => connection != null && connection.isConnected;
  static final TextEditingController textEditingController = new TextEditingController();

  // Get the instance of the bluetooth
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  static BluetoothConnection connection;

  static void toggleCooler() {
    print('toggle sent!');
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
    bluetooth = FlutterBluetoothSerial.instance;
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

    connection.input.listen((data) => {print('got data!')});
  }

  static void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0)  {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;
      }
      catch (e) {
        // Ignore error, but notify state
      }
    }
  }


  void _onBottomBarTapped(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Hitchhike Delivery'),
      ),
      body: _activities[_pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        selectedItemColor: Theme.of(context).accentColor,
        onTap: _onBottomBarTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            title: Text('Explore'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pages),
            title: Text('Scan'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Profile'),
          ),
        ],
      ),
    );
  }
}
