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
  final LatLng _center = const LatLng(41.8, -87.6);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 30.0,
      ),
    );
  }
  
}