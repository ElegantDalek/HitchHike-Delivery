import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NavigateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Navigate'),
      ),
      body: Center(child: Image(image: AssetImage('assets/dribbble-check-mark.gif')),)
    );
  }
}