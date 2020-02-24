import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchhike_delivery/map_request.dart';
import 'package:hitchhike_delivery/profile.dart';
import 'package:hitchhike_delivery/trip.dart';
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

  int _selectedIndex = 0;

  var _markers = Set<Marker>();

  @override
  void initState() {
    super.initState();
    _addMarker(Trip(0, "UPS Store", "Campus North Residential Commons",
        LatLng(41.79937, -87.5888), LatLng(41.7946, -87.59837), "2.91"));
    _addMarker(Trip(1, "Trader Joe's", "UChicago Institute of Politics",
        LatLng(41.79645, -87.58839), LatLng(41.79114, -87.59608), "3.72"));
    _addMarker(Trip(2, "Kent Chemical Laboratory", "Ida Noyes Hall",
        LatLng(41.79018, -87.60011), LatLng(41.78803, -87.59567), "3.23"));
    _addMarker(Trip(3, "Regenstein Library", "Logan Center for the Arts",
        LatLng(41.79236, -87.59998), LatLng(41.78504, -87.60347), "2.79"));
    _addMarker(Trip(4, "Hyde Park Produce", "Snell-Hitchcock Hall",
        LatLng(41.79994, -87.59552), LatLng(41.79111, -87.6005), "3.94"));
    _addMarker(Trip(5, "Polsky Exchange (North)", "John Crerar Library",
        LatLng(41.79972, -87.58968), LatLng(41.79052, -87.60285), "5.12"));
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

  void startNavigation(LatLng end) async {
    final origin = Location(
        name: "origin", latitude: latLng.latitude, longitude: latLng.longitude);
    final destination = Location(
        name: "destination", latitude: end.latitude, longitude: end.longitude);
    await _directions.startNavigation(
      origin: origin,
      destination: destination,
      mode: NavigationMode.drivingWithTraffic,
      simulateRoute: false,
    );
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
      setState(() {
        latLng = LatLng(currentLocation.latitude, currentLocation.longitude);
        _markers.add(Marker(
            markerId: MarkerId("Current location"),
            position: latLng,
            icon: locationIcon));
      });
      loading = false;
    });
  }

  void _addMarker(Trip trip) {
    _markers.add(Marker(
        markerId: MarkerId(trip.id.toString()),
        position: trip.startLatlng,
        icon: BitmapDescriptor.defaultMarker,
        onTap: (() {
          sendRequest(trip);
          Scaffold.of(context).showBottomSheet(
              (BuildContext bc) => bottomSheet(trip),
              elevation: 0);
        })));
  }

  Widget bottomSheet(Trip trip) {
    return Container(
        height: 200,
        width: 500,
        child: Column(
          children: <Widget>[
            ProfileWidget.historyContent(
                trip.price, trip.startName, trip.endName),
            buttonRow(trip),
          ],
        ));
  }

  Widget createChip(int index, Icon icon) {
    return Container(
      padding: EdgeInsets.only(left: 10),
      child: ChoiceChip(
        label: Row(
          children: <Widget>[
            Container(padding: EdgeInsets.all(10), child: icon),
          ],
        ),
        selected: index == _selectedIndex,
        selectedColor: Colors.lightGreen,
        onSelected: (bool selected) => {
          setState(() {
            _selectedIndex = selected ? index : null;
          })
        },
      ),
    );
  }

  Widget buttonRow(Trip trip) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          child: ActionChip(
              avatar: CircleAvatar(
                child: Icon(Icons.directions),
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
              ),
              padding: EdgeInsets.all(10),
              backgroundColor: Colors.blue,
              onPressed: () {
                startNavigation(trip.endLatlng);
              },
              label: Text(
                'Navigate',
                style: TextStyle(fontSize: 20, color: Colors.white),
              )),
        ),
        createChip(0, Icon(Icons.directions_walk)),
        createChip(1, Icon(Icons.directions_bus)),
        createChip(2, Icon(Icons.directions_car)),
      ],
    );
  }

  Future<void> _moveToCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 17)));
  }

  void sendRequest(Trip trip) async {
    String route = await _googleMapsServices.getRouteCoordinates(
        trip.startLatlng, trip.endLatlng);
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
      _polyLines.clear();
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
