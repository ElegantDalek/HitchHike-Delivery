import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProfileWidget extends StatelessWidget {
  Widget _profileHeader() {
    const double ICON_SIZE = 80;
    return Container(
        padding: EdgeInsets.only(left: 25, top: 20, bottom: 20),
        child: Row(children: <Widget>[
          Image.asset(
            'assets/Profile.png',
            width: ICON_SIZE,
            height: ICON_SIZE,
          ),
          Container(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Rachel Bishop',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ))
        ]));
  }

  Widget _walletAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text('\$43.20',
            style: TextStyle(fontSize: 60, color: Colors.lightGreen)),
        Text(
          "Your wallet",
          style: TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  static Widget historyCard(String amount, String from, String to) {
    return Container(
        padding: EdgeInsets.only(left: 10, bottom: 5, right: 10),
        child: Card(elevation: 2, child: historyContent(amount, from, to)));
  }

  static Widget historyContent(String amount, String from, String to) {
    return Row(
      children: [
        Expanded(
            child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 20),
              width: 150,
              child: Text(
                from,
                style: TextStyle(fontSize: 18),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 40,
            ),
            Container(
              padding: EdgeInsets.only(),
              width: 100,
              child: Text(
                to,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        )),
        Container(
            padding: EdgeInsets.all(10),
            child: CircleAvatar(
              child: Text('\$' + amount,
                  style: TextStyle(fontSize: 30, color: Colors.white)),
              backgroundColor: Colors.lightGreen,
              radius: 50,
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _profileHeader(),
        Divider(
          color: Colors.black,
        ),
        _walletAmount(),
        historyCard('2.30', 'First & Armory', 'Transit Plaza'),
        historyCard('4.50', 'Wright & Chalmers', 'Goodwin & Main'),
        historyCard('2.30', 'First & Armory', 'Transit Plaza'),
        historyCard('2.30', 'First & Armory', 'Transit Plaza'),
        historyCard('2.30', 'First & Armory', 'Transit Plaza'),
        historyCard('2.30', 'First & Armory', 'Transit Plaza'),
        historyCard('2.30', 'First & Armory', 'Transit Plaza'),
      ],
    );
  }
}
