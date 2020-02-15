import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExploreWidget extends StatefulWidget {
  final Color color;
  ExploreWidget(this.color);
  @override
  State<StatefulWidget> createState() => _ExploreState();
}

class _ExploreState extends State<ExploreWidget> {
  GoogleMapController mapController;
  final LatLng _center = const LatLng(41.7948, -87.5917);

  final _markers = {
    Marker(
      markerId: MarkerId("Hyde park"),
      position: LatLng(41.7948, -87.5917),
      infoWindow: InfoWindow(
        title: 'Hyde park',
        snippet: '5 star rating!'
      ),
      icon: BitmapDescriptor.defaultMarker,
    )
  };

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('Button pressed'),)
        );
      }, child: Icon(Icons.navigation)),
        body: GoogleMap(
      onMapCreated: _onMapCreated,
      markers: _markers,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 15.0,
      ),
    ));
  }
}
