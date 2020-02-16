import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchhike_delivery/map_request.dart';
import 'package:hitchhike_delivery/profile.dart';
import 'package:location/location.dart' as googlelocation;

class ExploreWidget extends StatefulWidget {
  final Color color;
  ExploreWidget(this.color);
  @override
  State<StatefulWidget> createState() => _ExploreState();
}

class _ExploreState extends State<ExploreWidget> {
  final LatLng _center = const LatLng(41.7948, -87.5917);
  static LatLng latLng;
  BitmapDescriptor locationIcon;
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  googlelocation.LocationData currentLocation;
  bool loading = true;
  final Set<Polyline> _polyLines = {};
  Set<Polyline> get polyLines => _polyLines;
  Completer<GoogleMapController> _controller = Completer();
  MapboxNavigation _directions;

  var _markers = Set<Marker>();

  @override
  void initState() {
    super.initState();
    _addMarker(LatLng(41.7948, -87.5917), 'Hyde park');
    getLocation();
    loading = true;
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(20, 20)), 'assets/blue-circle.png')
        .then((onValue) {
      locationIcon = onValue;
    });

    _directions = MapboxNavigation(onRouteProgress: (arrived) async {
      if (arrived) await _directions.finishNavigation();
    });
  }

  void startNavigation() async {
    final cityhall =
        Location(name: "City Hall", latitude: 42.886448, longitude: -78.878372);
    final downtown = Location(
        name: "Downtown Buffalo", latitude: 42.8866177, longitude: -78.8814924);
    await _directions.startNavigation(
        origin: cityhall,
        destination: downtown,
        mode: NavigationMode.drivingWithTraffic,
        simulateRoute: false,
        language: "French");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              _moveToCurrentLocation();
            },
            child: Icon(Icons.center_focus_strong)),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          markers: _markers,
          polylines: _polyLines,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 15.0,
          ),
        ));
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  getLocation() async {
    var location = googlelocation.Location();
    location.onLocationChanged().listen((currentLocation) {
      if (ModalRoute.of(context).isActive) {
        setState(() {
          latLng = LatLng(currentLocation.latitude, currentLocation.longitude);
          _markers.add(Marker(
              markerId: MarkerId("Current location"),
              position: latLng,
              infoWindow:
                  InfoWindow(title: 'Your location', snippet: '5 star rating!'),
              icon: locationIcon));
        });
        loading = false;
      }
    });
  }

  void _addMarker(LatLng location, String address) {
    _markers.add(Marker(
        markerId: MarkerId("112"),
        position: location,
        icon: BitmapDescriptor.defaultMarker,
        onTap: (() {
              sendRequest();
              showBottomSheet(
                  context: context,
                  builder: (BuildContext bc) {
                    return bottomSheet(location, address);
                  });
            })
            
            ));
  }

  Widget bottomSheet(LatLng location, String address) {
    return Container(
        height: 200,
        width: 500,
        child: Column(
          children: <Widget>[
            ProfileWidget.historyContent("4.00", address, "Transit Plaza"),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ActionChip(
                    avatar: CircleAvatar(
                      child: Icon(Icons.directions),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                    ),
                    padding: EdgeInsets.all(10),
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      startNavigation();
                    },
                    label: Text(
                      'Navigate',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )),
                ChoiceChip(
                  label: Row(
                    children: <Widget>[
                      Icon(Icons.directions_bike),
                      Text('Bike')
                    ],
                  ),
                  selected: false,
                )
              ],
            )
          ],
        ));
  }

  Future<void> _moveToCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 17)));
  }

  void sendRequest() async {
    LatLng destination = LatLng(41.7948, -87.5917);
    String route =
        await _googleMapsServices.getRouteCoordinates(latLng, destination);
    print(route);
    createRoute(route);
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    do {
      var shift = 0;
      int result = 0;

      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    return lList;
  }

  void createRoute(String encondedPoly) {
    setState(() {
      _polyLines.add(Polyline(
          polylineId: PolylineId(latLng.toString()),
          width: 4,
          points: _convertToLatLng(_decodePoly(encondedPoly)),
          color: Colors.red));
    });
  }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }
}
