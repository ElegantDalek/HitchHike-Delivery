import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hitchhike_delivery/map_request.dart';
import 'package:location/location.dart';

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
  LocationData currentLocation;
  bool loading = true;
  final Set<Polyline> _polyLines = {};
  Set<Polyline> get polyLines => _polyLines;
  Completer<GoogleMapController> _controller = Completer();

  var _markers = {
    Marker(
      markerId: MarkerId("Hyde park"),
      position: LatLng(41.7948, -87.5917),
      infoWindow: InfoWindow(title: 'Hyde park', snippet: '5 star rating!'),
      icon: BitmapDescriptor.defaultMarker,
    )
  };

  @override
  void initState() {
    getLocation();
    loading = true;
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(20, 20)), 'assets/blue-circle.png')
        .then((onValue) {
      locationIcon = onValue;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              // _moveToCurrentLocation();
              sendRequest();
            },
            child: Icon(Icons.navigation)),
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
    var location = new Location();
    location.onLocationChanged().listen((currentLocation) {
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
    });
  }

  void _addMarker(LatLng location, String address) {
    _markers.add(Marker(
        markerId: MarkerId("112"),
        position: location,
        infoWindow: InfoWindow(title: address, snippet: "go here"),
        icon: BitmapDescriptor.defaultMarker));
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
    _polyLines.add(Polyline(
        polylineId: PolylineId(latLng.toString()),
        width: 4,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.red));
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
